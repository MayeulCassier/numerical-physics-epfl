#include <iostream>       // basic input output streams
#include <fstream>        // input output file stream class
#include <cmath>          // librerie mathematique de base
#include <iomanip>        // input output manipulators
#include <valarray>       // valarray functions
#include "ConfigFile.h"   // Il contient les methodes pour lire inputs et ecrire outputs


using namespace std; // ouvrir un namespace avec la librerie c++ de base




/* definir a fonction template pour calculer la norm2 d'un valarray
   inputs:
     array: (valarray<T>)(N) vecteur de taille N
   outputs:
     norm2: (T) norm2 du vecteur
*/
template<typename T> T norm2(valarray<T> const& array){
    // compute and return the norm2 of a valarray
    return sqrt((array*array).sum());
}
// ==================================================================

class Engine{

public:
    

    /* Constructeur de la classe Engine
        inputs:
        configFile: (ConfigFile) handler du fichier d'input
    */
    Engine(ConfigFile configFile){
        // variable locale

        // Stockage des parametres de simulation dans les attributs de la classe
        tfin     = configFile.get<double>("tfin",tfin);          // lire la temps totale de simulation
        nsteps   = configFile.get<unsigned int>("nsteps",nsteps); // lire la nombre de pas de temps
        mass_L     = configFile.get<double>("mass_L",mass_L);          // lire la mass de la lune
        R_L        = configFile.get<double>("R_L",R_L);                  // lire le rayon de la Lune
        alpha       = configFile.get<double>("alpha",alpha);              // lire angle de la trajectoire asteroide
        epsilon      = configFile.get<double>("epsilon",epsilon);          // lire précision pour le pas de temps
        double v0        = configFile.get<double>("v0",v0);
        y_0[6]    = v0*cos(alpha);       // lire composante x vitesse initiale
        y_0[7]    = v0*sin(alpha);       // lire composante y vitesse initiale
        y_0[0]    = configFile.get<double>("x0_A",y_0[0]);          // lire composante x position initiale de la fusée
        y_0[1]    = configFile.get<double>("y0_A",y_0[1]);          // lire composante y position initiale de la fusée
        y_0[2]    = configFile.get<double>("x0_T",y_0[2]);          // lire composante x position initiale de la Terre
        y_0[3]    = configFile.get<double>("y0_T",y_0[3]);          // lire composante y position initiale de la Terre
        y_0[8]    = configFile.get<double>("vx0_T",y_0[8]);          // lire composante x vitesse initiale de la Terre
        y_0[9]    = configFile.get<double>("vy0_T",y_0[9]);          // lire composante y vitesse initiale de la Terre
        y_0[4]    = configFile.get<double>("x0_L",y_0[4]);          // lire composante x position initiale de la Lune
        y_0[5]    = configFile.get<double>("y0_L",y_0[5]);          // lire composante y position initiale de la Lune
        y_0[10]    = configFile.get<double>("vx0_L",y_0[10]);          // lire composante x vitesse initiale de la Lune
        y_0[11]    = configFile.get<double>("vy0_L",y_0[11]);          // lire composante y vitesse initiale de la Lune
        rho_0    = configFile.get<double>("rho_0",rho_0);    // lire la densité de l'air à la surface terrestre
        p_0      = configFile.get<double>("p_0",p_0);        // lire la pression à la surface terrrestre
        C_x      = configFile.get<double>("C_x",C_x);         // lire le coefficient de frottement
        gamma    = configFile.get<double>("gamma",gamma);     // lire l'indice d'adiabaticité
        fixe_step =configFile.get<bool>("fixe_step", fixe_step);
        K=p_0*pow(rho_0,-gamma);
        Lune = configFile.get<double>("Lune",Lune);
        sampling = configFile.get<unsigned int>("sampling",sampling); // lire le parametre de sampling
        cout << "   K=" << K << endl;
        dt = tfin / nsteps; // calculer le time step


        // Ouverture du fichier de sortie
        string outfile = configFile.get<string>("output","output.out").c_str();

        outputFile = new ofstream(outfile);
        // Si il n'arrive pas à ouvrir de fichier de sortie
        if (!outputFile->is_open()){
            cerr << "[Engine] Impossible d'ouvrir le fichier sortie" << outfile << endl;
        }

        outputFile->precision(15); // Les nombres seront ecrits avec 15 decimales

    }

    // destructor of the ConfigFile class
    virtual ~Engine(){
        outputFile->close();
        delete outputFile;
    }

    // Simulation complete
    void run(){
        t = 0.e0; // initialiser le temps
        y = y_0;   // initialiser les positions et les vitesses
        last = 0; // initialise le parametre d'ecriture
        int maxit = 500000000; // nombres d'itération max avant de s'arrêter
        int loop_cmp = 0;
        
        printOut(true); // ecrire premier pas de temps
        if(fixe_step){
            // Pas de temps fixe =============================================
            for(unsigned int i(0); i<nsteps; ++i) // boucle sur les pas de temps
            {
                valarray<double> r_A = y[slice(0, 2, 1)];
                valarray<double> r_T = y[slice(2, 2, 1)];
                valarray<double> r_TA = r_T - r_A;
                double altitude = norm2(r_TA);
                //if(altitude <= R_T+d_A/2.0) return;
                y = step(y, dt);
                t += dt;
                printOut(false); // ecrire le pas de temps actuel
            }
        }else{
            // Pas de temps adaptatif ========================================
            while((t < tfin)&&(++loop_cmp < maxit)) {
                valarray<double> r_A = y[slice(0, 2, 1)];
                valarray<double> r_T = y[slice(2, 2, 1)];
                valarray<double> r_TA = r_T - r_A;
                double altitude = norm2(r_TA);
                //if(altitude <= R_T+d_A/2.0) return;
                dt = min(tfin-t,dt);
                //cout << "dt numero 1 = " << dt << endl;
                valarray<double> y_1 = step(y, dt);
                //afficheValarray(y_1, "y_1");
                valarray<double> y_2 = step(y, dt / 2.0);
                y_2 = step(y_2, dt / 2.0);
                //afficheValarray(y_2, "y_2");
                valarray<double> diff_ = y_2 - y_1;
                double diff = norm2(diff_);
                //cout << "diff=" << diff << endl;

                if (debug)
                    //cout << "avant if : diff=" << diff << " dt=" << dt << " epsilon=" << epsilon << endl;

                if (debug) afficheValarray(y, "Y");

                //  dt = min(tfin - t, dt);

                if (diff < epsilon) {
                    y = y_2;
                    t += dt;
                    if (diff!=0)
                    {
                        //cout << "je suis ici" << endl;
                        dt = dt * pow(epsilon / diff, 1.0 / 5.0);

                    }

                } else {
                    int loop_cmp2 = 0;
                    while ((diff > epsilon) && (++loop_cmp2 < 50)) {
                        //cout << "dt=" << dt << endl;
                        if (diff!=0)
                      {
                        //cout << "je suis la" << endl;
                         dt = 0.99 * dt * pow(epsilon / diff, 1.0 / 5.0);
                      }
                        //cout << "dt nouveau=" << dt << endl;
                        y_1 = step(y, dt);
                        //afficheValarray(y_1, "y_1");
                        y_2 = step(y, dt / 2.0);
                        y_2 = step(y_2, dt / 2.0);
                        diff_ = abs(y_2 - y_1);

                        //afficheValarray(y_2, "y_2");
                         //afficheValarray(diff_, "diff_");
                        diff = norm2(diff_);
                        //cout << "diffnouveau = " << diff << endl;
                        if (debug)
                            cout << "boucle While : " << diff << " " << dt << endl;
                    }
                    y = y_2;
                    t += dt;
                }
                printOut(false); // ecrire le pas de temps actuel
            }
        }
        printOut(true); // ecrire le dernier pas de temps
        cout<< "l = " << l << endl;
    }



    void afficheValarray(valarray<double> const& array, string name="") const{
            // code to be executed
            if(name!="")
                cout << name << " ---- ";
            else
                cout << "The contents of array: ";
            for (double x : array){
                cout << x << " ";
            }
            cout << endl;

    }
    int l =0;
private:

    // definition des constantes
    const double pi=3.1415926535897932384626433832795028841971e0;
    const double mass_T=5.972e24;//masse de la Terre
    const double g=9.81;  //accélération de la pesanteur
    const double G=6.674e-11;//constante gravitationnelle
    const double R_T=6378.1e3;//rayon de la terre
    const double mass_A=5800, d_A=4.0;        // Masse et diamètre de la fusée


  
    // definition des variables
    double tfin=0.e0;                   // Temps final
    unsigned int nsteps=1;              // Nombre de pas de temps
    double alpha=0.e0;                  // angle de la trajectoire de la fusée
    double epsilon=0.e0;                // précision requise par pas de temps
    double mass_L=1.e0,R_L=0.e0;        // Masse et rayon de la Lune
    double K;
    bool fixe_step;
    double gamma;        // indice d'adiabaticité
    double p_0;          // pression à la surface de la Terre
    double rho_0;        // densité à la surface de la Terre
    double C_x;          // Coefficient de frottement
    double Lune;
    valarray<double> y_0=valarray<double>(0.e0, 12); //vecteur contenant les positions et vitesses initiales des trois corps
    // utilisant la sequence index-valeur:
    // 0-x_A, 1-y_A, 2-x_T, 3-y_T, 4-x_L, 5-y_L
    // 6-vx_A, 7-vy_A, 8-vx_T, 9-vy_T, 10-vx_L, 11-vy_L
    unsigned int sampling=1; // Nombre de pas de temps entre chaque ecriture des diagnostics
    unsigned int last;       // Nombre de pas de temps depuis la derniere ecriture des diagnostics
    ofstream *outputFile;    // Pointeur vers le fichier de sortie


    /* Calculer et ecrire les diagnostics dans un fichier
       inputs:
         write: (bool) ecriture de tous les sampling si faux
    */
    void printOut(bool write){

        // Ecriture tous les [sampling] pas de temps, sauf si write est vrai
        if((!write && last>=sampling) || (write && last!=1))
        {
            //Calcul des distance entres les différents corps
            valarray<double> pos_A = y[slice(0, 2, 1)];
            valarray<double> pos_T = y[slice(2, 2, 1)];
            valarray<double> pos_L = y[slice(4, 2, 1)];

            valarray<double> r_AT = pos_A-pos_T;
            valarray<double> r_AL = pos_A-pos_L;
            valarray<double> r_TL = pos_T-pos_L;


            //Vitesse de l'astéroïde, le Terre et la Lune
            valarray<double> vitesse_A = y[slice(6, 2, 1)];
            valarray<double> vitesse_T = y[slice(8, 2, 1)];
            valarray<double> vitesse_L = y[slice(10, 2, 1)];

            //Calcul de l'énergie mécanique totale
            double energyMecanique = 0.5 * mass_A * norm2(vitesse_A)*norm2(vitesse_A)  - G * mass_A * mass_T/norm2(r_AT) - Lune * G * mass_A * mass_L / norm2(r_AL);


            double P_Ft = 0.0;       // Puissance liée à la force de trainée
            P_Ft = -0.5*C_x*pi*d_A*d_A*0.25*rho(y)*pow(y[6]*y[6]+y[7]*y[7],2);


            *outputFile << t << " " << y[0] << " " << y[1] << " " << y[2] << " " << y[3] << " " << y[4]\
            << " " << y[5] << " " << y[6] << " " << y[7] << " " << y[8] << " " << y[9] << " " << y[10] << " "  << y[11] \
            << " " << P_Ft << " " << rho(y) << " " << sqrt(pow(acceleration(y)[0],2)+pow(acceleration(y)[1],2)) << endl; // write output on file

            last = 1;
        }
        else
        {
            last++;
        }

    }


    // Iteration temporelle, a definir au niveau des classes filles
    virtual valarray<double> step(valarray<double> const& y, double dt_)=0;


protected:

    // donnes internes
    double t,dt;  // Temps courant pas de temps
    valarray<double> y=valarray<double>(12); // Positions et vitesses actuelles des trois corps
    double d_TL;  //distance Terre-Lune

    bool debug = false;


    

    double rho(valarray<double> const& r) const
  {
    valarray<double> r_A = r[slice(0, 2, 1)];
    valarray<double> r_T = r[slice(2, 2, 1)];
 
 
    // calcul de l'acceleration de la fusée
    valarray<double> r_TA = r_T - r_A;
    double m=pow(rho_0,gamma-1)-(norm2(r_TA)-R_T-2.0)*g*(gamma-1)/(K*gamma);
    double altitude = norm2(r_TA);
    //bool isnan( arg );

    if ((altitude-R_T-d_A/2.0)<0)
    {
      return rho_0;
    }
    if(C_x==0 or m<=0)
    {
      return 0;
    }else{
      return pow(m,1/(gamma-1));
    }
  }
  
  /* Calcul de l'acceleration pour les trois corps
   outputs:
     a: (valarray<double>)(6) acceleration selon (x,y) des trois corps avec en premier la fusée, puis la Terre et enfin la Lune
    */
    valarray<double> acceleration(valarray<double> const& r) const{
        valarray<double> a = valarray<double>(0.e0, r.size());

        // création des vecteurs positions des trois corps
        valarray<double> r_A = r[slice(0, 2, 1)];
        valarray<double> r_T = r[slice(2, 2, 1)];
        valarray<double> r_L = r[slice(4, 2, 1)];

        // calcul de l'acceleration de la fusée
        valarray<double> r_TA = r_T - r_A;
        valarray<double> r_LA = r_L - r_A;
        valarray<double> a_A = - G * ((mass_T/ (norm2(r_TA)*norm2(r_TA)*norm2(r_TA))) * (r_A - r_T) + (mass_L/(norm2(r_LA)*norm2(r_LA)*norm2(r_LA)))*(r_A - r_L));
		//on ajoute une force de trainee si besoin
		//cout << "bool trainee : " << trainee << endl;//DEBUG


        // calcul de l'acceleration de la Terre
        valarray<double> r_AT = r_A - r_T;
        valarray<double> r_LT = r_L - r_T;
        valarray<double> a_T = - G * ((mass_A/ (norm2(r_AT)*norm2(r_AT)*norm2(r_AT))) * (r_T - r_A) + (mass_L/(norm2(r_LT)*norm2(r_LT)*norm2(r_LT)))*(r_T - r_L));


        // calcul de l'acceleration de la Lune
        valarray<double> r_AL = r_A - r_L;
        valarray<double> r_TL = r_T - r_L;
        valarray<double> a_L = Lune*(- G * ((mass_A/ (norm2(r_AL)*norm2(r_AL)*norm2(r_AL))) * (r_L - r_A) + (mass_T/(norm2(r_TL)*norm2(r_TL)*norm2(r_TL)))*(r_L - r_T)));

        a[slice(0, 2, 1)] = a_A;
        a[slice(2, 2, 1)] = a_T;
        a[slice(4, 2, 1)] = a_L;
        // cout << "rho = " << rho(r) << endl;
        // cout << "C_x = " << C_x << endl; 
        // cout << "d_A = " << d_A << endl;
        // cout << "r[6]*r[6]+r[7]*r[7] = " << r[6]*r[6]+r[7]*r[7] << endl;  
        double v1=r[6];
        double v2=r[7];
        // if (r[6]<1.e-23)
        // {
        //     v1 =0.0;
        // }
        // if (r[7]<1.e-23)
        // {
        //     v2=0;
        // }
        double lavaleurbizarre = v1*v1+v2*v2;
        // if (isnan( lavaleurbizarre ))
        // {
        //      lavaleurbizarre= 0;
        // }
        // cout << "la valeur bizarre =" << lavaleurbizarre << " " << v1 << " " << v2 << endl;
        
        a[0]      += -0.5*C_x*pi*d_A*d_A*0.25*rho(r)*sqrt(lavaleurbizarre)*v1/mass_A;
        a[1]      += -0.5*C_x*pi*d_A*d_A*0.25*rho(r)*sqrt(lavaleurbizarre)*v2/mass_A;//changer ici
        return a;
    }


    valarray<double> f(valarray<double> const& y){
        valarray<double> retour = valarray<double>(0.e0, y.size());

        retour[slice(0, 6, 1)] = y[slice(6, 6, 1)];
        retour[slice(6, 6, 1)] = acceleration(y);

        return retour;
    }



};


// ==================================================================

class EngineRungeKutta: public Engine{

public:
    /* Constructor of the class
       inputs:
         ConfigFile: (str) string containing the file name to read
    */
    EngineRungeKutta(ConfigFile configFile):Engine(configFile){}


private:

    /* Cette methode integre les equations du mouvement en utilisant
   le schema: Runge Kutta ordre 4
    */
    valarray<double> step(valarray<double> const& y, double dt_)
    {


        if(debug){
            afficheValarray(y,"Y");
        }
        //cout << "dt inside" <<dt_ << endl;
        valarray<double> k1 = dt_ * f(y);
        if(y[6]*y[6]+y[7]*y[7]<=0){
            l=l+1;
        }


            //afficheValarray(k1,"K1");



        valarray<double> k2 = dt_ * f(y + 0.5 *  k1);
        //afficheValarray(k2,"K2");
        valarray<double> k3 = dt_ * f(y + 0.5 *  k2);
        //afficheValarray(k3,"K3");
        valarray<double> k4 = dt_ * f(y +  k3);
        //afficheValarray(k4,"K4");

        return (y + (1.0/6.0) * (k1 + 2.0 * k2 + 2.0 * k3 + k4));

    }

};


int main(int argc, const char * argv[]) {

    string inputPath("configuration_supp1.in"); // Fichier d'input par defaut
    if(argc>1) // Fichier d'input specifie par l'utilisateur ("./Exercice2 config_perso.in")
        inputPath = argv[1];

    ConfigFile configFile(inputPath); // Les parametres sont lus et stockes dans une "map" de strings.

    for(int i(2); i<argc; ++i) // Input complementaires ("./Exercice2 config_perso.in input_scan=[valeur]")
        configFile.process(argv[i]);

    Engine* engine; // definer la class pour la simulation
    engine = new EngineRungeKutta(configFile);

    
    engine->run(); // executer la simulation

    delete engine; // effacer la class simulation
    cout << "Fin de la simulation." << endl;
    return 0;
}




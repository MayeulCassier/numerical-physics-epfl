#include <iostream>       // basic input output streams
#include <fstream>        // input output file stream class
#include <cmath>          // librerie mathematique de base
#include <iomanip>        // input output manipulators
#include <valarray>       // valarray functions
#include "ConfigFile.h" // Il contient les methodes pour lire inputs et ecrire outputs 
                          // Fichier .tpp car inclut fonctions template
#include <numeric>
using namespace std; // ouvrir un namespace avec la librerie c++ de base

/* definir a fonction template pour calculer le produit interne
   entre deux valarray
   inputs:
     array1: (valarray<T>)(N) vecteur de taille N
     array2: (valarray<T>)(N) vecteur de taille N
   outputs:
     produitInterne: (T) produit entre les deux vecteurs
*/ 

template<typename T> T scalarProduct(valarray<T> const& array1,\
valarray<T> const& array2){
  // compute and return the norm2 of a valarray
  return (array1*array2).sum();
} 

template<typename T> T norm2(valarray<T> const& array){
  // compute and return the norm2 of a valarray
  return sqrt((array*array).sum());
} 

/* definir a fonction template pour calculer le produit vecteur
   entre 2 valarray de dimension 3
   inputs:
     array1, array2: (valarray<T>)(N) vecteurs de taille N
   outputs:
     produitVecteur: (T) produit vectoriel array1 x aray2 
*/
template<typename T> valarray<T> produitVecteur(valarray<T> const& array1,\
valarray<T> const& array2){
  // initialiser le nouveau valarray
  valarray<T> array3=valarray<T>(3);
  // calculer le produit vecteur
  array3[0] = array1[1]*array2[2] - array1[2]*array2[1]; // premier composante
  array3[1] = array1[2]*array2[0] - array1[0]*array2[2]; // deuxieme composante
  array3[2] = array1[0]*array2[1] - array1[1]*array2[0]; // troisieme composante
  // retourner le array3
  return array3;
} 


/* La class Engine est le moteur principale de ce code. Il contient 
   les methodes de base pour lire / initialiser les inputs, 
   preparer les outputs et calculer les donnees necessaires
*/
class Engine
{

private:
  // definition des constantes
  const double pi=3.1415926535897932384626433832795028841971e0;
  const double m_T=5.972e24;//masse de la Terre
  const double g=9.81;  //accélération de la pesanteur
  const double G=6.674e-11;//constante gravitationnelle
  const double R_T=6378.1e3;//rayon de la terre
  // definition des variables
  double tfin;          // Temps final
  unsigned int nsteps;  // Nombre de pas de temps
  double m_A;          // mass du vaisseau
  double p_0;          // pression à la surface de la Terre
  double rho_0;        // densité à la surface de la Terre
  double C_x;          // Coefficient de frottement
  double gamma;        // indice d'adiabaticité
  double K;
  double d;            // diamètre du vaisseau        
  double epsilon;      // tolérance pour le pas de temps adaptatif  
  bool fixe_step;
  
  valarray<long double> y0=valarray<long double>(0.e0,4); // Vecteurs des conditions initiales (position et vitesse)
  
  unsigned int sampling;  // Nombre de pas de temps entre chaque ecriture des diagnostics
  unsigned int last;       // Nombre de pas de temps depuis la derniere ecriture des diagnostics
  ofstream *outputFile;    // Pointeur vers le fichier de sortie

  /* Calculer et ecrire les diagnostics dans un fichier
     inputs:
     write: (bool) ecriture de tous les sampling si faux
  */  
  void printOut(bool write)
  {
  // TODO calculer l'energie mecanique
    double Energy = 0.0; 
    Energy = 0.5*m_A*(y[2]*y[2]+y[3]*y[3])-G*m_A*m_T/sqrt(y[0]*y[0]+y[1]*y[1]);
    
    long double P_Ft = 0.0;       // Puissance liée à la force de trainée
    P_Ft = -0.5*C_x*pi*d*d*0.25*rho(y)*pow(y[2]*y[2]+y[3]*y[3],2);

    // Ecriture tous les [sampling] pas de temps, sauf si write est vrai
    if((!write && last>=sampling) || (write && last!=1))
    {
      *outputFile << t << " " << y[0] << " " << y[1] << " " \
      << y[2] << " " << y[3] <<  " " \
      << Energy << " " << P_Ft << " " << rho(y) << " " << sqrt(pow(acceleration(y)[0],2)+pow(acceleration(y)[1],2)) << endl; // write output on file
      last = 1;	
    }
    else
    {
      last++;
    }
  }

  // Iteration temporelle, a definir au niveau des classes filles
  valarray<long double> step(valarray<long double> const& y, long double dt_)
  {
        if(debug){
            afficheValarray(y,"Y");
        }

        valarray<long double> k1 = dt_ * f(y);
        

        if(debug){
            afficheValarray(k1,"K1");
        }
        valarray<long double> k2 = dt_ * f(y + 0.5 * k1);
        valarray<long double> k3 = dt_ * f(y + 0.5 * k2);
        valarray<long double> k4 = dt_ * f(y +  k3);
        if (debug)
      {
        *outputFile << "k1 size =" << k1.size() << "k1  =" << k1[0] << " " << k1[1] << " " << k1[2] << " " << k1[3] << endl;
      }

      if (debug)
      {
        *outputFile << "k2  =" << k2[0] << " " << k2[1] << " " << k2[2] << " " << k2[3] <<  endl;
      }
      if (debug)
        {
        *outputFile << "k3  =" << k3[0] << " " << k3[1] << " " << k3[2] << " " << k3[3] << endl;
      }
        
        if (debug)
      {
        *outputFile << "k4  =" << k4[0] << " " << k4[1] << endl;
      }
        return (y + (1.0/6.0) * (k1 + 2.0 * k2 + 2.0 * k3 + k4));

    }




protected:

  // donnes internes
  long double t,dt;  // Temps courant pas de temps
  bool debug=false; 

  // Ci-dessous, on définit deux vecteurs séparés, x et v, pour le vecteur-position
  // et le vecteur-vitesse, respectivement.
  //valarray<long double> x =valarray<long double>(2); // Position actuelle du vaisseau 
  //valarray<long double> v =valarray<long double>(2); // Vitesse actuelle du vaisseau
  
  // On pourrait aussi définir un seul vecteur y, de taille 6, qui regrouperait (x,v)
   valarray<long double> y=valarray<long double>(0.e0,4); // (Position,vitesse) actuelle du vaisseau

  
  // TODO
  /* Calcul de l'acceleration totale
     output:
       a: (valarray<long double>)(2) vecteur acceleration
  */
  bool rr = true;
  long double rho(valarray<long double> y_)
  {
    //cout << "r1=" << pow(rho_0,gamma-1) << endl;
    //cout << "r4=" << pow(rho_0,gamma-1)-(sqrt(y[0]*y[0]+y[1]*y[1])-R_T)*g*(gamma-1)/(K*gamma) << endl;

    //afficheValarray(y, "Y2");
    //cout << "r2=" << -(sqrt(y[0]*y[0]+y[1]*y[1])-R_T)*g*(gamma-1)/(K*gamma) << endl;
    long double m=pow(rho_0,gamma-1)-(sqrt(y_[0]*y_[0]+y_[1]*y_[1])-R_T)*g*(gamma-1)/(K*gamma);
    long double altitude = sqrt(y_[0]*y_[0]+y_[1]*y_[1]);
    
    /*if (rr){
      cout << rho_0 << endl;
      rr = false;
    }*/
  //return 0;
    if ((altitude-R_T)<0)
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
  
  valarray<long double> acceleration(valarray<long double> y_)
  {
    if (debug)
    {
      afficheValarray(y, "Y2");
    }
    
	valarray<long double> a = valarray<long double>(0.e0, 2);;
  //cout << "r1=" << y[0]*y[0]+y[1]*y[1] << endl;
    //cout << "r3=" << y[2]*y[2]+y[3]*y[3] << endl;
  //double m=pow(rho_0,gamma-1)-(sqrt(y_[0]*y_[0]+y_[1]*y_[1])-R_T)*g*(gamma-1)/(K*gamma);
  a[0]= - G*m_T*y_[0]/(pow((y_[0]*y_[0]+y_[1]*y_[1]),1.5)); // composante x acceleration
  a[1]= - G*m_T*y_[1]/(pow((y_[0]*y_[0]+y_[1]*y_[1]),1.5)); // composante y acceleration
  
    a[0]      += -0.5*C_x*pi*d*d*0.25*rho(y_)*sqrt(y_[2]*y_[2]+y_[3]*y_[3])*y_[2]/m_A;
    a[1]      += -0.5*C_x*pi*d*d*0.25*rho(y_)*sqrt(y_[2]*y_[2]+y_[3]*y_[3])*y_[3]/m_A;
  
    
     if (debug)
    {
      afficheValarray(a, "a");
    }
    return a;
  }
  
  valarray<long double> f(valarray<long double> y_){
        valarray<long double> retour = y_;
        //afficheValarray(y, "Y2");
        y_[0]=retour[2];
        y_[1]=retour[3];
        y_[2]=acceleration(retour)[0];
        y_[3]=acceleration(retour)[1];

        return y_;
    }

public:

  /* Constructeur de la classe Engine
     inputs:
       configFile: (ConfigFile) handler du fichier d'input
  */

  Engine(ConfigFile configFile)
  {
    // variable localel
    
    // Stockage des parametres de simulation dans les attributs de la classe
    tfin     = configFile.get<long double>("tfin",tfin);	        // lire la temps totale de simulation
    nsteps   = configFile.get<unsigned int>("nsteps",nsteps); // lire la nombre de pas de temps
    y0[0]    = configFile.get<long double>("x0",y0[0]);	    // lire composante x position initiale
    y0[1]    = configFile.get<long double>("y0",y0[1]);        // lire composante y position initiale
    double v0		 = configFile.get<long double>("v0",v0);
    long double alpha 	= configFile.get<long double>("alpha",alpha);
    y0[2]    = v0*cos(alpha);	    // lire composante x vitesse initiale
    y0[3]    = v0*sin(alpha);       // lire composante y vitesse initiale
    m_A      = configFile.get<long double>("m",m_A);          // lire la masse du vaisseau
    rho_0    = configFile.get<long double>("rho_0",rho_0);    // lire la densité de l'air à la surface terrestre
    p_0      = configFile.get<long double>("p_0",p_0);        // lire la pression à la surface terrrestre
    C_x      = configFile.get<long double>("C_x",C_x);         // lire le coefficient de frottement
    gamma    = configFile.get<long double>("gamma",gamma);     // lire l'indice d'adiabaticité
    d      = configFile.get<long double>("d",d);               // lire le diamètre du vaisseau
    fixe_step =configFile.get<bool>("fixe_step", fixe_step);
    sampling = configFile.get<unsigned int>("sampling",sampling); // lire le parametre de sampling
    epsilon      = configFile.get<long double>("epsilon",epsilon);
    dt = tfin / nsteps; // calculer le time step
    K=p_0*pow(rho_0,-gamma);
    cout << "   K=" << K << endl;
    // Ouverture du fichier de sortie
    outputFile = new ofstream(configFile.get<string>("output","output.out").c_str()); 
    outputFile->precision(19); // Les nombres seront ecrits avec 15 decimales
  };

  // Destructeur virtuel
  virtual ~Engine()
  {
    outputFile->close();
    delete outputFile;
  };

  // Simulation complete
  void run(){
        t = 0.e0; // initialiser le temps
        y = y0;   // initialiser les positions et les vitesses
        
        last = 0; // initialise le parametre d'ecriture
        int maxit = 500000000; // nombres d'itération max avant de s'arrêter
        int loop_cmp = 0;

        //cout << "rho=" << rho() << endl;
        //afficheValarray(y0, "Y0");
        //afficheValarray(y, "Y");
        printOut(true); // ecrire premier pas de temps
        if(fixe_step){
            // Pas de temps fixe =============================================

            for(unsigned int i(0); i<nsteps; ++i) // boucle sur les pas de temps
            {
                if(sqrt(pow(y[0],2)+pow(y[1],2)) <= R_T+d/2) return;
                y = step(y, dt);
                t += dt;
                printOut(false); // ecrire le pas de temps actuel
            }
        }else{
            // Pas de temps adaptatif ========================================
            while((t < tfin)&&(++loop_cmp < maxit)) {
                if(sqrt(pow(y[0],2)+pow(y[1],2)) <= R_T+d/2) return;
                dt = min(tfin-t,dt);
                valarray<long double> y_1 = step(y, dt);
                valarray<long double> y_2 = step(y, dt / 2.0);
                y_2 = step(y_2, dt / 2.0);
                valarray<long double> diff_ = y_2 - y_1;
                double diff = norm2(diff_);

                if (debug)
                    cout << "avant if : diff=" << diff << " dt=" << dt << " epsilon=" << epsilon << endl;

                if (debug) afficheValarray(y, "Y");

                //  dt = min(tfin - t, dt);

                if (diff < epsilon) {
                    y = y_2;
                    t += dt;
                    if (diff!=0)
                    {
                      dt = dt * pow(epsilon / diff, 1.0 / 5.0);
                    }
                    

                } else {
                    int loop_cmp2 = 0;
                    while ((diff > epsilon) && (++loop_cmp2 < 50)) {
                      if (diff!=0)
                      {
                         dt = 0.9999 * dt * pow(epsilon / diff, 1.0 / 5.0);
                      }
                        
                        y_1 = step(y, dt);
                        y_2 = step(y, dt / 2.0);
                        y_2 = step(y_2, dt / 2.0);
                        diff_ = y_2 - y_1;
                        diff = norm2(diff_);

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
    }
    
    void afficheValarray(valarray<long double> const& array, string name="") const{
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

};



// programme
int main(int argc, char* argv[])
{
  string inputPath("configuration3.in"); // Fichier d'input par defaut
  if(argc>1) // Fichier d'input specifie par l'utilisateur ("./Exercice2 config_perso.in")
    inputPath = argv[1];

  ConfigFile configFile(inputPath); // Les parametres sont lus et stockes dans une "map" de strings.

  for(int i(2); i<argc; ++i) // Input complementaires ("./Exercice2 config_perso.in input_scan=[valeur]")
    configFile.process(argv[i]);

  // Schema numerique ("Euler"/"E" ou "RungeKutta2"/"RK2" )
  //string schema(configFile.get<string>("schema"));

  Engine* engine; // definer la class pour la simulation
  // choisir quel schema utiliser
 // initialiser une simulation avec schema runge-kutta 2
    engine = new Engine(configFile);

  engine->run(); // executer la simulation

  delete engine; // effacer la class simulation 
  cout << "Fin de la simulation." << endl;
  return 0;
}

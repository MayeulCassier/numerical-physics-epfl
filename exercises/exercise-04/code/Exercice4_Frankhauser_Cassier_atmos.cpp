#include <iostream>       // basic input output streams
#include <fstream>        // input output file stream class
#include <cmath>          // librerie mathematique de base
#include <iomanip>        // input output manipulators
#include <valarray>       // valarray functions
#include "ConfigFile.h" // Il contient les methodes pour lire inputs et ecrire outputs 
                          // Fichier .tpp car inclut fonctions template
#include <numeric>
using namespace std; // ouvrir un namespace avec la librerie c++ de base


template<typename T> T scalarProduct(valarray<T> const& array1,\
valarray<T> const& array2){
  // compute and return the norm2 of a valarray
  return (array1*array2).sum();
} 

template<typename T> T norm2(valarray<T> const& array){
  // compute and return the norm2 of a valarray
  return sqrt((array*array).sum());
} 


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
  double zfin;          // Hauteur finale
  double z0;             // Hauteur initiale
  double signe;         // Sens de parcours de l'atmosphère (de z0 à zfin ou l'inverse)
  unsigned int nsteps;  // Nombre de pas de temps
  double p_0;          // pression à la surface de la Terre
  double gamma;        // indice d'adiabaticité
  double K; 
  double epsilon;      // tolérance pour le pas de temps adaptatif  
  bool fixe_step;
  int maxit;

  valarray<double> y0=valarray<double>(0.e0,1); // Vecteurs des conditions initiales (position et vitesse)
  
  unsigned int sampling;  // Nombre de pas de temps entre chaque ecriture des diagnostics
  unsigned int last;       // Nombre de pas de temps depuis la derniere ecriture des diagnostics
  ofstream *outputFile;    // Pointeur vers le fichier de sortie

  /* Calculer et ecrire les diagnostics dans un fichier
     inputs:
     write: (bool) ecriture de tous les sampling si faux
  */  
  void printOut(bool write)
  {

    // Ecriture tous les [sampling] pas de temps, sauf si write est vrai
    if((!write && last>=sampling) || (write && last!=1))
    {
      *outputFile << z << " " << y[0] << " "\
     << endl; // write output on file
      last = 1;	
    }
    else
    {
      last++;
    }
  }

  // Iteration temporelle, a definir au niveau des classes filles
  valarray<double> step(valarray<double>const& y, double dz_)
  {
    valarray<double> k1 = dz_*f(y);
    if (debug)
    {
      *outputFile << "k1 size =" << k1.size() << "k1  =" << k1[0] << endl;
    }
  	valarray<double> k2 = dz_*f(y + 0.5*k1);
  	valarray<double> k3 = dz_*f(y+ 0.5*k2);
    valarray<double> k4 = dz_*f(y+ k3);
    
  
    
    return (y +(1.0/6.0)*(k1+2.0*k2+2.0*k3+k4));
  }


protected:

  // donnes internes
  double z, dz;  // Hauteur à la surface et pas de hauteur
  bool debug=false; 

  valarray<double> y =valarray<double>(0.e0, 1); // densité et sa dérivée
  
  // Définition de f(y)=dy/dz
  valarray<double> f(valarray<double> y_){
      y_[0]=-signe*(g/(K*gamma))*pow(y_[0],2.0-gamma);
    if (debug)
      {
        *outputFile << "f  =" << y_[0] << endl;
      }
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
    fixe_step =configFile.get<bool>("fixe_step", fixe_step);
    zfin     = configFile.get<double>("zfin",zfin);	        // lire la temps totale de simulation
    z0     = configFile.get<double>("z0",z0);	
    signe     = configFile.get<double>("signe",signe);	  
    nsteps   = configFile.get<unsigned int>("nsteps",nsteps); // lire la nombre de pas de temps
    y0[0]    = configFile.get<double>("rho_0",y0[0]);	    // lire la valeur de rho à la surface de la Tere
    p_0      = configFile.get<double>("p_0",p_0);        // lire la pression à la surface terrrestre
    
    gamma    = configFile.get<double>("gamma",gamma);     // lire l'indice d'adiabaticité
    maxit    = configFile.get<int>("maxit",maxit);
    K=p_0*pow(y0[0], -gamma);
    if (signe == -1.0)
    {
      y0[0] = pow(pow(y0[0],gamma-1)-z0*g*(gamma-1)/(K*gamma),1/(gamma-1));
    }
    

    sampling = configFile.get<unsigned int>("sampling",sampling); // lire le parametre de sampling

    dz = abs(zfin-z0) / nsteps; // calculer le pas de hauteur (écart entre la hauteur de deux mesures)

    // Ouverture du fichier de sortie
    outputFile = new ofstream(configFile.get<string>("output2","output2.out").c_str()); 
    outputFile->precision(15); // Les nombres seront ecrits avec 15 decimales
  };

  // Destructeur virtuel
  virtual ~Engine()
  {
    outputFile->close();
    delete outputFile;
  };

  // Simulation complete
  void run(){
     z=z0;
      y = y0;   // initialiser la densité initiale ainsi que la dérivée correspondante
      last = 0; // initialise le parametre d'ecriture
       // nombres d'itération max avant de s'arrêter
      int loop_cmp = 0;
      printOut(true); // ecrire premier pas de temps
      if(signe==-1){
      
          for(unsigned int i(0); i<nsteps; ++i) // boucle sur les pas de temps
          {
              y = step(y, dz);
              z -= dz;
              printOut(false); // ecrire le pas de temps actuel
          }
         }else{
      /*
          for(unsigned int i(0); i<nsteps; ++i) // boucle sur les pas de temps
          {
              y = step(y, dz);
              z += dz;

              printOut(false); // ecrire le pas de temps actuel
          }
      */
      while(y[0]>y0[0]*1.0e-6) // boucle sur les pas de temps
          {
              y = step(y, dz);
              z += dz;

              printOut(false); // ecrire le pas de temps actuel
          }
        
	}
        printOut(true); // ecrire le dernier pas de temps
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

};



// programme
int main(int argc, char* argv[])
{
  string inputPath("configuration.in"); // Fichier d'input par defaut
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

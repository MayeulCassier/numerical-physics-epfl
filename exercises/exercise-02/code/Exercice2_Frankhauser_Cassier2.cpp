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
  // definition des variables
  double tfin;          // Temps final
  unsigned int nsteps;  // Nombre de pas de temps
  double kappa;    // parameter kappa
  double mass;          // mass du proton
  double B0;            // parameter B0
  double B1;            // parameter B1
  double B2;            // parameter B2
  double L;             // parameter L
  double q;             // charge du proton 

  valarray<double> E =valarray<double>(0.e0,3); // vecteur contenant le champ ́electrique 
  valarray<double> x0=valarray<double>(0.e0,3); // vecteur contenant la position initiale 
  valarray<double> v0=valarray<double>(0.e0,3); // vecteur contenant la vitesse initiale 
  
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
    Energy = 0.5*mass*scalarProduct(v,v) - q*scalarProduct(E,x);

    // Ecriture tous les [sampling] pas de temps, sauf si write est vrai
    if((!write && last>=sampling) || (write && last!=1))
    {
      
       // moment magnetique du proton
      *outputFile << t << " " << x[0] << " " << x[1] << " " \
      << x[2] << " " << v[0] << " " << v[1] << " " << v[2] << " " \
      << mu << " "<< Energy<< " " << magnetic_moment() << " " << scalarProduct(v,B)/norm2(B)<< endl; // write output on file
      last = 1;
    }
    else
    {
      last++;
    }
  }

  // Iteration temporelle, a definir au niveau des classes filles
  virtual void step()=0;




protected:

  // donnes internes
  double t,dt;  // Temps courant pas de temps
  double mu; // moment magnetique

  // Ci-dessous, on définit deux vecteurs séparés, x et v, pour le vecteur-position
  // et le vecteur-vitesse, respectivement.
  valarray<double> x =valarray<double>(3); // Position actuelle du proton 
  valarray<double> v =valarray<double>(3); // Vitesse actuelle du proton
  
  // On pourrait aussi définir un seul vecteur y, de taille 6, qui regrouperait (x,v)
  // valarray<double> y =valarray<double>(6); // (Position,vitesse) actuelle du proton

  
  valarray<double> B =valarray<double>(3); // vecteur du champ magnetique 

  
  // TODO
  /* Calcul de l'acceleration totale
     output:
       a: (valarray<double>)(3) vecteur acceleration
  */
  void acceleration(valarray<double>& a) const
  {
    valarray<double> v_cross_B =valarray<double>(0.e0,3); //  
    v_cross_B = produitVecteur(v,B);
    a[0]      = (q/mass)*(E[0]+v_cross_B[0]); // composante x acceleration
    a[1]      = (q/mass)*(E[1]+v_cross_B[1]); // composante y acceleration
    a[2]      = (q/mass)*(E[2]+v_cross_B[2]); // composante z acceleration
  }

  void update_magneticfield() 
  {
    B[0] = B2*x[0]*kappa* sin(kappa*x[2]);         
    B[1] = 0;
    B[2] = B0 + B1 * x[0]/L + B2 * cos(kappa * x[2]);
  }

  double magnetic_moment() 
  {
    double module_B;
    double v2 = scalarProduct(v,v);
    double v_par;
    update_magneticfield();
    module_B = norm2(B);
    v_par = scalarProduct(v,B)/module_B;
    mu = mass*(v2 - v_par*v_par)/(2*module_B);
    return mu;
  }


public:

  /* Constructeur de la classe Engine
     inputs:
       configFile: (ConfigFile) handler du fichier d'input
  */
  Engine(ConfigFile configFile)
  {
    // variable locale
    
    // Stockage des parametres de simulation dans les attributs de la classe
    tfin     = configFile.get<double>("tfin",tfin);         // lire la temps totale de simulation
    nsteps   = configFile.get<unsigned int>("nsteps",nsteps); // lire la nombre de pas de temps
    B0       = configFile.get<double>("B0",B0);           // lire B0 parameter
    B1       = configFile.get<double>("B1",B1);           // lire B1 parameter
    B2       = configFile.get<double>("B2",B2);           // lire B2 parameter
    L        = configFile.get<double>("L",L);             // lire L parameter
    q        = configFile.get<double>("q",q);             // lire la charge électrique du proton
    mass     = configFile.get<double>("m",mass);          // lire la masse du proton
    kappa    = configFile.get<double>("k",kappa);         // lire le parametre kappa
    E[0]     = configFile.get<double>("Ex",E[0]);         // lire composante x champ ́electrique
    E[1]     = configFile.get<double>("Ey",E[1]);         // lire composante y champ ́electrique
    E[2]     = configFile.get<double>("Ez",E[2]);    
    v0[0]    = configFile.get<double>("vx0",v0[0]);     // lire composante x vitesse initiale
    v0[1]    = configFile.get<double>("vy0",v0[1]);       // lire composante y vitesse initiale
    v0[2]    = configFile.get<double>("vz0",v0[2]);       // lire composante z vitesse initiale
    x0[0]    = mass*v0[1]/(q*B0);    // lire composante x position initiale
    x0[1]    = configFile.get<double>("y0",x0[1]);        // lire composante y position initiale
    x0[2]    = configFile.get<double>("z0",x0[2]);        // lire composante z position initiale
         // lire composante z champ ́electrique
    sampling = configFile.get<unsigned int>("sampling",sampling); // lire le parametre de sampling

    dt = tfin / nsteps; // calculer le time step

    // Ouverture du fichier de sortie
    outputFile = new ofstream(configFile.get<string>("output","output.out").c_str()); 
    outputFile->precision(15); // Les nombres seront ecrits avec 15 decimales
  };

  // Destructeur virtuel
  virtual ~Engine()
  {
    outputFile->close();
    delete outputFile;
  };

  // Simulation complete
  void run()
  {
    t = 0.e0; // initialiser le temps
    x = x0;   // initialiser la position
    v = v0;   // initialiser la vitesse
    last = 0; // initialise le parametre d'ecriture
    printOut(true); // ecrire premier pas de temps

    for(unsigned int i(0); i<nsteps; ++i) // boucle sur les pas de temps
    {
      step();  // faire la mise a jour de la simulation 
      printOut(false); // ecrire pas de temps actuel
    }
    printOut(true); // ecrire dernier pas de temps
  };

}; 




// Extension de la class Engine implementant l'integrateur Runge-Kutta 2
class EngineRungeKutta2: public Engine
{
public:
  EngineRungeKutta2(ConfigFile configFile): Engine(configFile) {}

  // TODO
  /* Cette methode integre les equations du mouvement en utilisant
     le scheme: Runge-kutta 2
  */
  void step()
  {
    valarray<double> a =valarray<double>(0.e0,3); 
    acceleration(a);// 
    // sauvgarder la position et la vitesse au debut de l'intervalle temporel
    valarray<double> x_ = x; // position
    valarray<double> v_ = v; // vitesse
    
    valarray<double> k1x(dt*v_);
    valarray<double> k1v(dt*a);
    x+=0.5*k1x;
    v+=0.5*k1v;
    update_magneticfield();
    acceleration(a);
    valarray<double> k2x(dt*v);
    valarray<double> k2v(dt*a);
    x=x_+k2x;
    v=v_+k2v;
    update_magneticfield();

    t+=dt;
    
  }
}; // fin de la classe RungeKutta2



// Extension de la class Engine implementant l'integrateur d'Euler
class EngineEuler: public Engine
{
private:
  unsigned int maxit=1000; // nombre maximale d iterations
  double tol=1.e12;        // tolerance methode iterative
  double alpha;        // parametre pour le scheme d'Eurler (alpha dans [0,1] -> 1 Esplicit, 0 Implicit, 0.5 semi-implicit)
public:
  
  EngineEuler(ConfigFile configFile, string schema ): Engine(configFile){
    tol   = configFile.get<double>("tol"); // lire la tolerance pour le method iterative
    maxit = configFile.get<unsigned int>("maxit"); // lire le nombre des iterations maximale 
    if (schema=="EE")
    {
      alpha=1.0;
    }else if (schema=="EI")
    {
      alpha=0.0;
    }else if (schema=="ESI")
    {
      alpha = 0.5;
    }else{
      alpha = configFile.get<double>("alpha");
    } // lire le parametre alpha (alpha dans [0,1] -> 1 Eesplicit, 0 Implicit, 0.5 semiimplicit)
    cout<< alpha << endl;
  }

  // TODO
  /* Cette methode integre les equations du mouvement en utilisant
     les schemas: Euler explicite, implicite et semi-implicite
  */
  void step()
  {
    unsigned int iteration=0;
    double error=999e0;
    valarray<double> a =valarray<double>(0.e0,3); 
    acceleration(a);
    valarray<double> a_init(a);
    valarray<double> x_init(x);
    valarray<double> v_init(v);
    
    while(iteration<=maxit and error >= tol){
    x = x_init + (alpha*v_init + (1-alpha)*v)*dt;
    v = v_init + (alpha*a_init + (1-alpha)*a)*dt;
    update_magneticfield();
    acceleration(a);
    error = norm2(valarray<double> (x-x_init-alpha*v_init*dt-(1-alpha)*dt*v));
    }
    
    t += dt; // mise a jour du temps 
    
  }
}; // fin de la classe Euler 





// programme
int main(int argc, char* argv[])
{
  string inputPath("configuration4.in"); // Fichier d'input par defaut
  if(argc>1) // Fichier d'input specifie par l'utilisateur ("./Exercice2 config_perso.in")
    inputPath = argv[1];

  ConfigFile configFile(inputPath); // Les parametres sont lus et stockes dans une "map" de strings.

  for(int i(2); i<argc; ++i) // Input complementaires ("./Exercice2 config_perso.in input_scan=[valeur]")
    configFile.process(argv[i]);

  // Schema numerique ("Euler"/"E" ou "RungeKutta2"/"RK2" )
  string schema(configFile.get<string>("schema"));

  Engine* engine; // definer la class pour la simulation
  // choisir quel schema utiliser
  if(schema == "EulerExplicite" || schema == "EE")
  {
    // initialiser une simulation avec schema Euler
    engine = new EngineEuler(configFile, "EE");
  }else if(schema == "RungeKutta2" || schema == "RK2")
  {
    // initialiser une simulation avec schema runge-kutta 2
    engine = new EngineRungeKutta2(configFile);
  } else if(schema == "EulerImplicite" || schema == "EI")
  {
    // initialiser une simulation avec schema Euler
    engine = new EngineEuler(configFile,"EI");
  } else if(schema == "EulerSemiImplicite" || schema == "ESI")
  {
    // initialiser une simulation avec schema Euler
    engine = new EngineEuler(configFile,"ESI");
  }else if(schema == "Euler" || schema == "E")
  {
    // initialiser une simulation avec schema Euler
    engine = new EngineEuler(configFile,"E");
  }else
  {
    cerr << "Schema inconnu" << endl;
    return -1;
  }

  engine->run(); // executer la simulation

  delete engine; // effacer la class simulation 
  cout << "Fin de la simulation." << endl;
  return 0;
}

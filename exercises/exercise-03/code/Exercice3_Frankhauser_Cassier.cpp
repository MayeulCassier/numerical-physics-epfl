#include <iostream>
#include <fstream>
#include <cmath>
#include <iomanip>
#include "ConfigFile.h" // Il contient les methodes pour lire inputs et ecrire outputs 

using namespace std;

class Exercice3
{

private:
  double t, dt, tFin;
  double m, g, L;
  double d, Omega, kappa;
  long double theta, thetadot;
  int N_excit, nstep_per;
  int sampling;
  int last;
  ofstream *outputFile;

  void printOut(bool force)
  {
    if((!force && last>=sampling) || (force && last!=1))
    {
      double emec = m*g*L*(1-cos(theta))+0.5*m*L*L*thetadot*thetadot; // TODO: Evaluer l'energie mecanique
      double pnc = -kappa*L*L*thetadot*thetadot+L*thetadot*d*Omega*Omega*sin(Omega*t)*sin(theta)*m; // TODO: Evaluer la puissance des forces non conservatives

      *outputFile << t << " " << theta << " " << thetadot << " " << emec << " " << pnc << endl;
      last = 1;
    }
    else
    {
      last++;
    }
  }

  double acceleration(const double theta_, const double thetadot_, const double t_)
  {
    // TODO: Modifier selon l'expression analytique
    
    return (-g/L)*sin(theta_)-(kappa/m)*thetadot_+(d/L)*Omega*Omega*sin(Omega*t_)*sin(theta_);
  }

  void step()
  {
    // TODO: Modifier  selon l'algorithme  
    double theta_(theta);
    double thetadot_(thetadot);
    double acceleration_(acceleration(theta_,thetadot_,t));
    
    
    theta += thetadot_*dt+0.5*acceleration_*dt*dt;
    
    double thetadot_moitie(thetadot_+0.5*acceleration_*dt);
    thetadot += (acceleration(theta_,thetadot_moitie,t)+acceleration(theta,thetadot_moitie,t+dt))*dt/2;
  }


public:

  Exercice3(int argc, char* argv[])
  {
    const double pi=3.1415926535897932384626433832795028841971e0;
    string inputPath("configurationsupp.in"); // Fichier d'input par defaut
    if(argc>1) // Fichier d'input specifie par l'utilisateur ("./Exercice3 config_perso.in")
      inputPath = argv[1];

    ConfigFile configFile(inputPath); // Les parametres sont lus et stockes dans une "map" de strings.

    for(int i(2); i<argc; ++i) // Input complementaires ("./Exercice3 config_perso.in input_scan=[valeur]")
      configFile.process(argv[i]);

    tFin     = configFile.get<double>("tFin");      // t final (overwritten if N_excit >0)
    dt       = configFile.get<double>("dt");        // time step (overwritten if nstep_per >0)
    d        = configFile.get<double>("d");         // amplitude forcing term
    Omega    = configFile.get<double>("Omega");     // angular frequency forcing term 

    kappa    = configFile.get<double>("kappa");     // coefficient for friction
    m        = configFile.get<double>("m");         // mass
    g        = configFile.get<double>("g");         // gravity acceleration
    L        = configFile.get<double>("L");         // length
    theta    = configFile.get<long double>("theta0");    // initial condition in theta
    thetadot = configFile.get<long double>("thetadot0"); // initial condition in thetadot
    sampling = configFile.get<int>("sampling");     // number of time steps between two writings on file
    N_excit  = configFile.get<int>("N");            // number of periods of excitation
    nstep_per= configFile.get<int>("nstep");        // number of time step per period
    //Omega= 2*sqrt(g/L);
    // Ouverture du fichier de sortie
    outputFile = new ofstream(configFile.get<string>("output").c_str());
    outputFile->precision(15);
    if(N_excit>0){
      tFin = N_excit*(2.0*pi/Omega);
      cout<< tFin << endl;
    }
     if(nstep_per>0){
      dt = 2.0*pi/(nstep_per * Omega);
    }  
  }

  ~Exercice3()
  {
    outputFile->close();
    delete outputFile;
  };

  void run()
  {
    t = 0.;
    last = 0;
    printOut(true);
    while( t < tFin-0.5*dt )
    {
      step();
      t += dt;
      printOut(false);
    }
    printOut(true);
  };

};


int main(int argc, char* argv[])
{
  Exercice3 engine(argc, argv);
  engine.run();
  return 0;
}

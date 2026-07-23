#include <iostream>
#include <vector>
#include <fstream>
#include <cmath>
#include <cstdlib>
#include <string.h>
#include <filesystem>
#include "ConfigFile.tpp"
#include <algorithm>
#ifdef _WIN32
#include <direct.h>
#else
#include <unistd.h>
#endif

using namespace std;

// est-ce que les Beta sont biens en fonction de i dans les évolutions? 
// est-ce que pour le bord 5. de gauche on prend en compte G(x+|u|t) ou alors on a aussi oublié F dans la partie de droite?
// lors de la dérivation des équations de droite c'est |beta| est une norme? (on doit sommer ou c'est juste la valeur absolue du numéro i?)
// Si c'est seulement la valeur absolue du numéro i c'est lequel qu'on doit prendre? N-1 ou N-2?


void boundary_condition(vector<vector<double>> &fnext, vector<vector<double>> &fnow, double const& A, double const& omega,\
		double const& time,double const& dt, \
		vector<vector<double>> &vel2, string &bc_l, string &bc_r,string &bc_h, string &bc_b, const vector<double>& x,
                      const vector<double>& y)
{
  double hx= abs(x[0]-x[1]);
      if (bc_l == "fixe"){
        fnext[0] = fnow[0]; // TODO : Completer la condition au bord gauche fixe
      }else if(bc_l == "libre"){
        fnext[0] = fnext[1]; // TODO : Completer la condition au bord gauche libre
      }else if(bc_l== "harmonique"){
        for(auto& f : fnext[0]){
        f=A*sin(omega*(time+dt));
        } // TODO : Completer la condition au bord gauche harmonique
      }else if (bc_l =="sortie"){
        double hx = x[1]-x[0];
        for(unsigned int i(0);i<fnext[0].size()-1;i++){
          // fnext.back()[i]=fnow.back()[i] -sqrt(vel2[0][i])*dt/hx*(fnow[fnow.size()-1][i]-fnow[fnow.size()-2][i]);
          fnext[0][i]=fnow[0][i] -sqrt(vel2[0][i])*dt/hx*(fnow[1][i]-fnow[0][i]);
        }  // TODO : Completer la condition au bord gauche "sortie de l'onde"
      }else{
        cerr << "Merci de choisir une condition valide au bord gauche" << endl;
      }
	      
      if (bc_r == "fixe"){
        fnext.back() = fnow[fnow.size()-1]; // TODO : Completer la condition au bord droit fixe
      }else if(bc_r== "harmonique"){
        for(auto& f : fnext.back()){
        f=A*sin(omega*(time+dt));
        } // TODO : Completer la condition au bord gauche harmonique
      }else if(bc_r == "libre"){
        fnext.back() = fnext[fnow.size()-2]; // TODO : Completer la condition au bord droit harmonique
      }else if (bc_r =="sortie"){
        for(unsigned int i(0);i<fnext.back().size()-1;i++){
          fnext.back()[i]=fnow.back()[i] -sqrt(vel2.back()[i])*dt/hx*(fnow[fnow.size()-1][i]-fnow[fnow.size()-2][i]);
          // fnext[0][i]=fnow[0][i] -sqrt(vel2[0][i])*dt/hx*(fnow[1][i]-fnow[0]][i]);
        } // TODO : Completer la condition au bord droit "sortie de l'onde"
      }else{
        cerr << "Merci de choisir une condition valide au bord droit" << endl;
      

      }
      if (bc_b == "fixe"){
        for(unsigned int i(0); i<fnext.size();i++){
        fnext[i][0]=fnow[i][0];
      }  // TODO : Completer la condition au bord droit fixe
      }else if(bc_b == "libre"){
        for(unsigned int i(0); i<fnext.size();i++){
        fnext[i][0]=fnext[i][1];
      }  // TODO : Completer la condition au bord droit harmonique
      }else if (bc_b =="sortie"){
        for(unsigned int i(0);i<fnext.size()-1;i++){
          fnext[i][0]=fnow[i][0] -sqrt(vel2[i][0])*dt/hx*(fnow[i][0]-fnow[i][1]);
          // fnext[0][i]=fnow[0][i] -sqrt(vel2[0][i])*dt/hx*(fnow[1][i]-fnow[0]][i]);
        } // TODO : Completer la condition au bord droit "sortie de l'onde"
      }else{
        cerr << "Merci de choisir une condition valide au bord bas" << endl;
      }


      if (bc_h == "fixe"){
        for(unsigned int i(0); i<fnext.size();i++){
        fnext[i].back()=fnow[i].back();
      }  // TODO : Completer la condition au bord droit fixe
      }else if(bc_h == "libre"){
        for(unsigned int i(0); i<fnext.size();i++){
        fnext[i].back()=fnext[i][fnext[i].size()-2];
      }  // TODO : Completer la condition au bord droit harmonique
      }else if (bc_h =="sortie"){
        for(unsigned int i(0);i<fnext.size()-1;i++){
          fnext[i].back()=fnow[i].back() -sqrt(vel2[i].back())*dt/hx*(fnow[i].back()-fnow[i][fnow[i].size()-2]);
          // fnext[0][i]=fnow[0][i] -sqrt(vel2[0][i])*dt/hx*(fnow[1][i]-fnow[0]][i]);
        } // TODO : Completer la condition au bord droit "sortie de l'onde"
      }else{
        cerr << "Merci de choisir une condition valide au bord haut" << endl;
      }
}

//
// TODO : Calcul de l'energie de l'onde
//
double energie(vector<vector<double>> const& f, double const& dx, double const& dy)
{
  double energie_(0.);
  for(unsigned int i(0); i<f.size()-1; ++i)

    for(unsigned int j(0); j<f[i].size()-1; ++j){
    energie_ += dx*(f[i][j]*f[i][j]+f[i+1][j]*f[i+1][j])/2.;
}
energie_*=dy;
  return energie_;
}

//
// Surcharge de l'operateur pour ecrire les elements d'un tableau
//
void
writeData(const string& filepath,
          const double time,
          const vector<double>& x,
          const vector<double>& y,
          const vector<vector<double>>& heightField)
{
    const int xDim = x.size();
    const int yDim = y.size();

    if (xDim != heightField.size())
        throw std::runtime_error("size mismatch: x and heightfield different dimensions");

    ofstream os(filepath);
    os.precision(15);
    // First store current simulation time
    os << time << "\n";

    // Then store all data
    for (unsigned int i = 0; i < xDim; ++i) {
        if (yDim != heightField[i].size())
            throw std::runtime_error("size mismatch: y and heightfield different dimensions");
        for (int j = 0; j < yDim; ++j) {
            const double f = heightField[i][j];
            os << x[i] << " " << y[j] << " " << f << "\n";
        }
    }
    // cout << time << "\n";
}
template <class T> ostream& operator<< (ostream& o, vector<T> const& v)
{
  unsigned int len(v.size());
  for(unsigned int i(0); i < (len - 1); ++i)
    o << v[i] << " ";
  if(len > 0)
    o << v[len-1];
  return o;
}


string
getFilepathForFrame(int frame, const string& filepath)
{
    const int hashPos = filepath.find('#');
    if (hashPos == string::npos) return filepath;
    std::stringstream ss;
    ss << filepath.substr(0, hashPos);
    ss << to_string(frame);
    ss << filepath.substr(hashPos + 1);
    return ss.str();
}
//
// Main
//
int main(int argc, char* argv[])
{
  const double PI = 3.1415926535897932384626433832795028841971e0;
  const double g  = 9.81;
  double dx;
  double dy;
  double dt;
  
  int stride(0);

  string inputPath("input_supp"); // Fichier d'input par defaut
  if(argc>1) // Fichier d'input specifie par l'utilisateur ("./Exercice7 config_perso.in")
    inputPath = argv[1];

  ConfigFile configFile(inputPath); // Les parametres sont lus et stockes dans une "map" de strings.

  for(int i(2); i<argc; ++i) // Input complementaires ("./Exercice7 config_perso.in input_scan=[valeur]")
    configFile.process(argv[i]);

  // Parametres de simulation :
  double tfin    = configFile.get<double>("tfin");
  int Nx          = configFile.get<int>("Nx");
  int Ny          = configFile.get<int>("Ny");
  double CFL     = configFile.get<double>("CFL");
  double A       = configFile.get<double>("A");
  double fmn     = configFile.get<double>("fmn");
  double minitx   = configFile.get<double>("minitx");
  double minity   = configFile.get<double>("minity");
  double omega   = configFile.get<double>("omega");
  double hL      = configFile.get<double>("hL");
  double hR      = configFile.get<double>("hR");
  double h00     = configFile.get<double>("h00");
  double xa      = configFile.get<double>("xa");
  double xb      = configFile.get<double>("xb");
  double ya      = configFile.get<double>("ya");
  double yb      = configFile.get<double>("yb");
  double xL      = configFile.get<double>("xL");
  double xR      = configFile.get<double>("xR");
  double yR = configFile.get<double>("yR");
  double yL = configFile.get<double>("yL");
  int n_stride(configFile.get<int>("n_stride"));
  string bc_l           = configFile.get<string>("cb_gauche");
  string bc_r           = configFile.get<string>("cb_droit");
  string bc_h           = configFile.get<string>("cb_haut");
  string bc_b           = configFile.get<string>("cb_bas");
  string initialization = configFile.get<string>("initialization");
  string v        = configFile.get<string>("v");
  bool lance        = configFile.get<bool>("lance");

  
  vector<vector<double>> fnow(Nx, vector<double>(Ny));
  vector<vector<double>> fpast(Nx, vector<double>(Ny));
  vector<vector<double>> fnext(Nx, vector<double>(Ny));
  vector<vector<double>> beta2(Nx, vector<double>(Ny));
  vector<vector<double>> h0(Nx, vector<double>(Ny));
  vector<vector<double>> vel2(Nx, vector<double>(Ny));
  vector<double> x(Nx);
  vector<double> y(Ny);
  for (unsigned int i = 0; i < x.size(); ++i) x[i] = i*(xR-xL)/(x.size()-1);
  for (unsigned int j = 0; j < y.size(); ++j) y[j] = j*(yR-yL)/(y.size()-1);

   dx = (xR - xL) / (Nx-1);
   dy = (yR-yL)/(Ny-1);
  bool ecrire_f = configFile.get<bool>("ecrire_f"); // Exporter f(x,t) ou non
  string schema = configFile.get<string>("schema");
  

  for(int i(0); i<Nx; ++i){
  for(int j(0); j<Ny; ++j){ 
     h0[i][j] = 0.0;
     if(v=="uniform"){
           h0[i][j]  = h00;
     } 
     if (v=="cas1")
     {
       h0[i][j]  = hL * (xL<=x[i] && x[i]<=xa) + \
		   (0.5*(hL + hR) + 0.5*(hL - hR)*cos(PI *(x[i]-xa)/(xa - xb))) * (xa<x[i] && x[i]<xb) +\
		   hR * (xb<=x[i] && x[i]<=xR);
	   if(i==0) cout << "v is not uniform"<<endl;
     }
     if (v== "cas2")
     {
       h0[i][j]  = hL * (xL<=x[i] && x[i]<=xa) + \
       (0.5*(hL + hR) + 0.5*(hL - hR)*cos(PI *(x[i]-xa)/(xa - xb))) * (xa<x[i] && x[i]<xb)*sqrt(sin(PI*y[j]/(yR-yL))) +\
       hR * (xb<=x[i] && x[i]<=xR)*sqrt(sin(PI*y[j]/(yR-yL)));
       if(i==0) cout << "v is not uniform"<<endl;
     }
     vel2[i][j]  = g* h0[i][j];
  }}
double lemax(0);
for (int i = 0; i < Nx; ++i)
{
  auto max_vel2 = std::max_element(vel2[i].begin(), vel2[i].end());
  if (lemax< *max_vel2)
  {
    lemax=*max_vel2;
  }
}
  
  dt = CFL  / (sqrt(lemax)*sqrt(1./(dx* dx)+1./(dy*dy)));
  cout << "dt is "<< dt<<endl; cout << "dx is " <<dx<< endl; cout << "dy is " <<dy<< endl;

  // Fichiers de sortie :
  string output = configFile.get<string>("output");

  const string simulation_directory = output + "_sim";
#ifdef _WIN32
  int status = _rmdir(simulation_directory.c_str());
#else
  int status = rmdir(simulation_directory.c_str());
#endif

  ofstream fichier_E((output + "_E").c_str());
  fichier_E.precision(15);


  // Initialisation des tableaux du schema numerique :

  //TODO initialize f and beta
  for(int i(0); i<Nx; ++i)
  {for(int j(0); j<Ny; ++j)
  {
    fpast[i][j] = 0.;
    fnow[i][j]  = 0.;
    beta2[i][j] = vel2[i][j]*dt*dt*(1.0/(dx*dx)+1.0/(dy*dy));
    if(initialization=="cas1"){
    double km(minitx*PI/(xR - xL));
    double kn(minity*PI/(yR - yL));
    fnow[i][j]=fmn*(cos(km*x[i])*cos(kn*y[j]));
    fpast[i][j]=fnow[i][j]*cos(-dt*sqrt(pow(km,2.0)+pow(kn,2.0))*sqrt(vel2[i][j]));
                    
    }else if(initialization=="cas2"){
	    if(x[i]<=xa || xb<=x[i] || y[j]<=ya || yb<=y[j]){
          fnow[i][j]=0;
          fpast[i][j]=0;
      }else{
          fnow[i][j]=fmn*(1-cos(2*PI*(x[i]-xa)/(xb-xa)))*(1-cos(2*PI*(y[j]-ya)/(yb-ya)));
      }
      fpast[i][j]=fnow[i][j];
    }else if (initialization=="cas3")
    {
      if(x[i]<=xa || xb<=x[i] || y[j]<=ya || yb<=y[j]){
          fnow[i][j]=0;
      }else{
          fnow[i][j]=fmn*(1-cos(2*PI*(x[i]-xa)/(xb-xa)))*(1-cos(2*PI*(y[j]-ya)/(yb-ya)));
      }
      if(x[i]+sqrt(vel2[i][j])*dt<=xa || xb<=x[i]+sqrt(vel2[i][j])*dt || y[j]<=ya || yb<=y[j]){
          fpast[i][j]=0;
      }else{
          fpast[i][j]=fmn*(1-cos(2*PI*(x[i]+sqrt(vel2[i][j])*dt-xa)/(xb-xa)))*(1-cos(2*PI*(y[j]-ya)/(yb-ya)));
      }
    }else if (initialization=="cas4")
    {
      if(x[i]<=xa || xb<=x[i] || y[j]<=ya || yb<=y[j]){
          fnow[i][j]=0;
      }else{
          fnow[i][j]=fmn*(1-cos(2*PI*(x[i]-xa)/(xb-xa)))*(1-cos(2*PI*(y[j]-ya)/(yb-ya)));
      }
      if(x[i]-sqrt(vel2[i][j])*dt<=xa || xb<=x[i]-sqrt(vel2[i][j])*dt || y[j]<=ya || yb<=y[j]){
          fpast[i][j]=0;
      }else{
          fpast[i][j]=fmn*(1-cos(2*PI*(x[i]-sqrt(vel2[i][j])*dt-xa)/(xb-xa)))*(1-cos(2*PI*(y[j]-ya)/(yb-ya)));
      }
    }
  }}
  cout<<"beta2[0] is "<<beta2[0]<<endl;
const int frameCount = tfin / dt+1;
double time=0;
  // Boucle temporelle :
  for(int frame = 0; frame < frameCount; ++frame)
  {
    time = frame * dt;
    // Ecriture :
    // cout << frame << " : " ;
      const string framepath = getFilepathForFrame(frame, output);
      writeData(framepath, time, x, y, fnow);
      fichier_E << time << " " << energie(fnow,dx,dy) << endl;
    

    // Evolution :
    for (unsigned int i = 1; i < x.size() - 1; ++i) {
        for (unsigned int j = 1; j < y.size() - 1; ++j) {
             // fnowNext[i][j] = ...
             double hx2=dx*dx;
             double hy2=dy*dy;
             fnext[i][j] = dt*dt*(((vel2[i+1][j]-vel2[i-1][j])*(fnow[i+1][j]-fnow[i-1][j]))/(4.0*hx2)
             + ((vel2[i][j+1]-vel2[i][j-1])*(fnow[i][j+1]-fnow[i][j-1]))/(4.0*hy2)+ 
             vel2[i][j]*((fnow[i+1][j]-2.0*fnow[i][j]+fnow[i-1][j])/(hx2)+(fnow[i][j+1]-2.0*fnow[i][j]+fnow[i][j-1])/(hy2))) 
             +2.0*fnow[i][j]-fpast[i][j];
        }
    }

    // add boundary conditions
    if (lance)
    {
    	if (time<=((2.*PI)/omega) )
    	{
    		string aha= "harmonique";
    		boundary_condition(fnext, fnow, A, omega, time, dt, vel2, aha, bc_r,bc_h, bc_b, x,y);
    	}else{
    		string aha="fixe";
    		boundary_condition(fnext, fnow, A, omega, time, dt, vel2, aha, bc_r,bc_h, bc_b, x,y);
    	}
    }else{
    	boundary_condition(fnext, fnow, A, omega, time, dt, vel2, bc_l, bc_r,bc_h, bc_b, x,y);
	}	
    // Mise a jour :
    std::swap(fpast, fnow);
      std::swap(fnow, fnext);

  }
  
	  

  
  fichier_E << time << " " << energie(fnow,dx,dy) << endl;
  
  fichier_E.close();

  return 0;
}

#include "ConfigFile.tpp"
#include <chrono>
#include <cmath>
#include <complex> // Pour les nombres complexes
#include <fstream>
#include <iomanip>
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>

using namespace std;
typedef vector<complex<double>> vec_cmplx;

// Fonction resolvant le systeme d'equations A * solution = rhs
// où A est une matrice tridiagonale
template<class T>
void
triangular_solve(vector<T> const& diag,
                 vector<T> const& lower,
                 vector<T> const& upper,
                 vector<T> const& rhs,
                 vector<T>& solution)
{
    vector<T> new_diag = diag;
    vector<T> new_rhs = rhs;

    // forward elimination
    for (int i(1); i < diag.size(); ++i) {
        T pivot = lower[i - 1] / new_diag[i - 1];
        new_diag[i] -= pivot * upper[i - 1];
        new_rhs[i] -= pivot * new_rhs[i - 1];
    }

    solution.resize(diag.size());

    // solve last equation
    solution[diag.size() - 1] = new_rhs[diag.size() - 1] / new_diag[diag.size() - 1];

    // backward substitution
    for (int i = diag.size() - 2; i >= 0; --i) {
        solution[i] = (new_rhs[i] - upper[i] * solution[i + 1]) / new_diag[i];
    }
}
//la détection:
void ladetection(vec_cmplx & psi,const vector<double>& x){
    double xda(0);
    double xdb(x.back());
    size_t zero_x;
    bool test=true;
    for (size_t i = 0; i < x.size(); ++i)
    {
        if (x[i]>=0 && test)
        {
            test=false;
            zero_x=i;
        }
    }
    vector<double> psi_norm(psi.size());
    for (int i = 0; i < psi.size(); ++i)
    {
        psi_norm[i]=abs(psi[i]);
    }
    double & ldb=psi_norm[zero_x];
    double max=*max_element(&(ldb), &psi_norm.back());
    test=true;
    for (int i = 0; i < psi.size(); ++i)
    {
        if (psi_norm[i]>max/sqrt(2)&&test)
        {
            xda=x[i];
        }
        if (psi_norm[i]<max/sqrt(2)&& not(test))
        {
            xdb=x[i];
        }
    }
    for (int i = 0; i < x.size(); ++i)
    {
        if (x[i]<0)
        {
            psi[i]*=0.;
        }
        if (x[i]>=0 && xda>x[i])
        {
            psi[i]*=pow(sin(M_PI*x[i]/(2.*xda)),2);
        }
        if (x[i]>=xdb && x.back()>x[i])
        {
            psi[i]*=pow(cos(M_PI*(x[i]-xdb)/(2.*(x.back()-xdb))),2);
        }
    }
}


// Potentiel V(x) :
double
V(double const& x, double const& m, double const& delta, double const& w1, double const& w2, string const& lecas)
{
// TODO: Initialiser le potentiel   
    double bornes=149.;
    double bornesint=2;
    if(lecas == "cas1"){
       double V1(0.5*m*w1*w1*pow((x+delta),2));
       double V2(0.5*m*w2*w2*pow((x-delta),2));
       return min(V1,V2);
    }
    if (lecas=="cas2")
    {
       if (x<-bornes or x>bornes)
       {
           return 2;
       }
       if ((x>=-bornes and x<=-bornesint) or(x<=bornes and x>=bornesint))
       {
           return 0;
       }else{
        return 0.22222;
       }
    }
    if (lecas=="cas3")
    {
        double V1(0.5*m*w1*w1*pow((x+delta),2));
       double V2(0.5*m*w2*w2*pow((x-delta),2));
       
        
       if ((x<=-bornesint) or(x>=bornesint))
       {
           return min(V1,V2);
       }else{
        return 0.22222;
       }
    }
    if (lecas=="cas4")
    {
        if (x<-bornes or x>bornes)
       {
           return 2;
       }
      else{
        return 0.;
       }
    }
    return 1;
}

// Declaration des diagnostiques de la particule d'apres sa fonction d'onde psi :
//  - prob: calcule la probabilite de trouver la particule entre les points de maillage nL et nR,
//  - E:    calcule son energie,
//  - xmoy: calcule sa position moyenne,
//  - x2moy:calcule sa position au carre moyenne,
//  - pmoy: calcule sa quantite de mouvement moyenne,
//  - p2moy:calcule sa quantite de mouvement au carre moyenne.
double
prob(vec_cmplx const& psi, int nL, int nR, double dx);
double
E(vec_cmplx const& psi,
  vec_cmplx const& diagH,
  vec_cmplx const& lowerH,
  vec_cmplx const& upperH,
  double const& dx);
double
xmoy(vec_cmplx const& psi, const vector<double>& x, double const& dx);
double
x2moy(vec_cmplx const& psi, const vector<double>& x, double const& dx);
double
pmoy(vec_cmplx const& psi, double const& dx, double const& hbar);
double
p2moy(vec_cmplx const& psi, double const& dx, double const& hbar);

// Fonction pour normaliser une fonction d'onde :
vec_cmplx
normalize(vec_cmplx const& psi, double const& dx);

// Les definitions de ces fonctions sont en dessous du main.

int
main(int argc, char** argv)
{
    complex<double> complex_i = complex<double>(0, 1); // Nombre imaginaire i

    string inputPath("configuration_supp1.in"); // Fichier d'input par defaut
    if (argc > 1) // Fichier d'input specifie par l'utilisateur ("./Exercice8 config_perso.in")
        inputPath = argv[1];

    ConfigFile configFile(
      inputPath); // Les parametres sont lus et stockes dans une "map" de strings.

    for (int i(2); i < argc;
         ++i) // Input complementaires ("./Exercice8 config_perso.in input_scan=[valeur]")
        configFile.process(argv[i]);

    // Set verbosity level. Set to 0 to reduce printouts in console.
    const int verbose = configFile.get<int>("verbose");
    configFile.setVerbosity(verbose);

    // Parametres physiques :
    double hbar = 1.;
    double m = 1.;
    double tfin = configFile.get<double>("tfin");
    double tdetect = configFile.get<double>("tdetect");
    double xL = configFile.get<double>("xL");
    double xR = configFile.get<double>("xR");
    // double xda = configFile.get<double>("xda");
    // double xdb = configFile.get<double>("xdb");
    double w1 = configFile.get<double>("w1");
    double w2 = configFile.get<double>("w2");
    double delta = configFile.get<double>("delta");
    string Vcase = configFile.get<string>("V");

    double n  = configFile.get<int>("n"); // Read mode number as integer, convert to double

    // Parametres numeriques :

    int Nsteps = configFile.get<int>("Nsteps");
    int Nintervals = configFile.get<int>("Nintervals");
    int Npoints = Nintervals + 1;
    double dx = (xR - xL) / Nintervals;
    double dt = tfin / Nsteps;

    const auto simulationStart = std::chrono::steady_clock::now();

    // Maillage :
    vector<double> x(Npoints);
    for (int i(0); i < Npoints; ++i)
        // TODO: calculer le maillage
        x[i] = xL+dx*i;

    // Initialisation de la fonction d'onde :
    vec_cmplx psi(Npoints);
  
    // TODO: initialiser le paquet d'onde, equation (4.116) du cours
        double x0 = configFile.get<double>("x0");
        double k0 = n*2.*M_PI/(abs(xR-xL)); //à modifier par l'élève
        double sigma0 = configFile.get<double>("sigma_norm") * (xR - xL);
        for (int i(0); i < Npoints; ++i)
            psi[i] =exp(1i*k0*x[i])*exp(-x[i]*x[i]/(2.*sigma0*sigma0))/sqrt(sqrt(3.1415)*sigma0);

            //psi[i] = exp(1i*k0*x[i])*exp(-(x[i]-x0)*(x[i]-x0)/(2.*sigma0*sigma0));
        // Modifications des valeurs aux bords :
        psi[0] = complex<double>(0., 0.);
        psi[Npoints - 1] = complex<double>(0., 0.);
        // Normalisation :
        psi = normalize(psi, dx);

    // Matrices (d: diagonale, a: sous-diagonale, c: sur-diagonale) :
    vec_cmplx dH(Npoints), aH(Nintervals), cH(Nintervals); // matrice Hamiltonienne
    vec_cmplx dA(Npoints), aA(Nintervals),
      cA(Nintervals); // matrice du membre de gauche de l'equation (4.100)
    vec_cmplx dB(Npoints), aB(Nintervals),
      cB(Nintervals); // matrice du membre de droite de l'equation (4.100)

  complex<double> a = 1i*hbar*dt/(4*m*dx*dx);; // Coefficient complexe a de l'equation (4.100), à modifier par l'élève
    
    for (int i(0); i < Npoints; ++i) // Boucle sur les points de maillage
    {
        complex<double> b = 1i*dt*V(x[i],m,delta,w1,w2,Vcase)/(hbar*2);; // Coefficient complexe b de l'equation (4.100), à modifier par l'élève
    // TODO: éléments de matrices diagonales
        dH[i] = pow(hbar,2)/(m*dx*dx)+V(x[i],m,delta,w1,w2,Vcase);
        dA[i] = 1.+2.*a+b;
        dB[i] = 1.-2.*a-b;
    }
    for (int i(0); i < Nintervals; ++i) // Boucle sur les intervalles
    {
    // TOTO: éléments de matrices sous- et sur- diagonales
        aH[i] = -pow(hbar,2)/(2*m*dx*dx);
        cH[i] = -pow(hbar,2)/(2*m*dx*dx);
        aA[i] = -a;
        cA[i] = -a;
        aB[i] = a;
        cB[i] = a;
    }

    // Conditions aux limites: psi nulle aux deux bords
    // TODO: Modifier les matrices A et B pour satisfaire les conditions aux limites
    dA[0] = 1.0;
    dA[Npoints-1]=1.0;
    dB[0]=1.0;
    dB[Npoints-1]=1.0;
    aA[0]=0.0;
    aB[0]=0.0;
    aA[Nintervals-1]=0.0;
    aB[Nintervals-1]=0.0;
    cA[0]=0.0;
    cB[0]=0.0;
    cA[Nintervals-1]=0.0;
    cB[Nintervals-1]=0.0;
    // Fichiers de sortie :
    string output = configFile.get<string>("output_supp");

    ofstream fichier_potentiel((output + "_pot.out").c_str());
    fichier_potentiel.precision(15);
    for (int i(0); i < Npoints; ++i)
        fichier_potentiel << x[i] << " " << V(x[i], m, delta, w1, w2,Vcase) << endl;
    fichier_potentiel.close();

    ofstream fichier_psi((output + "_psi2.out").c_str());
    fichier_psi.precision(15);

    ofstream fichier_observables((output + "_obs.out").c_str());
    fichier_observables.precision(15);

    // Boucle temporelle :
    double t = 0;
    bool tdetect_test=true;
    
    //TODO: intersection des deux paraboles (x=x_c)
    double x_local_max = -delta*(w1-w2)/(w1+w2); 
    cout << "xlocal = " << x_local_max << endl;
    // TODO: Nombre d'intervalles entre xL et x_local_max (x=x_c)
    unsigned int Nx0 = (abs(xL-x_local_max))/dx;
    cout << "Nx0 = " << Nx0 << endl;

    cout << "V(xc)= " << V(x_local_max, m, delta, w1, w2,Vcase) << endl;
    
    for (int nt = 0.; nt <= Nsteps; nt += 1) {
        // Ecriture de |psi|^2 and phase information
        for (int i(0); i < Npoints; ++i){
            fichier_psi << norm(psi[i])
                     << " " 
                     << real(psi[i]) 
                     << " " 
                     << imag(psi[i]) << " ";
                     }
            fichier_psi << endl;

        // Ecriture des observables :
        fichier_observables << t << " " 
                     << prob(psi, 0, Nx0+1, dx)
                            << " " // probabilite que la particule soit en x < x0
                            << prob(psi, Nx0, Npoints, dx)
                            << " " // probabilite que la particule soit en x >= x0
                            << E(psi, dH, aH, cH, dx) << " " // Energie
                            << xmoy (psi, x,  dx) << " "       // Position moyenne
                            << x2moy(psi, x,  dx) << " "      // Position^2 moyenne
                            << pmoy (psi, dx, hbar) << " "    // Quantite de mouvement moyenne
                            << p2moy(psi, dx, hbar) << " " 
                            << sqrt(abs(x2moy(psi, x,  dx)-xmoy(psi, x,  dx)*xmoy(psi, x,  dx))) << " "
                            << sqrt(abs(p2moy(psi, dx, hbar)-pmoy(psi, dx, hbar)*pmoy(psi, dx, hbar))) << endl; // (Quantite de mouvement)^2 moyenne
        // Only do writing of data on the last step
       if (nt < Nsteps) {
            // Calcul du membre de droite :
            vec_cmplx psi_tmp(Npoints, 0.);
            for (int i = 1; i < Npoints-1; ++i)
            {
                psi_tmp[i] += psi[i]*dB[i]+psi[i-1]*aB[i-1]+psi[i+1]*cB[i];
            }
            psi_tmp[0]+=dB[0]*psi[0]+psi[1]*cB[0];
            psi_tmp[Npoints-1]+=dB.back()*psi.back()+psi[Npoints-2]*aB.back();
              
            // TODO: Programmer l'algorithme semi-implicite
            triangular_solve(dA,aA,cA,psi_tmp,psi);
            if (tdetect-t < 0. && tdetect_test)
            {
                tdetect_test=false;
                ladetection(psi,x);
                psi = normalize(psi,dx);
                cout<< "je detecte" << endl;
            }
            t += dt;
        }
    } // Fin de la boucle temporelle
    fichier_observables.close();
    fichier_psi.close();

    const auto simulationEnd = std::chrono::steady_clock::now();
    const std::chrono::duration<double> elapsedSeconds = simulationEnd - simulationStart;
    std::cout << "Simulation finished in " << setprecision(3) << elapsedSeconds.count()
              << " seconds" << std::endl;
}

double
prob(vec_cmplx const& psi, int nL, int nR, double dx)
{
    // TODO: calculer la probabilite de trouver la particule entre les points nL et nR
    double resultat(0.);
     vec_cmplx psi_tmp=normalize(psi,dx);
    for (int i = nL; i <nR-1; ++i)
    {
        resultat+=(norm(psi_tmp[i+1])+norm(psi_tmp[i]))*dx/2.;
    }
    return resultat;
}

double
E(vec_cmplx const& psi,
  vec_cmplx const& dH,
  vec_cmplx const& lH,
  vec_cmplx const& uH,
  double const& dx)
{   
    // TODO: calcul de l’énergie de la particule, moyenne de l’Hamiltonien
    vec_cmplx psi_tmp(psi.size(), 0.);
    double resultat(0.);
    size_t Npoints=psi.size();
    // TODO: calculer H(psi)*psi
    for (int i = 1; i <Npoints-1 ; ++i)
    {
        psi_tmp[i]=lH[i-1]*psi[i-1]+psi[i]*dH[i]+uH[i]*psi[i+1];
    }
    psi_tmp[0]+=dH[0]*psi[0]+psi[1]*uH[0];
    psi_tmp[Npoints-1]+=dH.back()*psi.back()+psi[Npoints-2]*lH.back();
    for (int i = 0; i < psi.size()-1; ++i)
    {
        resultat+=real(dx/2.*(conj(psi[i])*psi_tmp[i]+conj(psi[i+1])*psi_tmp[i+1]));
    }
    
    
    // TODO: calculer Integrale de conj(psi)* H(psi)*psi dx
    
    return resultat;
}

double
xmoy(vec_cmplx const& psi, const vector<double>& x, double const& dx)
{
    // TODO: calcul de la position moyenne de la particule <x>
    double resultat(0.);
    for (int i = 0; i <psi.size()-1; ++i)
    {
        resultat+=(norm(psi[i+1])*x[i+1]+norm(psi[i])*x[i])*dx/2.;
    }
    return resultat;
}

double
x2moy(vec_cmplx const& psi, const vector<double>& x, double const& dx)
{
    // TODO: calcul de la x^2 moyenne de la particule <x^2>
    double resultat(0.);
    for (int i = 0; i <psi.size()-1; ++i)
    {
        resultat+=(norm(psi[i+1])*x[i+1]*x[i+1]+norm(psi[i])*x[i]*x[i])*dx/2.;
    }
    return resultat;
}

double
pmoy(vec_cmplx const& psi, double const& dx, double const& hbar)
{
    // TODO: calcul de la quantité de mouvement moyenne de la particule <p>
    double resultat(0.);
    vec_cmplx psi_tmp(psi.size(), 0.);
    for (int i = 1; i <psi.size()-1; ++i)
    {
        psi_tmp[i]=((-psi[i+1]+psi[i-1])*1i*conj(psi[i]))*hbar/2.;
    } 
    psi_tmp[0]=((psi[0]-psi[1])*1i*conj(psi[0]))*hbar;psi_tmp.back()=((+psi[psi.size()-2]-psi.back())*1i*conj(psi.back()))*hbar;
    for (int i = 0; i < psi_tmp.size()-1; ++i)
    {
        resultat+=real(psi_tmp[i+1]+psi_tmp[i])/2.;
    }
    return resultat;
}

double
p2moy(vec_cmplx const& psi, double const& dx, double const& hbar)
{
    // TODO: calcul de la p^2 moyenne de la particule <p^2>
    double resultat(0.);
    vec_cmplx psi_tmp(psi.size(), 0.);
    for (int i = 1; i <psi.size()-1; ++i)
    {
        psi_tmp[i]=((-psi[i+1]+2.*psi[i]-psi[i-1])*conj(psi[i]))*hbar*hbar/dx;
    }
    // psi_tmp[0]=psi_tmp[1];psi_tmp.back()=psi_tmp[psi.size()-2];
    for (int i = 0; i < psi_tmp.size()-1; ++i)
    {
        resultat+=real(psi_tmp[i+1]+psi_tmp[i])/2.;
    }
    return resultat;
}

vec_cmplx
normalize(vec_cmplx const& psi, double const& dx)
{
    // TODO: Normalisation de la fonction d'onde initiale psi
    double lanorme(0.);
    for (int i = 0; i < psi.size()-1; ++i)
    {
        lanorme+=(norm(psi[i])+norm(psi[i+1]))*dx/2.;
    }
    vec_cmplx psi_norm(psi.size(), 0.);
    for (int i = 0; i < psi.size(); ++i)
    {
        psi_norm[i]=psi[i]/sqrt(lanorme);
    }

    return psi_norm;
}

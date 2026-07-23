#include <cmath>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include "ConfigFile.tpp"


using namespace std;

// Résolution d'un système d'équations linéaires par élimination de
// Gauss-Jordan:
template<class T>
vector<T> solve(const vector<T>& diag,
      const vector<T>& lower,
      const vector<T>& upper,
      const vector<T>& rhs)
{
    vector<T> solution(diag.size());
    vector<T> new_diag(diag);
    vector<T> new_rhs(rhs);

    int diag_size = diag.size();
    for (int i = 1; i < diag_size; ++i) {
        double pivot = lower[i - 1] / new_diag[i - 1];
        new_diag[i] -= pivot * upper[i - 1];
        new_rhs[i] -= pivot * new_rhs[i - 1];
    }

    solution[diag.size() - 1] =
      new_rhs[diag.size() - 1] / new_diag[diag.size() - 1];

    for (int i(diag.size() - 2); i >= 0; --i)
        solution[i] = (new_rhs[i] - upper[i] * solution[i + 1]) / new_diag[i];

    return solution;
}

// TODO: Computation of epsilon relative (vacuum + medium)
double epsilon(double r, 
	double R, 
	double rb, 
	double epsilon_a,
	double epsilon_b,
	double epsilon_R, const int testnumber, bool aha=false)
{   
    if (testnumber==2 and aha)
    {
        return epsilon_a;
    }else if (testnumber==1)
	{
		return epsilon_a;
	}else if (testnumber==2)
	{
		if (r<rb) return epsilon_a;
	else if (r<=R and r>=rb)return epsilon_b+(epsilon_R-epsilon_b)*((r-rb)/(R-rb));
	}
	
	return 0;
	
}

// TODO: Computation of rho_eps=rho_free(r)/eps0

double rho_epsilon(double r,
	double ra,
	double rb,
	double A, double R, int testnumber)
{
	if (testnumber==1)
	{
		return 0.0;
	}else if (testnumber==2)
	{
		if (r<rb and r>=ra) return (4.0*A*(r-ra)*(rb-r))/((rb-ra)*(rb-ra));
    	else if (r<=R and r>=rb)return 0;
	}
	
    return 0;
}

int main(int argc, char* argv[])
{
    // USAGE: Exercise6 [configuration-file] [<settings-to-overwrite> ...]

    // Read the default input
    string inputPath = "configuration_supp.in";
    // Optionally override configuration file.
    if (argc > 1)
        inputPath = argv[1];

    ConfigFile configFile(inputPath);
    // Override settings
    for (int i = 2; i < argc; i++)
        configFile.process(argv[i]);

    // Set verbosity level. Set to 0 to reduce printouts in console.
    const int verbose = configFile.get<int>("verbose");
    configFile.setVerbosity(verbose);

    // Read geometrical inputs
    const double R  = configFile.get<double>("R");
    const double ra = configFile.get<double>("ra");
    const double rb = configFile.get<double>("rb");
    
    // Free charge source
    const double A = configFile.get<double>("A");

    // mixed trapèze point
    const int p = configFile.get<int>("p");

    // geometry of the problem
    const string geom = configFile.get<string>("geom");
    
    // Dielectric relative permittivity
    const double epsilon_a = configFile.get<double>("epsilon_a");
    const double epsilon_b = configFile.get<double>("epsilon_b");
    const double epsilon_R = configFile.get<double>("epsilon_R");
    
    // Boundary conditions
    const double Va = configFile.get<double>("Va");
    const double VR = configFile.get<double>("VR");
    
    // Discretization
    int N1 = configFile.get<int>("N1");
    int N2 = configFile.get<int>("N2");
    const int testnumber = configFile.get<int>("testnumber");
    const int testN = configFile.get<int>("testN");

    if (testN==1)
    {
    	N1=N2;
    }else if (testN==2)
    {
    	N1=N1*N2;
    }
    
    // Fichiers de sortie:
    string fichier = configFile.get<string>("output");
    string fichier_phi = fichier+"_phi.out";
    string fichier_E   = fichier+"_E.out";
    string fichier_D   = fichier+"_D.out";
    string fichier_Ddiv   = fichier+"_Ddiv.out";

    // TODO: Create the finite elements
    const int pointCount = N1 + N2 + 1;
    
    // TODO: Initialize position of elements
    vector<double> r(pointCount);
    int rsize =r.size();
    for (int i = 0; i < rsize; ++i){
       if(i<=N1) r[i] = ra + i*(rb-ra)/N1;
       else r[i]= rb + (i-N1)*(R-rb)/N2;
   }
    
    // TODO: Calculate distance between elements
    vector<double> h(pointCount-1);
    vector<double> midPoint(pointCount-1);
	vector<double> midmidPoint(pointCount-2);
    for (size_t i = 0; i < h.size(); ++i){
        h[i] = r[i+1]-r[i];
        midPoint[i] = (r[i]+r[i+1])/2;
    }
    
    for (size_t i = 0; i < midmidPoint.size(); ++i)
    {
    	midmidPoint[i]=(midPoint[i]+midPoint[i+1])/2.0;
    }
    
    // TODO: Construct the matrices
    vector<double> diagonal(pointCount, 0.0);  // Diagonal
    vector<double> lower(pointCount - 1, 0.0); // Lower diagonal
    vector<double> upper(pointCount - 1, 0.0); // Upper diagonal
    vector<double> rhs(pointCount, 0.0);       // Right-hand-side
    
    if (geom=="cy")
    {
        
    
    for (int i = 0; i < pointCount -1 ; ++i) { 
        // TODO: Matrix entries

        if(i==0) lower[i] = -h[i]*(p*(1/pow(h[i],2))*((r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                        +r[i+1]*epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                        +(1-p)*(1/pow(h[i],2))*((r[i]+r[i+1])/2)*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));
        else if (i+1< pointCount-2 and r[i+1]==rb )
        {
        	upper[i] = -h[i]*(p*(1/pow(h[i],2))*((r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                +r[i+1]*epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber,true))/2)
                +(1-p)*(1/pow(h[i],2))*((r[i]+r[i+1])/2)*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));
			lower[i] = upper[i];
			diagonal[i] = h[i-1]*(p*(1/pow(h[i-1],2))*((r[i-1]*epsilon(r[i-1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                            +(1-p)*(1/pow(h[i-1],2))*((r[i-1]+r[i])/2)*epsilon((r[i-1]+r[i])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))
                            +h[i]*(p*(1/pow(h[i],2))*((r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +r[i+1]*epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber,true))/2)
                            +(1-p)*(1/pow(h[i],2))*((r[i]+r[i+1])/2)*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));

        rhs[i] = p*(((h[i]+h[i-1])/2.0)*rho_epsilon(r[i],ra,rb,A,R,testnumber)*r[i])
                +(1-p)*(rho_epsilon(midPoint[i],ra,rb,A,R,testnumber)*midPoint[i])*(h[i]+h[i-1])/2.;
        }else if (r[i]==rb)
        {
        	upper[i] = -h[i]*(p*(1/pow(h[i],2))*((r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                        +r[i+1]*epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                        +(1-p)*(1/pow(h[i],2))*((r[i]+r[i+1])/2)*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));
			lower[i] = upper[i];
			diagonal[i] = h[i-1]*(p*(1/pow(h[i-1],2))*((r[i-1]*epsilon(r[i-1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber,true))/2)
                            +(1-p)*(1/pow(h[i-1],2))*((r[i-1]+r[i])/2)*epsilon((r[i-1]+r[i])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))
                            +h[i]*(p*(1/pow(h[i],2))*((r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +r[i+1]*epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                            +(1-p)*(1/pow(h[i],2))*((r[i]+r[i+1])/2)*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));

        rhs[i] = p*(((h[i]+h[i-1])/2.0)*rho_epsilon(r[i],ra,rb,A,R,testnumber)*r[i])
                +(1-p)*(rho_epsilon(midPoint[i],ra,rb,A,R,testnumber)*midPoint[i])*(h[i]+h[i-1])/2.;
	    
        }else{
        	
			upper[i] = -h[i]*(p*(1/pow(h[i],2))*((r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                        +r[i+1]*epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                        +(1-p)*(1/pow(h[i],2))*((r[i]+r[i+1])/2)*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));
			lower[i] = upper[i];
			diagonal[i] = h[i-1]*(p*(1/pow(h[i-1],2))*((r[i-1]*epsilon(r[i-1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                            +(1-p)*(1/pow(h[i-1],2))*((r[i-1]+r[i])/2)*epsilon((r[i-1]+r[i])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))
                            +h[i]*(p*(1/pow(h[i],2))*((r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +r[i+1]*epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                            +(1-p)*(1/pow(h[i],2))*((r[i]+r[i+1])/2)*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));

        rhs[i] = p*(((h[i]+h[i-1])/2.0)*rho_epsilon(r[i],ra,rb,A,R,testnumber)*r[i])
                +(1-p)*(rho_epsilon(midPoint[i],ra,rb,A,R,testnumber)*midPoint[i])*(h[i]+h[i-1])/2.;
	    }
    }
    
    }else if (geom == "sp")
    {
         for (int i = 0; i < pointCount -1 ; ++i) { 
        if(i==0) lower[i] = -h[i]*(p*(1/pow(h[i],2))*((r[i]*r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                        +r[i+1]*r[i+1]*epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                        +(1-p)*(1/pow(h[i],2))*((r[i]+r[i+1])*(r[i]+r[i+1])/2)*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));
        else if (i+1< pointCount-2 and r[i+1]==rb )
        {
            upper[i] = -h[i]*(p*(1/pow(h[i],2))*((r[i]*r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                +r[i+1]*r[i+1]*epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber,true))/2)
                +(1-p)*(1/pow(h[i],2))*((r[i]+r[i+1])*(r[i]+r[i+1])/2)*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));
            lower[i] = upper[i];
            diagonal[i] = h[i-1]*(p*(1/pow(h[i-1],2))*((r[i-1]*r[i-1]*epsilon(r[i-1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +r[i]*r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                            +(1-p)*(1/pow(h[i-1],2))*((r[i-1]+r[i])*(r[i-1]+r[i])/2)*epsilon((r[i-1]+r[i])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))
                            +h[i]*(p*(1/pow(h[i],2))*((r[i]*r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +r[i+1]*r[i+1]*epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber,true))/2)
                            +(1-p)*(1/pow(h[i],2))*((r[i]+r[i+1])*(r[i]+r[i+1])/2)*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));

        rhs[i] = p*(((h[i]+h[i-1])/2.0)*rho_epsilon(r[i],ra,rb,A,R,testnumber)*r[i]*r[i])
                +(1-p)*(rho_epsilon(midPoint[i],ra,rb,A,R,testnumber)*midPoint[i]*midPoint[i])*(h[i]+h[i-1])/2.;
        }else if (r[i]==rb)
        {
            upper[i] = -h[i]*(p*(1/pow(h[i],2))*((r[i]*r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                +r[i+1]*r[i+1]*epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                +(1-p)*(1/pow(h[i],2))*((r[i]+r[i+1])*(r[i]+r[i+1])/2)*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));
            lower[i] = upper[i];
            diagonal[i] = h[i-1]*(p*(1/pow(h[i-1],2))*((r[i-1]*r[i-1]*epsilon(r[i-1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +r[i]*r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber,true))/2)
                            +(1-p)*(1/pow(h[i-1],2))*((r[i-1]+r[i])*(r[i-1]+r[i])/2)*epsilon((r[i-1]+r[i])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))
                            +h[i]*(p*(1/pow(h[i],2))*((r[i]*r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +r[i+1]*r[i+1]*epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                            +(1-p)*(1/pow(h[i],2))*((r[i]+r[i+1])*(r[i]+r[i+1])/2)*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));

        rhs[i] = p*(((h[i]+h[i-1])/2.0)*rho_epsilon(r[i],ra,rb,A,R,testnumber)*r[i]*r[i])
                +(1-p)*(rho_epsilon(midPoint[i],ra,rb,A,R,testnumber)*midPoint[i]*midPoint[i])*(h[i]+h[i-1])/2.;

        }else{
            
            upper[i] = -h[i]*(p*(1/pow(h[i],2))*((r[i]*r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                +r[i+1]*r[i+1]*epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                +(1-p)*(1/pow(h[i],2))*((r[i]+r[i+1])*(r[i]+r[i+1])/2)*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));
            lower[i] = upper[i];
            diagonal[i] = h[i-1]*(p*(1/pow(h[i-1],2))*((r[i-1]*r[i-1]*epsilon(r[i-1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +r[i]*r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                            +(1-p)*(1/pow(h[i-1],2))*((r[i-1]+r[i])*(r[i-1]+r[i])/2)*epsilon((r[i-1]+r[i])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))
                            +h[i]*(p*(1/pow(h[i],2))*((r[i]*r[i]*epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +r[i+1]*r[i+1]*epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                            +(1-p)*(1/pow(h[i],2))*((r[i]+r[i+1])*(r[i]+r[i+1])/2)*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));

        rhs[i] = p*(((h[i]+h[i-1])/2.0)*rho_epsilon(r[i],ra,rb,A,R,testnumber)*r[i]*r[i])
                +(1-p)*(rho_epsilon(midPoint[i],ra,rb,A,R,testnumber)*midPoint[i]*midPoint[i])*(h[i]+h[i-1])/2.;
        }
    }
        
    }else if (geom == "ca")
    {
         for (int i = 0; i < pointCount -1 ; ++i) { 
        if(i==0) lower[i] = -h[i]*(p*(1/pow(h[i],2))*((epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                        +epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                        +(1-p)*(1/pow(h[i],2))*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));
        else if (i+1< pointCount-2 and r[i+1]==rb )
        {
            upper[i] = -h[i]*(p*(1/pow(h[i],2))*((epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                +epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber,true))/2)
                +(1-p)*(1/pow(h[i],2))*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));
            lower[i] = upper[i];
            diagonal[i] = h[i-1]*(p*(1/pow(h[i-1],2))*((epsilon(r[i-1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                            +(1-p)*(1/pow(h[i-1],2))*epsilon((r[i-1]+r[i])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))
                            +h[i]*(p*(1/pow(h[i],2))*((epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber,true))/2)
                            +(1-p)*(1/pow(h[i],2))*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));

        rhs[i] = p*(((h[i]+h[i-1])/2.0)*rho_epsilon(r[i],ra,rb,A,R,testnumber))
                +(1-p)*(rho_epsilon(midPoint[i],ra,rb,A,R,testnumber))*(h[i]+h[i-1])/2.;
        }else if (r[i]==rb)
        {
            upper[i] = -h[i]*(p*(1/pow(h[i],2))*((epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                +epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                +(1-p)*(1/pow(h[i],2))*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));
            lower[i] = upper[i];
            diagonal[i] = h[i-1]*(p*(1/pow(h[i-1],2))*((epsilon(r[i-1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber,true))/2)
                            +(1-p)*(1/pow(h[i-1],2))*epsilon((r[i-1]+r[i])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))
                            +h[i]*(p*(1/pow(h[i],2))*((epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                            +(1-p)*(1/pow(h[i],2))*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));

        rhs[i] = p*(((h[i]+h[i-1])/2.0)*rho_epsilon(r[i],ra,rb,A,R,testnumber))
                +(1-p)*(rho_epsilon(midPoint[i],ra,rb,A,R,testnumber))*(h[i]+h[i-1])/2.;
        
        }else{
            
            upper[i] = -h[i]*(p*(1/pow(h[i],2))*((epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                +epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                +(1-p)*(1/pow(h[i],2))*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));
            lower[i] = upper[i];
            diagonal[i] = h[i-1]*(p*(1/pow(h[i-1],2))*((epsilon(r[i-1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                            +(1-p)*(1/pow(h[i-1],2))*epsilon((r[i-1]+r[i])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))
                            +h[i]*(p*(1/pow(h[i],2))*((epsilon(r[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber)
                            +epsilon(r[i+1],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber))/2)
                            +(1-p)*(1/pow(h[i],2))*epsilon((r[i]+r[i+1])/2,R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber));

        rhs[i] = p*(((h[i]+h[i-1])/2.0)*rho_epsilon(r[i],ra,rb,A,R,testnumber))
                +(1-p)*(rho_epsilon(midPoint[i],ra,rb,A,R,testnumber))*(h[i]+h[i-1])/2.;
        }
    }
    }
    // TODO: Set boundary conditions
   diagonal[0]=1.0;
   upper[0]=0.0;
   rhs[0]=Va;
   
   diagonal[pointCount-1]=1.0;
   lower[pointCount-2]=0.0;
   rhs[pointCount-1]=VR;
    
    // Solve the system of equations
    vector<double> phi = solve(diagonal, lower, upper, rhs);
    
    // TODO: Calculate electric field E and displacement vector D
    vector<double> E(pointCount - 1, 0);
    vector<double> D(pointCount - 1, 0);
    vector<double> Ddiv(pointCount - 2, 0);
    //double dphidr=0.0;
    for (size_t i = 0; i < E.size(); ++i) {
        E[i] =  -(phi[i+1]-phi[i])/(h[i]);
        D[i] = E[i]*epsilon(midPoint[i],R,rb,epsilon_a,epsilon_b,epsilon_R,testnumber);  //NB: Normalized D (factor of eps_0)
    }
    if (geom == "cy")
    {
        for (int i = 0; i < Ddiv.size(); ++i)
        {
            Ddiv[i]=(midPoint[i+1]*D[i+1]-midPoint[i]*D[i])/(midmidPoint[i]*(midPoint[i+1]-midPoint[i]));
        }
    }else if (geom=="ca")
    {
        for (int i = 0; i < Ddiv.size(); ++i)
        {
            Ddiv[i]=(D[i+1]-D[i])/((midPoint[i+1]-midPoint[i]));
        }
    }else if (geom=="sp")
    {
        for (int i = 0; i < Ddiv.size(); ++i)
        {
            Ddiv[i]=(midPoint[i+1]*midPoint[i+1]*D[i+1]-midPoint[i]*midPoint[i]*D[i])/(midmidPoint[i]*midmidPoint[i]*(midPoint[i+1]-midPoint[i]));
        }
    }
    
    
    // Export data
    {
        // Electric potential phi
        ofstream ofs(fichier_phi);
        ofs.precision(15);

        if (r.size() != phi.size())
            throw std::runtime_error("error when writing potential: r and "
                                     "phi does not have size");

        for (size_t i = 0; i < phi.size(); ++i) {
            ofs << r[i] << " " << phi[i] << endl;
        }
    }
    
    {
        // Electric field E
        ofstream ofs(fichier_E);
        ofs.precision(15);

        if (r.size() != (E.size() + 1))
            throw std::runtime_error("error when writing electric field: size of "
                                     "E should be 1 less than r");

        for (size_t i = 0; i < E.size(); ++i) {
            ofs << midPoint[i] << " " << E[i] << endl;
        }
    }
    {
        // Displacement field D
        ofstream ofs(fichier_D);
        ofs.precision(15);

        if (E.size() != D.size())
            throw std::runtime_error("error when writing displacement field: size of "
                                     "D should be equal than E");

        for (size_t i = 0; i < D.size(); ++i) {
            ofs << midPoint[i] << " " << D[i] << endl;
        }
    }
    
    {
        // Displacement field Ddiv
        ofstream ofs(fichier_Ddiv);
        ofs.precision(15);

        if (midmidPoint.size() != Ddiv.size())
            throw std::runtime_error("error when writing displacement field: size of "
                                     "Ddiv should be equal than midmidPoint");

        for (size_t i = 0; i < Ddiv.size(); ++i) {
            ofs << midmidPoint[i] << " " << Ddiv[i] << " " << rho_epsilon(midmidPoint[i],ra,rb,A,R,testnumber) <<endl;
            
        }
    }

    return 0;
}


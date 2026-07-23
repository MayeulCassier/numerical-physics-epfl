repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice3_2022_student.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input      = 'configuration4.in'; % Nom du fichier d'entrée 
g= 9.81;
L= 0.2;
pi=3.1415926535897932384626433832795028841971e0;
t1=3*pi/8;

t3=7*pi/8;


Omega= 7.00357051796;
% NE PAS OUBLIER DE METTRE n=0 et N=50 et thetadot = 0 et et sampling=1
%nsteps = [1000 1500 2000 3000 5000 10000];
nsteps = round(linspace(100, 5000, 300));
theta0=[t1 t3]; 
%theta0 = [1.0e-2 pi/6-1.0e-2];


tfin = N*2*pi/Omega;
dt= 2*pi./(Omega.*nsteps);
ndt = numel(dt); % Nombre de simulations a faire:

ntheta = numel(theta0);


% numel est une fonction Matlab qui retourne le nombre d'elements d'un tableau.
paramstr2 = 'dt'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param2 = dt; 
paramstr1 = 'theta0';
param1=theta0;
N=50;


fl =16;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
%% Simulations %% 
%%%%%%%%%%%%%%%%%
% Lance une serie de simulations (= executions du code C++)
% Normalement, on ne devrait pas avoir besoin de modifier cette partie
close all;
output = cell(ndt , ntheta); % Tableau de cellules contenant les noms des fichiers de sortie
for j = 1:ntheta
   for i = 1:ndt
       
        output{j}{i} = [paramstr1, '=', num2str(param1(j), 15), paramstr2, '=', num2str(param2(i),15), '.out'];
    % Execution du programme en lui envoyant la valeur a scanner en argument
        cmd = sprintf('%s%s %s %s=%0.15g %s=%0.15g output=%s', repertoire, executable, input, paramstr1, param1(j), paramstr2, param2(i), output{j}{i});
        disp(cmd)
        system(cmd);
        disp('Done.')
   end
end

%% Analyse %%
%%%%%%%%%%%%%
% Ici, on aimerait faire une etude de convergence: erreur fonction de dt, sur diagramme log-log.
% A MODIFIER ET COMPLETER SELON VOS BESOINS
close all;
lw=1.0; fs=16;
%radius of the trajectory [m]
for j= 1:ntheta  
    error            = zeros(1,ndt);
    errortheta            = zeros(1,ndt);
    theta_end_vector = zeros(1,ndt);
    max_Emec         = zeros(1,ndt);
    for i = 1:ndt % Parcours des resultats de toutes les simulations
        data  = load(output{j}{i});
        t           = data(end,1); % the index (i.e. 1,2,4.. ) can change according to how you save data in the c++ code
        tv=data(:,1);
        theta       = data(end,2);
        thetav=data(:,2);
        thetadot    = data(end,3);
        thetadotv    = data(:,3);
        E = data(:,4);
        max_Emec(i) = max(data(:,4));
        Pnc=data(1:length(tv)-2,5);
        % TODO:  inserer ici les expressions de la solution exacte  
        omega0        = 0.0;
        theta_ana     = 10^(-6)*cos(w0*tfin);
        %errortheta(i) = sqrt((theta-theta_ana).^2);
        theta_dot_ana = 0.0;
        error(i)      =  sqrt((theta-theta_ana).^2+(thetadot-theta_dot_ana).^2 );
        theta_end_vector(i) = theta;
    end
    figure
    p=polyfit(dt.^2,theta_end_vector,1);
    f=polyval(p,dt.^2);
    plot(dt.^2, theta_end_vector, 'black+', 'Linewidth', lw);
    hold on
    plot(dt.^2,f, '--', 'linewidth', lw)
    set(gca,'fontsize',fs)
    xlabel('$\Delta t^2$ [s$^2$]')
    ylabel('$\theta_{fin}$ [rad]')
    if p(2)>0
            fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p(1),p(2));
    else 
            fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p(1),p(2));
    end
    legend({"simulations pour: $\theta_0$="+theta0(j), fit},'Location','northwest');
    grid on 


    figure
     for i = 1:ndt % Parcours des resultats de toutes les simulations
        data  = load(output{j}{i});
        tv=data(:,1);
        thetav=data(:,2);
        thetadotv    = data(:,3);
        E = data(:,4);
        max_Emec(i) = max(data(:,4));
        Pnc=data(1:length(tv)-2,5);
        plot (tv, thetav, 'Linewidth', lw);
        hold on
     end
    set(gca,'fontsize',fs)
    xlabel('$t$ [s]')
    ylabel('$\theta$ [rad]')
    grid on
    legend({""+nsteps(1), ""+nsteps(2), ""+nsteps(3), ""+nsteps(4), ""+nsteps(5), ""+nsteps(6)},'Location','northwest');
    title(legend, "$N_{steps}$");
    hold off
end

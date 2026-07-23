repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice3_2022_student.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input      = 'configuration3.in'; % Nom du fichier d'entrée 
g= 9.81;
L= 0.2;
close all;

d = [0.05 0.0];
%nsteps = linspace(100, 10000, 300); 14.0071410359
 %Verifier que la valeur de tfin est EXACTEMENT la meme que dans le fichier input
N=40;
n=250;
Omega= 50;
tfin = N*2*pi/Omega;
dt= 2*pi/(Omega.*n);
paramstr = 'd'; 
param = d;  

fl =40;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
nsimul = numel(param); % Nombre de simulations a faire:

%% Simulations %% 
%%%%%%%%%%%%%%%%%
% Lance une serie de simulations (= executions du code C++)

output = cell(1, nsimul); % Tableau de cellules contenant les noms des fichiers de sortie
for i = 1:nsimul
    output{i} = [paramstr, '=', num2str(param(i)), '.out'];
    % Execution du programme en lui envoyant la valeur a scanner en argument
    cmd = sprintf('%s%s %s %s=%.15g output=%s', repertoire, executable, input, paramstr, param(i), output{i});
    disp(cmd)
    system(cmd);
    disp('Done.')
end

%% Analyse %%
%%%%%%%%%%%%%
% Ici, on aimerait faire une etude de convergence: erreur fonction de dt, sur diagramme log-log.
% A MODIFIER ET COMPLETER SELON VOS BESOINS
close all;
lw=1.5; fs=16;
error            = zeros(1,nsimul);
errortheta            = zeros(1,nsimul);
theta_end_vector = zeros(1,nsimul);
max_Emec         = zeros(1,nsimul);
w0=sqrt(g/L);
figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data        = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
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
    theta_ana     = 0.0;
    %errortheta(i) = sqrt((theta-theta_ana).^2);
    theta_dot_ana = 0.0;
    error(i)      =  sqrt((theta-theta_ana).^2+(thetadot-theta_dot_ana).^2 );
    theta_end_vector(i) = theta;
    plot(tv,E, 'LineWidth',lw)
    hold on
end
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$E_{mec}$ [J]')
grid on
title(legend, '$d$')
legend('0.05','0');


figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data        = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
    tv=data(:,1);
    thetav=data(:,2);
    plot(tv,thetav, 'LineWidth',lw)
    hold on
end
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$\theta$ [rad]')
grid on
title(legend, '$d$')
legend('0.05','0');
figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data        = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
    tv=data(:,1);
    thetadotv    = data(:,3);
    plot(tv,thetadotv, 'LineWidth',lw)
    hold on
end
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$\dot{\theta}$ [rad/s]')
grid on
title(legend, '$d$')
legend('0.05','0');
figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data        = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
    thetav=data(:,2);
    thetadotv    = data(:,3);
    plot(thetav,thetadotv, 'LineWidth',lw)
    hold on
end
set(gca,'fontsize',fs)
xlabel('$\theta$ [rad]')
ylabel('$\dot{\theta}$ [rad/s]')
grid on
title(legend, '$d$')
legend('0.05','0');
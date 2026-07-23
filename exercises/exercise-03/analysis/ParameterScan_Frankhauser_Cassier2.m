repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice3_2022_student.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input      = 'configuration2.in'; % Nom du fichier d'entrée 
g= 9.81;
L= 0.2;
close all;

nsteps = [1000 1500 2000 3000 5000 10000];
%nsteps = round(linspace(100, 10000, 300));
tfin = 17.9428; %Verifier que la valeur de tfin est EXACTEMENT la meme que dans le fichier input
dt = tfin ./ nsteps;
paramstr = 'dt'; 
param = dt;  

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
    theta_ana     = 10^(-6)*cos(w0*tfin);
    %errortheta(i) = sqrt((theta-theta_ana).^2);
    theta_dot_ana = 0.0;
    error(i)      =  sqrt((theta-theta_ana).^2+(thetadot-theta_dot_ana).^2 );
    theta_end_vector(i) = theta;
    
    
end
figure
plot(tv, thetav, 'LineWidth',lw);
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$\theta(t)$ [rad]')
%title(titre);
legend({'10000'},'Location','north');
%legend('1600','3200','6400','12800','25600')
grid on
% set(gca, 'YScale', 'log')
title(legend, 'Nstep');


figure
plot(tv, thetadotv, 'LineWidth',lw);
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$\dot{\theta}(t)$ [rad/s]')
%title(titre);
legend({'10000'},'Location','north');
%legend('1600','3200','6400','12800','25600')
grid on
% set(gca, 'YScale', 'log')
title(legend, 'Nstep');

figure
plot(thetav, thetadotv, 'LineWidth',lw);
set(gca,'fontsize',fs)
xlabel('$\theta(t)$ [rad]')
ylabel('$\dot{\theta}(t)$ [rad/s]')
%title(titre);
legend({'10000'},'Location','north');
%legend('1600','3200','6400','12800','25600')
grid on
% set(gca, 'YScale', 'log')
title(legend, 'Nstep');

figure
plot(tv, E, 'LineWidth',lw);
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$E_{mec}$ [J]')
%title(titre);
legend({'10000'},'Location','north');
%legend('1600','3200','6400','12800','25600')
grid on
% set(gca, 'YScale', 'log')
title(legend, 'Nstep');


figure
p=polyfit(dt.^2,theta_end_vector,1);
f=polyval(p,dt.^2);
plot(dt.^2, theta_end_vector, 'black+', 'Linewidth', lw);
hold on
plot(dt.^2,f, '--', 'linewidth', lw)
set(gca,'fontsize',fs)
xlabel('$\Delta t^2$ [s]')
ylabel('$\theta_{fin}$ [rad]')
if p(2)>0
        fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p(1),p(2));
else 
        fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p(1),p(2));
end
legend({'simulations', fit},'Location','northwest');
grid on 


l=length(tv);
deltaE=zeros(l-2,1);
for i=1:l-2
    deltaE(i)=(-E(i)+E(i+2))/(2*dt(end));
end
figure
plot(tv(1:l-2, 1), deltaE,'r', 'LineWidth',lw);
hold on
plot(tv(1:l-2, 1), Pnc,'blue--', 'LineWidth',lw);
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('d$E_{mec}/$d$t$ \& $P_{NC}$ [J/s]')
%title(titre);
legend({'d$E_{mec}/$d$t$', '$P_{NC}$'},'Location','north');
%legend('1600','3200','6400','12800','25600')
grid on
% set(gca, 'YScale', 'log')
title(legend, 'Nstep = 10000'); 

errorPncEmec=deltaE-Pnc;
figure 
plot(tv(1:l-2, 1), errorPncEmec, 'LineWidth',lw);
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('d$E_{mec}/$d$t-P_{NC}$ [J/s]')
%title(titre);
legend({'10000'},'Location','north');
%legend('1600','3200','6400','12800','25600')
grid on
title(legend, 'Nstep'); 
repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice3_2022_student.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input      = 'configuration.in'; % Nom du fichier d'entrée 
g= 9.81;
L= 0.2;
close all;

%nsteps = [100 150 200 300 500 1000];
nsteps = [1000 1500 2000 3000 5000 10000];
tfin = 10; %Verifier que la valeur de tfin est EXACTEMENT la meme que dans le fichier input
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
figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data        = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
    t           = data(end,1); % the index (i.e. 1,2,4.. ) can change according to how you save data in the c++ code
    tv=data(:,1);
    theta       = data(end,2);
    thetav=data(:,2);
    thetadot    = data(end,3);
    max_Emec(i) = max(data(:,4));
    % TODO:  inserer ici les expressions de la solution exacte  
    omega0        = 0.0;
    theta_ana     = 10^(-6)*cos(w0*tfin);
    errortheta(i) = sqrt((theta-theta_ana).^2);
    theta_dot_ana = 0.0;
    error(i)      =  sqrt((theta-theta_ana).^2+(thetadot-theta_dot_ana).^2 );
    theta_end_vector(i) = theta;
    
    plot(tv, thetav, 'linewidth',lw)
    hold on
end
l=length(tv);
thetana=zeros(l, 1);
for i=1:l
    thetana(i)=10^(-6)*cos(w0*tv(i));
end
plot(tv, thetana,'r--', 'linewidth',lw);
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$\theta$ [rad]')
%title(titre);
legend({'100', '150', '200', '300', '500', '1000', 'Solution analytique'},'Location','north','NumColumns',4);
%legend('1600','3200','6400','12800','25600')
grid on
% set(gca, 'YScale', 'log')
title(legend, 'Nstep');
hold off

thetaverror=thetav-thetana;
figure
plot(tv, thetaverror, 'Linewidth', lw);
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$\theta_{exact}(t) - \theta_{num}(t)$ [rad]')
title(legend, 'Nstep');
legend({'10000'},'Location','northwest');

figure
p=polyfit(log(dt),log(errortheta),1);
f=polyval(p,log(dt));
loglog(dt, errortheta, 'black+', 'linewidth',lw)
hold on
loglog(dt,exp(f), '--', 'linewidth', lw)
set(gca,'fontsize',fs)
xlabel('$\Delta$t [s]')
ylabel('$|\theta_{i}^{exact}-\theta_{i}^{num}|$ [rad]')
if p(2)>0
        fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p(1),p(2));
else 
        fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p(1),p(2));
end
legend({'simulations', fit},'Location','northwest');
grid on 
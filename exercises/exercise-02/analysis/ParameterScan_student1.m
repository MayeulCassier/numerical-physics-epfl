% MODIFIER SELON VOS BESOINS LES NOMS ET LES VALEURS
repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice2_student.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input = 'configuration.in'; % Nom du fichier d'entrée 

nsteps = [1600 3200 6400 12800 25600];
nsimul = numel(nsteps); % Nombre de simulations a faire:
% numel est une fonction Matlab qui retourne le nombre d'elements d'un tableau.

% Autre exemple: 
%nsteps = round(logspace(2,4,nsimul)); % Nombre d'iterations entier de 10^2 a 10^4
% logspace est une fonction Matlab retournant un tableau de valeurs dont les logarithmes sont equidistants
% tapez 'help logspace' pour plus de details
% Voir aussi la fonction 'linspace'

q = 1.6022e-19; %charge of the proton [C]
m = 1.6726e-27; %mass of the proton [kg]
B = 4;          %intensity of the magnetic field [T]
omega = q*B/m;  %cyclotron frequency [rad/s]
v = 5e5;        %proton initial velocity modulus [m/s]
r=v/omega;      %radius of the trajectory [m]
monpi=3.1415926535897932384626433832795028841971e0;
tfin= (2*monpi*5*m)/(q*B);
dt = tfin ./ nsteps;

paramstr = 'nsteps'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param = nsteps;  % Valeurs du parametre a scanner  MODIFIER SELON VOS BESOINS


fl =40;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);

%% Simulations %% 
%%%%%%%%%%%%%%%%%
% Lance une serie de simulations (= executions du code C++)
% Normalement, on ne devrait pas avoir besoin de modifier cette partie

output = cell(1, nsimul); % Tableau de cellules contenant les noms des fichiers de sortie
for i = 1:nsimul
    output{i} = [paramstr, '=', num2str(param(i)), '.out']
    % Execution du programme en lui envoyant la valeur a scanner en argument
    cmd = sprintf('%s%s %s %s=%.15g output=%s', repertoire, executable, input, paramstr, param(i), output{i})
    disp(cmd)
    system(cmd);
    disp('Done.')
end

%% Analyse %%
%%%%%%%%%%%%%
% Ici, on aimerait faire une etude de convergence: erreur fonction de dt, sur diagramme log-log.
% A MODIFIER ET COMPLETER SELON VOS BESOINS

error = zeros(1,nsimul);
error1 = zeros(1,nsimul);
error2 = zeros(1,nsimul);
figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data  = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
    t     = data(:,1); 
    x     = data(:,2);
    y     = data(:,3);
    vx    = data(:,5);
    vy    = data(:,6);
    vxfin = data(end,5);
    vyfin = data(end,6);
    xfin  = data(end,2);
    yfin  = data(end,3);
    E     = data(:, 9);
    %mu    = data(:,10);
% TODO:  inserer ici les expressions de la solution exacte
    x_th  = 0.0; 
    y_th  = 0.0; 
    vx_th = v*sin(2*pi*5); 
    vy_th = v*cos(2*pi*5); 
    
    error(i) = max(abs(vxfin-vx_th),abs(vyfin-vy_th));
    error1(i) = abs(vxfin-vx_th);
    error2(i)=abs(vyfin-vy_th);
end


lw=1.5; fs=16;
figure
p=polyfit(log(dt),log(error),1)
f=polyval(p,log(dt))
loglog(dt, error, 'black+', 'linewidth',lw)
hold on
loglog(dt,exp(f), '--', 'linewidth', lw)
set(gca,'fontsize',fs)
xlabel('$\Delta$t [s]')
ylabel('$\max_{i=x,y} |v_{i}^{exact}-v_{i}^{num}|$ [m]')
if p(2)>0
   fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p(1),p(2));
else 
   fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p(1),p(2));
end
legend('simulation en euler explicite: erreur sur la vitesse finale',fit)
grid on
% set(gca, 'YScale', 'log')
hold off

% Si on n'a pas la solution analytique: on représente la quantite voulue
% (ci-dessous v_y, modifier selon vos besoins)
% en fonction de (Delta t)^norder, ou norder est un entier.

% lw=1.5; fs=16;
% figure
% p1=polyfit(log(dt),log(error1),1)
% f1=polyval(p1,log(dt))
% loglog(dt, error1, 'black+', 'linewidth',lw)
% hold on
% loglog(dt,exp(f1), '--', 'linewidth', lw)
% set(gca,'fontsize',fs)
% xlabel('$\Delta$t [s]')
% ylabel('$\|v_{x}^{exact}-v_{x}^{num}|$ [m]')
% if p1(2)>0
%         fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p1(1),p1(2));
%     else 
%         fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p1(1),p1(2));
%     end
% legend('simulation: erreur sur la vitesse finale en x',fit)
% grid on
% % set(gca, 'YScale', 'log')
% hold off
% 
% lw=1.5; fs=16;
% figure
% p2=polyfit(log(dt),log(error2),1)
% f2=polyval(p2,log(dt))
% loglog(dt, error2, 'black+', 'linewidth',lw)
% hold on
% loglog(dt,exp(f2), '--', 'linewidth', lw)
% set(gca,'fontsize',fs)
% xlabel('$\Delta$t [s]')
% ylabel('$\|v_{y}^{exact}-v_{y}^{num}|$ [m]')
% if p2(2)>0
%         fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p2(1),p2(2));
%     else 
%         fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p2(1),p2(2));
%     end
% legend('simulation: erreur sur la vitesse finale en y',fit)
% grid on
% % set(gca, 'YScale', 'log')
% hold off
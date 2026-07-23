repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice1_student.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input = 'configuration.in'; % Nom du fichier d'entrée 

nsteps = [160 320 640 1280 2560 5120 10240];
nsimul = length(nsteps); % Nombre de simulations a faire
% autre exemple: 
%nsteps = round(logspace(2,4,nsimul)); % Nombre d'iterations entier de 10^2 a 10^4
tfin = 120 ; % TODO: Verifier que la valeur de tfin est EXACTEMENT la meme que dans le fichier input

dt = tfin ./ nsteps;

paramstr = 'nsteps'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param = nsteps; % Valeurs du parametre a scanner  MODIFIER SELON VOS BESOINS

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
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
    t    = data(:,1); 
    mF   = data(:,2);
    x    = data(:,3);
    v    = data(:,4);
    Emec = data(:,5);
    Pnc    = data(:,6); 
    xfin = data(:,7);
    vfin = data(:,8);
    x_th = xfin(1); % TODO: Entrer la vraie solution analytique a tfin
    v_th = vfin(1); % TODO: Entrer la vraie solution analytique a tfin
    error(i) = abs(x(nsteps(i))-x_th);
    error1(i) = abs(v(nsteps(i))-v_th);
end

lw=2; fs=16;


figure
p=polyfit(log(dt),log(error),1)
f=polyval(p,log(dt))
loglog(dt, error, 'black+', 'linewidth',lw)
hold on
loglog(dt,exp(f), '--', 'linewidth', lw)
set(gca,'fontsize',fs)
xlabel('$\Delta$t [s]')
ylabel('$|x_{th}-x_{fin}|$ [m]')
grid on
% set(gca, 'YScale', 'log')
hold off

figure
p1=polyfit(log(dt),log(error1),1)
f1=polyval(p1,log(dt))
loglog(dt, error1, 'black+', 'linewidth',lw)
hold on
loglog(dt,exp(f1), '--', 'linewidth', lw)
set(gca,'fontsize',fs)
xlabel('$\Delta$t [s]')
ylabel('$|v_{th}-v_{fin}|$ [m/s]')
grid on
hold off
% 
% figure
% p1=polyfit(log(dt),log(error1),1)
% f1=polyval(p1,log(dt))
% loglog(dt, error1, 'r+', 'linewidth',lw)
% hold on
% plot(tfin./nsteps,exp(f1), '--', 'linewidth', lw)
% set(gca,'fontsize',fs)
% xlabel('\Delta t [s]')
% ylabel('\Delta E_{mec}[J]')
% grid on
% hold off
% 
% figure
% hold on
% for i = 1:nsimul
%     data = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
%     x = data(:,2);
%     z = data(:,3);
%     plot(x,z,'linewidth',lw)
%     
% end
% set(gca,'fontsize',fs)
% axis equal
% grid on
% xlabel('x [m]')
% ylabel('z [m]')
% lgd =legend('20','40','80','160','320', '640', '2000','location','best')
% lgd.Title.String='Nstep'
% hold off
% 
% figure
% hold on
% for i = 1:nsimul
%     data = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
%     energy = data(:,6);
%     t = data(:,1);
%     plot(t,energy,'linewidth',lw)
% end
% 
% set(gca,'fontsize',fs)
% 
% grid on
% xlabel('t [s]')
% ylabel('E_{mec}[J]')
% lgd =legend('20','40','80','160','320', '640', '2000','location','best')
% lgd.Title.String='Nstep'
% hold off
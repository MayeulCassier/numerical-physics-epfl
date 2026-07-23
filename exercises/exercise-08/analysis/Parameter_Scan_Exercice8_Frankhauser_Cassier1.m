repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice8_2023_student.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input      = 'configuration.in'; % Nom du fichier d'entrée 

close all;
%nsteps = [10 20 30 40 50];
nsteps = floor(logspace(3,4,100));
%nsteps = [100 150 200 300 500 1000];
%nsteps = [1000 1500 2000 3000 5000 10000];
tfin = 1000; %Verifier que la valeur de tfin est EXACTEMENT la meme que dans le fichier input
dt = tfin ./ nsteps;
paramstr = 'Nsteps'; 
param = nsteps;  

fl =40;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
nsimul = numel(param); % Nombre de simulations a faire:
output = cell(1, nsimul);
for i = 1:nsimul
    output{i} = [paramstr, '=', num2str(param(i)), '.out'];
end
%% Simulations %% 
%%%%%%%%%%%%%%%%%
% Lance une serie de simulations (= executions du code C++)

 % Tableau de cellules contenant les noms des fichiers de sortie
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
errorxmoy            = zeros(1,nsimul);
errorpmoy            = zeros(1,nsimul);
errordx            = zeros(1,nsimul);
errordp            = zeros(1,nsimul);
titre            = string([1 nsimul]);

figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data  = load([output{i},'_obs.out']);
    t     = data(:,1);
    xmoy  = data(:,5);
    errorxmoy(i)=xmoy(end);
    plot(t,xmoy,'Color',[i*0.3/nsimul 0.3 i/nsimul], 'linewidth',lw)
    titre(i)=num2str(param(i));
    hold on
end
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$\langle x\rangle(t)$ [m]')
%title(titre);
legend(titre,'Location','north','NumColumns',4);
%legend('1600','3200','6400','12800','25600')
grid on
% set(gca, 'YScale', 'log')
title(legend, '$N_{steps}$');
hold off

figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data  = load([output{i},'_obs.out']);
    t     = data(:,1);
    pmoy  = data(:,7);
    errorpmoy(i)=pmoy(end);
    plot(t,pmoy,'Color',[i*0.3/nsimul 0.3 i/nsimul], 'linewidth',lw)
    hold on
end
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$\langle p\rangle (t)$ [m/s]')
%title(titre);
legend(titre,'Location','north','NumColumns',4);
%legend('1600','3200','6400','12800','25600')
grid on
% set(gca, 'YScale', 'log')
title(legend, '$N_{steps}$');
hold off


figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data  = load([output{i},'_obs.out']);
    t     = data(:,1);
    xmoy  = data(:,5);
    x2moy = data(:,6);
    
    % Uncertainty in x, p; eqs. (9-10-11)
    dx = sqrt(x2moy - xmoy.^2);
    errordx(i)=dx(end);
    plot(t,dx,'Color',[i*0.3/nsimul 0.3 i/nsimul], 'linewidth',lw)
    hold on
end
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$\langle \Delta x\rangle (t)$ [m]')
%title(titre);
legend(titre,'Location','north','NumColumns',4);
%legend('1600','3200','6400','12800','25600')
grid on
% set(gca, 'YScale', 'log')
title(legend, '$N_{steps}$');
hold off

figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data  = load([output{i},'_obs.out']);
    t     = data(:,1);
    pmoy  = data(:,7);
    p2moy = data(:,8);
    dp = sqrt(p2moy - pmoy.^2);
    errordp(i)=dp(end);
    plot(t,dp,'Color',[i*0.3/nsimul 0.3 i/nsimul], 'linewidth',lw)
    hold on
end
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$\langle \Delta p\rangle (t)$ [m/s]')
%title(titre);
legend(titre,'Location','north','NumColumns',4);
%legend('1600','3200','6400','12800','25600')
grid on
% set(gca, 'YScale', 'log')
title(legend, '$N_{steps}$');
hold off
%%
ymin = 1;
ymax = 100;
puissance1=2;
figure
plot(dt(ymin:ymax).^(puissance1), abs(errorxmoy(ymin:ymax)),'.', 'Linewidth', lw);
set(gca,'fontsize',fs)
xlabel('$\Delta t^2$ [s]')
ylabel('$\langle x\rangle (t_{fin})$ [m]')
% title(legend, 'Nstep');
% legend(titre,'Location','northwest');
grid on
%%
puissance2=2;
figure
plot(dt(ymin:ymax).^(puissance2), abs(errorpmoy(ymin:ymax)),'.', 'Linewidth', lw);
set(gca,'fontsize',fs)
xlabel('$\Delta t^2$ [s]')
ylabel('$\langle p\rangle (t_{fin})$ [m/s]')
% title(legend, 'Nstep');
grid on
% legend(titre,'Location','northwest');
%%
puissance3=2;
figure
plot(dt(ymin:ymax).^(puissance3), abs(errordx(ymin:ymax)),'.', 'Linewidth', lw);
set(gca,'fontsize',fs)
xlabel('$\Delta t^2$ [s]')
ylabel('$\langle \Delta x\rangle (t_{fin})$ [m]')
% title(legend, 'Nstep');
grid on
% legend(titre,'Location','northwest');
%%
puissance4=2;
figure
plot(dt(ymin:ymax).^(puissance4), abs(errordp(ymin:ymax)),'.', 'Linewidth', lw);
set(gca,'fontsize',fs)
xlabel('$\Delta t^2$ [s]')
ylabel('$\langle \Delta p\rangle (t_{fin})$ [m/s]')
% title(legend, 'Nstep');
grid on
% legend(titre,'Location','northwest');



% 
% figure
% p=polyfit(log(dt),log(errortheta),1);
% f=polyval(p,log(dt));
% loglog(dt, errortheta, 'black+', 'linewidth',lw)
% hold on
% loglog(dt,exp(f), '--', 'linewidth', lw)
% set(gca,'fontsize',fs)
% xlabel('$\Delta$t [s]')
% ylabel('$|\theta_{i}^{exact}-\theta_{i}^{num}|$ [rad]')
% if p(2)\rangle0
%         fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p(1),p(2));
% else 
%         fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p(1),p(2));
% end
% legend({'simulations', fit},'Location','northwest');
% grid on 
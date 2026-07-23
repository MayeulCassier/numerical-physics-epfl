repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice8_2023_student_supp.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input      = 'configuration_supp.in'; % Nom du fichier d'entrée 

close all;
tdetect=[400 2000];
tfin = 1000; %Verifier que la valeur de tfin est EXACTEMENT la meme que dans le fichier input

paramstr = 'tdetect'; 
param = tdetect;  

fl =16;
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
    cmd = sprintf('%s%s %s %s=%.15g output_supp=%s', repertoire, executable, input, paramstr, param(i), output{i});
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
titre = strings(size(param));
figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data  = load([output{i},'_obs.out']);
    t     = data(:,1);
    E     = data(:,4);
    
   
    plot(t, E);
    titre(i)=num2str(param(i));
    hold on
end
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$\langle E \rangle$ [J]')
legend(titre,'Location','north');
grid on
title(legend, '$t_{\rm detect}$');
hold off

figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data  = load([output{i},'_obs.out']);
    t     = data(:,1);
    xmoy  = data(:,5);
    plot(t,xmoy, 'linewidth',lw)
    hold on
end
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$\langle x\rangle (t)$ [m/s]')
legend(titre,'Location','north','NumColumns',4);
grid on
title(legend, '$t_{\rm detect}$');
hold off

figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data  = load([output{i},'_obs.out']);
    t     = data(:,1);
    xmoy  = data(:,7);
    plot(t,xmoy, 'linewidth',lw)
    hold on
end
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$\langle p\rangle (t)$ [m/s]')
legend(titre,'Location','north','NumColumns',4);
grid on
title(legend, '$t_{\rm detect}$');
hold off


figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data  = load([output{i},'_obs.out']);
    t     = data(:,1);
    xmoy  = data(:,5);
    x2moy = data(:,6);
    
    dx = sqrt(x2moy - xmoy.^2);
    plot(t,dx, 'linewidth',lw)
    hold on
end
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$\langle \Delta x\rangle (t)$ [m]')
legend(titre,'Location','north','NumColumns',4);
grid on
title(legend, '$t_{\rm detect}$');
hold off

figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data  = load([output{i},'_obs.out']);
    t     = data(:,1);
    pmoy  = data(:,7);
    p2moy = data(:,8);
    dp = sqrt(p2moy - pmoy.^2);
    plot(t,dp, 'linewidth',lw)
    hold on
end
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$\langle \Delta p\rangle (t)$ [m/s]')
legend(titre,'Location','north','NumColumns',4);
grid on
title(legend, '$t_{\rm detect}$');
hold off
%%
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data  = load([output{i},'_obs.out']);
    P1    = data(:,2);
    P2    = data(:,3);  
    figure
    plot(t,P1,t,P2,t,P1+P2)
    %plot(t,P1,t,P2)
    grid on
    xlabel('$t$ [s]')
    ylabel('Probability')
    legend('$P_{x<x_0}$','$P_{x>=x_0}$','$P_{tot}$')
end
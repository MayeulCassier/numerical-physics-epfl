repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice2_student.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input = 'configuration.in'; % Nom du fichier d'entrée 

nsteps = round(linspace(20,10000,300));
%nsteps = [200 300 400 500 600];
nsimul1 = numel(nsteps);
schema = ["EE" "EI" "ESI" "RK2"];
nschema = numel(schema); % Nombre de simulations a faire:
% numel est une fonction Matlab qui retourne le nombre d'elements d'un tableau.
paramstr1 = 'schema'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param1 = schema; 
paramstr2 = 'nsteps';
param2=nsteps;

nstep1=1600; % TODO: Verifier que la valeur de nstep1 est EXACTEMENT la meme que dans le fichier input
tfin = 8.199082312436474e-08 ;
dt = tfin ./ nsteps;
fl =40;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
%% Simulations %% 
%%%%%%%%%%%%%%%%%
% Lance une serie de simulations (= executions du code C++)
% Normalement, on ne devrait pas avoir besoin de modifier cette partie
close all;
output = cell(nsimul1, nschema); % Tableau de cellules contenant les noms des fichiers de sortie
for j = 1:nschema
   for i = 1:nsimul1
       
        output{j}{i} = [paramstr1, '=', num2str(param1(j)), paramstr2, '=', num2str(param2(i)), '.out'];
    % Execution du programme en lui envoyant la valeur a scanner en argument
        cmd = sprintf('%s%s %s %s=%s %s=%.15g output=%s', repertoire, executable, input, paramstr1, param1(j), paramstr2, param2(i), output{j}{i});
        disp(cmd)
        system(cmd);
        disp('Done.')
   end
end
%% Graphs %%
%%%%%%%%%%%%
q = 1.6022e-19; %charge of the proton [C]
m = 1.6726e-27; %mass of the proton [kg]
B = 4;          %intensity of the magnetic field [T]
omega = q*B/m;  %cyclotron frequency [rad/s]
v = 5e5;        %proton initial velocity modulus [m/s]
r=v/omega;      %radius of the trajectory [m]
for j= 1:nschema
    errorEE = zeros(1,nsimul1);
    errorEE1 = zeros(1,nsimul1);
    errorEE2 = zeros(1,nsimul1);
    errorEM = zeros(1,nsimul1);
    
    lw=1.5; fs=16;
    figure
    for i = 1:nsimul1 % Parcours des resultats de toutes les simulations
        data  = load(output{j}{i}); % Chargement du fichier de sortie de la i-ieme simulation
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
        
        errorEE(i) = max(abs(vxfin-vx_th),abs(vyfin-vy_th));
        errorEE1(i) = abs(vxfin-vx_th);
        errorEE2(i)=abs(vyfin-vy_th);
        Eth=(v^2)*0.5*m;
        Eth1= 2.09075e-016;
        errorEM(i)= abs(E(end)-Eth1);
        Eforerror=E-Eth1;
        plot(t, E, 'linewidth',lw)
        hold on
    end
    set(gca,'fontsize',fs)
    xlabel('t [s]')
    ylabel('Energie [J]')
    if j==1
        titre= sprintf('simulation en %s','euler explicite');
        set(gca, 'YScale', 'log');
    elseif j==2
        titre= sprintf('simulation en %s','euler implicite');
    elseif j==3
        titre= sprintf('simulation en %s','euler semi-implicite');
    elseif j==4
        titre= sprintf('simulation en %s','Runge_Kutta 2');
        set(gca, 'YScale', 'log');
    end
    %title(titre);
    legend('200','300','400','500','600')
    %legend('1600','3200','6400','12800','25600')
    grid on
    % set(gca, 'YScale', 'log')
    title(legend, 'Nstep');
    hold off

    
    figure
    p=polyfit(log(dt),log(errorEE),1);
    f=polyval(p,log(dt));
    loglog(dt, errorEE, 'black+', 'linewidth',lw)
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
    if j==1
        titre= sprintf('simulation en %s: erreur sur la vitesse finale','euler explicite');
    elseif j==2
        titre= sprintf('simulation en %s: erreur sur la vitesse finale','euler implicite');
    elseif j==3
        titre= sprintf('simulation en %s: erreur sur la vitesse finale','euler semi-implicite');
    elseif j==4
        titre= sprintf('simulation en %s: erreur sur la vitesse finale','Runge Kutta 2');
    end
    legend(titre,fit)
    grid on
    % set(gca, 'YScale', 'log')
    hold off
    
    %LA C POUR CHACUN INDEPENDEMMENT
    
%     figure
%     p1=polyfit(log(dt),log(errorEE1),1);
%     f1=polyval(p1,log(dt));
%     loglog(dt, errorEE1, 'black+', 'linewidth',lw)
%     hold on
%     loglog(dt,exp(f1), '--', 'linewidth', lw)
%     set(gca,'fontsize',fs)
%     xlabel('$\Delta$t [s]')
%     ylabel('$\|v_{x}^{exact}-v_{x}^{num}|$ [m/s]')
%     if p1(2)>0
%         fit = sprintf('fit:$y=$%0.5f$x+$%0.5f',p1(1),p1(2));
%     else 
%         fit = sprintf('fit:$y=$%0.5f$x$%0.5f',p1(1),p1(2));
%     end
%      if j==1
%         titre= sprintf('simulation en %s :erreur sur la vitesse finale en x','euler explicite');
%     elseif j==2
%         titre= sprintf('simulation en %s :erreur sur la vitesse finale en x','euler implicite');
%     elseif j==3
%         titre= sprintf('simulation en %s :erreur sur la vitesse finale en x','euler semi-implicite');
%     elseif j==4
%         titre= sprintf('simulation en %s :erreur sur la vitesse finale en x','Runge_Kutta 2');
%     end
%     legend(titre,fit)
%     grid on
%     % set(gca, 'YScale', 'log')
%     hold off
%     
%     lw=1.5; fs=16;
%     figure
%     p2=polyfit(log(dt),log(errorEE2),1);
%     f2=polyval(p2,log(dt));
%     loglog(dt, errorEE2, 'black+', 'linewidth',lw)
%     hold on
%     loglog(dt,exp(f2), '--', 'linewidth', lw)
%     set(gca,'fontsize',fs)
%     xlabel('$\Delta$t [s]')
%     ylabel('$\|v_{y}^{exact}-v_{y}^{num}|$ [m/s]')
%     if p2(2)>0
%         fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p2(1),p2(2));
%     else 
%         fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p2(1),p2(2));
%     end
%      if j==1
%         titre= sprintf('simulation en %s :erreur sur la vitesse finale en y','euler explicite');
%     elseif j==2
%         titre= sprintf('simulation en %s :erreur sur la vitesse finale en y','euler implicite');
%     elseif j==3
%         titre= sprintf('simulation en %s :erreur sur la vitesse finale en y','euler semi-implicite');
%     elseif j==4
%         titre= sprintf('simulation en %s :erreur sur la vitesse finale en y','Runge_Kutta 2');
%      end
%      legend(titre,fit)
%     grid on
%     % set(gca, 'YScale', 'log')
%     hold off
%     
    lw=1.5; fs=16;
    figure
    pM=polyfit(log(dt),log(errorEM),1)
    fM=polyval(pM,log(dt))
    loglog(dt, errorEM, 'black+', 'linewidth',lw)
    hold on
    loglog(dt,exp(fM), '--', 'linewidth', lw)
    set(gca,'fontsize',fs)
    xlabel('$\Delta$t [s]')
    ylabel('$\|E_{mec}^{exact}-E_{mec, fin}^{num}|$ [J]')
    if pM(2)>0
        fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',pM(1),pM(2));
    else 
        fit = sprintf('fit:$y=$%0.5g$x$%0.5g',pM(1),pM(2));
    end
     if j==1
        titre= sprintf('simulation en %s: erreur sur l énergie','euler explicite');
    elseif j==2
        titre= sprintf('simulation en %s: erreur sur l énergie','euler implicite');
    elseif j==3
        titre= sprintf('simulation en %s: erreur sur l énergie','euler semi-implicite');
    elseif j==4
        titre= sprintf('simulation en %s: erreur sur l énergie','Runge Kutta 2');
     end
     legend(titre,fit)
    grid on
    % set(gca, 'YScale', 'log')
    hold off

%     for i=1: nsimul1
%         
%     end
%     lw=1.5; fs=16;
%     figure
%     plot(t, Eforerror, 'black+', 'linewidth',lw)
%     hold on
%     set(gca,'fontsize',fs)
%     xlabel('$\Delta$t [s]')
%     ylabel('$\|E_{mec}^{k+1}-E_{mec, fin}^{k}|/2$ [J]')
%     if pM(2)>0
%         fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',pM(1),pM(2));
%     else 
%         fit = sprintf('fit:$y=$%0.5g$x$%0.5g',pM(1),pM(2));
%     end
%      if j==1
%         titre= sprintf('simulation en %s: erreur sur l''énergie','euler explicite');
%     elseif j==2
%         titre= sprintf('simulation en %s: erreur sur l''énergie','euler implicite');
%     elseif j==3
%         titre= sprintf('simulation en %s: erreur sur l''énergie','euler semi-implicite');
%     elseif j==4
%         titre= sprintf('simulation en %s: erreur sur l''énergie','Runge_Kutta 2');
%      end
%      legend(titre,fit)
%     grid on
%     set(gca, 'YScale', 'log')
%     hold off
end


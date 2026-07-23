repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice2_student.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input = 'configuration2.in'; % Nom du fichier d'entrée 
 % Nombre de simulations a faire:
close all;
tfin = 8.199082312436474e-08; % TODO: Verifier que la valeur de tfin est EXACTEMENT la meme que dans le fichier input

nsteps = [200 400 800 1600 3200 6400];
nsimul1 = numel(nsteps);
schema = ["ESI" "RK2"];
nschema = numel(schema); % Nombre de simulations a faire:
% numel est une fonction Matlab qui retourne le nombre d'elements d'un tableau.
paramstr1 = 'schema'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param1 = schema; 
paramstr2 = 'nsteps';
param2=nsteps;

nstep1=1600; % TODO: Verifier que la valeur de nstep1 est EXACTEMENT la meme que dans le fichier input

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
%% plots %%
%%%%%%%%%%%
q = 1.6022e-19; %charge of the proton [C]
m = 1.6726e-27; %mass of the proton [kg]
B = 4;          %intensity of the magnetic field [T]
omega = q*B/m;  %cyclotron frequency [rad/s]
v = 5e5;        %proton initial velocity modulus [m/s]
r=v/omega; 
E0=8*10^4;%radius of the trajectory [m]
for j= 1:nschema
    errorEM1 = zeros(1,nsimul1);
    
    lw=1.5; fs=16;
    
    for i = 1:nsimul1 % Parcours des resultats de toutes les simulations
        data  = load(output{j}{i}); % Chargement du fichier de sortie de la i-ieme simulation
        t     = data(:,1);
        x     = data(:,2);
        y     = data(:,3);
        E     = data(:,9);
    % TODO:  inserer ici les expressions de la solution exacte
        Eth=2.09075e-016;
        errorEM= E-Eth;
        errorEM1(i)=abs(E(end,1)-Eth);
        errorEM2 = zeros(numel(t),1);
        for k=1:numel(t)-1
            errorEM2(k,1)=abs(E(k,1)-E(k+1,1))/dt(i);
        end
        ve= E0/B;
        xt=x-ve.*t;
        yt=y;
        hold on
    end
    figure
    plot(t, errorEM, 'linewidth',lw)
    set(gca,'fontsize',fs)
    xlabel('t [s]')
    ylabel('Energie [J]')
    if j==1
        titre= sprintf('simulation en %s','euler semi-implicite');
    elseif j==2
        titre= sprintf('simulation en %s','Runge_Kutta 2');
    end
    %title(titre);
    legend('nsteps = 6400')
    grid on
    % set(gca, 'YScale', 'log')
    hold off

    lw=1.5; fs=16;
    figure
    pM=polyfit(log(dt),log(errorEM1),1);
    fM=polyval(pM,log(dt));
    loglog(dt, errorEM1, 'black+', 'linewidth',lw)
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
        titre= sprintf('simulation en %s :erreur sur l''Energie','euler semi-implicite');
    elseif j==2
        titre= sprintf('simulation en %s :erreur sur l''Energie','Runge_Kutta 2');
     end
     legend(titre,fit)
    grid on
    % set(gca, 'YScale', 'log')
    hold off
    figure
    plot(x, y, 'linewidth',lw)
    set(gca,'fontsize',fs)
    xlabel('$x$ [m]')
    ylabel('$y$ [m]')
    if j==1
        titre= sprintf('simulation en %s :trajectoire','euler semi-implicite');
    elseif j==2
        titre= sprintf('simulation en %s :trajectoire','Runge_Kutta 2');
     end
     %title(titre);
    lgd =legend('nstep = 6400');
%     title(lgd, 'Nstep');
    grid on
    % set(gca, 'YScale', 'log')
    hold off



    
    
    figure
    plot(xt, yt, 'linewidth',lw)
     set(gca,'fontsize',fs)
    xlabel('$x$ corrig\''e [m]')
    ylabel('$y$ corrig\''e [m]')
    if j==1
        titre= sprintf('simulation en %s :trajectoire corrigée','euler semi-implicite');
    elseif j==2
        titre= sprintf('simulation en %s :trajectoire corrigée','Runge_Kutta 2');
     end
     %title(titre);
    lgd =legend('nstep = 6400');
%     title(lgd, 'Nstep');
    grid on
    % set(gca, 'YScale', 'log')
    hold off
    

    figure
    plot(t(1:6399),errorEM2(1:6399),'linewidth',lw)
    %plot(t,errorEM2,'linewidth',lw)
    set(gca,'fontsize',fs)
    xlabel('$t$ [s]')
    ylabel('$\Delta E_{mec}/dt$ [J/s]')
    lgd =legend('nstep = 6400');
    grid on

end


repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice3_2022_student.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input      = 'configuration5.in'; % Nom du fichier d'entrée 
g= 9.81;
L= 0.2;
pi=3.1415926535897932384626433832795028841971e0;
%theta0 = [103719755.1196598e-8 103719756.1196598e-8 208439510.2393196e-8 208439511.2393195e-8];
theta0=[7*pi/8 7*pi/8+1.0e-2 3*pi/8 3*(pi/8)+1.0e-2];
%NE PAS OUBLIER DE METTRE n=1000 et N=50 et sampling=1
%theta0 = [1.0e-2 pi/6-1.0e-2];
ntheta = numel(theta0);
thetadot0 = [1.0e-2];
%thetadot0 = [-0.02 0.0];
nthetadot = numel(thetadot0); % Nombre de simulations a faire:
% numel est une fonction Matlab qui retourne le nombre d'elements d'un tableau.
paramstr1 = 'thetadot0'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param1 = thetadot0; 
paramstr2 = 'theta0';
param2=theta0;
N=20;
n=1000;
Omega= 14.0071410359;
tfin = N*2*pi/Omega;
dt= 2*pi/(Omega*n);
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
output = cell(ntheta, nthetadot); % Tableau de cellules contenant les noms des fichiers de sortie
for j = 1:nthetadot
   for i = 1:ntheta
       
        output{j}{i} = [paramstr1, '=', num2str(param1(j), 15), paramstr2, '=', num2str(param2(i),15), '.out'];
    % Execution du programme en lui envoyant la valeur a scanner en argument
        cmd = sprintf('%s%s %s %s=%0.15g %s=%0.15g output=%s', repertoire, executable, input, paramstr1, param1(j), paramstr2, param2(i), output{j}{i});
        disp(cmd)
        system(cmd);
        disp('Done.')
   end
end
%% Graphs %%
%%%%%%%%%%%%
close all;
lw=1.0; fs=16;
%radius of the trajectory [m]
for j= 1:nthetadot    
    for i = 1:ntheta-1 % Parcours des resultats de toutes les simulations
        data1  = load(output{j}{i});
        data2  = load(output{j}{(i+1)});% Chargement du fichier de sortie de la i-ieme simulation
        theta1=data1(:,2);
        theta2=data2(:,2);
        thetadot1    = data1(:,3);
        thetadot2    = data2(:,3);
        t= data1(:,1);
        figure
        d= (thetadot1-thetadot2).^2+(Omega^(2))*(theta1-theta2).^2;
        if i==1
            plot(t, d, 'k','linewidth',lw);
            ylabel('$d=[(\dot{\theta}_1-\dot{\theta}_2)^2+\Omega^2(\theta_1-\theta_2)^2]^{1/2}$ [rad/s]')
            %legend("$\dot{\theta}_0=$ "+thetadot0(j)+" et $\theta_0=$ "+theta0(i) +"$\pm 10^{-8}$", fit);
            legend("$\dot{\theta}_0=$ "+thetadot0(j)+" et $\theta_0=7\pi/8\pm 10^{-8}$", fit);
            
        elseif i==3
            plot(t, d, 'k','linewidth',lw);
            ylabel('$d=[(\dot{\theta}_1-\dot{\theta}_2)^2+\Omega^2(\theta_1-\theta_2)^2]^{1/2}$ [rad/s]')
            %legend("$\dot{\theta}_0=$ "+thetadot0(j)+" et $\theta_0=$ "+theta0(i)+ "$\pm 10^{-8}$");
            legend("$\dot{\theta}_0=$ "+thetadot0(j)+" et $\theta_0=3\pi/8\pm 10^{-8}$", fit);
        else 
            plot(t, theta1,'linewidth',lw);
            hold on
            plot(t, theta2,'linewidth',lw);
            hold off
            ylabel('$\theta$');
            legend("$\dot{\theta}_0=$ "+thetadot0(j)+" et $\theta_0=7\pi/8$", ...
                "$\dot{\theta}_0=$ "+thetadot0(j)+" et $\theta_0=3\pi/8$");
            
        end
        %titre= sprintf('$\dot{\theta}_0=$ %0.5g et $\theta_0=$ %0.5g',thetadot0(j), theta0(i));
        
        %title(titre);
        xlabel('t [s]')
        set(gca,'fontsize',fs)
        %legend('1600','3200','6400','12800','25600')
        grid on
        % set(gca, 'YScale', 'log')
        title(legend, 'Conditions Initiales');
        %xlim([ 0 100])
    end
    
end
% figure
% data = load(output{1}{1}); % Chargement du fichier de sortie de la i-ieme simulation
% theta1 = data(:,2);
% t3=data(:,1);
% data = load(output{1}{2}); % Chargement du fichier de sortie de la i-ieme simulation
% theta2 = data(:,2);
% error = abs(theta1 - theta2);
% semilogy(t3,error,'linewidth',lw);
% set(gca,'fontsize',fs)
% xlabel('t [s]')
% ylabel('|\Delta\theta|')
% %xlim([0 40])
% grid on
% 
% 
% figure
% data = load(output{1}{1}); % Chargement du fichier de sortie de la i-ieme simulation
% theta1 = data(:,2);
% t7=data(:,1);
% data = load(output{1}{2}); % Chargement du fichier de sortie de la i-ieme simulation
% theta2 = data(:,2);
% error = abs(theta1 - theta2);
% semilogy(t7,error,'linewidth',lw);
% set(gca,'fontsize',fs)
% xlabel('t [s]')
% ylabel('|\Delta\theta|')
% %xlim([0 100])
% grid on
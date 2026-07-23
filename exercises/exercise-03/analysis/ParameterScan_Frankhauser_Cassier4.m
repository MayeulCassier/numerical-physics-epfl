repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice3_2022_student.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input      = 'configuration4.in'; % Nom du fichier d'entrée 
g= 9.81;
L= 0.2;
%theta0 = [1.0e-2 pi/6-1.0e-2 pi/4-1.0e-2 pi/3-1.0e-2 2*pi/3-1.0e-2 pi/2-1.0e-2 3*pi/4-1.0e-2 5*pi/6-1.0e-2 pi-1.0e-2];
theta0 = [0.0 pi/8 pi/4 3*pi/8 pi/2 5*pi/8 3*pi/4 7*pi/8 pi -pi/8 ];

% t1=pi/3 -1.0e-2;
% t2=pi/3 -1.0e-2 +1.0e-8;
% t3=2*pi/3 -1.0e-2;
% t4= 2*pi/3-1.0e-2+1.0e-8;
% theta0 = [t1 t2 t3 t4];
%theta0 = [1.0e-2 pi/6-1.0e-2];
ntheta = numel(theta0);
%NE PAS OUBLIER DE METTRE n=250 et sampling = 250 et N=10000
thetadot0 = [1.0e-2];
%thetadot0 = [-0.02 0.0];
nthetadot = numel(thetadot0); % Nombre de simulations a faire:
% numel est une fonction Matlab qui retourne le nombre d'elements d'un tableau.
paramstr1 = 'thetadot0'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param1 = thetadot0; 
paramstr2 = 'theta0';
param2=theta0;

N=10000;
n=250;
Omega= 7.00357051796;
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
       
        output{j}{i} = [paramstr1, '=', num2str(param1(j)), paramstr2, '=', num2str(param2(i)), '.out'];
    % Execution du programme en lui envoyant la valeur a scanner en argument
        cmd = sprintf('%s%s %s %s=%.15g %s=%.15g output=%s', repertoire, executable, input, paramstr1, param1(j), paramstr2, param2(i), output{j}{i});
        disp(cmd)
        system(cmd);
        disp('Done.')
   end
end
%% Graphs %%
%%%%%%%%%%%%
close all;
lw=1.5; fs=16;
%radius of the trajectory [m]
for j= 1:nthetadot    
figure 
    for i = 1:ntheta % Parcours des resultats de toutes les simulations
        data  = load(output{j}{i}); % Chargement du fichier de sortie de la i-ieme simulation
        thetav=data(100:end,2);
        thetadotv    = data(100:end,3);
        
        thetaPI = mod(thetav-pi, 2*pi);
        plot(thetaPI-pi, thetadotv, '.','linewidth',lw)
        hold on
        %titre= sprintf('$\dot{\theta}_0=$ %0.5g et $\theta_0=$ %0.5g',thetadot0(j), theta0(i));
        
        %title(titre);
        
        %legend('1600','3200','6400','12800','25600')
        grid on
        % set(gca, 'YScale', 'log')
        
        %xlim([ 0 100])
    end
    xlabel('$\dot{\theta}$ [rad/s]')
        ylabel('$\theta$ [rad]')
        %legend("$\dot{\theta}_0=$ "+thetadot0(j)+" et $\theta_0=$ "+theta0(1), );
%         legend("$\theta_0=$ "+theta0(1), "$\theta_0=$ "+theta0(2), "$\theta_0=$ "+theta0(3), ...
%             "$\theta_0=$ "+theta0(4),"$\theta_0=$ "+theta0(5),"$\theta_0=$ "+theta0(6), ...
%             "$\theta_0=$ "+theta0(7), "$\theta_0=$ "+theta0(8),"$\theta_0=$ "+theta0(9) );
legend({'$\theta_0= 0$', '$\theta_0=\pi/8$ ', '$\theta_0=\pi/4$ ', ...
            '$\theta_0=3\pi/8$ ','$\theta_0=\pi/2$ ','$\theta_0=5\pi/2$ ', ...
            '$\theta_0=3\pi/4$ ', '$\theta_0=7\pi/8$ ','$\theta_0=\pi$ ', '$\theta_0=-\pi/8$ '},'NumColumns',4 );
        title(legend, 'Conditions Initiales');
end

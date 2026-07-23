repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice2_student2.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input = 'configuration4.in'; % Nom du fichier d'entrée 
 % Nombre de simulations a faire:

tfin = 1.579632924974590e-06; % TODO: Verifier que la valeur de tfin est EXACTEMENT la meme que dans le fichier input
close all;
vz0 = [8e5 2e5];

vy0 = [8e5 2e5];
% numel est une fonction Matlab qui retourne le nombre d'elements d'un tableau.
paramstr1 = 'vz0'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param1 = vz0; 
paramstr2 = 'vy0';
param2=vy0;

nstep=5000; % TODO: Verifier que la valeur de nstep1 est EXACTEMENT la meme que dans le fichier input

dt = tfin / nstep;

fl =40;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
%% Simulations %% 
%%%%%%%%%%%%%%%%%
% Lance une serie de simulations (= executions du code C++)
% Normalement, on ne devrait pas avoir besoin de modifier cette partie

output = cell(2, 2); % Tableau de cellules contenant les noms des fichiers de sortie
for j = 1:2
   for i = 1:2
       
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
lw=1.5; fs = 16;
figure
data = load(output{1}{2});
data1 = load(output{2}{1});
plot3(data(:,2),data(:,3), data(:,4), 'r', data1(:,2),data1(:,3), data1(:,4), 'b')
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')
set(gca,'fontsize',fs)
legend('$v_{z0}= 8*10^5$ m/s, $v_{y0}= 2*10^5$ m/s', '$v_{z0}= 2*10^5$ m/s, $v_{y0}= 8*10^5$ m/s')
title(legend, 'vitesses initiales');
grid on

figure
data = load(output{1}{2});
data1 = load(output{2}{1});
plot3(data(:,5),data(:,6), data(:,7), 'r', data1(:,5),data1(:,6), data1(:,7), 'b')
xlabel('$v_x$ [m/s]')
ylabel('$v_y$ [m/s]')
zlabel('$v_z$ [m/s]')
set(gca,'fontsize',fs)
legend('$v_{z0}= 8*10^5$ m/s, $v_{y0}= 2*10^5$ m/s', '$v_{z0}= 2*10^5$ m/s, $v_{y0}= 8*10^5$ m/s')
title(legend, 'vitesses initiales');
grid on
for j=1:2
    for i=1:2
        
        data= load(output{j}{i});
        t = data(:,1);
        vpar=data(:,11);
        mu=data(:,10);
        E=data(:,9);
        figure 
        plot(t, E, 'LineWidth', lw)
        set(gca,'fontsize',fs)
        xlabel('t [s]')
        ylabel('$E_{mec}$ [J]')
        if i==1 && j==2
            legend('$v_{z0}= 2*10^5$ m/s, $v_{y0}= 8*10^5$ m/s')
        elseif i==2 && j==1
            legend('$v_{z0}= 8*10^5$ m/s, $v_{y0}= 2*10^5$ m/s')
        elseif i==1 && j==1
            legend('$v_{z0}= 8*10^5$ m/s, $v_{y0}= 8*10^5$ m/s')
        else 
            legend('$v_{z0}= 2*10^5$ m/s, $v_{y0}= 2*10^5$ m/s')
            
        end
        title(legend, 'vitesses initiales');

        figure 
        plot(t, mu, 'LineWidth', lw)
        set(gca,'fontsize',fs)
        xlabel('t [s]')
        ylabel('$\mu$ [kgms$^{-2}$T$^{-1}$]')
        if i==1 && j==2
            legend('$v_{z0}= 2*10^5$ m/s, $v_{y0}= 8*10^5$ m/s')
        elseif i==2 && j==1
            legend('$v_{z0}= 8*10^5$ m/s, $v_{y0}= 2*10^5$ m/s')
        elseif i==1 && j==1
            legend('$v_{z0}= 8*10^5$ m/s, $v_{y0}= 8*10^5$ m/s')
        else 
            legend('$v_{z0}= 2*10^5$ m/s, $v_{y0}= 2*10^5$ m/s')
            
        end
        title(legend, 'vitesses initiales');

        figure
        plot(t,vpar, 'LineWidth', lw)
        set(gca,'fontsize',fs)
        xlabel('t [s]')
        ylabel('$v_{||}$ [m/s]')
        if i==1 && j==2
            legend('$v_{z0}= 2*10^5$ m/s, $v_{y0}= 8*10^5$ m/s')
        elseif i==2 && j==1
            legend('$v_{z0}= 8*10^5$ m/s, $v_{y0}= 2*10^5$ m/s')
        elseif i==1 && j==1
            legend('$v_{z0}= 8*10^5$ m/s, $v_{y0}= 8*10^5$ m/s')
        else 
            legend('$v_{z0}= 2*10^5$ m/s, $v_{y0}= 2*10^5$ m/s')
            
        end
        title(legend, 'vitesses initiales');
    end
end
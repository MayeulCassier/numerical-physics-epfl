% Ce script Matlab automatise la production de resultats
% lorsqu'on doit faire une serie de simulations en
% variant un des parametres d'entree.
% 
% Il utilise les arguments du programme (voir ConfigFile.h)
% pour remplacer la valeur d'un parametre du fichier d'input
% par la valeur scannee.
%
clear; clc; close all;
%% Parametres %%
%%%%%%%%%%%%%%%%
fl =16;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
%Chemin d'acces au code compile
repertoire = ''; % './' on Linux, '' on Windows
executable = 'Exercice6_2023_student1.exe'; % Nom de l'executable


input = 'configuration12.in';
N2       = floor(linspace(20, 50, 5));
N1       = N2;
nN1   = numel(N1);
nN2   =numel(N2);
paramstr = 'N'; % Nom du parametre a scanner, par exemple dt, w, x0, etc
%param    = [N1;N2]; % Valeurs du parametre a scanner

paramstr1 = 'N1'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param1 = N1; % Valeurs du parametre a scanner  MODIFIER SELON VOS BESOINS
paramstr2 = 'N2'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param2 = N2;
%% Simulations %% 
%%%%%%%%%%%%%%%%%
% Lance une serie de simulations (= executions du code C++)
% Normalement, on ne devrait pas avoir besoin de modifier cette partie
close all;
output = cell(nN2, nN1); % Tableau de cellules contenant les noms des fichiers de sortie
for j = 1:nN1
   for i = 1:nN2
       
        output{j}{i} = [paramstr1, '=', num2str(param1(j)), paramstr2, '=', num2str(param2(i)), '.out'];
    % Execution du programme en lui envoyant la valeur a scanner en argument
        cmd = sprintf('%s%s %s %s=%.15g %s=%.15g output=%s', repertoire, executable, input, paramstr1, param1(j), paramstr2, param2(i), output{j}{i});
        disp(cmd)
        system(cmd);
        disp('Done.')
   end
end





%%
lw=1.5;fs=16;
for k=1:nN1
    name = strings(1, nN2);
    figure
    for i = 1:nN2 % Parcours des resultats de toutes les simulations
        file_phi   = [output{k}{i},'_phi.out'];
        file_D   = [output{k}{i},'_D.out'];
        file_E   = [output{k}{i},'_E.out'];
        file_Ddiv   = [output{k}{i},'_Ddiv.out'];
        data = load(file_phi); % Chargement du fichier de sortie de la i-ieme simulation
        r = data(:,1);
        phi=data(:,2);
        %phib(i)=phi(N1(k)*N2(i)+1);
        plot(r, phi,'-','linewidth',lw) %POUR PLOT LES TRAJECTOIRES
        hold on
        name(i)= num2str(N2(i));

    end
    ylabel('$\phi (r)$ $[V]$')
    xlabel('$r$ [m]')
    grid on
    legend(name);
    titre= "$N_1$="+num2str(N1(k))+ ", $N_2=$";
    title(legend,titre);
    set(gca,'fontsize',fs)
end
for k=1:nN1
    name = strings(1, nN2);
    figure
    for i = 1:nN2 % Parcours des resultats de toutes les simulations
        file_phi   = [output{k}{i},'_phi.out'];
        file_D   = [output{k}{i},'_D.out'];
        file_E   = [output{k}{i},'_E.out'];
        file_Ddiv   = [output{k}{i},'_Ddiv.out'];
        data = load(file_E); % Chargement du fichier de sortie de la i-ieme simulation
        r = data(:,1);
        E=data(:,2);
        plot(r, E,'-','linewidth',lw) %POUR PLOT LES TRAJECTOIRES
        hold on
        
        name(i)= num2str(N2(i));
    end
    ylabel('$E (r)$ $[V]$')
    xlabel('$r$ [m]')
    legend(name);
    titre= "$N_1$="+num2str(N1(k))+ ", $N_2=$";
    title(legend,titre);
    grid on
    set(gca,'fontsize',fs)
end

for k=1:nN2
    name = strings(1, nN1);
    figure
    for i = 1:nN1 % Parcours des resultats de toutes les simulations
        file_phi   = [output{i}{k},'_phi.out'];
        file_D   = [output{i}{k},'_D.out'];
        file_E   = [output{i}{k},'_E.out'];
        file_Ddiv   = [output{i}{k},'_Ddiv.out'];
        data = load(file_phi); % Chargement du fichier de sortie de la i-ieme simulation
        r = data(:,1);
        phi=data(:,2);
        plot(r, phi,'-','linewidth',lw) %POUR PLOT LES TRAJECTOIRES
        hold on
        name(i)= num2str(N2(i));
    end
    ylabel('$\phi (r)$ $[V]$')
    xlabel('$r$ [m]')
    legend(name);
    titre= "$N_2=$"+num2str(N2(k))+ ", $N_1=$";
    title(legend,titre);
    grid on
    set(gca,'fontsize',fs)
end
for k=1:nN2
    name = strings(1, nN1);
    figure
    for i = 1:nN1 % Parcours des resultats de toutes les simulations
        file_phi   = [output{i}{k},'_phi.out'];
        file_D   = [output{i}{k},'_D.out'];
        file_E   = [output{i}{k},'_E.out'];
        file_Ddiv   = [output{i}{k},'_Ddiv.out'];
        data = load(file_E); % Chargement du fichier de sortie de la i-ieme simulation
        r = data(:,1);
        E=data(:,2);
        plot(r, E,'-','linewidth',lw) %POUR PLOT LES TRAJECTOIRES
        hold on
        
        name(i)= num2str(N2(i));
    end
    ylabel('$E (r)$ $[V]$')
    xlabel('$r$ [m]')
    legend(name);
    titre= "$N_2=$"+num2str(N2(k))+ ", $N_1=$";
    title(legend,titre);
    grid on
    set(gca,'fontsize',fs)
end
% Parcours des resultats de toutes les simulations

% for ii = 1:nsimul
%     
%     data_phi   = load(file_phi);
%     phib(ii)=abs(data_phi(N1(ii)+1,2)-phith(rb));
%     rbtest=data_phi(N1(ii)+1,1);
% end
% p=polyfit(log(N1),log(phib),1);
% f=polyval(p,log(N1));
% 
% loglog(N1, phib,'b+', 'Linewidth',  lw);
% hold on
% loglog(N1,exp(f), '--', 'linewidth', lw);
% 
% if p(2)>0
%     fit = "fit:$y=$"+num2str(p(1))+"$x+$"+num2str(p(2));
% else 
%     fit = "fit:$y=$"+num2str(p(1))+"$x$"+num2str(p(2));
% end
% 
% title(legend, '$N_1=N_2$');
% legend('data', fit);
% xlabel('$N_1$');
% ylabel('$\phi (r_b)$')

%name{2*j} = ['name' string(fit)];
%name{2*j+1} =['name' string(simualtions)];
%legend(gca,'show');
% 


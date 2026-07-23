% Ce script Matlab automatise la production de resultats
% lorsqu'on doit faire une serie de simulations en
% variant un des parametres d'entree.
% 
% Il utilise les arguments du programme (voir ConfigFile.h)
% pour remplacer la valeur d'un parametre du fichier d'input
% par la valeur scannee.
%
clear; clc; close all;
repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice6_2023_student1_supp.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input = 'configuration_supp.in'; % Nom du fichier d'entrée 

geom = ["sp" "ca" "cy"];
nsimul = numel(geom); % Nombre de simulations a faire:
% numel est une fonction Matlab qui retourne le nombre d'elements d'un tableau.

% Autre exemple: 
%nsteps = round(logspace(2,4,nsimul)); % Nombre d'iterations entier de 10^2 a 10^4
% logspace est une fonction Matlab retournant un tableau de valeurs dont les logarithmes sont equidistants
% tapez 'help logspace' pour plus de details
% Voir aussi la fonction 'linspace'


paramstr = 'geom'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param = geom;  % Valeurs du parametre a scanner  MODIFIER SELON VOS BESOINS


fl =16;
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
    output{i} = [paramstr, '=', num2str(param(i)), '.out'];
    % Execution du programme en lui envoyant la valeur a scanner en argument
    cmd = sprintf('%s%s %s %s=%s output=%s', repertoire, executable, input, paramstr, param(i), output{i})
    disp(cmd)
    system(cmd);
    disp('Done.')
end



%% Analyse %%
%%%%%%%%%%%%%
% Ici, on aimerait faire une etude de convergence: erreur fonction de dt,
% sur diagramme log-log. A MODIFIER ET COMPLETER SELON VOS BESOINS
lw=1.5;
Va=1.5;
ra=0.03;
rb=0.05;
R=0.1;
figure
for ii = 1:nsimul
    file_phi   = [output{ii},'_phi.out'];
    data_phi   = load(file_phi);
    phi=data_phi(:,2);
    r=data_phi(:,1);
    plot(r,phi,'LineWidth',lw);
    hold on
end
xlabel('$r$ [m]')
ylabel('$\phi$[V]')
grid on
legend('spherique', 'cartesien', 'cylindrique')
title(legend, 'geometrie');
figure
for ii = 1:nsimul
    file_phi   = [output{ii},'_E.out'];
    data_phi   = load(file_phi);
    E=data_phi(:,2);
    r=data_phi(:,1);
    plot(r,E,'LineWidth',lw);
    hold on
end
xlabel('$r$ [m]')
ylabel('$E$[V/m]')
grid on
legend('spherique', 'cartesien', 'cylindrique')
title(legend, 'geometrie');
figure
for ii = 1:nsimul
    file_phi   = [output{ii},'_D.out'];
    data_phi   = load(file_phi);
    D=data_phi(:,2);
    r=data_phi(:,1);
    plot(r,D,'LineWidth',lw);
    hold on
end
xlabel('$r$ [m]')
ylabel('$D$[V/m]')
grid on
legend('spherique', 'cartesien', 'cylindrique')
title(legend, 'geometrie');
figure
for ii = 1:nsimul
    file_phi   = [output{ii},'_Ddiv.out'];
    data_phi   = load(file_phi);
    D=data_phi(:,2);
    r=data_phi(:,1);
    plot(r,D,'LineWidth',lw);
    hold on
end
xlabel('$r$ [m]')
ylabel('$\nabla\cdot D$[C/m$^3$]')
grid on
legend('spherique', 'cartesien', 'cylindrique')
title(legend, 'geometrie');
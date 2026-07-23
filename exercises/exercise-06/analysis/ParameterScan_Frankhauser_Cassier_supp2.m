
clear; clc; close all;
repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice6_2023_student1_supp.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input = 'configuration_supp.in'; % Nom du fichier d'entrée 

geom = ["sp" "ca" "cy"];
N1 = [200 400 800 1600 3200 6400];
nsimul = numel(N1);
ngeom = numel(geom); % Nombre de simulations a faire:
% numel est une fonction Matlab qui retourne le nombre d'elements d'un tableau.

% Autre exemple: 
%nsteps = round(logspace(2,4,nsimul)); % Nombre d'iterations entier de 10^2 a 10^4
% logspace est une fonction Matlab retournant un tableau de valeurs dont les logarithmes sont equidistants
% tapez 'help logspace' pour plus de details
% Voir aussi la fonction 'linspace'


paramstr1 = 'geom'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param1 = geom;  % Valeurs du parametre a scanner  MODIFIER SELON VOS BESOINS
paramstr2 = 'N1'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param2 = N1;

fl =16;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
%%
output = cell(nsimul, ngeom); % Tableau de cellules contenant les noms des fichiers de sortie
for j = 1:ngeom
   for i = 1:nsimul
       
        output{j}{i} = [paramstr1, '=', num2str(param1(j)), paramstr2, '=', num2str(param2(i)), '.out'];
    % Execution du programme en lui envoyant la valeur a scanner en argument
        cmd = sprintf('%s%s %s %s=%s %s=%.15g output=%s', repertoire, executable, input, paramstr1, param1(j), paramstr2, param2(i), output{j}{i});
        disp(cmd)
        system(cmd);
        disp('Done.')
   end
end
%%
lw=1.5;
Va=1.5;
ra=0.03;
rb=0.05;
R=0.1;
phib=zeros(1, nsimul);
names = strings(1, ngeom);
for k=1:ngeom
    
    for i = 1:nsimul % Parcours des resultats de toutes les simulations
        file_phi   = [output{k}{i},'_phi.out'];
        data = load(file_phi); % Chargement du fichier de sortie de la i-ieme simulation
        [r vv]= min(abs(rb-data(:,1)));
        phib(i)=data(vv,2);
        
    end
    %plot(1./N2, phib,'+-','linewidth',lw) %POUR PLOT LES TRAJECTOIRES
    plot(1./(N2.^2), phib,'+-','linewidth',lw)
    hold on
    names(k)= num2str(N1(k));
end
ylabel('$\phi (r_b)$ $[V]$')
xlabel('$1/N_2^2$')
legend(names);
titre= "coef=";
title(legend,titre);
set(gca,'fontsize',fs)
grid on
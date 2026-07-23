repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice2_student.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input = 'configuration3.in'; % Nom du fichier d'entrée 

%nsteps = [400 500 800 1600];
nsteps = [5000 8000 10000 12000 16000];
nsimul = numel(nsteps); % Nombre de simulations a faire:
% numel est une fonction Matlab qui retourne le nombre d'elements d'un tableau.

% Autre exemple: 
%nsteps = round(logspace(2,4,nsimul)); % Nombre d'iterations entier de 10^2 a 10^4
% logspace est une fonction Matlab retournant un tableau de valeurs dont les logarithmes sont equidistants
% tapez 'help logspace' pour plus de details
% Voir aussi la fonction 'linspace'

tfin = 3.279632924974590e-07;
dt = tfin ./ nsteps;

paramstr = 'nsteps'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param = nsteps;  % Valeurs du parametre a scanner  MODIFIER SELON VOS BESOINS


fl =40;
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
    cmd = sprintf('%s%s %s %s=%.15g output=%s', repertoire, executable, input, paramstr, param(i), output{i});
    disp(cmd)
    system(cmd);
    disp('Done.')
end

%% Analyse %%
lw=1.5; fs=16;
Eerror = zeros(1,nsimul);
figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data  = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
    t     = data(:,1); 
    x     = data(:,2);
    y     = data(:,3);
    z     =data(:,4);
    E     = data(:, 9);
    mu    = data(:,10);
% TODO:  inserer ici les expressions de la solution exacte
    plot(t,mu, LineWidth=lw)
    hold on

end
xlabel('t [s]')
ylabel('$\mu$ [kgms$^{-2}$T$^{-1}$]')
set(gca,'fontsize',fs)
legend('5000', '8000', '10000', '12000', '16000')
title(legend, 'Nstep');
grid on
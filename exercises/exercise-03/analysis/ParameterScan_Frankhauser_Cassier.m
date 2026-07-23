% Ce script Matlab automatise la production de résultats
% lorsqu'on doit faire une série de simulations en
% variant un des paramètres d'entrée.
% 
% Il utilise les arguments du programme (voir ConfigFile.h)
% pour remplacer la valeur d'un paramètre du fichier d'input
% par la valeur désirée.

%% Parametres %%
%%%%%%%%%%%%%%%%

% MODIFIER SELON VOS BESOINS LES NOMS ET LES VALEURS
repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice3_student.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input      = 'configuration.in'; % Nom du fichier d'entrée 
g= 9.81;
L= 0.2;

scan_case = "scan_dt_avec_exc"; % TO BE MODIFIED ACCORDING TO THE KIND OF EXCERSISE

% SWITCH allows to take only one of the cases below, it executes the block
% corresponding to the value of the variable scan_case
switch scan_case

    case 'scan_dt_sans_exc'
        nsteps = [1000 1500 2000 3000 5000 10000];
        tfin = 10; %Verifier que la valeur de tfin est EXACTEMENT la meme que dans le fichier input
        dt = tfin ./ nsteps;
        paramstr = 'dt'; 
        param = dt;  
    
    case 'scan_dt_avec_exc'
        % write here the variables in case of the scan with excitation (vertical displacement of the box activated)
    
    case 'scan_frequency'
        % write here the variables in case of the scan of frequency  
    
    % suggestion: to obtain the Poincare' plot you could iterate on few
    % initial conditions..

end


nsimul = numel(param); % Nombre de simulations a faire:

%% Simulations %% 
%%%%%%%%%%%%%%%%%
% Lance une serie de simulations (= executions du code C++)

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
%%%%%%%%%%%%%
% Ici, on aimerait faire une etude de convergence: erreur fonction de dt, sur diagramme log-log.
% A MODIFIER ET COMPLETER SELON VOS BESOINS


error            = zeros(1,nsimul);
theta_end_vector = zeros(1,nsimul);
max_Emec         = zeros(1,nsimul);
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data        = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
    t           = data(end,1); % the index (i.e. 1,2,4.. ) can change according to how you save data in the c++ code
    theta       = data(end,2);
    thetadot    = data(end,3);
    max_Emec(i) = max(data(:,4));
    % TODO:  inserer ici les expressions de la solution exacte  
    omega0        = 0.0;
    theta_ana     = 0.0;
    theta_dot_ana = 0.0;
    error(i)      =  sqrt((theta-theta_ana).^2+(thetadot-theta_dot_ana).^2 );
    theta_end_vector(i) = theta;
end


switch scan_case

    case 'scan_dt_sans_exc'
    %write the plot instructions

% Si on n'a pas la solution analytique: on représente la quantite voulue
% en fonction de (Delta t)^norder, ou norder est un entier.
    case 'scan_dt_avec_exc'
    %write the plot instructions


    case 'scan_frequency'
    %write the plot instructions
  

end

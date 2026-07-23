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


input = 'configuration.in';
N1       = floor(linspace(10, 5000, 300));
N2       = N1;
nsimul   = numel(N1);
paramstr = 'N'; % Nom du parametre a scanner, par exemple dt, w, x0, etc
param    = [N1;N2]; % Valeurs du parametre a scanner


%% Simulations %%
%%%%%%%%%%%%%%%%%

output = cell(1, nsimul);

for ii = 1:nsimul
    % Variant to scan N1 and N2 together:
    filename  = [paramstr, '=', num2str(param(1,ii))];
    output{ii} = [filename, '.out'];
    eval(sprintf('!%s%s %s %s=%.15g %s=%.15g output=%s', repertoire, executable, input, [paramstr,'1'], param(1,ii), [paramstr,'2'], param(2,ii), output{ii}));
    disp('Done.')
end

%% Analyse %%
%%%%%%%%%%%%%

% Parcours des resultats de toutes les simulations
lw=1.5;
Va=1.5;
ra=0.03;
rb=0.05;
R=0.1;
phith=@(x) Va*log(x/R)/log(ra/R);
phib=zeros(1, nsimul);
for ii = 1:nsimul
    file_phi   = [output{ii},'_phi.out'];
    data_phi   = load(file_phi);
    phib(ii)=abs(data_phi(N1(ii)+1,2)-phith(rb));
    rbtest=data_phi(N1(ii)+1,1);
end
p=polyfit(log(N1),log(phib),1);
f=polyval(p,log(N1));

loglog(N1, phib,'b+', 'Linewidth',  lw);
hold on
loglog(N1,exp(f), 'r--', 'linewidth', lw);

if p(2)>0
    fit = "fit:$y=$"+num2str(p(1))+"$x+$"+num2str(p(2));
else 
    fit = "fit:$y=$"+num2str(p(1))+"$x$"+num2str(p(2));
end

title(legend, '$N_1=N_2$');
legend('data', fit);
xlabel('$N_1$');
ylabel('$\phi (r_b)$')
grid on
%name{2*j} = ['name' string(fit)];
%name{2*j+1} =['name' string(simualtions)];
%legend(gca,'show');
% 


repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice2_student.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input = 'configuration3.in'; % Nom du fichier d'entrée 

nsteps = [400 500 800 1600];
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
    %mu    = data(:,10);
% TODO:  inserer ici les expressions de la solution exacte
    Eerror(i)=E(end,1);
    plot(t,E, LineWidth=lw)
    hold on

end
xlabel('t [s]')
ylabel('$E_{mec}$ [J]')
set(gca,'fontsize',fs)
legend('200', '400', '800', '1600', '3200', '6400')
title(legend, 'Nstep');
grid on
% lw=1.5; fs=16;
% figure
% p=polyfit(dt,xnorm,2);
% f=polyval(p,dt);
% plot(dt, xnorm,'black+', 'LineWidth', lw)
% hold on
% plot(dt,f, '--', 'linewidth', lw)
% set(gca,'fontsize',fs)
% xlabel('$\Delta$t [s]')
% ylabel('norme de la position finale $|\vec{x}(t_{fin})|$ [m]')
% if p(2)>0 && p(3)>0
%    fit = sprintf('fit:$y=$%0.5g$x^2+$%0.5g$x+$%s',p(1),p(2),p(3));
% elseif p(2)>0 && p(3)<0
%    fit = sprintf('fit:$y=$%0.5g$x^2+$%0.5g$x$%s',p(1),p(2),p(3));
% elseif p(2)<0 && p(3)<0
%     fit = sprintf('fit:$y=$%0.5g$x^2$%0.5g$x$%s',p(1),p(2),p(3));
% else
%     fit = sprintf('fit:$y=$%0.5g$x^2$%0.5g$x+$%s',p(1),p(2),p(3));
% end
% legend('simulation en euler semi explicite: norme de la position finale',fit)
% grid on
% % set(gca, 'YScale', 'log')
% hold off
lw=1.5; fs=16;
figure
p=polyfit(dt,Eerror,1);
f=polyval(p,dt);
plot(dt, Eerror,'black+', 'LineWidth', lw)
hold on
plot(dt,f, '--', 'linewidth', lw)
set(gca,'fontsize',fs)
xlabel('$\Delta$t [s]')
ylabel('$|E_{mec}(t_{fin})|$ [J]')
if p(2)>0
   fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p(1),p(2));
else 
   fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p(1),p(2));
end
legend('simulation: Energie mécanique finale',fit)
grid on
% set(gca, 'YScale', 'log')
hold off

error = abs(Eerror - p(2));

figure
p1=polyfit(log(dt),log(error),1);
f1=polyval(p1,log(dt));
loglog(dt, error, 'black+', 'linewidth',lw)
hold on
loglog(dt,exp(f1), '--', 'linewidth', lw-1)
set(gca,'fontsize',fs)
xlabel('$\Delta$t [s]')
ylabel('$|\Delta E_{mec}(t_{fin})|$ [J]')
if p1(2)>0
   fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p1(1),p1(2));
else 
   fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p1(1),p1(2));
end
legend('erreur sur l''énergie finale ',fit)
grid on
hold off

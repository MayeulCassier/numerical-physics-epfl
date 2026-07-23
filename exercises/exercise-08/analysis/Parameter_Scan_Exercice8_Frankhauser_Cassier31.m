repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice8_2023_student.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input      = 'configuration21.in'; % Nom du fichier d'entrée 

close all;
%nsteps = [10 20 30 40 50];
n = [20 33 50];
%nsteps = [100 150 200 300 500 1000];
%nsteps = [1000 1500 2000 3000 5000 10000];

paramstr = 'n'; 
param = n;  

fl =16;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
nsimul = numel(param); % Nombre de simulations a faire:
output = cell(1, nsimul);
for i = 1:nsimul
    output{i} = [paramstr, '=', num2str(param(i)), '.out'];
end
%% Simulations %% 
%%%%%%%%%%%%%%%%%
% Lance une serie de simulations (= executions du code C++)

 % Tableau de cellules contenant les noms des fichiers de sortie
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
%close all;
lw=1.5; fs=16;
errorxmoy            = zeros(1,nsimul);
errorpmoy            = zeros(1,nsimul);
errordx            = zeros(1,nsimul);
errordp            = zeros(1,nsimul);
titre            = string([1 nsimul]);
Vmax= 0.222222 ;
figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data  = load([output{i},'_obs.out']);
    t     = data(:,1);
    P1    = data(:,2);
    P2    = data(:,3);
    E     = data(:,4);
    xmoy  = data(:,5);
    errorxmoy(i)=xmoy(end);
    x2moy = data(:,6);
    pmoy  = data(:,7);
    errorpmoy(i)=pmoy(end);
    p2moy = data(:,8);
    data  = load([output{i},'_pot.out']);
    x     = data(:,1);
    V     = data(:,2);
    
    wave  = reshape(load([output{i},'_psi2.out']), length(t), 3, length(x));
    psi2  = squeeze(wave(:, 1, :));
    real  = squeeze(wave(:, 2, :));
    imag  = squeeze(wave(:, 3, :));
    
    % Uncertainty in x, p; eqs. (9-10-11)
    dx = sqrt(x2moy - xmoy.^2);
    errordx(i)=dx(end);
    dp = sqrt(p2moy - pmoy.^2);
    errordp(i)=dp(end);
    uncertainty = dx .* dp;
    
    plot(t,E./Vmax, 'linewidth',lw)
    titre(i)=num2str(param(i));
    hold on
end
set(gca,'fontsize',fs)
xlabel('$t$ [s]')
ylabel('$\langle E\rangle/V_{\rm max}$ $(t)$ [J]')
%title(titre);
legend(titre,'Location','north','NumColumns',4);
%legend('1600','3200','6400','12800','25600')
grid on
% set(gca, 'YScale', 'log')
title(legend, '$n$');
hold off

%% evol
% stride=30;
% fps=100;
% figure;
% hold on;
% 
% ylabel('$\psi$ [arb.]');
% xlabel('$x$ [arb.]');
% ylim([yMin-0.1 yMax+0.1])
% xlim([-150 150])
% for n=1:stride:length(t)
%     title(sprintf('Wave packet for frame %d/%d', n, length(t)));
%     cla; % Clear drawing
%     series = [];
%     series(1) = plot(x, sqrt(psi2(n, :)));
%     series(2) = plot(x, real(n, :));
%     series(3) = plot(x, imag(n, :));
%     labels = {'$\psi^2$', '$Re(\psi )$', '$Im(\psi )$'};
%     series(4) = plot(x,V-0.2);
%     labels{4}= 'Potential Wall';
%     % Draw potential well
% %     if VmaxIndex > VminIndex
% %         xPatch = [x(VminIndex), x(VmaxIndex), x(VmaxIndex), x(VminIndex)];
% %         yPatch = [yMin, yMin, yMax, yMax];
% %         series(4) = patch(xPatch, yPatch, [0.6350, 0.0780, 0.1840]);
% %         labels{4} = 'Potential well';
% %     end
%     legend(series, labels);
%     pause(1.0/fps);
% end
%%
ptrans=zeros(1,nsimul);
t_trans=301;

for i = 1:nsimul
    data  = load([output{i},'_obs.out']);
    t     = data(:,1);
    P1    = data(:,2);
    P2    = data(:,3);
    E     = data(:,4);
    xmoy  = data(:,5);
    errorxmoy(i)=xmoy(end);
    x2moy = data(:,6);
    pmoy  = data(:,7);
    errorpmoy(i)=pmoy(end);
    p2moy = data(:,8);
    data  = load([output{i},'_pot.out']);
    x     = data(:,1);
    V     = data(:,2);
    %calcul t_trans;
    ptrans(i)=P2(t_trans);
    wave  = reshape(load([output{i},'_psi2.out']), length(t), 3, length(x));
    psi2  = squeeze(wave(:, 1, :));
    real  = squeeze(wave(:, 2, :));
    imag  = squeeze(wave(:, 3, :));
    
    % Uncertainty in x, p; eqs. (9-10-11)
    dx = sqrt(x2moy - xmoy.^2);
    errordx(i)=dx(end);
    dp = sqrt(p2moy - pmoy.^2);
    errordp(i)=dp(end);
    uncertainty = dx .* dp;
    figure
    pcolor(x,t,sqrt(psi2))
    xlabel('$x$ [m]')
    ylabel('$t$ [s]')
    shading interp
    colorbar();
    title("$|\psi |$ pour $n=$"+num2str(n(i)))
    
    figure
    plot(t,P1,t,P2,t,P1+P2)
    %plot(t,P1,t,P2)
    grid on
    xlabel('$t$ [s]')
    ylabel('Probabilite')
    legend('$P_{x<x_0}$','$P_{x>=x_0}$','$P_{tot}$')
    title("probabilite pour le cas $n=$"+num2str(n(i)))
end
erreur_max_probtot=max(abs(P1+P2-1));
erreur_max_E=max(abs(E-E(1)));

figure
plot(n,ptrans)
%plot(t,P1,t,P2)
grid on
xlabel('$n$ [s]')
ylabel('Probabilite')
legend('$P_{x>=x_0}$')

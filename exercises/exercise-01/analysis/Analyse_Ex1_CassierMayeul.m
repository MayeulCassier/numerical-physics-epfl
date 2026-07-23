% Nom du fichier d'output a analyser (modifiez selon vos besoins)
filename = 'output.out'; 

% Chargement des donnees
data = load(filename);

% Extraction des quantites d'interet
% (Le code c++ ecrit t, x(t), v(t), E_mec(t)  ligne par ligne, 
%  une ligne par pas de temps)
t    = data(:,1); 
mF   = data(:,2);
x    = data(:,3);
v    = data(:,4);
Emec = data(:,5);
P    = data(:,6);   


% nombre de pas de temps effectués:
nsteps = length(t);

% longueur du pas de temps:
dt = t(2)-t(1);

% Figures
% line width and font size (utile pour la lisibilité des figures dans le
% rapport)
lw=2; fs=16; 
figure('Name', [filename ': x(t)'])
plot(t, x, '-','linewidth',lw)
set(gca,'fontsize',fs)
xlabel('t [s]')
ylabel('x [m]')
grid on

figure('Name', [filename ': v(t)'])
plot(t, v, '-','linewidth',lw)
set(gca,'fontsize',fs)
xlabel('t [s]')
ylabel('v [m/s]')
grid on

figure('Name', [filename ': (x,v)'])
plot(x, v, '-','linewidth',lw)
set(gca,'fontsize',fs)
xlabel('x [m]')
ylabel('v [m/s]')
grid on

figure('Name', [filename ': Emec(t)'])
plot(t, Emec, '-','linewidth',lw)
set(gca,'fontsize',fs)
xlabel('t [s]')
ylabel('Emec [J]')
grid on

%% Voici un exemple de script pour les etudes de convergence:
%% Mettez/le dans un autre fichier .m, et decommentez les lignes
% nsteps_num  = [... ... ... ... ...]; % vous complétez ici 'a la main' 
% xfin_num = [... ... ... ... ...]; % vous complétez ici 'a la main' 
% lw=2; fs=16;
% figure
% plot(1./nsteps_num, vfin_num, 'k+-','linewidth',lw)
% set(gca,'fontsize',fs)
% xlabel('1/N_{steps}')
% ylabel('v_{final}')
% grid on
%
% si on a la solution analytique:
% vfin_ana = ...; % à compléter
% error_vfin = vfin_num-vfin_ana;
% figure
% plot(nsteps_num, abs(error_vfin),'k+-')
% set(gca,'fontsize',fs)
% set(gca,'xscale','log')
% set(gca,'yscale','log')
% xlabel('N_{steps}')
% ylabel('Error on v_{fin}')
% grid on



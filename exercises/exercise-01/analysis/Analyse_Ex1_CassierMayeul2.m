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
fl =40;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
% nombre de pas de temps effectués:
nsteps = length(t);
% longueur du pas de temps:
dt = t(2)-t(1);

% Figures
% line width and font size (utile pour la lisibilité des figures dans le
% rapport)
dEmec = zeros(1, nsteps-2)
lw=2; fs=16; 
for i= 1:(nsteps-2) 
    dEmec(i)=-(Emec(i)-Emec(i+2))/(2*dt);
end


t1 = t(1:nsteps-2)

figure
plot(t, P, 'r+','linewidth',lw)
hold on
plot(t1, dEmec, 'b--', 'linewidth', lw )
set(gca,'fontsize',fs)
xlabel('t [s]')
ylabel('[Watt]')
legend('$P_{NC}$','$dE_{mec}/dt$')
grid on
err = zeros(1, nsteps-2);

P1=zeros(1,nsteps-2);
for i=1:(nsteps-2)
    P1(i)=P(i+1);
end
for i=1:(nsteps-2)
    err(i)= P1(i)-dEmec(i);
end
figure
plot(t1, err, 'b-', 'linewidth', lw )
set(gca,'fontsize',fs)
xlabel('t [s]')
ylabel('[Watt]')
legend('$|P_{NC}-\frac{dE_{mec}}{dt}|$')
grid on

% figure('Name', [filename ': x(t)'])
% plot(t, x, '-','linewidth',lw)
% set(gca,'fontsize',fs)
% xlabel('t [s]')
% ylabel('x [m]')
% grid on

% figure('Name', [filename ': v(t)'])
% plot(t, v, '-','linewidth',lw)
% set(gca,'fontsize',fs)
% xlabel('t [s]')
% ylabel('v [m/s]')
% grid on
% 
% figure('Name', [filename ': (x,v)'])
% plot(x, v, '-','linewidth',lw)
% set(gca,'fontsize',fs)
% xlabel('x [m]')
% ylabel('v [m/s]')
% grid on
% 
% figure('Name', [filename ': Emec(t)'])
% plot(t, Emec, '-','linewidth',lw)
% set(gca,'fontsize',fs)
% xlabel('t [s]')
% ylabel('Emec [J]')
% grid on

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



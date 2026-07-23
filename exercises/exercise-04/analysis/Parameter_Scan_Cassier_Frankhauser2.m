repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice4_apollo.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input      = 'configuration2.in'; % Nom du fichier d'entrée 

g= 9.81;
mA=5800;
rA=2;
mT=5.972e24;
rT= 6378.1e3;
rho0=0;
G=6.674e-11;
r0=310000e3;
v0=1.25e3;
6.406797587174716e+06;
vmaxth=sqrt(v0^2+2*G*mT*(1/rT - 1/r0));
%nsteps = [1000000];
nsteps = round(linspace(5000,10000,1000));
nsimul = length(nsteps); % Nombre de simulations a faire
% autre exemple: 
%nsteps = round(logspace(2,4,nsimul)); % Nombre d'iterations entier de 10^2 a 10^4
tfin = 3*24*60*60; % TODO: Verifier que la valeur de tfin est EXACTEMENT la meme que dans le fichier input
alpha=asin(vmaxth*(rT+rA)/(r0*v0));
a=0.184307750740664;
v0xth= cos(alpha)*v0; v0yth=sin(alpha)*v0;
a2=1.228829189944620e+03; a3=2.290825657706174e+02;
fl =40;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
paramstr = 'nsteps'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param = nsteps; % Valeurs du parametre a scanner  MODIFIER SELON VOS BESOINS
dt = tfin./nsteps;
%% Simulations %% 
%%%%%%%%%%%%%%%%%
% Lance une serie de simulations (= executions du code C++)
% Normalement, on ne devrait pas avoir besoin de modifier cette partie
close all;
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
close all;
lw=1.5; fs=16;


npi = linspace(0,2*pi,35);

%dt = zeros(1,nsimul);

errorvmax = zeros(1,nsimul);
figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
    t   = data(:,1);
    xA  = data(:,2);
    yA  = data(:,3);
    plot(xA, yA,'-','linewidth',lw) %POUR PLOT LES TRAJECTOIRES
    hold on
end
plot(rT*cos(npi), rT*sin(npi), 'black', 'linewidth',lw) %TRACER LA TERRE
axis equal
grid on
xlabel('$x$ [m]')
ylabel('$y$ [m]')
set(gca,'fontsize',fs)
lgd =legend( '10000','location','best');
title(legend, '$N_{step}$');
error = zeros(1,nsimul);
mini = zeros(1,nsimul);

figure
for i= 1:nsimul
    data = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
    t   = data(:,1);
    xA  = data(:,2);
    yA  = data(:,3);


    rmin=sqrt(xA.^2+yA.^2);
    [M, Ivi]=min(rmin);
        k=10;
        range_1 =Ivi-k;
        range_2 = Ivi+k;
        d= rmin(range_1:range_2,:);
        t1= t(range_1:range_2,:);
    %plot(t, d,'--','LineWidth',lw )%PLOT LES RAYONS MIN
    p=polyfit(t1,d,2);
    f=polyval(p,t1);
    a = p(1);
    b= p(2);
    c= p(3);
    B= -b/(2*a);
    mini(i) = a*B*B+b*B+c;
    error(i)=abs(rT+rA-mini(i));
     hold on
    plot(t(Ivi),mini(i), 'k+')
    plot(t1, f, '--','LineWidth',lw)
   
end
xlabel('$r_{min}$ [m]')
ylabel('$t$ [s]')
set(gca,'fontsize',fs)
legend( 'minimas','location','best');
%title(legend, '$N_{step}$');
grid on
hold off

figure
errorvmaxinterpole = zeros(1,nsimul);
vmaxi = zeros(1,nsimul);
for i= 1:nsimul
    data = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
    t   = data(:,1);
    vxA = data(:,4);
    vyA = data(:,5);
    acc = data(:,9);


    vmax=sqrt(vxA.^2+vyA.^2);
    [Mv, Iviv]=max(vmax);
        k=15;
        range_1 =Iviv-k;
        range_2 = Iviv+k;
        d= vmax(range_1:range_2,:);
        t1= t(range_1:range_2,:);
    %plot(t, d,'--','LineWidth',lw )%PLOT LES RAYONS MIN
    p=polyfit(t1,d,2);
    f=polyval(p,t1);
    
    a = p(1);
    b= p(2);
    c= p(3);
    B= -b/(2*a);
    vmaxi(i) = a*B*B+b*B+c;
    errorvmax(i)=abs(max(sqrt(vxA.^2+vyA.^2))-vmaxth);
    errorvmaxinterpole(i)= abs(vmaxth-vmaxi(i));
     hold on
    plot(t(Iviv),vmaxi(i), 'k+');
   plot(t1, f, '--','LineWidth',lw)
end
xlabel('$v_{max}$ [m.s$^{-1}$]')
ylabel('$t$ [s]')
set(gca,'fontsize',fs)
legend( 'maximas','location','best');
%title(legend, '$N_{step}$');
grid on
hold off


errorhmin= zeros(1,nsimul);
minimum= zeros(1,nsimul);
%%
figure
for i= 1:nsimul
    data = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
    t   = data(:,1);
    xA  = data(:,2);
    yA  = data(:,3);
   
    rmin=abs(sqrt(xA.^2+yA.^2));
    plot (t, rmin, 'LineWidth',lw);
    minimum(i)=min(rmin);
    errorhmin(i)=abs(rT+rA-minimum(i));
    hold on
end
ylabel('$r_{min}$ [m]')
xlabel('$t$ [s]')
set(gca,'fontsize',fs)
%legend( 'maximas','location','best');
%title(legend, '$N_{step}$');
grid on
hold off
%% SEPARATION %%
figure
plot(rmin,acc,'LineWidth',lw);
set(gca,'fontsize',fs)
grid on
xlabel('$r$ [m]')
ylabel('acc\''el\''eration [m.s$^{-2}$]')
legend( '10000','location','best');
title(legend, '$N_{step}$');


figure 
loglog(dt, errorhmin, 'k+', 'linewidth',lw)
hold on
p1=polyfit(log(dt),log(errorhmin),1);
f1=polyval(p1,log(dt));
set(gca,'fontsize',fs)
loglog(dt,exp(f1), 'r--', 'linewidth', lw)
grid on
xlabel('$\Delta t [s]$')
ylabel('$\Delta r_{min}$ [m] brut')
hold off
if p1(2)>0
    fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p1(1),p1(2));
else 
    fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p1(1),p1(2));
end
legend('Simulations',fit);
hold off


limsup=1000;
liminf=1;
figure 
loglog(dt, error, 'k+', 'linewidth',lw)
hold on
p2=polyfit(log(dt(liminf:limsup)),log(error(liminf:limsup)),1);
f2=polyval(p2,log(dt(liminf:limsup)));
loglog(dt(liminf:limsup),exp(f2), '--', 'linewidth', lw)
grid on
xlabel('$\Delta t [s]$')
ylabel('$\Delta r_{min}$ [m] trait\''e')
set(gca,'fontsize',fs)
if p2(2)>0
    fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p2(1),p2(2));
else 
    fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p2(1),p2(2));
end
legend('Simulations',fit);
hold off

figure 
loglog(dt, errorvmax , 'k+', 'linewidth',lw)
hold on
p3=polyfit(log(dt),log(errorvmax),1);
f3=polyval(p3,log(dt));
loglog(dt,exp(f3), '--', 'linewidth', lw)
grid on
xlabel('$\Delta t [s]$')
ylabel('$\Delta v_{max}$ [m.s$^{-1}$] brut')
set(gca,'fontsize',fs)
if p3(2)>0
    fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p3(1),p3(2));
else 
    fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p3(1),p3(2));
end
legend('simulations',fit);
hold off

%%
limsup=1000;
liminf=750;
figure 
loglog(dt, errorvmaxinterpole, 'k+', 'linewidth',lw)
hold on
p2=polyfit(log(dt(liminf:limsup)),log(errorvmaxinterpole(liminf:limsup)),1);
f2=polyval(p2,log(dt(liminf:limsup)));
loglog(dt(liminf:limsup),exp(f2), '--', 'linewidth', lw)
grid on
xlabel('$\Delta t [s]$')
ylabel('$\Delta v_{max}$ [m.s$^{-1}$] trait\''e')
set(gca,'fontsize',fs)
if p2(2)>0
    fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p2(1),p2(2));
else 
    fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p2(1),p2(2));
end
legend('simulations',fit);
hold off
% figure
% p=polyfit(log(dt),log(error),1)
% f=polyval(p,log(dt))
% loglog(dt, error, 'r+', 'linewidth',lw)
% hold on
% plot(dt,exp(f), '--', 'linewidth', lw)
% set(gca,'fontsize',fs)
% xlabel('\Delta t [s]')
% ylabel('Erreur sur la position finale [m]')
% grid on
% hold off
% 
% figure
% p1=polyfit(log(dt),log(error1),1)
% f1=polyval(p1,log(dt))
% loglog(dt, error1, 'r+', 'linewidth',lw)
% hold on
% plot(tfin./nsteps,exp(f1), '--', 'linewidth', lw)
% set(gca,'fontsize',fs)
% xlabel('\Delta t [s]')
% ylabel('\Delta E_{mec}[J]')
% grid on
% hold off



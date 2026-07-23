%% Chargement des résultats %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all;
fl =16;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
Va=1.5;
ra=0.03;
R=0.1;

fichier_phi = 'output_phi.out';
fichier_E   = 'output_E.out';
fichier_D   = 'output_D.out';
fichier_Ddiv   = 'output_Ddiv.out';
data = load(fichier_phi);
r=data(:,1);
phi=data(:,2);

data = load(fichier_E);
rmid=data(:,1);
E=data(:,2);

data = load(fichier_D);
D=data(:,2);
data = load(fichier_Ddiv);
Ddiv=data(:,2);
rmidmid=data(:,1);

%% Figures %%
%%%%%%%%%%%%%
figure
h = plotyy(r,phi,rmid,E);
xlabel('$r$ [m]')
ylabel(h(1),'$\phi$ [V]')
ylabel(h(2),'$E_{r}$ [V/m]')
title('Potentiel electrique $\phi=\phi(r)$ et champ electrique $E_{r}=E_{r}(r)$')

grid

figure
h = plotyy(rmid,D,rmid,E);
xlabel('$r$ [m]')
ylabel(h(1),'$D_{r}/ \epsilon_{0}$ [V/m]')
ylabel(h(2),'$E_{r}$ [V/m]')
title('champ de deplacement $D_{r}=D_{r}(r)$ et champ electrique $E_{r}=E_{r}(r)$')

grid


%% Verification of continuity equation
%%%%%%%%%%%%%%%

%% TO DO: Compute div_D with forward finite differences
ii  = 1:(length(rmid)-1);
div_D   = 0*ii;

%% TO D0: Compute the free charge profile /eps_0 with an handle func
%%        (See MATLAB documentation for handle func)         
rho = @(x) 0*x;
phith=@(x) Va*log(x/R)/log(ra/R);
figure('Name','Equation de continuité')
plot(rmidmid,Ddiv,'b.')
xlabel('$r$ [m]')
ylabel('$\nabla \cdot D$[C/m$^{3}$]')
grid
hold on
plot(r,rho(r),'r')
legend('$\nabla \cdot D$','$\rho(r)$')
hold off

figure
plot(r,phi, 'r')
hold on 
plot(r, phith(r),'b.')
xlabel('$r$ [m]')
ylabel('$\phi$[V]')
legend('$\phi_{\rm exp}$', '$\phi_{\rm th}$')
grid on

figure
plot(r,abs(phi-phith(r)), 'r+-')
xlabel('$r$ [m]')
ylabel('$\Delta\phi$[V]')
grid on

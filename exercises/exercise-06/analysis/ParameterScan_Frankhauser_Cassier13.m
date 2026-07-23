%% Chargement des résultats %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; 
fl =16;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
Va=1.5;
R=0.10;
ra=0.03;
rb=0.05;
A=2e4;
epsilon0= 8.85418782*10^(-12);
fichier_phi = 'output_phi.out';
fichier_E   = 'output_E.out';
fichier_D   = 'output_D.out';
fichier_Ddiv   = 'output_Ddiv.out';
data = load(fichier_phi);
r=data(:,1);
phi=data(:,2);
%diag=data(:,3);
oh= r(2: end)-r(1:end-1);
data = load(fichier_E);
rmid=data(:,1);
E=data(:,2);
%h=data(:,3);

data = load(fichier_D);
D=data(:,2);
%upper=data(:,3);
%lower=data(:,4);
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

grid on
figure 
plot(rmid,D)
grid on
xlabel('$r$ [m]')
ylabel('$D$')

%% Verification of continuity equation
%%%%%%%%%%%%%%%

%% TO DO: Compute div_D with forward finite differences
ii  = 1:(length(rmid)-1);
div_D   = 0*ii;

%% TO D0: Compute the free charge profile /eps_0 with an handle func
%%        (See MATLAB documentation for handle func)

syms rho(x)

Dmath=2*(rmid(2:end).*D(2:end)-rmid(1:end-1).*D(1:end-1))./((rmidmid.*(rmid(2:end)-rmid(1:end-1))));

DE=2*(rmid(2:end).*E(2:end)-rmid(1:end-1).*E(1:end-1))./((rmidmid.*(rmid(2:end)-rmid(1:end-1))));
rhopaslib=DE-Dmath;
y=1;
rho(x) = piecewise((x>=ra) & (x<rb), y.*4.*A.*(x-ra).*(rb-x)./((rb-ra)^2), 0);
rhocpp = data(:,3);
figure('Name','Equation de continuité')
plot(rmidmid,Ddiv,'b')
xlabel('$r$ [m]')
ylabel('$\nabla \cdot D$[C/m$^{3}$]')
grid
hold on
plot(rmidmid,rhocpp,'r.')
legend('$\nabla \cdot D^{exp}$','$\rho_{\rm lib}$')
hold off

figure
plot(rmidmid,rhopaslib, '.')
xlabel('$r$ [m]')
ylabel('$\rho_{\rm pol}/\epsilon_0$')
grid on


figure('Name','Equation de continuité')
plot(rmidmid,abs(Ddiv-rhocpp),'b.')
xlabel('$r$ [m]')
ylabel('$\Delta\nabla \cdot D$[C/m$^{3}$]')
grid on


figure
plot(r,phi, 'r')
xlabel('$r$ [m]')
ylabel('$\phi$[V]')
legend('$\phi_{\rm exp}$')
grid on
Q=0;
N1=5000;
Q_pol = (rhopaslib(N1)*rmidmid(N1)*(rmidmid(N1+1) - rmidmid(N1- 1)) /2)* epsilon0 / (0.05);
for i=1:(N1-1)
    Q= Q+oh(i)*(rmidmid(i+1)*rhopaslib(i+1)+rmidmid(i)*rhopaslib(i));
end
Q=Q*pi*epsilon0;
% 
% epsilon= data(:,4);
% figure 
% plot(rmidmid, epsilon)
% xlabel('r')
% ylabel('$\epsilon$')
% grid on
%%
% figure 
% plot(rmidmid, Ddiv)
% xlabel('r')
% ylabel('$div D$')
% grid on
% figure 
% plot(rmidmid, Dmath)
% xlabel('r')
% ylabel('$div1 D$')
% grid on
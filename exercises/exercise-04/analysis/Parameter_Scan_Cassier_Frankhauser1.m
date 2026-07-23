data = load('output2.out');
g= 9.81;
m=5.972*10^(24);
gamma=1.4;
rho0=1.2;
P0=10^5;
C=P0*rho0^(-gamma);
z0=gamma*P0*(1/((gamma-1)*rho0*g));
alpha=1/(gamma-1);
A=(C*gamma*alpha*1/g)^(-alpha);
epsilon= (10^(-6)*rho0/A)^(1/alpha);


zfin=z0-epsilon;
nsteps=100;
dz=zfin/nsteps;
close all;

fl =40;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);


%% Analyse %%
%%%%%%%%%%%%%
% Ici, on aimerait faire une etude de convergence: erreur fonction de dt, sur diagramme log-log.
% A MODIFIER ET COMPLETER SELON VOS BESOINS

z   = data(:,1);
rho  = data(:,2);


lw=1.5; fs=16;

rhoana = @(x) (rho0^(gamma-1)-g*(gamma-1)*x/(C*gamma)).^(1/(gamma-1));
plot(z, rho, 'k+-', 'linewidth',lw);
hold on
plot(z, rhoana(z),'r--', 'linewidth',lw);
set(gca,'fontsize',fs)
xlabel('$z$ [m]')
ylabel('$\rho$ [kg.m$^{-3}$]')
%title(titre);
legend('$\rho_{num}$', '$\rho_{exact}$');
%legend('1600','3200','6400','12800','25600')
grid on
% set(gca, 'YScale', 'log')
title(legend, '$N_{step}=100$');
hold off

rhoerror=rho-rhoana(z);
figure
plot(z, rhoerror, 'Linewidth', lw);
set(gca,'fontsize',fs)
xlabel('$z$ [m]')
ylabel('$\rho_{exact}(z) - \rho_{num}(z)$ [kg.m$^{-3}$]')
title(legend, '$N_{step}$');
legend({'100'},'Location','northwest');
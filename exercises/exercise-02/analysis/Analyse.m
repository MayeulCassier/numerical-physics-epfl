% close all
% Nom du fichier d'output a analyser (TODO: modifier selon vos besoins)
filename = 'output.out';

% Chargement des donnees
output = load(filename);

% Extraction des quantites d'interet 
% TODO: verifier la consistance avec l'ecriture du fichier output par le code  C++
t  = output(:,1);
x  = output(:,2);
y  = output(:,3);
z  = output(:,4);
vx = output(:,5);
vy = output(:,6);
vz = output(:,7);
mu = output(:,8);
E  = output(:,9);

% Figures%conserve l'espace de phase
fs=16; % font size
lw=2;  % linewidth

figure

% Si on veut faire une figure combinée de 4 sous-figures, 
% enlever le commentaire des lignes %subplot(...)
% et commenter les lignes 'figure' CI-APRES
% subplot(2,2,1) % array 2x2 of subfigures, 1st subfigure

plot(x,y,'linewidth',lw)
set(gca,'fontsize',fs)
axis equal
grid on
xlabel('x [m]')
ylabel('y [m]')

figure
%subplot(2,2,2) % array 2x2 of subfigures, 2nd subfigure
plot(vx,vy,'linewidth',lw)
set(gca,'fontsize',fs)
axis equal
grid on
xlabel('v_x [m/s]')
ylabel('v_y [m/s]')

figure
%subplot(2,2,3) % array 2x2 of subfigures, 3rd subfigure
plot(t,x,t,y,'linewidth',lw)
set(gca,'fontsize',fs)
grid on
xlabel('t [s]')
ylabel('x,y [m]')
legend('x','y')

figure
%subplot(2,2,4) % array 2x2 of subfigures, 4th subfigure
plot(t,vx,t,vy,'linewidth',lw)
set(gca,'fontsize',fs)
grid on
xlabel('t [s]')
ylabel('v_x,v_y [m/s]')
legend('v_x','v_y')


figure
plot(t,E,'linewidth',lw)
set(gca,'fontsize',fs)
grid on
xlabel('t [s]')
ylabel('E_{mec} [J]')
title('Energie')

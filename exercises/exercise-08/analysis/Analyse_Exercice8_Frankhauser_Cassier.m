%eval(sprintf('!make student'))
eval(sprintf('!Exercice8_2023_student.exe'))
%%
fl =16;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);


%% Chargement des resultats %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fichier = 'output';
data  = load([fichier,'_obs.out']);
t     = data(:,1);
P1    = data(:,2);
P2    = data(:,3);
E     = data(:,4);
xmoy  = data(:,5);
x2moy = data(:,6);
pmoy  = data(:,7);
p2moy = data(:,8);
data  = load([fichier,'_pot.out']);
x     = data(:,1);
V     = data(:,2);

wave  = reshape(load([fichier,'_psi2.out']), length(t), 3, length(x));
psi2  = squeeze(wave(:, 1, :));
real  = squeeze(wave(:, 2, :));
imag  = squeeze(wave(:, 3, :));

% Uncertainty in x, p; eqs. (9-10-11)
dx = sqrt(x2moy - xmoy.^2);
dp = sqrt(p2moy - pmoy.^2);
uncertainty = dx .* dp;

%% Figures %%
%%%%%%%%%%%%%
figure
hold on;
plot(x,V)
plot(x, E(1) * ones(size(x)));
grid on
xlabel('$x$ ')
ylabel('$V(x)$ ')
legend('$V(x)$', '$E(t=0)$');

figure
plot(t,P1,t,P2,t,P1+P2)
%plot(t,P1,t,P2)
grid on
xlabel('$t$ [s]')
ylabel('Probability')
legend('$P_{x<x_0}$','$P_{x>=x_0}$','$P_{tot}$')

figure
pcolor(x,t,sqrt(psi2))
xlabel('$x$ [m]')
ylabel('$t$ [s]')
shading interp
colorbar();
title("valeure absolue")

figure
pcolor(x,t,real)
xlabel('$x$ [m]')
ylabel('$t$ [s]')
shading interp
colorbar();
title("partie reelle")

figure
pcolor(x,t,imag)
xlabel('$x$ [m]')
ylabel('$t$ [s]')
shading interp
colorbar();
title("partie imaginaire")


n=1;
figure
plot(x,real(n, :),x,imag(n, :),x,sqrt(psi2(n, :)))
xlabel('$t$ [s]')
ylabel('$\psi$')
legend('Re($\psi$)','Im($\psi$)','$|\psi|$')
grid on
grid minor
%%
w2=0.02;
T2=pi/w2;
w1=0.01;
T1=pi/w1;
AAA=sqrt(1/(2*w1));
%B=max(pmoy)/w1;
m=1;
Emax=max(E);
xana = zeros(size(t));
pana= zeros(size(t));
B= sqrt(2*Emax/m)/w1;
% for i=1:numel(t)



%     if(0<t(i) && t(i)<T2)
%     xana(i)=B*sin(w2*t(i));
%     pana(i)=B*w2*cos(w2*t(i));
%     end
% %     if(T2<t(i) && t(i) <T2+T1)
% %       xana(i)=B*sin(w1*t(i))+10;
% %       pana(i)=B*w1*cos(w1*t(i));
% %     end
% end
%E= 0.5mv2 et p=m*v implies v = sqrt(2*E/m)=p/m=B*w2

for i=1:numel(t)
    
    xana(i)=B*sin(w1*t(i));
    pana(i)=B*w1*cos(w1*t(i));
end
%%
% delta =0;
% Vana=zeros(size(x));
% for i=1:size(x)
%     Vana(i)= min(0.5*w1^2*(x(i)+delta)^2,0.5*w2^2*(x(i)-delta)^2);
% end
% figure
% plot(x, Vana)
% diffmaxV=max(Vana-V)
%%
%B*sin(w1.*t));
figure
plot(t,xmoy,t,xana); %,t, B*sin(w1.*t), t,B*sin(w2.*t)
xlabel('$t$ [s]')
ylabel('$\langle x\rangle $')
legend('$\langle x\rangle $','$x(t)_{\rm analytique }$')
grid on

figure
plot(t,pmoy,t,pana);
xlabel('$t$ [s]')
ylabel('$\langle p\rangle $')
legend('$\langle p \rangle $','$p(t)_{\rm analytique }$')
grid on
%%



figure
plot(t,xmoy,t,x2moy,t,pmoy,t,p2moy);
xlabel('$t$ [s]')
ylabel('$\psi$')
legend('$\langle x\rangle $','$\langle x^2\rangle $','$\langle p\rangle $','$\langle p^2 \rangle $')
grid on

figure
plot(t, uncertainty);
hold on
plot(t,0.5*t./t);
xlabel('$t$ [s]')
ylabel('incertitude')
legend('$\langle \Delta x \rangle \cdot \langle \Delta p \rangle$','$h_{bar}/2$')
grid on

figure
plot(t, E);
xlabel('$t$ [s]')
ylabel('$\langle E \rangle$ [J]')
grid on

%% la grande figure %%
%%%%%%%%%%%%%%%%%%%%%%
figure('Name',['Analyse de ' fichier]) %,'Position',[300,500,1200,1800]
subplot(3,2,1)
hold on;
plot(x,V)
plot(x, E(1) * ones(size(x)));
grid on
xlabel('$x$')
ylabel('$V(x)$')
legend('$V(x)$', '$E(t=0)$');

subplot(3,2,2)
plot(t,P1,t,P2,t,P1+P2)
%plot(t,P1,t,P2)
grid on
xlabel('$t$')
legend('$P_{x<x_0}$','$P_{x>=x_0}$','$P_{tot}$')

subplot(3,2,3)
[X,T] = meshgrid(x,t);
pcolor(x,t,psi2)
xlabel('$x$')
ylabel('$t$')
shading interp

subplot(3,2,4)
plot(t,xmoy,t,x2moy,t,pmoy,t,p2moy);
xlabel('$t$')
legend('$\langlex\rangle$','$\langlex^2\rangle$','$\langlep\rangle$','$\langlep^2\rangle$')
grid on

subplot(3,2,5)
plot(t, uncertainty);
hold on
plot(t,0.5*t./t);
xlabel('$t$')
legend('$\langle \Delta x \rangle \cdot \langle \Delta p \rangle$','$h_{bar}/2$')
grid on

subplot(3,2,6)
plot(t, E);
xlabel('$t$')
legend('$\langle E \rangle$')
grid on



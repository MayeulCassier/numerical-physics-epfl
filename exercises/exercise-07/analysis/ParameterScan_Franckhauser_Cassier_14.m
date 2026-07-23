repertoire = ""; % TODO change as you need 
executable = 'Exercice7_student.exe'; % TODO change as you need 
input = 'input12'; % TODO change as you need 
fl =16;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
    L=12;
pi=3.14;

vel=sqrt(19.620000000000000);
minit = [1 2 3 4 5];
w=minit*pi*vel/L;
G=meshgrid(w);
T=2*pi./w;
Ttot=100*T(1);
%%

omegamin=1; omegamax=6; nomega=500; % TODO: choose your own parameters
%omegamin=1.159038610228322; omegamax=1.159038610228322; nomega=1;
omega = linspace(omegamin, omegamax,nomega);
paramstr = 'omega'; 
param = omega;
output = cell(1, length(param));
Emax = zeros(1,length(param));
for i = 1:length(param)
    output{i} = [paramstr, '=', num2str(param(i)), '.out'];
     % TODO: choose your own path
    cmd = sprintf('%s%s %s %s=%.15g output=%s', repertoire, executable, input, paramstr, param(i), output{i});
    disp(cmd)
    system(cmd);
    disp('Done.')
    filename = repertoire+output{i}+"_E";
    energy     = load(filename);
    Emax(i)    = max(energy(:,2));
end

%%
lw=1.5;
figure
plot(omega,Emax) % TODO: xlabel, ylabel, etc...
hehe=linspace(0,25,5);
hold on
name=strings([1 7]);
name(1)="data";
for i= 1:5
    plot(G(:,i),hehe,'Linewidth', lw)
    name(i+1)="n="+num2str(i)+": $\omega$="+num2str(w(i));
end
grid on
[A,B]=max(Emax);
legend(name);
titre="$\omega_n$:";
title(legend,titre);
set(gca,'fontsize',fl)
xlabel('$\omega$ [s$^{-1}$]')
ylabel('$E_{\rm max}$')
i=B;
filename = output{i}+"_f";
data_wave=load(filename);
filename = output{i}+"_v";
velocity = load(filename);
filename = output{i}+"_x";
data_x = load(filename);
time = data_wave(:,1);
wave = data_wave(:,2:end);
%figure
filename = output{i}+"_ana";
data_waveth = load(filename);
waveth = data_waveth(:,2:end); %TODO: rentrer les valeurs analytique 
% plot(data_x,wave(end,:)-waveth(end,:)) % TODO: xlabel, ylabel, etc...
% grid on
% % name="T="+num2str(T);
% % legend(name);
% %     titre="";
% %     title(legend,titre);
% set(gca,'fontsize',fl)
% xlabel('$x$ [m]')
% ylabel('$\  f(x)_{\rm fin}$')
figure %TODO: rentrer les valeurs analytique 
plot(data_x,wave(end,:), '+','LineWidth',lw )
hold on% TODO: xlabel, ylabel, etc...
RR= max(wave(end,:));
huhu=max(waveth(end,:));
plot(data_x,-22.31.*waveth(end,:),'-', 'LineWidth',lw)
grid on
legend('$f(x)_{\rm exp}$', '$f(x)_{\rm th}$')
% name="T="+num2str(T);
% legend(name);
%     titre="";
%     title(legend,titre);
set(gca,'fontsize',fl)
xlabel('$x$ [m]')
ylabel('$\  f(x)_{\rm fin}$')

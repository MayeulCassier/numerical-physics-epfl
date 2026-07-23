repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice4_apollo.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
%executable = 'Exercice4_apollo_supp1.exe';
input      = 'configuration3.in'; % Nom du fichier d'entrée 
d=digits(20);
g= 9.81;
%close all;
mA=5800;
mT=5.972e24;
rT= 6378.1e3;
rA=2;
G=6.674e-11;
r0=310000e3;
g= 9.81;
m=5.972*10^(24);
gamma=1.4;
rho0=1.2;
P0=10^5;
z0= (gamma*P0*(1/((gamma-1)*rho0*g)));
v0=1.25e3;
%alphamax= 0.18471582031232810281 %sauvegarde
%alphamin = 0.18471416262364700131 %sauvegarde
vmaxthmax= (sqrt(v0^2+2*G*mT*(1/(rT+z0) - 1/r0)));
alphamax =  (asin((rT+rA+z0)/(r0*v0)*vmaxthmax));
%alphamax=0.184725180664822;
vmaxth= (sqrt(v0^2+2*G*mT*(1/(rT) - 1/r0)));
alphamin =  (asin(vmaxth*(rT+rA)/(r0*v0)));
%0.18387124650613086825;
optimal= (0.18471518991935501284);
taillealpha=10;
precision = 20;


%alphamax=0.185458820836944;
%alphamin = 0.184789594036781;


%0.18470672895965672966;
%0.18470612430001646934242783093642;
%0.18470612430001646926912824851969;
alpha=zeros(1,taillealpha);
difference= abs( (alphamax  )- (alphamin  ));
% alphamax=0.18471751115478282207; %ceux pour la réduction 3 : fais avec 50
% alphamin=0.18471255466562632431;
% alphamax= (0.18471833171067996802); %les mêmes 3 : fais avec 100
% alphamin= (0.1847117009559555563);
%alphamax = (0.18472246764393933311); %ceux pendant la réduction 2 : 100
%alphamin=  (0.18470764774136139203);

% alphamax = (0.18473822534995240908); %Ceux avant réduction les bons
% % 1:100 
% alphamin=  (0.18468870668507730252);

% alphamax= (0.18471722288881970024); %continuité 1
% alphamin= (0.1847127876013786104);
% alphamax= (0.18471648120195663926); %continuité 2
% alphamin= (0.18471351445450440128);
% alphamax= (0.18471598509034254814); %continuité 3
% alphamin= (0.18471400064388620558);
% alphamax= (0.18471565324310903875); %continuité 4
% alphamin= (0.1847143258541750409);
% alphamax= (0.18471528279586680491); %continuité 5
% alphamin= (0.1847146888924724395);
% alphamax= (0.18471528279586680491); %continuité 6
% alphamin= (0.1847146888924724395);


% alphamax= (0.18469764985532230942); % seconde partie
% alphamin= (0.18469698739826712417);
%  alphamax= (0.18469727763864915772); % seconde partie
%  alphamin= (0.18469726877634741613);
% alphamax= (0.1846972700563864915772); % seconde partie
% alphamin= (0.18469727032634741613);
alphamax= (0.18830972700563864915772); % seconde partie
%   alphamin= (0.188499727032634741613);

%  alphamax= (0.18469727255398606757); % seconde partie
%  alphamin= (0.18469727255219999104);
alphaoptimal= (zeros(1,5));
%%
for k =1: 3
% if k<50
%     close all;
% end
% difference= abs( (alphamax  )- (alphamin  ));
% for i=1: taillealpha
%         alpha(i)=  (alphamin  )+i* (difference  );
% end
alpha= (linspace( (alphamin), (alphamax),300));

nsimul = length(alpha); % Nombre de simulations a faire

% autre exemple: 
%nsteps = round(logspace(2,4,nsimul)); % Nombre d'iterations entier de 10^2 a 10^4
tfin =  3*24*60*60; % TODO: Verifier que la valeur de tfin est EXACTEMENT la meme que dans le fichier input


 
fl =40;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
paramstr = 'alpha'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param = alpha; % Valeurs du parametre a scanner  MODIFIER SELON VOS BESOINS

%% Simulations %% 
%%%%%%%%%%%%%%%%%
% Lance une serie de simulations (= executions du code C++)
% Normalement, on ne devrait pas avoir besoin de modifier cette partie

output = cell(1, nsimul); % Tableau de cellules contenant les noms des fichiers de sortie
for i = 1:nsimul
    nom1=sprintf('%.25f', (param(i)  ));
    output{i} = [paramstr, '=', nom1, '.out'];
    % Execution du programme en lui envoyant la valeur a scanner en argument
    cmd = sprintf('%s%s %s %s=%.25f output=%s', repertoire, executable, input, paramstr,  (param(i)  ), output{i});
    disp(cmd)
    system(cmd);
    disp('Done.')
end

%% Analyse %%
%%%%%%%%%%%%%
% Ici, on aimerait faire une etude de convergence: erreur fonction de dt, sur diagramme log-log.
% A MODIFIER ET COMPLETER SELON VOS BESOINS
lw=1.5; fs=16;


npi = linspace(0,2*pi,300);
dt = zeros(1,nsimul);
figure
for i = 1:nsimul % Parcours des resultats de toutes les simulations
    data = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
    t   = data(:,1);
    xA  = data(:,2);
    yA  = data(:,3);
    
    %dt  = data(:,10);
    %plot(Rt, t, '-');
    %dT1= data(:,16);
    %plot(t, dT1,'linewidth',lw )
    
    
    
%     plot (1.71e5, min, '+')
    plot(xA, yA,'-','linewidth',lw) %POUR PLOT LES TRAJECTOIRES
    hold on
end
plot(rT*cos(npi), rT*sin(npi), 'black') %TRACER LA TERRE
hold on
plot((rT+z0)*cos(npi), (rT+z0)*sin(npi), 'r--' );
%hold on
%plot(dT +rL*cos(npi), rL*sin(npi), 'green') %TRACER LA LUNE

axis equal
xlabel('$x$ [m]')
ylabel('$y$ [m]')
%xlabel('t [s]')
%ylabel('rmin [m]')
set(gca,'fontsize',fs)
%%
maxPnc = zeros(1, nsimul);
compteurPnc = zeros(1, nsimul);
maxacc = zeros(1, nsimul);

figure
for i=1:nsimul
    data =  (load(output{i})); % Chargement du fichier de sortie de la i-ieme simulation
    t   = data(:,1);
    Pnc =  (data(:,7));
    e2=0; e1=0;
%     for h=1:length(Pnc)
%         e1=Pnc(h);
%         if (e2 <0 && e1==0)
%             compteurPnc(i)= compteurPnc(i) +1;
%         end
%         e2=Pnc(h);
%     end
    maxPnc(i)=  (max(abs(Pnc)));

    plot(t, Pnc, 'Linewidth', lw);
    hold on
end
set(gca,'fontsize',fs)
hold off
grid on
xlabel('$t$ [s]')
ylabel('$P_{NC}$')
figure
for i=1:nsimul
    data =  (load(output{i})); % Chargement du fichier de sortie de la i-ieme simulation
    t   = data(:,1);
    acc =  (data(:,9));
    maxacc(i)= (max(acc));
    plot(t, acc, 'Linewidth', lw);
    hold on
end
set(gca,'fontsize',fs)
hold off
grid on
xlabel('$t$ [s]')
ylabel('acc [m.s$^2$]')
%%
figure 
plot(alpha, maxacc,'+-', 'Linewidth', lw)
set(gca,'fontsize',fs)
grid on
xlabel('$\alpha$ [rad]')
ylabel('acc [m.s$^2$]')
figure 
plot(alpha, maxPnc,'+-', 'Linewidth', lw)
set(gca,'fontsize',fs)
grid on
xlabel('$\alpha$ [rad]')
ylabel('Pnc [J]')
%%
j=nsimul;
data = load(output{j});
tmax   = data(end,1);
maxaccn= (maxacc);
maxPncn= (maxPnc);
while (tmax >= tfin && j>0)
    maxaccn =  (maxacc(1, 1:j-1));
    maxPncn =  (maxPnc(1, 1:j-1));
    j = j-1;
    if j>0
        data = load(output{j});
        tmax   = data(end,1);
    end
end

% j=1;
% haha= [0];
% for i =1:nsimul
%     data = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
%     tmax   = data(end,1);
%     if tmax == tfin && tmax == inf
%         haha(1,j)=i;
%         j=j+1;
%     end
% end
%
% maxaccn=zeros(1,nsimul-length(haha));
% maxPncn=zeros(1,nsimul-length(haha));
% j=1;
% k=1;
% for i = 1 :(nsimul-length(haha))
%    while maxaccn(i)==0
%     if haha(k)~=i
%         maxaccn(i)=maxacc(j);
%         maxPncn(i)=maxPnc(j);
%         j=j+1;
%     else
%         k=k+1;
%         j=j+1;
%     end
%    end
% end
%
diff= (maxPncn);
[mindiff, la]=min(diff);
data = load(output{la});
t   = data(:,1);
acc = data(:,9);
Pnc = data(:,7);
xA  = data(:,2);
yA  = data(:,3);
vxA = data(:,4);
vyA = data(:,5);
dt=tfin/length(t);

figure
plot(t, acc, 'Linewidth', lw);
set(gca,'fontsize',fs)
hold off
grid on
xlabel('$t$ [s]')
ylabel('acc [m.s$^2$]')

figure
plot(t, Pnc, 'Linewidth', lw);
set(gca,'fontsize',fs)
hold off
grid on
xlabel('t [s]')
ylabel('$P_{NC}$')
%%
figure
plot(xA, yA,'+-','linewidth',lw) %POUR PLOT LES TRAJECTOIRES
hold on
plot(rT*cos(npi), rT*sin(npi), 'black') %TRACER LA TERRE
hold on
plot((rT+z0)*cos(npi), (rT+z0)*sin(npi), 'r--' );
set(gca,'fontsize',fs)
grid on
xlabel('x [m]')
ylabel('y [m]')
%%
%xlabel('t [s]')
%ylabel('rmin [m]')
set(gca,'fontsize',fs)
alphaoptimal(k)= (alpha(la));

compare = 4;
if la+compare>length(maxacc)
   alphamax= (alpha(length(maxacc))  );
else
    alphamax= (alpha(la+compare)  );
end
if la-compare<1
   alphamin= (alpha(length(maxacc))  );
else
    alphamin= (alpha(la-compare)  );
end

end
%%
% j=nsimul;
% data = load(output{j});
% tmax   = data(end,1);
% maxaccn=maxacc;
% maxPncn=maxPnc;
% 153500.4798976507;
% while (tmax >= tfin && j>0)
%     maxaccn = maxacc(1, 1:j-1);
%     maxPncn = maxPnc(1, 1:j-1);
%     j = j-1;
%     if j>0
%         data = load(output{j});
%         tmax   = data(end,1);
%     end
% end
% 
% % j=1;
% % haha= [0];
% % for i =1:nsimul
% %     data = load(output{i}); % Chargement du fichier de sortie de la i-ieme simulation
% %     tmax   = data(end,1);
% %     if tmax == tfin && tmax == inf
% %         haha(1,j)=i;
% %         j=j+1;
% %     end
% % end
% %
% % maxaccn=zeros(1,nsimul-length(haha));
% % maxPncn=zeros(1,nsimul-length(haha));
% % j=1;
% % k=1;
% % for i = 1 :(nsimul-length(haha))
% %    while maxaccn(i)==0
% %     if haha(k)~=i
% %         maxaccn(i)=maxacc(j);
% %         maxPncn(i)=maxPnc(j);
% %         j=j+1;
% %     else
% %         k=k+1;
% %         j=j+1;
% %     end
% %    end
% % end
% %
% diff=( (maxaccn));
% [mindiff, la]=min(diff);
% data = load(output{la});
% t   = data(:,1);
% acc = data(:,9);
% Pnc = data(:,7);
% xA  = data(:,2);
% yA  = data(:,3);
% vxA = data(:,4);
% vyA = data(:,5);
% dt=tfin/length(t);
% 
% figure
% plot(t, acc, 'Linewidth', lw);
% set(gca,'fontsize',fs)
% hold off
% grid on
% xlabel('$t$ [s]')
% ylabel('acc [m.s$^2$]')
% 
% figure
% plot(t, Pnc, 'Linewidth', lw);
% set(gca,'fontsize',fs)
% hold off
% grid on
% xlabel('t [s]')
% ylabel('$P_{NC}$')
% 
% figure
% plot(xA, yA,'+-','linewidth',lw) %POUR PLOT LES TRAJECTOIRES
% hold on
% plot(rT*cos(npi), rT*sin(npi), 'black') %TRACER LA TERRE
% axis equal
% xlabel('x [m]')
% ylabel('y [m]')
% %xlabel('t [s]')
% %ylabel('rmin [m]')
% set(gca,'fontsize',fs)
% alphaoptimal=alpha(la);
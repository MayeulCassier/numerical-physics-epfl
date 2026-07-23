repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice4_apollo_supp.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input      = 'configuration_supp2.in'; % Nom du fichier d'entrée 
g= 9.81;

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
0.18430775074066356684;
z0=gamma*P0*(1/((gamma-1)*rho0*g));
v0=1.25e3;
vmaxth=sqrt(v0^2+2*G*mT*(1/rT - 1/r0));
fixe_step = [1 0];
nfixe_step = numel(fixe_step);
alpha = 0.184307750740664;
%epsilon= logspace(-7, -5, 15);
epsilon = logspace(-3, 2, 100);
%epsilon = epsilon1.*10^(-9);
nepsilon = numel(epsilon); % Nombre de simulations a faire
% autre exemple: 
%nsteps = round(logspace(2,4,nepsilon)); % Nombre d'iterations entier de 10^2 a 10^4
tfin =  3*24*60*60; % TODO: Verifier que la valeur de tfin est EXACTEMENT la meme que dans le fichier input
PNCth=0;


fl =40;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
paramstr1 = 'fixe_step'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param1 = fixe_step; % Valeurs du parametre a scanner  MODIFIER SELON VOS BESOINS
paramstr2 = 'epsilon'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param2 = epsilon;
%% Simulations %% 
%%%%%%%%%%%%%%%%%
% Lance une serie de simulations (= executions du code C++)
% Normalement, on ne devrait pas avoir besoin de modifier cette partie
close all;
output = cell(nepsilon, nfixe_step); % Tableau de cellules contenant les noms des fichiers de sortie
for j = 2:2
   for i = 1:nepsilon
       
        output{j}{i} = [paramstr1, '=', num2str(param1(j)), paramstr2, '=', num2str(param2(i)), '.out'];
    % Execution du programme en lui envoyant la valeur a scanner en argument
        cmd = sprintf('%s%s %s %s=%.15g %s=%.15g output=%s', repertoire, executable, input, paramstr1, param1(j), paramstr2, param2(i), output{j}{i});
        disp(cmd)
        system(cmd);
        disp('Done.')
   end
end

nstep = round(linspace(5000, 10000, nepsilon));

paramstr3 = 'nsteps'; % Nom du parametre a scanner  MODIFIER SELON VOS BESOINS
param3 = nstep;
for j = 1:1
   for i = 1:nepsilon
        output{j}{i} = [paramstr1, '=', num2str(param1(j)), paramstr3, '=', num2str(param3(i)), '.out'];
    % Execution du programme en lui envoyant la valeur a scanner en argument
        cmd = sprintf('%s%s %s %s=%.15g %s=%.15g output=%s', repertoire, executable, input, paramstr1, param1(j), paramstr3, param3(i), output{j}{i});
        disp(cmd)
        system(cmd);
        disp('Done.')
   end
end


%% Simulations %%
close all;
lw=1.5; fs=16;

for k=1:1
    npi = linspace(0,2*pi,70);
    figure
    for i =  nepsilon:nepsilon % Parcours des resultats de toutes les simulations
        data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
        t   = data(:,1);
        xA  = data(:,2);
        yA  = data(:,3);

%     t       = data(:,1);
%     xA      = data(:,2);
%     yA      = data(:,3);
     xT      = data(:,4);
    yT      = data(:,5);
     xL      = data(:,6);
     yL      = data(:,7);
%     vxA     = data(:,8);
%     vyA     = data(:,9);
%     vxT     = data(:,10);
%     vyT     = data(:,11);
%     vxL     = data(:,12);
%     vyL     = data(:,13);
%     Pnc     = data(:,14);
     rho     = data(:,15);
%     acc     = data(:,16);
        plot(xA, yA,'+-','linewidth',lw) %POUR PLOT LES TRAJECTOIRES
        hold on
    end
    plot(xT(1)+rT*cos(npi), yT(1)+rT*sin(npi), 'black', 'linewidth',lw) %TRACER LA TERRE
    hold on
    plot(xT(end)+rT*cos(npi), yT(end)+rT*sin(npi), 'black', 'linewidth',lw) %TRACER LA TERRE
    hold on
    plot(xL, yL,'-', 'Color', [0.5 0.5 0.5],'linewidth',lw)
    hold on
    plot(xL(1)+rL*cos(npi), yL(1)+rL*sin(npi), 'blue', 'linewidth',lw) %TRACER LA TERRE
    hold on
    plot(xL(end)+rL*cos(npi), yL(end)+rL*sin(npi), 'blue', 'linewidth',lw) %TRACER LA TERRE
    hold on
    plot(xT(1)+(rT+z0)*cos(npi), yT(1)+(rT+z0)*sin(npi), 'r--' );
    hold on
    plot(xT(end)+(rT+z0)*cos(npi), yT(end)+(rT+z0)*sin(npi), 'r--' );

    %hold on
    %plot(dT +rL*cos(npi), rL*sin(npi), 'green') %TRACER LA LUNE
    xlim([-50000 5000]);
    axis equal
    xlabel('x [m]')
    ylabel('y [m]')
    %xlabel('t [s]')
    %ylabel('rmin [m]')
    set(gca,'fontsize',fs)
    % lgd =legend( '400', '800','1600','3200', '6400', '12800','20000','location','best')
    % lgd.Title.String='Nstep'
end
%%
% figure
% fit3=cell(1, nfixe_step);
% simulations=cell(1, nfixe_step);
% for k=1:nfixe_step
%     errorPnc = zeros(1,nepsilon);
%     nstep = zeros(1,nepsilon);
%     for i=1:nepsilon
%         data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
%         t   = data(:,1);
%         Pnc = data(:,7);
%         rho = data(:,8);
%         acc = data(:,9);
%         nstep(i)=length(t);
%         errorPnc(i)=max(Pnc);
%     end
%     semilogx(nstep, errorPnc , 'k+', 'linewidth',lw)
%     hold on
%     p3=polyfit(nstep,log(errorPnc),1);
%     f3=polyval(p3,nstep);
%     semilogx(nstep,exp(f3), '--', 'linewidth', lw)
%     if p3(2)>0
%         fit3(k) = sprintf('fit:$y=$%0.5g$x+$%0.5g',p3(1),p3(2));
%     else 
%         fit3(k) = sprintf('fit:$y=$%0.5g$x$%0.5g',p3(1),p3(2));
%     end
%     simulations(k)= sprintf('simualtions avec $\epsilon=$%.5g',epsilon(k));
% end
% set(gca,'fontsize',fs)
% legend(simulations(1),fit3(1),simulations(2),fit3(2));
% hold off
% grid on
% xlabel('nstep')
% ylabel('error maxPnc')
% 
%   
% figure
% fit2=cell(1, nfixe_step);
% simulations=cell(1, nfixe_step);
% for k=1:nfixe_step
%     erroracc = zeros(1,nepsilon);
%     nstep = zeros(1,nepsilon);
%     for i=1:nepsilon
%         data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
%         t   = data(:,1);
%         Pnc = data(:,7);
%         rho = data(:,8);
%         acc = data(:,9);
%         nstep(i)=length(t);
%         erroracc(i)=max(acc);
%     end
%     semilogx(nstep, erroracc , 'k+', 'linewidth',lw)
%     hold on
%     p2=polyfit(nstep,log(erroracc),1);
%     f2=polyval(p2,nstep);
%     semilogx(nstep,exp(f3), '--', 'linewidth', lw)
%     if p2(2)>0
%         fit2(k) = sprintf('fit:$y=$%0.5g$x+$%0.5g',p2(1),p2(2));
%     else 
%         fit2(k) = sprintf('fit:$y=$%0.5g$x$%0.5g',p2(1),p2(2));
%     end
%      simulations(k)= sprintf('simualtions avec $\epsilon=$%.5g',epsilon(k));
% end
% set(gca,'fontsize',fs)
% legend(simulations(1),fit2(1),simulations(2),fit2(2));
% hold off
% grid on
% xlabel('nstep')
% ylabel('error accélération')
% 
% for k=1:nfixe_step
%     nstep = zeros(1,nepsilon);
%     figure
%     for i=1:nepsilon
%         data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
%         t   = data(:,1);
%         Pnc = data(:,7);
%         nstep(i)=length(t);
%         plot(t, Pnc, 'Linewidth', lw);
%         hold on
%     end
%     set(gca,'fontsize',fs)
%     hold off
%     grid on
%     xlabel('t [s]')
%     ylabel('Pnc')
%     figure
%     for i=1:nepsilon
%         data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
%         t   = data(:,1);
%         acc = data(:,9);
%         nstep(i)=length(t);
%         plot(t, acc, 'Linewidth', lw);
%         hold on
%     end
%     set(gca,'fontsize',fs)
%     hold off
%     grid on
%     xlabel('t [s]')
%     ylabel('acc [m.s$^2$]')
%     
% end
% 


















%%








g1 = zeros(1,nfixe_step);

name = strings(1,nfixe_step);

%SECONDE PARTIE INDEP
% figure
% 
% for k=1:nfixe_step
%     error = zeros(1,nepsilon);
%     nstep = zeros(1,nepsilon);
%     for i=1:nepsilon
%         data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
%         t   = data(:,1);
%         Pnc = data(:,7);
%         rho = data(:,8);
%         acc = data(:,9);
%         [M,Ivi]=max(abs(Pnc));
%         if (Ivi>1 && Ivi<Pnc(length(t)))
%         l=1;
%         d= Pnc(Ivi-l:Ivi+l,:);
%         t1= t(Ivi-l:Ivi+l,:);
%         p=polyfit(t1,d,2);
%         f=polyval(p,t1);
%         %plot(t, f, '--')
%         a = p(1);
%         b= p(2);
%         c= p(3);
%         B= -b/(2*a);
%         maxi = abs(a*B*B+b*B+c);
%         error(i)=abs(maxi);
%         else 
%             error(i)=M;
%         end
%         nstep(i)=length(t);
%         
%         
%     end
%     
%     p2=polyfit(log(1./nstep),error,1);
%     f2=polyval(p2,log(1./nstep));
%     g1(2*k-1) =semilogx(1./nstep, error, 'k+', 'linewidth',lw);
%     hold on
%     g1(2*k)=plot(log(1./nstep),f2, '--', 'linewidth', lw);
%     
%     if p2(2)>0
%         fit = "fit:$y=$"+num2str(p2(1))+"$x+$"+num2str(p2(2));
%     else 
%         fit = "fit:$y=$"+num2str(p2(1))+"$x$"+num2str(p2(2));
%     end
%     if k==1
%         nom= "Simulations en temps adaptatif";
%     else
%         nom="Simulations en temps fixe";
%     end
%     name(2*k-1) = nom;
%     name(2*k) = fit;
%     
% end
% set(gca,'fontsize',fs)
% legend(name);
% hold off
% grid on
% xlabel('$1/N_{step}$')
% ylabel('$\Delta P_{NC}^{max}$ [W] revisit\''ee')
% 

maximum=zeros(1, nepsilon);
figure
for k=1:nfixe_step
    errorPNC= zeros(1,nepsilon);
    nstep = zeros(1,nepsilon);
    for i=1:nepsilon
        data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
        t   = data(:,1);
    Pnc     = data(:,14);

        nstep(i)=length(t);
        maximum(i)=max(abs(Pnc));
        errorPNC(i)=abs(PNCth-maximum(i));
    end
    g1(k) =semilogx(1./nstep, errorPNC, '+', 'linewidth',lw);
    hold on
    if k==1
        nom= "Simulations en temps adaptatif";
    else
        nom="Simulations en temps fixe";
    end
    name(k) = nom;
end
set(gca,'fontsize',fs)
legend(name);
hold off
grid on
xlabel('$1/N_{steps}$')
ylabel('$\Delta P_{NC}^{max}$ [W]')


figure

for k=1:nfixe_step
    erroraccmax = zeros(1,nepsilon);
    nstep = zeros(1,nepsilon);
    for i=1:nepsilon
        data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
        t   = data(:,1);

    acc     = data(:,16);
        nstep(i)=length(t);
        erroraccmax(i)=max(acc);
    end
    
   g1(k) =semilogx(1./nstep, erroraccmax , '+', 'linewidth',lw);
   hold on
    if k==1
        nom= "Simulations en temps adaptatif";
    else
        nom="Simulations en temps fixe";
    end
    name(k) = nom;
end
set(gca,'fontsize',fs)
legend(name);
hold off
grid on
xlabel('$1/N_{steps}$')
ylabel('$\Delta $acc\''el\''eration$_{max}$ [m.s$^{-2}$]')
% 
% figure
% 
% for k=1:nfixe_step
%     erroraccmaxinterpole = zeros(1,nepsilon);
%     accmaxi = zeros(1,nepsilon);
%     nstep = zeros(1,nepsilon);
%     for i=1:nepsilon
%         data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
%         t   = data(:,1);
%         nstep(i)=length(t);
%         Pnc = data(:,7);
%         rho = data(:,8);
%         acc = data(:,9);
%         [Mv, Iviv]=max(acc);
%             l=5;
%             range_1 =Iviv-l;
%             range_2 = Iviv+l;
%             d= acc(range_1:range_2,:);
%             t1= t(range_1:range_2,:);
%         p=polyfit(t1,d,2);
%         a = p(1);
%         b= p(2);
%         c= p(3);
%         B= -b/(2*a);
%         accmaxi(i) = a*B*B+b*B+c;
%         erroraccmaxinterpole(i)= accmaxi(i);
%     end
%         
%     
%     p3=polyfit(log(1./nstep),log(erroraccmaxinterpole),1);
%     f3=polyval(p3,log(1./nstep));
%     
%    g1(2*k-1) =loglog(1./nstep, erroraccmaxinterpole , 'k+', 'linewidth',lw);
%    hold on
%     g1(2*k)= loglog(1./nstep,exp(f3), '--', 'linewidth', lw);
%     
%     if p3(2)>0
%         fit = "fit:$y=$"+num2str(p3(1))+"$x+$"+num2str(p3(2));
%     else 
%         fit = "fit:$y=$"+num2str(p3(1))+"$x$"+num2str(p3(2));
%     end
%     if k==1
%         nom= "Simulations en temps adaptatif";
%     else
%         nom="Simulations en temps fixe";
%     end
%     name(2*k-1) = nom;
%     name(2*k) = fit;
% end
% set(gca,'fontsize',fs)
% legend(name);
% hold off
% grid on
% xlabel('$1/N_{steps}$')
% ylabel('$\Delta $acc\''el\''eration$_{max}$ [m.s$^{-2}$] revisit\''e')

%% NOT ERROR NOW %%

for k=1:nfixe_step
    nstep = zeros(1,nepsilon);
    figure
    for i=1:nepsilon
        data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
        t   = data(:,1);
        nstep(i)=length(t);
        Pnc = data(:,14);
        plot(t, Pnc, 'LineWidth', lw);
        hold on
    end
    set(gca,'fontsize',fs)
%     legend(name);
    hold off
    grid on
    xlabel('$t$ [s]')
    ylabel('$P_{NC}$ [W]')

end


for k=1:nfixe_step  
    nstep = zeros(1,nepsilon);
    figure
    for i=1:nepsilon
        data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
        t   = data(:,1);
        nstep(i)=length(t);
        acc = data(:,16);
        plot(t, acc, 'LineWidth', lw);
        hold on
    end
    set(gca,'fontsize',fs)
%     legend(name);
    hold off
    grid on
    xlabel('$t$ [s]')
    ylabel('acc\''el\''eration [m.s$^{-2}$]')
end


%% Les vrais

% maximum=zeros(1, nepsilon);
% figure
% for k=1:nfixe_step
%     errorPNC= zeros(1,nepsilon);
%     nstep = zeros(1,nepsilon);
%     for i=1:nepsilon
%         data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
%         t   = data(:,1);
%         Pnc = data(:,7);
%         nstep(i)=length(t);
%         maximum(i)=max(abs(Pnc));
%         errorPNC(i)=abs(PNCth-maximum(i));
%     end
%     
%     
%     p1=polyfit(nstep,log(errorPNC),1);
%     f3=polyval(p1,nstep);
%     
%     g1(2*k-1) =semilogx(nstep, errorPNC , 'k+', 'linewidth',lw);
%     hold on
%     g1(2*k)= semilogx(nstep,exp(f3), '--', 'linewidth', lw);
%     
%     if p1(2)>0
%         fit = "fit:$y=$"+num2str(p1(1))+"$x+$"+num2str(p1(2));
%     else 
%         fit = "fit:$y=$"+num2str(p1(1))+"$x$"+num2str(p1(2));
%     end
%     if k==1
%         nom= "Simulations en temps adaptatif";
%     else
%         nom="Simulations en temps fixe";
%     end
%     name(2*k-1) = nom;
%     name(2*k) = fit;
% end
% set(gca,'fontsize',fs)
% legend(name);
% hold off
% grid on
% xlabel('$1/N_{steps}$')
% ylabel('$\Delta P_{NC}^{max}$ [W] brut')




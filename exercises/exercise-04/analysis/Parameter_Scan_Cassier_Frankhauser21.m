repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Exercice4_apollo.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input      = 'configuration2.in'; % Nom du fichier d'entrée 
g= 9.81;

mA=5800;
mT=5.972e24;
rT= 6378.1e3;
rA=2;
rho0=0;
G=6.674e-11;
r0=310000e3;
v0=1.25e3;
vmaxth=sqrt(v0^2+2*G*mT*(1/rT - 1/r0));
fixe_step = [1 0];
nfixe_step = numel(fixe_step);
%epsilon= logspace(-7, -5, 15);
%epsilon = logspace(-7, -4, 100); %PAS MAL POUR VOIR PLUS GRAND
epsilon = logspace(-3, -1, 100);

nepsilon = numel(epsilon); % Nombre de simulations a faire
% autre exemple: 
%nsteps = round(logspace(2,4,nepsilon)); % Nombre d'iterations entier de 10^2 a 10^4
tfin =  3*24*60*60; % TODO: Verifier que la valeur de tfin est EXACTEMENT la meme que dans le fichier input



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

%% Analyse %%
%%%%%%%%%%%%%
% Ici, on aimerait faire une etude de convergence: erreur fonction de dt, sur diagramme log-log.
% A MODIFIER ET COMPLETER SELON VOS BESOINS
close all;
lw=1.5; fs=16;

for k=2:2
    npi = linspace(0,2*pi,35);
    error = zeros(1,nepsilon);
    nstep = zeros(1,nepsilon);
    errorhmin= zeros(1,nepsilon);
    errorvmax = zeros(1,nepsilon);
    errorvmaxinterpole = zeros(1,nepsilon);
    vmaxi = zeros(1,nepsilon);
    mini = zeros(1, nepsilon);
    figure
    for i =  nepsilon:nepsilon % Parcours des resultats de toutes les simulations
        data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
        t   = data(:,1);
        xA  = data(:,2);
        yA  = data(:,3);
        vxA = data(:,4);
        vyA = data(:,5);
        Emec= data(:,6);
        Pnc = data(:,7);
        rho = data(:,8);
        acc = data(:,9);
        
        
    
        %dt  = data(:,10);
        %plot(Rt, t, '-');
        %dT1= data(:,16);
        %plot(t, dT1,'linewidth',lw )
        
        
        
    %     plot (1.71e5, min, '+')
        plot(xA, yA,'+-','linewidth',lw) %POUR PLOT LES TRAJECTOIRES
        hold on
    end
    plot(rT*cos(npi), rT*sin(npi), 'black') %TRACER LA TERRE
    %hold on
    %plot(dT +rL*cos(npi), rL*sin(npi), 'green') %TRACER LA LUNE
    
    axis equal
    xlabel('x [m]')
    ylabel('y [m]')
    %xlabel('t [s]')
    %ylabel('rmin [m]')
    set(gca,'fontsize',fs)
    % lgd =legend( '400', '800','1600','3200', '6400', '12800','20000','location','best')
    % lgd.Title.String='Nstep'
    
    minimum=zeros(1,nepsilon);
    figure
    for i= 1:nepsilon
        data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
        t   = data(:,1);
        xA  = data(:,2);
        yA  = data(:,3);
        vxA = data(:,4);
        vyA = data(:,5);
        
        rmin=sqrt(xA.^2+yA.^2);
        [M,Ivi]=min(rmin);
        l=5;
        d= rmin(Ivi-l:Ivi+l,:);
        t1= t(Ivi-l:Ivi+l,:);
        %plot(t, d,'linewidth',lw )%PLOT LES RAYONS MIN
        p=polyfit(t1,d,2);
        f=polyval(p,t1);
        plot(t1, f, '--', 'LineWidth', lw)
        hold on
        a = p(1);
        b= p(2);
        c= p(3);
        B= -b/(2*a);
        mini(i) = abs(a*B*B+b*B+c);
        error(i)=abs(rT+rA-mini(i));
        minimum(i)=min(rmin);
        errorhmin(i)=abs(rT+rA-minimum(i));
        plot(t(Ivi),mini(i), 'k+')
        nstep(i)=length(t);
    end
    set(gca,'fontsize',fs)
    grid on
    figure
    for i=1:nepsilon
        data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
        t   = data(:,1);
        vxA = data(:,4);
        vyA = data(:,5);
        vmax=sqrt(vxA.^2+vyA.^2);
        [Mv, Iviv]=max(vmax);
            l=5;
            range_1 =Iviv-l;
            range_2 = Iviv+l;
            d= vmax(range_1:range_2,:);
            t1= t(range_1:range_2,:);
        %plot(t, d,'--','LineWidth',lw )%PLOT LES RAYONS MIN
        p=polyfit(t1,d,2);
        f=polyval(p,t1);
        plot(t1, f, '--','LineWidth',lw)
        hold on
        a = p(1);
        b= p(2);
        c= p(3);
        B= -b/(2*a);
        vmaxi(i) = a*B*B+b*B+c;
        errorvmax(i)=abs(max(sqrt(vxA.^2+vyA.^2))-vmaxth);
        errorvmaxinterpole(i)= abs(vmaxth-vmaxi(i));
        plot(t(Iviv),vmaxi(i), 'k+');
        
        
    end
    
    set(gca,'fontsize',fs)
    grid on
    figure 
    loglog(1./nstep, errorhmin, 'k+', 'linewidth',lw)
    hold on
    p1=polyfit(log(1./nstep),log(errorhmin),1);
    f1=polyval(p1,log(1./nstep));
    loglog(1./nstep,exp(f1), 'r--', 'linewidth', lw)
    grid on
    xlabel('$\Delta t$ [s]')
    ylabel('$\Delta r_{min}$ [m] brut')
    hold off
    if p1(2)>0
        fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p1(1),p1(2));
    else 
        fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p1(1),p1(2));
    end
    legend('simulations',fit);
    set(gca,'fontsize',fs)
    hold off
    
    figure 
    loglog(1./nstep, error, 'k+', 'linewidth',lw)
    hold on
    p2=polyfit(log(1./nstep),log(error),1);
    f2=polyval(p2,log(1./nstep));
    loglog(1./nstep,exp(f2), '--', 'linewidth', lw)
    grid on
    xlabel('$\Delta t$ [s]')
    ylabel('$\Delta r_{min}$ [m] revisit\''ee')
    set(gca,'fontsize',fs)
    if p2(2)>0
        fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p2(1),p2(2));
    else 
        fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p2(1),p2(2));
    end
    legend('Simulations',fit);
    hold off
    
    figure 
    loglog(1./nstep, errorvmax , 'k+', 'linewidth',lw)
    hold on
    p3=polyfit(log(1./nstep),log(errorvmax),1);
    f3=polyval(p3,log(1./nstep));
    loglog(1./nstep,exp(f3), '--', 'linewidth', lw)
    grid on
    xlabel('$\Delta t$ [s]')
    ylabel('$\Delta v_{max}$ [m.s$^{-1}$] brut')
    set(gca,'fontsize',fs)
    if p3(2)>0
        fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p3(1),p3(2));
    else 
        fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p3(1),p3(2));
    end
    legend('simulations',fit);
    hold off

    figure 
    loglog(1./nstep, errorvmaxinterpole , 'k+', 'linewidth',lw)
    hold on
    p3=polyfit(log(1./nstep),log(errorvmaxinterpole),1);
    f3=polyval(p3,log(1./nstep));
    loglog(1./nstep,exp(f3), '--', 'linewidth', lw)
    grid on
    xlabel('$\Delta t$ [s]')
    ylabel('$\Delta v_{max}$ [m.s$^{-1}$] revisit\''ee')
    set(gca,'fontsize',fs)
    if p3(2)>0
        fit = sprintf('fit:$y=$%0.5g$x+$%0.5g',p3(1),p3(2));
    else 
        fit = sprintf('fit:$y=$%0.5g$x$%0.5g',p3(1),p3(2));
    end
    legend('simulations',fit);
    hold off
    figure
    for i= 1:nepsilon
        data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
        t   = data(:,1);
        xA  = data(:,2);
        yA  = data(:,3);
        vxA = data(:,4);
        vyA = data(:,5);
        Emec= data(:,6);
        Pnc = data(:,7);
        acc = data(:,9);
        dtv=zeros(1, length(t)-1);
        for j=1:length(t)-1
            dtv(j)=abs(t(j)-t(j+1));
        end
        plot(t(1:length(t)-1), dtv, 'linewidth',lw);
        hold on
    end
    grid on
    ylabel('$\Delta t$ [s]')
    xlabel('$t$ [s]')
    set(gca,'fontsize',fs)
    hold off
end




























g1 = zeros(1,2*nepsilon);

name = strings(1,2*nepsilon);

%SECONDE PARTIE INDEP
figure

for k=1:nfixe_step
    error = zeros(1,nepsilon);
    nstep = zeros(1,nepsilon);
    for i=1:nepsilon
        data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
        t   = data(:,1);
        xA  = data(:,2);
        yA  = data(:,3);
        rmin=sqrt(xA.^2+yA.^2);
        [M,Ivi]=min(rmin);
        l=5;
        d= rmin(Ivi-l:Ivi+l,:);
        t1= t(Ivi-l:Ivi+l,:);
        p=polyfit(t1,d,2);
        f=polyval(p,t1);
        %plot(t, f, '--')
        a = p(1);
        b= p(2);
        c= p(3);
        B= -b/(2*a);
        mini = abs(a*B*B+b*B+c);
        error(i)=abs(rT+rA-mini);
        nstep(i)=length(t);
        
        
    end
    
    p2=polyfit(log(1./nstep),log(error),1);
    f2=polyval(p2,log(1./nstep));
    g1(2*k-1) =loglog(1./nstep, error, 'k+', 'linewidth',lw);
    hold on
    g1(2*k)=loglog(1./nstep,exp(f2), '--', 'linewidth', lw);
    
    if p2(2)>0
        fit = "fit:$y=$"+num2str(p2(1))+"$x+$"+num2str(p2(2));
    else 
        fit = "fit:$y=$"+num2str(p2(1))+"$x$"+num2str(p2(2));
    end
    if k==2
        nom= "Simulations en temps adaptatif";
    else
        nom="Simulations en temps fixe";
    end
    name(2*k-1) = nom;
    name(2*k) = fit;
    
end
set(gca,'fontsize',fs)
legend(name);
hold off
grid on
xlabel('$1/N_{step}$')
ylabel('$\Delta r_{min}$ [m] revisit\''ee')




figure
for k=1:nfixe_step
    errorhmin= zeros(1,nepsilon);
    nstep = zeros(1,nepsilon);
    for i=1:nepsilon
        data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
        t   = data(:,1);
        xA  = data(:,2);
        yA  = data(:,3);
        rmin=sqrt(xA.^2+yA.^2);
        nstep(i)=length(t);
        minimum(i)=min(rmin);
        errorhmin(i)=abs(rT+rA-minimum(i));
    end
    
    p1=polyfit(log(1./nstep),log(errorhmin),1);
    f1=polyval(p1,log(1./nstep));
    g1(2*k-1) =loglog(1./nstep, errorhmin, '+', 'linewidth',lw);
    hold on
    g1(2*k)= loglog(1./nstep,exp(f1), 'r--', 'linewidth', lw);
    
    if p1(2)>0
        fit = "fit:$y=$"+num2str(p1(1))+"$x+$"+num2str(p1(2));
    else 
        fit = "fit:$y=$"+num2str(p1(1))+"$x$"+num2str(p1(2));
    end
    if k==2
        nom= "Simulations en temps adaptatif";
    else
        nom="Simulations en temps fixe";
    end
    name(2*k-1) = nom;
    name(2*k) = fit;
end
set(gca,'fontsize',fs)
legend(name);
hold off
grid on
xlabel('$1/N_{steps}$')
ylabel('$\Delta r_{min}$ [m] brut')


figure

for k=1:nfixe_step
    errorvmax = zeros(1,nepsilon);
    nstep = zeros(1,nepsilon);
    for i=1:nepsilon
        data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
        t   = data(:,1);
        vxA = data(:,4);
        vyA = data(:,5);
        nstep(i)=length(t);
        errorvmax(i)=abs(max(sqrt(vxA.^2+vyA.^2))-vmaxth);
    end
    
    p3=polyfit(log(1./nstep),log(errorvmax),1);
    f3=polyval(p3,log(1./nstep));
    
   g1(2*k-1) =loglog(1./nstep, errorvmax , '+', 'linewidth',lw);
    hold on
    g1(2*k)= loglog(1./nstep,exp(f3), '--', 'linewidth', lw);
    
    if p3(2)>0
        fit = "fit:$y=$"+num2str(p3(1))+"$x+$"+num2str(p3(2));
    else 
        fit = "fit:$y=$"+num2str(p3(1))+"$x$"+num2str(p3(2));
    end
    if k==2
        nom= "Simulations en temps adaptatif";
    else
        nom="Simulations en temps fixe";
    end
    name(2*k-1) = nom;
    name(2*k) = fit;
end
set(gca,'fontsize',fs)
legend(name);
hold off
grid on
xlabel('$1/N_{steps}$')
ylabel('$\Delta v_{max}$ [m.s$^{-1}$] brut')

figure

for k=1:nfixe_step
    errorvmaxinterpole = zeros(1,nepsilon);
    vmaxi = zeros(1,nepsilon);
    nstep = zeros(1,nepsilon);
    for i=1:nepsilon
        data = load(output{k}{i}); % Chargement du fichier de sortie de la i-ieme simulation
        t   = data(:,1);
        nstep(i)=length(t);
        vxA = data(:,4);
        vyA = data(:,5);
        vmax=sqrt(vxA.^2+vyA.^2);
        [Mv, Iviv]=max(vmax);
            l=5;
            range_1 =Iviv-l;
            range_2 = Iviv+l;
            d= vmax(range_1:range_2,:);
            t1= t(range_1:range_2,:);
        p=polyfit(t1,d,2);
        a = p(1);
        b= p(2);
        c= p(3);
        B= -b/(2*a);
        vmaxi(i) = a*B*B+b*B+c;
        errorvmaxinterpole(i)= abs(vmaxth-vmaxi(i));
    end
        
    
    p3=polyfit(log(1./nstep),log(errorvmaxinterpole),1);
    f3=polyval(p3,log(1./nstep));
    
   g1(2*k-1) =loglog(1./nstep, errorvmaxinterpole , 'k+', 'linewidth',lw);
   hold on
    g1(2*k)= loglog(1./nstep,exp(f3), '--', 'linewidth', lw);
    
    if p3(2)>0
        fit = "fit:$y=$"+num2str(p3(1))+"$x+$"+num2str(p3(2));
    else 
        fit = "fit:$y=$"+num2str(p3(1))+"$x$"+num2str(p3(2));
    end
    if k==2
        nom= "Simulations en temps adaptatif";
    else
        nom="Simulations en temps fixe";
    end
    name(2*k-1) = nom;
    name(2*k) = fit;
end
set(gca,'fontsize',fs)
legend(name);
hold off
grid on
xlabel('$1/N_{steps}$')
ylabel('$\Delta v_{max}$ [m.s$^{-1}$] revisit\''ee')

        
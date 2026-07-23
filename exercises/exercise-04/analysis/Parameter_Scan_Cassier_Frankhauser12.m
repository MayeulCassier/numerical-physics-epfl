repertoire = ''; % Chemin d'accès au code compilé (NB: enlever le ./ sous Windows)
executable = 'Ex4_atmos.exe'; % Nom de l'exécutable (NB: l'extension.exe est nécessaire sous Windows)
input      = 'configuration12.in'; % Nom du fichier d'entrée 
close all;
g= 9.81;
m=5.972*10^(24);
gamma=1.4;
rho0=1.2;
P0=10^5;
C=P0*rho0^(-gamma);
z0=gamma*P0*(1/((gamma-1)*rho0*g));
alpha=1/(gamma-1);
A=(C*gamma*alpha*1/g)^(-alpha);
fff=(rho0^(gamma-1)-(z0-(1.0e-5))*g*(gamma-1)/(C*gamma))^(1/(gamma-1));
%alpha=1/(gamma-1);
%A=(C*gamma*alpha*1/g)^(-alpha);
%epsilon= (10^(-6)*rho0/A)^(1/alpha);
%nsteps = round(linspace(100,10000,10));
nsteps = round(logspace(0,5,100));


%nsteps = [200 300 400 500 600];
nsimul1 = length(nsteps);
%epsilon = round(linspace(1, 10^3, 10));
epsilon = [1 10 20 35 50 75 100 445 1000]; 
nepsilon = length(epsilon); % Nombre de simulations a faire:
zdebut=z0-epsilon;
zfin=0;

close all;
paramstr1 = 'z0'; 
param1 = zdebut; 
paramstr2='nsteps';
param2=nsteps;

fl =40;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);


%% Simulations %% 
%%%%%%%%%%%%%%%%%
% Lance une serie de simulations (= executions du code C++)

output2 = cell(nsimul1, nepsilon); % Tableau de cellules contenant les noms des fichiers de sortie
for j = 1:nepsilon
   for i = 1:nsimul1
       
        output2{j}{i} = [paramstr1, '=', num2str(param1(j)), paramstr2, '=', num2str(param2(i)), '.out'];
    % Execution du programme en lui envoyant la valeur a scanner en argument
        cmd = sprintf('%s%s %s %s=%.15g %s=%.15g output2=%s', repertoire, executable, input, paramstr1, param1(j), paramstr2, param2(i), output2{j}{i});
        disp(cmd)
        system(cmd);
        disp('Done.')
   end
end

%% Analyse %%
%%%%%%%%%%%%%
% Ici, on aimerait faire une etude de convergence: erreur fonction de dt, sur diagramme log-log.
% A MODIFIER ET COMPLETER SELON VOS BESOINS
% close all;
% lw=1.5; fs=16;
% 
% %g2 = zeros(1,nsimul1);
% figure
% for j=1:1
%     for i = 1:nsimul1 % Parcours des resultats de toutes les simulations
%         data        = load(output2{j}{i}); % Chargement du fichier de sortie de la i-ieme simulation
%         z           = data(:,1);
%         rho         = data(:,2);
%         plot(z, rho,'+-','Color', [i/(nsimul1) 0.2 0.2], 'linewidth',lw);
%         hold on
%         %leg2= legend(g2(i),{num2str(nsteps(i))}, 'Interpreter','latex');
%     end
%     
%     
% end
% rhoana = @(x) (rho0^(gamma-1)-g*(gamma-1)*x/(C*gamma)).^(1/(gamma-1));
% plot(z, rhoana(z),'k--', 'linewidth',lw);
% set(gca,'fontsize',fs)
% xlabel('$z$ [m]')
% ylabel('$\rho$ [kg.m$^{-3}$]')
% %leg2= legend({"simulations avec $\epsilon=$"+ num2str(epsilon(j))}, 'Interpreter','latex');
% %leg2=legend(num2str(nsteps(1)),num2str(nsteps(2)),num2str(nsteps(3)),num2str(nsteps(4)), ...
% %    num2str(nsteps(5)), num2str(nsteps(6)), num2str(nsteps(7)), num2str(nsteps(8)), num2str(nsteps(9)), num2str(nsteps(10)));
% title(legend, '$N_{step}$');
% %set(leg2,'Interpreter','latex');
% grid on
% g1 = zeros(1,2*nepsilon);
% 
% name = strings(1,2*nepsilon);
% figure
% for j=1:nepsilon
%     errorrho           = zeros(1,nsimul1);
%     for i = 1:nsimul1 % Parcours des resultats de toutes les simulations
%         data        = load(output2{j}{i}); % Chargement du fichier de sortie de la i-ieme simulation
%         rhofin      = data(end,2); % the index (i.e. 1,2,4.. ) can change according to how you save data in the c++ code
%         z           = data(:,1);
%         rho         = data(:,2);
%         errorrho(i)=abs(rhofin-rho0);
%     end
%     %title(titre);
%     %legend({'100', '150', '200', '300', '500', '1000', 'Solution analytique'},'Location','north','NumColumns',4);
%     %legend('1600','3200','6400','12800','25600')
%     % set(gca, 'YScale', 'log')
%     %title(legend, 'Nstep');
%    dz=zdebut(j)./nsteps;
%     p=polyfit(log(dz),log(errorrho),1);
%     f=polyval(p,log(dz));
%     
%     g1(2*j-1)=loglog(dz, errorrho,'b+', 'Linewidth',  lw);
%     hold on
%     g1(2*j)=loglog(dz,exp(f), '--', 'linewidth', lw);
%     
%     if p(2)>0
%         fit = "fit:$y=$"+num2str(p(1))+"$x+$"+num2str(p(2));
%     else 
%         fit = "fit:$y=$"+num2str(p(1))+"$x$"+num2str(p(2));
%     end
%     
%     name(2*j-1) = "simulations avec $\epsilon=$" +num2str(epsilon(j));
%     name(2*j) = fit;
%     
%     
%     %name{2*j} = ['name' string(fit)];
%     %name{2*j+1} =['name' string(simualtions)];
%     %legend(gca,'show');
% 
%     %leg3= legend((fit), 'Interpreter','latex');
% end
% set(gca,'fontsize',fs)
% xlabel('$\Delta z$ [m]')
% ylabel('$\rho_{fin} - \rho_{0}$ [kg.m$^{-3}$]')
% legend(name)
% %lgd1= legend(simulations(1),fit(1),simulations(2),fit(2));
% %set(leg1,'Interpreter','latex');
% % for j=1:nepsilon
% %     legend([g1(2*j:2*j+1)], simulations, fit, 'Interpreter','latex');
% % end
% grid on 

%% BIG PART

close all;
lw=1.5; fs=16;

%g2 = zeros(1,nsimul1);
figure
for j=1:1
    for i = 1:nsimul1 % Parcours des resultats de toutes les simulations
        data        = load(output2{j}{i}); % Chargement du fichier de sortie de la i-ieme simulation
        z           = data(:,1);
        rho         = data(:,2);
        plot(z, rho,'+-','Color', [i/(nsimul1) 0.2 0.2], 'linewidth',lw);
        hold on
        %leg2= legend(g2(i),{num2str(nsteps(i))}, 'Interpreter','latex');
    end
    
    
end
rhoana = @(x) (rho0^(gamma-1)-g*(gamma-1)*x/(C*gamma)).^(1/(gamma-1));
plot(z, rhoana(z),'k--', 'linewidth',lw);
set(gca,'fontsize',fs)
xlabel('$z$ [m]')
ylabel('$\rho$ [kg.m$^{-3}$]')
%leg2= legend({"simulations avec $\epsilon=$"+ num2str(epsilon(j))}, 'Interpreter','latex');
%leg2=legend(num2str(nsteps(1)),num2str(nsteps(2)),num2str(nsteps(3)),num2str(nsteps(4)), ...
%    num2str(nsteps(5)), num2str(nsteps(6)), num2str(nsteps(7)), num2str(nsteps(8)), num2str(nsteps(9)), num2str(nsteps(10)));
title(legend, '$N_{step}$');
%set(leg2,'Interpreter','latex');
grid on
g1 = zeros(1,nepsilon);

name = strings(1,nepsilon);
figure
for j=1:nepsilon
    errorrho           = zeros(1,nsimul1);
    for i = 1:nsimul1 % Parcours des resultats de toutes les simulations
        data        = load(output2{j}{i}); % Chargement du fichier de sortie de la i-ieme simulation
        rhofin      = data(end,2); % the index (i.e. 1,2,4.. ) can change according to how you save data in the c++ code
        z           = data(:,1);
        rho         = data(:,2);
        errorrho(i)=abs(rhofin-rho0);
    end
    %title(titre);
    %legend({'100', '150', '200', '300', '500', '1000', 'Solution analytique'},'Location','north','NumColumns',4);
    %legend('1600','3200','6400','12800','25600')
    % set(gca, 'YScale', 'log')
    %title(legend, 'Nstep');
   dz=zdebut(j)./nsteps;
    
    loglog(dz, errorrho,'+-', 'Linewidth',  lw);
    hold on
    name(j) = "simulations avec $\epsilon=$" +num2str(epsilon(j));
    
    
    %name{2*j} = ['name' string(fit)];
    %name{2*j+1} =['name' string(simualtions)];
    %legend(gca,'show');

    %leg3= legend((fit), 'Interpreter','latex');
end
set(gca,'fontsize',fs)
xlabel('$\Delta z$ [m]')
ylabel('$\rho_{fin} - \rho_{0}$ [kg.m$^{-3}$]')
legend(name)
%lgd1= legend(simulations(1),fit(1),simulations(2),fit(2));
%set(leg1,'Interpreter','latex');
% for j=1:nepsilon
%     legend([g1(2*j:2*j+1)], simulations, fit, 'Interpreter','latex');
% end
grid on 

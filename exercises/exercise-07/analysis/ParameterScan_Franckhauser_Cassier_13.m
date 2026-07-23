repertoire = ""; % TODO change as you need 
executable = 'Exercice7_student.exe'; % TODO change as you need 
input = 'input1'; % TODO change as you need 
fl =16;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
L=12;
pi=3.14;
minit=4;
vel=sqrt(19.620000000000000);
w=minit*pi*vel/L;%TODO METTRE LE BON CHIFFRE

T=2*pi/w;
lambda = vel*T;
L=2*12;
Ttot=T*L/lambda;

initialization = ["cos"];
paramstr = 'initialization'; 
param = initialization;
output = cell(1, length(param));

fmn=0.1;

    %%
for i = 1:length(param)
    output{i} = [paramstr, '=', num2str(param(i)), '.out'];
     % TODO: choose your own path
    cmd = sprintf('%s%s %s %s=%s output=%s', repertoire, executable, input, paramstr, param(i), output{i});
    disp(cmd)
    system(cmd);
    disp('Done.')
    filename = output{i}+"_f";
    data_wave=load(filename);
    filename = output{i}+"_v";
    velocity = load(filename);
    filename = output{i}+"_x";
    data_x = load(filename);
    time = data_wave(:,1);
    filename = output{i}+"_ana";
    data_waveth = load(filename);
    waveth = data_waveth(:,2:end);
    wave = data_wave(:,2:end);
    %waveth=@(t) fmn*sin(data_x*minit*pi/L)*sin(minit*pi*vel*t/L+minit*pi*vel/L);%TO DO: rentrer la vraie valeur
    T=2*pi/w;
    [a,N]=min(abs(T-time));
    figure 
    hold on
%     plot(data_x,wave(1,1:end)-waveth(time(1)),'.')
%     plot(data_x,wave(end,1:end)-waveth(time(end)),'.')
%     plot(data_x,wave(N,1:end)-waveth(time(N)),'.')
%fpast[i] = fmn*sin(x[i]*minit*PI/x[N-1])*sin(minit*PI*sqrt(vel2[i])*(1.0-dt)/x[N-1]);

    plot(data_x,wave(1,1:end)-waveth(1,1:end),'-')
    plot(data_x,wave(end,1:end)-waveth(end,1:end),'.')
    plot(data_x,wave(N,1:end)-waveth(N,1:end),'.')
    %plot(data_x,waveth(time(1)),'+')
    %plot(data_x,waveth(1,1:end),'+')
    grid on
    name = strings([1,3]);
    name(1)="t="+num2str(time(1));
    name(2)="t="+num2str(time(end));
    name(3)="t="+num2str(time(N));
    legend(name);
%     titre="";
%     title(legend,titre);
    set(gca,'fontsize',fl)
    xlabel('$x$ [m]')
    ylabel('$\Delta f(x)$ [m]')
    hold off
    figure
    pcolor(data_x,time,wave);
    shading interp;
    colorbar();
    xlabel("x [m]");ylabel("t [s]");
end

figure;hold on;
plot(data_x,waveth(N,1:end))
plot(data_x,wave(1,1:end))
plot(data_x,wave(end,1:end))
% figure('DoubleBuffer', 'on')
%     
%     p = plot(data_x,wave(1,:),'r-');
%     
%     xlim([min(data_x) max(data_x)])
%     ylim([-0.1 0.1])
%     
%     for n=2:numel(time)
%     
%         set(p, 'XData', data_x, 'YData', wave(n,:));
%         drawnow
%         pause(.1)
%     
%     end
    figure('DoubleBuffer', 'on')
    
    p = plot(data_x,waveth(1,:),'r-');
    
    xlim([min(data_x) max(data_x)])
    ylim([-0.1 0.1])
    
    for n=2:numel(time)
    
        set(p, 'XData', data_x, 'YData', waveth(n,:));
        drawnow
        pause(.1)
    
    end

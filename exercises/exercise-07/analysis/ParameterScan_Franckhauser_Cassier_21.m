repertoire = ""; % TODO change as you need 
executable = 'Exercice7_student.exe'; % TODO change as you need 
input = 'input21'; % TODO change as you need 
fl =16;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);

schema = ["A" "B" "C"];
paramstr = 'schema'; 
param = schema;
output = cell(1, length(param));
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
    wave = data_wave(:,2:end);
    maxwave= zeros(1, length(data_x));
    figure
    pcolor(data_x,time,wave);
    shading interp;
    colorbar();
    xlabel("x [m]");ylabel("t [s]");
end

%%

for i = 1:length(param)
    filename = output{i}+"_f";
    data_wave=load(filename);
    filename = output{i}+"_v";
    velocity = load(filename);
    filename = output{i}+"_x";
    data_x = load(filename);
    time = data_wave(:,1);
    wave = data_wave(:,2:end);
    maxwave= zeros(1, length(data_x));
    %interpolation quadratique:
    B=zeros(1,length(maxwave));
     M=zeros(1,length(maxwave));
    for k=1:length(data_x)
        [M(k), Ivi] = max(wave(:,k));
        j=1;
        range_1 =Ivi-j;
        range_2 = Ivi+j;
        d= wave((range_1:range_2),k);
        t1= time((range_1:range_2));
        p=polyfit(t1,d,2);
        f=polyval(p,t1);
        a = p(1);
        b= p(2);
        c= p(3);
        B(k)= -b/(2*a);
        maxwave(k) = a*B(k)*B(k)+b*B(k)+c;
    end
    r=10;
    v=zeros(1,length(data_x)-2*r);
    for crea=1:length(data_x)-2*r
        v(crea)=(data_x(crea+2*r)-data_x(crea))./(B(crea+2*r)-B(crea));
    end
    if i==1
        Puissance=1/4;
    end 
    if i==2
        Puissance=-1/4;
    end
    if i==3
        Puissance = -3/4;
    end
    Ath= (velocity/velocity(1)).^(Puissance);
    lw=1.5;
    figure 
    dat_x_redim=data_x(r:length(data_x)-r-1);
    plot(dat_x_redim,v,'LineWidth',lw)
    hold on
    plot(data_x, sqrt(velocity), 'LineWidth',lw)
    set(gca,'fontsize',fl)
    xlabel('$x$ [m]')
    ylabel('$v$ [m/s]')
    grid on
    figure 
    plot(data_x,M,'-','LineWidth',lw)
    hold on
    plot(data_x,Ath,'--','LineWidth',lw+0.2)
    set(gca,'fontsize',fl)
    legend('$A_{\rm max, exp}$','$A_{\rm max, th}$')
    xlabel('$x$ [m]')
    ylabel('$A_{\rm max}$ [m]')
    grid on
    figure 
    plot(data_x,M-Ath,'.','LineWidth',lw)
    set(gca,'fontsize',fl)
    xlabel('$x$ [m]')
    ylabel('$\Delta A_{\rm max}$ [m]')
    grid on
    grid minor

end
%%
figure('DoubleBuffer', 'on')
    
    p = plot(data_x,wave(1,:),'r-');
    
    xlim([min(data_x) max(data_x)])
    ylim([-80 80])
    
    for n=2:numel(time)
    
        set(p, 'XData', data_x, 'YData', wave(n,:));
        drawnow
        pause(.1)
    
    end

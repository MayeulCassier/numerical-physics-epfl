repertoire = ""; % TODO change as you need 
executable = 'Exercice7_student.exe'; % TODO change as you need 
input = 'input'; % TODO change as you need 
fl =16;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
% w=7.5;
% T=2*pi/w;
% lambda = sqrt(velocity(1))*T;
% L=2*12;
% Ttot=T*L/lambda;
%%
CFLmin=1; CFLmax=1.001; nCFL=2; % TODO: choose your own parameters
CFL = linspace(CFLmin, CFLmax,nCFL);
paramstr = 'CFL'; 
param = CFL;
output = cell(1, length(param));
for i = 1:length(param)
    output{i} = [paramstr, '=', num2str(param(i)), '.out'];
     % TODO: choose your own path
    cmd = sprintf('%s%s %s %s=%.15g output=%s', repertoire, executable, input, paramstr, param(i), output{i});
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
    
    figure
    pcolor(data_x,time,wave);
    shading interp;
    colorbar();
    xlabel("x [m]");ylabel("t [s]");
end
name = strings(1, 3);
for i = 1:length(param)
    filename = output{i}+"_f";
    data_wave=load(filename);
    filename = output{i}+"_v";
    velocity = load(filename);
    filename = output{i}+"_x";
    data_x = load(filename);
    time = data_wave(:,1);
    wave = data_wave(:,2:end);
    
    N=35;
    M=80;
    L=100;
    figure
    hold on
    plot(data_x,wave(N,:),'+-')
    plot(data_x,wave(M,:),'+-')
    plot(data_x,wave(L,:),'+-')
    name(1) = num2str(time(N))+" s";
    name(2) = num2str(time(M))+" s";
    name(3) = num2str(time(L))+" s";
    grid on
    legend(name);
    titre="$t=$";
    title(legend,titre);
    set(gca,'fontsize',fl)
    xlabel('$x$ [m]')
    ylabel('$f(x)$')
    hold off
end

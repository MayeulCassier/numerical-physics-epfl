repertoire = ""; % TODO change as you need 
executable = 'Exercice7_student.exe'; % TODO change as you need 
input = 'input'; % TODO change as you need 
fl =16;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);

cb_droit = ["fixe" "libre" "sortie"];
paramstr = 'cb_droit'; 
param = cb_droit;
output = cell(1, length(param));
for i = 1:length(param)
    output{i} = [paramstr,'=',num2str(param(i)),'.out'];
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
    
    figure
    pcolor(data_x,time,wave);
    shading interp;
    colorbar();
    xlabel("x [m]");ylabel("t [s]");
end
for i = 1:length(param)
    filename = output{i}+"_f";
    data_wave=load(filename);
    filename = output{i}+"_v";
    velocity = load(filename);
    filename = output{i}+"_x";
    data_x = load(filename);
    time = data_wave(:,1);
    wave = data_wave(:,2:end);
    figure('DoubleBuffer', 'on')
    
    p = plot(data_x,wave(1,:),'r-');
    
    xlim([min(data_x) max(data_x)])
    ylim([-2 2])
    
    for n=2:numel(time)
    
        set(p, 'XData', data_x, 'YData', wave(n,:));
        drawnow
        pause(.1)
    
    end
end
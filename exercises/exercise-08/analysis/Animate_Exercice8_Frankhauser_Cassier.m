%% Load data %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fichier = 'output';
data  = load([fichier,'_obs.out']);
t     = data(:,1);
data  = load([fichier,'_pot.out']);
x     = data(:,1);
V     = data(:,2);

data  = load([fichier,'_psi2.out']);
wave  = reshape(load([fichier,'_psi2.out']), length(t), 3, length(x));
psi2  = squeeze(wave(:, 1, :));
real  = squeeze(wave(:, 2, :));
imag  = squeeze(wave(:, 3, :));

% Animation settings
stride = 1; % Plot every `stride` frame. A larger value will make the animation go faster
fps = 100; % How many updates per second. A larger value will make the animation go faster

VminIndex = min(find(V > 0));
VmaxIndex = max(find(V > 0));
yMax = max(wave(:));
yMin = min(wave(:));
%%
fl =16;
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultAxesFontSize', fl);
figure;
hold on;

ylabel('$\psi$ [arb.]');
xlabel('$x$ [arb.]');
ylim([yMin-0.1 yMax+0.1])
xlim([-150 150])
for n=1:stride:length(t)
    title(sprintf('Wave packet for frame %d/%d', n, length(t)));
    cla; % Clear drawing
    series = [];
    series(1) = plot(x, sqrt(psi2(n, :)));
    series(2) = plot(x, real(n, :));
    series(3) = plot(x, imag(n, :));
    labels = {'$\psi^2$', '$Re(\psi )$', '$Im(\psi )$'};
    series(4) = plot(x,V-0.2);
    labels{4}= 'Potential Wall';
    % Draw potential well
%     if VmaxIndex > VminIndex
%         xPatch = [x(VminIndex), x(VmaxIndex), x(VmaxIndex), x(VminIndex)];
%         yPatch = [yMin, yMin, yMax, yMax];
%         series(4) = patch(xPatch, yPatch, [0.6350, 0.0780, 0.1840]);
%         labels{4} = 'Potential well';
%     end
    legend(series, labels);
    pause(1.0/fps);
end

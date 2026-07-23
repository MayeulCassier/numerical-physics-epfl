

% Chargement des resultats %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Nx=65;
Ny=65;
ntime = size(dir('sim'),1)-3;
%ntime=100;
Lx=12;
Ly=6;

eigenmodeM=3;
eigenmodeN=2;
km=eigenmodeM*pi/Lx;
kn=eigenmodeN*pi/Ly;
u0=3;
omega=u0*sqrt(km^2+kn^2);

animate = 1;% animate=1 to plot a sequence of snapshots of the solution
H=zeros(Ny,Nx,ntime);
time=zeros(ntime,1);
Hcompare=zeros(Nx,Ny,ntime);

 for ii=1:ntime
    fichier    = ['sim/output.',num2str(ii-1),'.out'];
    data_str   = importdata(fichier,' ',1);
    time(ii)   = str2double(data_str.textdata{1});
    data       = data_str.data;
    H(:,:,ii)  = reshape(data(:,3),Ny,Nx);
%     for i1=1:Nx
%         for i2=1:Ny
%             Hcompare(i1,i2,ii)=cos(time(ii)*u0*sqrt(km^2+kn^2))*cos(km*(i1-1)*Lx/Nx+kn*(i2-1)*Ly/Ny);
%         end
%     end

 end


X         = data(1:Ny:Nx*Ny,1);
Y         = data(1:Ny,2);
% errorH=sum((Hcompare-H).^2,'all')^(1/2)/Nx/Ny/ntime;
%% Figures %%
%%%%%%%%%%%%%

if animate
    figure
    for ii=1:ntime
        contourf(X,Y,H(:,:,ii),15,'LineStyle','None')
        xlabel('x [m]')
        ylabel('y [m]')
        title('H(x,y) [m]')
        h = colorbar;
        %set(h, 'ylim', [-2 2])
        
        %axis equal
        axis([min(X) max(X) min(Y) max(Y)])
        disp(ii)
        pause(.01)
    end
end

pause(.5)
%%
if animate
    figure
    for ii=1:ntime
        surf(X,Y,H(:,:,ii))
        axis equal
        axis([min(X) max(X) min(Y) max(Y) -1 1])%min(min(H)) max(max(H))])
        disp(ii)
        pause(.01)
    end
end
%%
fs=22
nImages = numel(time);
fig = figure;

for idx = 1:nImages
    surf(X,Y,H(:,:,idx))
    axis equal
    axis([min(X) max(X) min(Y) max(Y) -1 1])% -200 200])
    drawnow
    set(gca,'fontsize',fs)
    frame = getframe(fig);
    im{idx} = frame2im(frame);
    xlabel('$x$ [m]',Interpreter='latex')
    ylabel('$x$ [m]',Interpreter='latex')
    zlabel('$H$ [m]',Interpreter='latex')
end
%close;

filename = 'FinitStatic_Dirichlet.gif'; % Specify the output file name
for idx = 1:nImages
    [A,map] = rgb2ind(im{idx},256);
    if idx == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',0.0);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.0);
    end
end
%%
figure
fs=22;
index_y=round(Ny/2);
Hcut=squeeze(H(index_y,:,:))';
contourf(X,time,Hcut);
xlabel('$x$ [m]','Interpreter','latex')
ylabel('$t$ [s]','Interpreter','latex')
title(['$H(x,y=',num2str(Y(index_y)),')$ [m]'],'Interpreter','latex')
%colormap magma
colorbar
set(gca,'fontsize',fs)
%%
figure
fs=22;
index_x=round(Nx/2);
Hcut=squeeze(H(:,index_x,:))';
contourf(Y,time,Hcut);
xlabel('$y$ [m]','Interpreter','latex')
ylabel('$t$ [s]','Interpreter','latex')
title(['$H(x=',num2str(X(index_x)),',y)$ [m]'],'Interpreter','latex')
%colormap magma
colorbar
set(gca,'fontsize',fs)

%%
index_x=round(Nx/2);
HmidTh=cos(km*X(index_x))*cos(kn*Y(index_y))*cos(time*u0*sqrt(km^2+kn^2));
figure
fs=22;

Hcut=squeeze(H(index_y,index_x,:))';
plot(time,Hcut,'r-','DisplayName','Solution numérique','LineWidth',2);
hold on
plot(time,HmidTh,'b--','DisplayName','Solution théorique','LineWidth',2);
legend
grid on


xlabel('$y$ [m]','Interpreter','latex')
ylabel('$t$ [s]','Interpreter','latex')
title(['$H(x=',num2str(X(index_x)),',y=',num2str(Y(index_y)),')$ [m]'],'Interpreter','latex')
%colormap magma
set(gca,'fontsize',fs)



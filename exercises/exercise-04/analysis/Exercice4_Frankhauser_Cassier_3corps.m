%% Parametres et constantes -- Does not vary
G = 6.674e-11;
Mterre = 5.972e24;
Mlune = 7.348e22*1e-14;
Masteroide = 5.278e11;
Rt = 6378100;
Ra = 80;
G = 6.674e-11;
d = 384748000;
rt = d*(Mlune/(Mterre + Mlune));
rl = d*(Mterre/(Mterre + Mlune));
Omega = sqrt( ((Mterre + Mlune)*G)/((d)^3));
r0 = 320000000;
q = Mlune/(Mterre + Mlune);
epsilonp = (q/3)^(1/3);
L1x = d + d*(-epsilonp + (epsilonp^2)/3 + (epsilonp^3)/9);
L2x = d + d*(epsilonp + (epsilonp^2)/3 - (epsilonp^3)/9);
L3x = d*(-1 -5*q/12 + 1127*(q^3)/20736);
L45x = d*(0.5 - Mlune/(Mlune + Mterre));
L4y = d*sqrt(3)*0.5;
L5y = -d*sqrt(3)*0.5;
vmax = sqrt(1100.^2 + 2.*G.*Mterre*(1/(Rt + Ra) - 1/r0));
crashe = false;

%% Conditions initiales -- This part is modified for each question
sin_alpha = (vmax*(Rt + Ra)/(1100*r0));
alpha = asin(sin_alpha);
tfin = 2*24*3600;
dt = tfin/8000; % initial time step
epsilon = logspace(-5, 5, 10000); % different epsilons for the simulations below
adapt_oui_non = 1; % decides if it is going to use the adaptive time step

X(1,:) = [r0 0 d 0 0 0];
V(1,:) = [-1100*cos(alpha) 1100*sin_alpha 0 0 0 0];

%% Code -- This part is modified for each question
for k = 1:10000 % does k simulations
    i = 2;
    t(1) = 0;
%     [momentC(1,:), Emec(1,:), P(1,:)] = qtys(X(1,:), V(1,:)); calculates the important quantities, useful only when doing one simulation at a time as the are witten in the same variables 
    while and(t(i-1) < tfin, crashe == false) % continues to simulate while the asteroid hasn't crashed or the alloted time hasn't been exceeded
        if adapt_oui_non == 1
            [X(i,:), V(i,:), dt(i), t(i)] = adapt(X(i-1,:), V(i-1,:), dt(i-1), t(i-1), epsilon(k)); % uses the kth epsilon  when doing simulation with the adaptative step
        else
            t(i) = t(i-1) + dt(k);
            [X(i,:), V(i,:)] = step(X(i-1,:), V(i-1,:), dt(k)); % uses the kth dt when doing simulation with the fixed step
        end
%         [momentC(i,:), Emec(i,:), P(i,:)] = qtys(X(i,:), V(i,:)); % calculates the useful quantities every loop, 
%         crashe = crash(X(i,:)); % to make the simulation stop upon crashing on a body
        i = i+1;
    end
    
    for h = 1:size(X(:,1))
        distance(h) = sqrt( (X(h,1) - X(h,5))^2 + (X(h,2)  - X(h,6))^2 ) - Rt - 80; % evaluates the distance at all points to the surface of the earth
    end
    [~, idmin] = min(distance);
    a = polyfit([idmin-1 idmin idmin+1],[distance(idmin-1) distance(idmin) distance(idmin+1)], 2);
    minimas(k) = abs(polyval(a, -0.5*a(2)/a(1))); % the minimal value of the distance, recovered by the polynomial interpolation
    nsteps(k) = i-1; % the amounts of steps the given simulation took
    X = []; V = []; X(1,:) = [r0 0 d 0 0 0]; V(1,:) = [-1100*cos(alpha) 1100*sin_alpha 0 0 0 0]; t = []; distance = []; % clears the variables after a simulation to make sure they don't interfere with the next one
end
%% Fonctions -- Varies only for the bonus and to neglect the mass of the moon

function [fX, fV] = f(Xin, Vin) % the function that evaluates f(y)
    G = 6.674e-11;
    Mterre = 5.972e24;
    Mlune = 7.348e22*1e-14; % reduction of the mass of the moon for the first part
    Masteroide = 5.278e11;
    Rt = 6378100;
    Cx = 0.47;
    rho = 1.2*exp(-( (sqrt((Xin(5) - Xin(1))^2 + (Xin(6) - Xin(2))^2) - Rt) )*3*log(10)/50000);
    S = pi*80*80;
    F = 0; %0.5*rho*Cx*S*(Vin(1)^2 + Vin(2)^2)/Masteroide; % Bonus 4.6a friction force : note that I kept the atmosphere infinite
    fX = Vin;
    fV(1) = (G.*Mlune.*(Xin(3) - Xin(1)))./( ( (Xin(3) - Xin(1)).^2 + (Xin(4) - Xin(2)).^2 ).^1.5 ) + (G.*Mterre.*(Xin(5) - Xin(1)))./( ( (Xin(5) - Xin(1)).^2 + (Xin(6) - Xin(2)).^2 ).^1.5 ) - F*Vin(1)/sqrt(Vin(1)^2 + Vin(2)^2);
    fV(2) = (G.*Mlune.*(Xin(4) - Xin(2)))./( ( (Xin(3) - Xin(1)).^2 + (Xin(4) - Xin(2)).^2 ).^1.5 ) + (G.*Mterre.*(Xin(6) - Xin(2)))./( ( (Xin(5) - Xin(1)).^2 + (Xin(6) - Xin(2)).^2 ).^1.5 ) - F*Vin(2)/sqrt(Vin(1)^2 + Vin(2)^2);
    fV(3) = (G.*Mterre.*(Xin(5) - Xin(3)))./( ( (Xin(5) - Xin(3)).^2 + (Xin(6) - Xin(4)).^2 ).^1.5 );
    fV(4) = (G.*Mterre.*(Xin(6) - Xin(4)))./( ( (Xin(5) - Xin(3)).^2 + (Xin(6) - Xin(4)).^2 ).^1.5 );
    fV(5) = (G.*Mlune.*(Xin(3) - Xin(5)))./( ( (Xin(3) - Xin(5)).^2 + (Xin(4) - Xin(6)).^2 ).^1.5 );
    fV(6) = (G.*Mlune.*(Xin(4) - Xin(6)))./( ( (Xin(3) - Xin(5)).^2 + (Xin(4) - Xin(6)).^2 ).^1.5 );
end

function [xout, vout] = step(xin, vin, dtinst) % the runge kutta integrator / classic step function
    [k1x, k1v] = f(xin, vin);
    k1x = k1x.*dtinst; k1v = k1v.*dtinst;
    [k2x, k2v] = f(xin + 0.5*k1x, vin + 0.5*k1v);
    k2x = k2x.*dtinst; k2v = k2v.*dtinst;
    [k3x, k3v] = f(xin + 0.5*k2x, vin + 0.5*k2v);
    k3x = k3x.*dtinst; k3v = k3v.*dtinst;
    [k4x, k4v] = f(xin + k3x, vin + k3v);
    k4x = k4x.*dtinst; k4v = k4v.*dtinst;
    xout = xin + (1/6).*(k1x + 2.*k2x + 2.*k3x + k4x);
    vout = vin + (1/6).*(k1v + 2.*k2v + 2.*k3v + k4v);
end

function [xbon, vbon, dtmod, tplus1] = adapt(xin, vin, dtinst, t, epsilon) % the adaptative step function
    c = 0.98; % factor when shortening dt
    j = 1; % loop limit variable
    dtmodtemp = dtinst;
    [x1, ~] = step(xin, vin, dtmodtemp);
    [x2, v2] = step(xin, vin, 0.5*dtmodtemp);
    [x3, v3] = step(x2, v2, 0.5*dtmodtemp);
    dif = abs(x1 - x3);
    d = sqrt(dif(1)^2 + dif(2)^2 + dif(3)^2 + dif(4)^2 + dif(5)^2 + dif(6)^2);
    if d < epsilon
    tplus1 = t + dtmodtemp;
    xbon = x3;
    vbon = v3;
    if d ~= 0 % to remove the risk of division by zero
        dtmod = dtmodtemp*(epsilon./d)^(0.2);
    else
        dtmod = dtmodtemp;
    end
    else
        while j < 200 % loop condition to prevent infinites
            if d ~= 0 % to remove the risk of division by zero
                dtmodtemp = dtmodtemp*c*(epsilon./d)^(0.2);
            end
            [x1, ~] = step(xin, vin, dtmodtemp);
            [x2, v2] = step(xin, vin, 0.5*dtmodtemp);
            [x3, v3] = step(x2, v2, 0.5*dtmodtemp);
            dif = abs(x1 - x3);
            d = sqrt(dif(1)^2 + dif(2)^2 + dif(3)^2 + dif(4)^2 + dif(5)^2 + dif(6)^2);
            j = j + 1;
            if d < epsilon % loop break condition
                j = 500;
            end
        end
        xbon = x3;
        vbon = v3;
        tplus1 = t + dtmodtemp;
        dtmod = dtmodtemp;
    end
end

function [momentC, Emec, P] = qtys(Xinst, Vinst) % allows to get the conserved values : Angular momentum, Mecanical energy, and Momentum
    Mterre = 5.972e24;
    Mlune = 7.348e22;
    Masteroide = 5.278e11;
    G = 6.674e-11;
    momentC = [Masteroide*(Xinst(1)*Vinst(2) - Xinst(2)*Vinst(1)) Mlune*(Xinst(3)*Vinst(4) - Xinst(4)*Vinst(3)) Mterre*(Xinst(5)*Vinst(6) - Xinst(6)*Vinst(5))]; % Angular momentum, it was never used in the repport but I still left it there since it was coded
    Emec(1) = -G*Masteroide*( Mlune/(sqrt( (Xinst(1) - Xinst(3))^2 + (Xinst(2) - Xinst(4))^2 ) ) + Mterre/(sqrt( (Xinst(1) - Xinst(5))^2 + (Xinst(2) - Xinst(6))^2))) + 0.5*Masteroide*(Vinst(1)^2 + Vinst(2)^2); % Mecanical energy of the asteroid
    Emec(2) = -G*Mlune*Mterre/(sqrt( (Xinst(3) - Xinst(5))^2 + (Xinst(4) - Xinst(6))^2)) + 0.5*Mlune*(Vinst(3)^2 + Vinst(4)^2); % Mecanical energy of the moon
    Emec(3) = -G*Mlune*Mterre/(sqrt( (Xinst(3) - Xinst(5))^2 + (Xinst(4) - Xinst(6))^2)) + 0.5*Mterre*(Vinst(5)^2 + Vinst(6)^2); % Mecanical energy of the earth
    P = [Masteroide*Vinst(1) Masteroide*Vinst(2) Mlune*Vinst(3) Mlune*Vinst(4) Mterre*Vinst(5) Mterre*Vinst(6)]; % Momentum
end

function [crashe] = crash(X) % verifies if the asteroid crashed on the earth or the moon
Rt = 6378100;
Rl = 1737400;
if sqrt((X(1) - X(5))^2 + (X(2) - X(6))^2 ) < Rt
    crashe = 1;
    disp("crashe sur la terre");
elseif sqrt((X(1) - X(3))^2 + (X(2) - X(4))^2 ) < Rl
    crashe = 1;
    disp("crashe sur la lune");
else
    crashe = 0;
end
end
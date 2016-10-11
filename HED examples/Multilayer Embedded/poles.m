clear;close all;tic
% f = 1e12;
f = 1e12;
omega = 2*pi*f;
lambda = 3e8/f;
num = 500; %Size of the arrays

% Example Validations

% Material Properties
ep1 = 1; % Air
ep2 = 9.7 ; % GaN/AlGaN layers combined
ep3 = 11; % Silicon base
% backed by a PEC layer

% EM constants
mu0 = 4*pi*1e-7;
ep0 = 8.854e-12;

% Propagations Constants
k1 = omega*sqrt(mu0*ep0*ep1);
k2 = omega*sqrt(mu0*ep0*ep2);
k3 = omega*sqrt(mu0*ep0*ep3);


% Middle Layer thickness
d = 1.0*lambda;

% Source Location
zp = -d/2;

% Layer Heights
z0 = -d;
z1 = 0;
z_pec = -5*d;

% TE/TM switch
nu = 1;

kz1 = @(kp) sqrt(k1 ^2 - kp .^2);

kz2 = @(kp) sqrt(k2 ^2 - kp .^2);

kz3 = @(kp) sqrt(k3 ^2 - kp .^2);

% Define impedances
if nu == 0
    
    % TE Case
    Z1 = @(kp) omega./kz1(kp);
    Z2 = @(kp) omega./kz2(kp);
    Z3 = @(kp) omega./kz3(kp);
else
    % TM case
    Z1 = @(kp) kz1(kp)./(omega*ep1);
    Z2 = @(kp) kz2(kp)./(omega*ep2);
    Z3 = @(kp) kz3(kp)./(omega*ep3);
end
% Gammas
Gamma_32 = @(kp)(Z3(kp) - Z2(kp))./ (Z3(kp) + Z2(kp));
Gamma_43 =  -1;

% % Left Looking Input Impedance
% Z_in_left = @(kp)  Z2(kp) .* (Z3(kp) + Z2(kp)*1i.*tan(kz2(kp)*d/2))...
%     ./(Z2(kp) + Z3(kp)*1i.*tan(kz2(kp)*d/2));
% 
% % Right Looking Input Impedance
% Z_in_right = @(kp) Z2(kp) .* (Z1(kp) + Z2(kp)*1i.*tan(kz2(kp)*d/2))...
%     ./(Z2(kp) + Z1(kp)*1i.*tan(kz2(kp)*d/2));
% 
% % % Reflection Coefficients
% Gamma_left = @(kp) (Z_in_left(kp) - Z2(kp)) ./ (Z_in_left(kp) + Z2(kp)); % Left-looking
% Gamma_right = @(kp)  (Z_in_right(kp) - Z2(kp)) ./ (Z_in_right(kp) + Z2(kp)); % Right-looking

% % Reflection Coefficients
% Gamma_left = @(kp)(Z3(kp) - Z2(kp)) ./ (Z3(kp) + Z2(kp)); % Left-looking
Gamma_left = @(kp)(Gamma_32(kp) + (-1)*exp(-1i*kz3(kp)*4*d))...
    ./(1 + Gamma_32(kp).*(-1).*exp(-1i*kz3(kp)*4*d)); % Left-looking
Gamma_right = @(kp) (Z1(kp) - Z2(kp)) ./ (Z1(kp) + Z2(kp)); % Right-looking

% Unknown A
A = @(kp) (Gamma_left(kp) .* exp(1i*kz2(kp)*2*z0))./(1 - Gamma_left(kp).*Gamma_right(kp).*exp(-2i * kz2(kp) * d)) ...
    .*( exp(-1i * kz2(kp) * zp) + Gamma_right(kp) .* exp( -1i * kz2(kp) * (2*z1 - zp)));

% Unknown B
B = @(kp) (Gamma_right(kp) .* exp(-1i*kz2(kp)*2*z1))./(1 - Gamma_left(kp).*Gamma_right(kp).*exp(-2i * kz2(kp) * d)) ...
    .*( exp(+1i * kz2(kp) * zp) + Gamma_left(kp) .* exp( +1i * kz2(kp) * (2*z0 - zp)));

% Denominator
D = @(kp) 1 - Gamma_left(kp).*Gamma_right(kp).*exp(-2i * kz2(kp) * d);

lxlim = k1*.5;
uxlim = k3*2;
p = linspace(lxlim,uxlim,num);
root = [];
for i = 1 : length(p)
    r = newtzero(D,1i*p(i));
    root = vertcat(root,r);
end
% Sort the array
root = sort(root);
% Clean up roots by weeding out too close values
if ~isempty(root)
    cnt = 1;  % Counter for while loop.
    
    while ~isempty(root)
        vct = abs(root - root(1)) < 1e-10; % Minimum spacing between roots.
        C = root(vct);  % C has roots grouped close together.
        [idx,idx] = min(abs(D(C)));  % Pick the best root per group.
        rt(cnt) = C(idx); %  Most root vectors are small.
        root(vct) = []; % Deplete the pool of roots.
        cnt = cnt + 1;  % Increment the counter.
    end
    root = sort(rt).';  % return a nice, sorted column vector
end


%% Physical Roots
% Real_roots = root(real(root)>k1);
% % Plot
figure(1)
N = 5; % Number of colors to be used
% Use Brewer-map color scheme
axes('ColorOrder',brewermap(N,'Set1'),'NextPlot','replacechildren')
Colord = get(gca, 'ColorOrder');

plot((real(root)/k1), (imag(root)/k1), 's', 'markersize',4,...
    'MarkerFaceColor',Colord(1,:));
hold on
plot((real(k1)/k1) , (imag(k1)/k1), 'd', 'markersize',4,...
    'MarkerFaceColor',Colord(2,:));
% plot(real(k1)/k1 , imag(k1)/k1, 'd', 'markersize',4,...
%     'MarkerFaceColor',Colord(4,:));
% plot(real(k3)/k1 , imag(k3)/k1, 'd', 'markersize',4,...
%     'MarkerFaceColor',Colord(5,:));
% plot(real(Real_roots)/k1 , imag(Real_roots)/k1, 's', 'markersize',6,...
%     'MarkerFaceColor',Colord(5,:));
xlabel('$\Re\textrm{k}_{\rho}$','interpreter','latex')
ylabel('$\Im\textrm{k}_{\rho}$','interpreter','latex')
legend('Poles','Branch Point',...
    'Location','southwest','Orientation','horizontal');
if nu == 0
    title(['TE Pole Locations for thickness d = ', num2str(d), 'm']);
else
    title(['TM Pole Locations for thickness d = ', num2str(d), 'm']);
end
% Decorations

box on
set(gcf,'color','white');
set(groot,'defaulttextinterpreter','latex');
set(gca,'TickLabelInterpreter', 'latex');
set(gca,...
    'box','on',...
    'FontName','times new roman',...
    'FontSize',12);
hold off

% xlim([lxlim 10*uxlim])
% ylim([-4.5e6 1e6])
% xlim([0           12000])
% ylim([-400000      600000])
% -1.9399e+09   2.7713e+08.
% 0           12000

% Save tikz figure
% cleanfigure();
if nu == 0
    matlab2tikz('filename',sprintf('figures/TE_pole_loc_d_%d.tex',floor(d*1e7)),'showInfo', false);
else
    matlab2tikz('filename',sprintf('figures/TM_pole_loc_d_%d.tex',floor(d*1e7)),'showInfo', false);
end



%% Plot Relative Pole Locations from the Branch Point
figure(2)
N = 2; % Number of colors to be used
% Use Brewer-map color scheme
axes('ColorOrder',brewermap(N,'Set1'),'NextPlot','replacechildren');
Colord = get(gca, 'ColorOrder');
%
plot(real(root) , (imag(root)), 's', 'markersize',4,...
    'MarkerFaceColor',Colord(1,:));
hold on
plot(real(k1)  , imag(k1) , 'd', 'markersize',4,...
    'MarkerFaceColor',Colord(2,:));
%
xlabel('$\textrm{Real Relative Distance from Branch Point}$','interpreter','latex')
ylabel('$\textrm{Imaginary Relative Distance from Branch Point}$','interpreter','latex')
legend('Poles','Branch Point',...
    'Location','northeast','Orientation','horizontal');
if nu == 0
    title(['Relative TE Pole Locations for thickness d = ', num2str(d), 'm']);
else
    title(['Relative TM Pole Locations for thickness d = ', num2str(d), 'm']);
end
% Decorations

box on
set(gcf,'color','white');
set(groot,'defaulttextinterpreter','latex');
set(gca,'TickLabelInterpreter', 'latex');
set(gca,...
    'box','on',...
    'FontName','times new roman',...
    'FontSize',12);
hold off

% Save tikz figure
% cleanfigure();
if nu == 0
    matlab2tikz('filename',sprintf('figures/TE_pole_rel_loc_d_%d.tex',floor(d*1e7)),'showInfo', false)
else
    matlab2tikz('filename',sprintf('figures/TM_pole_rel_loc_d_%d.tex',floor(d*1e7)),'showInfo', false)
end

%% Plot Pole Verification
figure(3)
N = 2; % Number of colors to be used
% Use Brewer-map color scheme
axes('ColorOrder',brewermap(N,'Set1'),'NextPlot','replacechildren')
% Obtain the colors of the plot to apply it on marker faces
Colord = get(gca, 'ColorOrder');
%
semilogy(abs(real(D(root))), 's', 'markersize',4,...
    'MarkerFaceColor',Colord(1,:));
hold on
semilogy(abs(imag(D(root))), 'o', 'markersize',4,...
    'MarkerFaceColor',Colord(2,:));
%
xlabel('$\textrm{Zero Number}$','interpreter','latex')
ylabel('$\textrm{Absolute Error}$','interpreter','latex')
legend('Real Part','Imaginary Part',...
    'Location','southeast','Orientation','horizontal');
title('Evaluation of Denominator at computed zeros');
% Decorations

box on
set(gcf,'color','white');
set(groot,'defaulttextinterpreter','latex');
set(gca,'TickLabelInterpreter', 'latex');
set(gca,...
    'box','on',...
    'FontName','times new roman',...
    'FontSize',12);
hold off

% Save tikz figure
% cleanfigure();
if nu == 0
    matlab2tikz('filename',sprintf('figures/TE_pole_discrepancy_with_nopec_d_%d.tex',floor(d*1e7)),'showInfo', false)
else
    matlab2tikz('filename',sprintf('figures/TM_pole_discrepancy_nopec_d_%d.tex',floor(d*1e7)),'showInfo', false)
end
% End
toc


% clear;clc

f = 1e12;
omega = 2*pi*f;
lambda = 3e8/f;

% Material Properties
ep1 = 1; % Air
ep2 = 7.4; % GaN layer
ep3 = 11.9; % Silicon base

% EM constants
mu0 = 4*pi*1e-7;
ep0 = 8.854e-12;

% Propagations Constants
k1 = omega*sqrt(mu0*ep0*ep1);
k2 = omega*sqrt(mu0*ep0*ep2);
k3 = omega*sqrt(mu0*ep0*ep3);

% Middle Layer thickness
d = -.5*lambda;

% Source Location
zp = 0;

% Layer Heights
z0 = -lambda;
z1 = 0;


% TE/TM switch
nu = 1;

syms kp

% Wavevector
kz1 = sqrt(k1 ^2 - kp .^2);

kz2 = sqrt(k2 ^2 - kp .^2);

kz3 = sqrt(k3 ^2 - kp .^2);
if nu == 0
    
    % TE Case
    Z1 = omega./kz1;
    Z2 = omega./kz2;
    Z3 = omega./kz3;
else
    % TM case
    Z1 = kz1./(omega*ep1);
    Z2 = kz2./(omega*ep2);
    Z3 = kz3./(omega*ep3);
end

% Reflection Coefficients
Gamma_left = (Z3 - Z2) ./ (Z3 + Z2); % Left-looking
Gamma_right =  (Z1 - Z2) ./ (Z1 + Z2); % Right-looking

% Unknown A
A = (Gamma_left .* exp(1i*kz2*2*z0))./(1 - Gamma_left.*Gamma_right.*exp(-2i * kz2 * d)) ...
    .*( exp(-1i * kz2 * zp) + Gamma_right .* exp( -1i * kz2 * (2*z1 - zp)));

% Unknown B 
B = (Gamma_right .* exp(-1i*kz2*2*z1))./(1 - Gamma_left.*Gamma_right.*exp(-2i * kz2 * d)) ...
    .*( exp(+1i * kz2 * zp) + Gamma_left .* exp( +1i * kz2 * (2*z0 - zp)));

% Denominator
D = 1 - Gamma_left.*Gamma_right.*exp(-2i * kz2 * d);

lxlim = k1/2;
uxlim = k3*1.2;
kpp = linspace(lxlim,uxlim,1e3);

% D = sqrt(-1 + kp^2);
% zzz = taylor(D, kp,'ExpansionPoint', k2, 'Order',6,'OrderMode','relative');
% yD = subs(D,kp,kpp);

%%
% clf
% figure (2);
% N = 2; % Number of colors to be used
% % Use Brewer-map color scheme
% axes('ColorOrder',brewermap(N,'Set1'),'NextPlot','replacechildren')
% % 
% semilogx(kpp,real(yD), 'linewidth',1.3);
% 
% % loglog(kp, abs(D), 's', 'markersize',4);
% xlabel('$k_{\rho}$','interpreter','latex')
% ylabel('$\mathcal{D}$','interpreter','latex')
% % legend([h1],{'DE Rule 0 to k'},...
% %      'location','northwest');
% if nu == 0
%     title('Denominator in TE case','interpreter','latex');
% else
%     title('Denominator in TM case','interpreter','latex');
% end
% % Decorations
% box on
% set(gcf,'color','white');
% set(groot,'defaulttextinterpreter','latex');
% set(gca,'TickLabelInterpreter', 'latex');
% set(gca,...
%     'box','on',...
%     'FontName','times new roman',...
%     'FontSize',12);
% hold off
% xlim([lxlim uxlim])
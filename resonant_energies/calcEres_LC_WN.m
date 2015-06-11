function [Eres_keV, theta] = calcEres_LC_WN( r, mlat, f, ne);

% RETURNS Resonant Energy at loss cone 
% for wave normals from zero to the resonance cone

% NEED
% r, mlat (in deg)
% f in Hz
% ne in cm-3
mlat = mlat*pi/180;
w = 2*pi*f;
ne = ne.*100^3;



me = 9.11e-31;
mp = 1.67e-27;
q  = 1.60e-19;
Bo = 3.12e-5;
epsilon_o = 8.85e-12;
c = 3e8;
RE = 6378e3;
ra = (100e3+RE)/RE;

wpe = sqrt( ne.*q^2/me/epsilon_o );
fpe = wpe./2/pi;

L = r./cos(mlat)^2;
B = Bo * (1/r)^3 * sqrt( 1 + 3*sin(mlat)^2 );
wce = q*B/me;

% LOSS CONE AT r, mlat
mlat_a = acos(sqrt(ra/L));
Ba = Bo * (1/ra)^3 * sqrt( 1 + 3*sin(mlat_a)^2 );
alpha_LC = asin( sqrt(B/Ba) );

% RESONANCE CONE
theta_res = acos( w/wce );
theta = linspace(0, theta_res, 50);
theta = theta(1:end-1);

% QUASI-LONGITUDINAL PROPAGATION
k = w ./ c .* sqrt( 1 - wpe.^2./(w^2 - w*wce.*cos(theta) ) );

% PARALLEL RESONANT ENERGY AND VELOCITY
vpar =  (wce - w)./ (k .* (cos(theta) + tan(alpha_LC).*sin(theta) ) );


vperp = vpar .* tan( alpha_LC );

v = sqrt( vpar.^2 + vperp.^2 );
E = 0.5*me.*v.^2;
E_eV = E./1.6e-19;

Eres_keV = E_eV/1e3;
theta = rad2deg(theta);


function [Eres_keV_rel, w] = calcEres_LC( r, mlat, f, ne, m_resonance)
% Eres_keV_rel = calcEres_LC( r, mlat, f, ne)
% 
% Determine minimum resonant energy by calculating parallel resonant
% velocity and adding perpendicular velocity for particles on the loss cone
% (which is the maximum total velocity for trapped particles)
% 
% INPUTS
% r (Re)
% mlat (deg)
% f (Hz if f > 1, or fraction of wce if f < 1)
% ne in (cm^-3)
% m_resonance: resonance number (0=Landau, 1=cyclotron)
% 
% OUTPUTS
% Eres_keV_rel: relativistically corrected energy
% w: wave frequency (useful if input frequency f is a fraction of equatorial
% gyrofrequency)

% Originally by Maria Spasojevic
% Modified by Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id$

if ~exist('m_resonance', 'var')
%   m_resonance = 0;
  m_resonance = 1;
end

mlat = mlat*pi/180;
ne = ne.*100^3; % convert to m^-3

me = 9.11e-31;
mp = 1.67e-27;
q  = 1.60e-19;
Bo = 3.12e-5;
epsilon_o = 8.85e-12;
c = 3e8;
RE = 6378e3;
ra = (100e3+RE)/RE; % 100 km altitude (ionosphere)

wpe = sqrt( ne.*q^2/me/epsilon_o );
fpe = wpe./2/pi;

L = r./cos(mlat)^2;
B = Bo * (1./r).^3 * sqrt( 1 + 3*sin(mlat)^2 );

wce = q*B/me;
if f > 1
  w = 2*pi*f;
else
  w = f*wce;
end

% LOSS CONE AT r, mlat
mlat_a = acos(sqrt(ra./L)); % mag lat at ionosphere along this field line
Ba = Bo * (1/ra)^3 * sqrt( 1 + 3*sin(mlat_a).^2 ); % B-field strength at ionosphere along this field line
alpha_LC = asin( sqrt(B./Ba) );

% PARALLEL RESONANT ENERGY AND VELOCITY
% Derived from NON-RELATIVISTIC Appleton-Hartree.  The dominant cold plasma
% is what influences the wave velocity, so there is no need for a
% relativistic correction
k = w ./ c .* sqrt( 1 - wpe.^2./(w.^2 - w.*wce) );

% Write the resonance condition as w - k*vpar = m*wce/gamma
% Also, vpar = vres*cos(alpha_LC)
% Then you can solve for vres
vres = ((k.*cos(alpha_LC)./(w - m_resonance*wce)).^2 + 1/c^2).^(-1/2);
vres(imag(vres) ~= 0) = nan;
vpar = vres.*cos(alpha_LC);

% Relativistic correction
if vres >= c
    Eres_keV_rel = inf;
else
    gamma = (1 - (vres/c).^2).^(-1/2);
    E = (gamma - 1)*me*c^2; % Energy in joules
    % E = 0.5*me.*vres.^2;
    E_eV = E/1.6e-19;

    Eres_keV_rel = E_eV/1e3;
end

% fprintf('Non-relativistic: %0.1f keV\n', 0.5*me.*vres.^2/1.6e-19/1e3);
% fprintf('Relativistic: %0.1f keV\n', Eres_keV);

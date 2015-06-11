function [Brad,Btheta,Bmag] = bmodel( R, theta_rad );
% [Brad,Btheta,Bmag] = bmodel( R, theta )
%
% Returns the radial and theta directed Earth B-field components 
% in Tesla for a dipole field given geocentric radial distance 
% R in Earth radii and polar angle theta (magnetic co-latitude) 
% in radians.
%
% Also returns absolute field magnitude Bmag in Tesla.
%
% Notes:
% 1. Assumes 3.12e-5 T at the magnetic equator at 1 Earth radius.
% 2. Radial and theta directions are standard speherical coordinates.
% 3. R is not L-shell.  Use roflmlatd.m.
% 4. theta = pi/2 - magnetic_latitude

Bo = .312/10000; 			% B field at Equator (gauss -> tesla)

Bor3 = Bo*(R.^(-3));
Brad = -2*Bor3 .* cos(theta_rad);	% radial B-field
Btheta = -Bor3 .* sin(theta_rad);	% azimuthal B-field (theta-directed)
Bmag = sqrt(Brad.*Brad + Btheta.*Btheta); % magnitude

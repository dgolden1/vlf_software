function [F]=dispersion_relation(n, w, qs, Ns, ms, nus, B0 )
% Evaluate the dispersion relation function F(n,w) given the plasma
% parameters and the wavenormal n (in cartesian coordinates)
%
% n = refractive index vector
% w = frequency
% qs = vector of charges
% Ns = vector of number densities in m^-3
% ms = vector of masses
% nus = vector of collision frequencies
% B0 = the magnetic field (vector)

physconst

% Rotate n into the reference space
R = rotation_matrix_z(B0);
n = R'*n;

% Find the needed spherical components
nmag2 = (n(1).^2+n(2).^2+n(3).^2);
phi = real(acos((n(3)+eps)/(sqrt(nmag2)+eps)));

% Find the stix parameters
[S,D,P,R,L] = stix_parameters(w, qs, Ns, ms, nus, norm(B0));

% Old code
% $$$ A = S*sin(phi)^2+P*cos(phi)^2;
% $$$ B = R*L*sin(phi)^2+P*S*(1+cos(phi)^2);
% $$$ F = A*nmag2^2 - B*nmag2 + R*L*P;

% New code - evaluate the determinant directly
F = det([S-nmag2*cos(phi)^2, -j*D, nmag2*sin(phi)*cos(phi);
         j*D, S-nmag2, 0; 
         nmag2*sin(phi)*cos(phi),0,P-nmag2*sin(phi)^2]);


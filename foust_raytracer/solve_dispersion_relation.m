function [k1,k2]=solve_dispersion_relation(k, w, x, funcPlasmaParams)
% Solve the dispersion relation and return k.  Inputs:
% 
% k = wavenormal
% w = frequency
% x = position
%
% funcPlamsaParams should return the plasma parameters given a position x
% 
% function [qs, Ns, ms, nus, B0] = funcPlasmaParams(x)
% 
% where qs, Ns, ms, and nus are the charge, number density (m^-3), mass
% (kg), and collision frequency as column vectors, one per species.  B0 
% is the vector background magnetic field.
% 
% k1 and k2 are the positive and negative roots, respectively.

physconst;

[qs, Ns, ms, nus, B0] = funcPlasmaParams(x);

% Normalize the wavenormal direction by B0
k=k/norm(B0);
% Find the angle the k vector makes with B0
phi = acos(k'*B0/norm(k)/norm(B0));
% Magnitude of B0
B0mag = norm(B0);

% Find the stix parameters
[S,D,P,R,L] = stix_parameters(w, qs, Ns, ms, nus, B0mag);

A = S*sin(phi)^2+P*cos(phi)^2;
B = R*L*sin(phi)^2+P*S*(1+cos(phi)^2);
nsquared1 = (B+sqrt(B^2-4*A*R*L*P))/(2*A);
nsquared2 = (B-sqrt(B^2-4*A*R*L*P))/(2*A);

n1 = sqrt(nsquared1);
n2 = sqrt(nsquared2);

k1 = w*n1/c;
k2 = w*n2/c;

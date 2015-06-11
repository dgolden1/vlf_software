function [dFdk]=dispersion_relation_dFdk(k, w, x, funcPlasmaParams, d)
% Evaluate the gradient of the dispersion relation with respect to k.
% d is the relative factor for finite differencing 
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
% d = finite difference relative factor
physconst
[qs, Ns, ms, nus, B0] = funcPlasmaParams(x);

d=d*norm(k);
if( d == 0 )
  d = 1e-12;
end;

F = @(k) dispersion_relation(k*c/w, w, qs, Ns, ms, nus, B0 );

dFdk = zeros(3,1);
dFdk(1) = (F(k+d*[1;0;0])-F(k-d*[1;0;0]))/d/2;
dFdk(2) = (F(k+d*[0;1;0])-F(k-d*[0;1;0]))/d/2;
dFdk(3) = (F(k+d*[0;0;1])-F(k-d*[0;0;1]))/d/2;

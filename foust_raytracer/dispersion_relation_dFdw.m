function [dFdw]=dispersion_relation_dFdw(k, w, x, funcPlasmaParams, d )
% Evaluate the gradient of the dispersion relation with respect to w
% d is the relative factor for finite differencing.
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

d=d*norm(w);

F = @(w) dispersion_relation(k*c/w, w, qs, Ns, ms, nus, B0 );
dFdw = (F(w+d)-F(w-d))/d/2;

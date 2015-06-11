function [rhs] = raytracer_evalrhs(t, args, root, funcPlasmaParams)
physconst
% Format of args:
% args(1) = x (meters)
% args(2) = y (meters)
% args(3) = z (meters)
% args(4) = kx (m^-1)
% args(5) = ky (m^-1)
% args(6) = kz (m^-1)
% args(7) = w (rad/s)
% 
% funcPlamsaParams should return the plasma parameters given a position x
% 
% function [qs, Ns, ms, nus, B0] = funcPlasmaParams(x)
% 
% where qs, Ns, ms, and nus are the charge, number density (m^-3), mass
% (kg), and collision frequency as column vectors, one per species.  B0 
% is the vector background magnetic field.
%
d = 1e-8;
rhs = zeros(size(args));

x = args(1:3);
k = args(4:6);
w = args(7);

dfdk = dispersion_relation_dFdk(k, w, x, funcPlasmaParams, d);
dfdw = dispersion_relation_dFdw(k, w, x, funcPlasmaParams, d);
dfdx = dispersion_relation_dFdx(k, w, x, funcPlasmaParams, d);

rhs(1:3) = -(dfdk./dfdw);
rhs(4:6) = dfdx./dfdw;
rhs(7) = 0;

rhs = real(rhs);

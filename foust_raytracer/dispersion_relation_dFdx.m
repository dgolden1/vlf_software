function [dFdx]=dispersion_relation_dFdx(k, w, x, funcPlasmaParams, d)
% Evaluate the gradient of the dispersion relation with respect to x.
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
d=d*norm(x);

dFdx = zeros(3,1);

n = k*c/w;
% Central differencing
% x component
[qs, Ns, ms, nus, B0] = funcPlasmaParams(x+d*[1;0;0]);
Fp = dispersion_relation(n, w, qs, Ns, ms, nus, B0 );
[qs, Ns, ms, nus, B0] = funcPlasmaParams(x-d*[1;0;0]);
Fn = dispersion_relation(n, w, qs, Ns, ms, nus, B0 );
dFdx(1) = (Fp-Fn)/d/2;
% y component
[qs, Ns, ms, nus, B0] = funcPlasmaParams(x+d*[0;1;0]);
Fp = dispersion_relation(n, w, qs, Ns, ms, nus, B0 );
[qs, Ns, ms, nus, B0] = funcPlasmaParams(x-d*[0;1;0]);
Fn = dispersion_relation(n, w, qs, Ns, ms, nus, B0 );
dFdx(2) = (Fp-Fn)/d/2;
% z component
[qs, Ns, ms, nus, B0] = funcPlasmaParams(x+d*[0;0;1]);
Fp = dispersion_relation(n, w, qs, Ns, ms, nus, B0 );
[qs, Ns, ms, nus, B0] = funcPlasmaParams(x-d*[0;0;1]);
Fn = dispersion_relation(n, w, qs, Ns, ms, nus, B0 );
dFdx(3) = (Fp-Fn)/d/2;

% $$$ % Forward differencing (faster)
% $$$ [qs, Ns, ms, nus, B0] = funcPlasmaParams(x);
% $$$ Fn = dispersion_relation(n, w, qs, Ns, ms, nus, B0 );
% $$$ % x component
% $$$ [qs, Ns, ms, nus, B0] = funcPlasmaParams(x+d*[1;0;0]);
% $$$ Fp = dispersion_relation(n, w, qs, Ns, ms, nus, B0 );
% $$$ dFdx(1) = (Fp-Fn)/d;
% $$$ % y component
% $$$ [qs, Ns, ms, nus, B0] = funcPlasmaParams(x+d*[0;1;0]);
% $$$ Fp = dispersion_relation(n, w, qs, Ns, ms, nus, B0 );
% $$$ dFdx(2) = (Fp-Fn)/d;
% $$$ % z component
% $$$ [qs, Ns, ms, nus, B0] = funcPlasmaParams(x+d*[0;0;1]);
% $$$ Fp = dispersion_relation(n, w, qs, Ns, ms, nus, B0 );
% $$$ dFdx(3) = (Fp-Fn)/d;

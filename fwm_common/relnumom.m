function r=relnumom(gam)
% The reduced relativistic momentum transfer rate nu_m/Nm=2D(p)/Nm
% D - angular diffusion coeff.; in FP equation D_2=I_\perp*p^2*D(p).
% See the thesis.
global rclass0 clight
if isempty(rclass0)
    loadconstants
end
Zm=14.5;
v=sqrt(1-1./gam.^2);
p=sqrt(gam.^2-1);
r=2*pi*Zm^2*rclass0^2*clight./(v.^3.*gam.^2).*log(165/Zm^(1/3)*p);

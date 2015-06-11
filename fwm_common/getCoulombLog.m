function r=getCoulombLog(T0,en,Ne)
% T0,enav -- ion temperature and electron energy in eV
% Ne -- electron (ion) density
% See also "eecollisions.m"
global eps0 ech me
if Ne<=0
    error('Coulomb Log is defined only for Ne>0');
end
if isempty(eps0)
    loadconstants
end
% Plasma parameter or Coulomb logarithm
% Lambda=dmax/dmin for Coulomb collisions
%enav=sum(en.*ne); % average energy in eV
%Teff=2/3*enav*ech; % effective temperature in J
vth=sqrt(T0/me); % background thermal velocity
wp=sqrt(ech^2*Ne/me/eps0); % plasma frequency
%lamD=sqrt(eps0*Teff./(Ne*ech^2));
lamD=vth./wp; % Debye length
bm=ech.^2/2./(en*ech)/(4*pi*eps0); % minimum target parameter
r=log(lamD./bm);

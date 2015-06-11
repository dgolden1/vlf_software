function [ce,ch,che,co] = dens(L,lam,dsrrng,dsrlat,dsdens,...
                               therm,rbase,rzero,scbot,alpha0,...
                               KDUCTS,LK,EXPK,DDK,RCONSN,SCR,...
                               L0,DEF,DD,RDUCLN,HDUCLN,RDUCUN,HDUCUN,...
                               RDUCLS,HDUCLS,RDUCUS,HDUCUS,SIDEDU)
% [ce,ch,che,co] = dens(L,lam,dsrrng,dsrlat,dsdens,...
%                       therm,rbase,rzero,scbot,alpha0,...
%                       KDUCTS,LK,EXPK,DDK,RCONSN,SCR,...
%                       L0,DEF,DD,RDUCLN,HDUCLN,RDUCUN,HDUCUN,...
%                       RDUCLS,HDUCLS,RDUCUS,HDUCUS,SIDEDU)
%
% This function, "dens()", is the one you want to call.
%
% Interface to denssub.m to return plasma density at (L,lam) pairs based on
% the electron density set point given as the (dsrrng,dsrlat,dsdens) triple,
% according the the Diffusive Equilibrium Plasma Density Model as implemented
% in the Stanford VLF Group Raytracer. See Raytracer Documentation, denssub.m
% code, and Fortran code (newray1.8.f) for detail.
%
% Only the first 5 arguments are mandatory.
%
% Synopsis (denssub returns array ani, where ce,ch,che,co <- ani(1,2,3,4)):
%
% ANI(r) = ANE0 ANR(r) ANLI(r) ANLK(r,L) \Prod_2^{KDUCTS} ANL(r,L)
%
% In the above formula:
%
% r is understood to correspond to the L,lam pairs via the std. formula:
%   r = r0 * L .* cos(lamr').^2;
%
% ANI(r) here understood to be ANI(1) = ce at r
% ANE0 is base density, set by the (dsrlat,dsrrng,dsdens) triple.
% ANR  is the std. Diffusive Equilibrium factor after Angerami, Thomas, Park
% ANLI is the Lower Ionosphere factor to blend to zero density @ r = rzero
% ANLK is the Plasmapause Knee factor to drop density an order of magnitude
% ANL  are the Duct factors.  See Raytracer Documentation or study the code.
%
% Inputs (minimum required are 5 = 2 + 3):
% --------------------------
% evaluate density at:
%   L      = L-shell
%   lam    = magnetic latitude (deg)
%
% density set point at:
%   dsrrng = radial distance in earth radii for dsdens
%   dsrlat = magnetic latitude at which dsdens is valid
%   dsdens = density in el/cc
%
% (The remaining optional input values regard the density boundary conditions
% and addition of Ducts. See Raytracer Documentation by Ngo Hoc and/or inspect 
% dens.m and denssub.m)
%
% Outputs:
% --------
% ce	= electron density /cm^3
% ch	= proton   density /cm^3
% che	= helium   density /cm^3
% co	= oxygen   density /cm^3
%
% species ratios at base altitude default to 90% O+, 8% H+, 2% He+
% You may change this by passing down more arguments.

d2r = pi/180;
r0 = 6370;	% Earth radius (km)
drl = 1000;	% std. base height of magnetosphere (km)

deftherm = 2000; 	% default temperature
defrbase = r0 + drl;
defrzero = r0 + 100;
defscbot = 140;

if nargin < 5, error('not enough input arguments (need first 5)'); end;

if nargin < 6, therm = deftherm; end;
if nargin < 7, rbase = defrbase; end;
if nargin < 8, rzero = defrzero; end;
if nargin < 9, scbot = defscbot; end;

if nargin < 10, 	% default ion concentrations at rbase
  alpha0(2) = .08;	% H+ 
  alpha0(3) = .02;	% He+
  alpha0(4) = .90;	% O+
end;

num = 4;		% always use all 4 species: e-, H+, He+, O+

n = length(L);
if length(lam) ~= n, disp('dens: L,lam must be same length'); return; end;

L = L(:);		% ensure column vector
lam = lam(:)';		% ensure row    vector
lamr = lam*d2r;		% radian values

if length(L) ~= length(lam),
  disp('dens: L and lam must be same length-- abort');
  return;
end;

% ----------------------------------------------------------------------
% follow newray.for logic and variables *exactly* for now. Principally
% this is necessary to reset ane0 to the value implied by dsdens.
%
% If you can think of a better way which matches the result calculated
% by newray.for (or newray1.7.f), well, go ahead and implement it!
%
ane0 = 2562;		% this value will be reset by dsdens
z(1) = dsrrng*r0;
z(2) = d2r*(90.0-dsrlat);

% complicated calling logic depending on number of passed values
%
if nargin < 11,
  ani = denssub(z,rbase,therm,num,rzero,scbot,ane0,alpha0);
end;
if nargin > 10 & nargin < 17,
  ani = denssub(z,rbase,therm,num,rzero,scbot,ane0,alpha0,...
                 KDUCTS,LK,EXPK,DDK,RCONSN,SCR);
end;
if nargin > 16,
  ani = denssub(z,rbase,therm,num,rzero,scbot,ane0,alpha0,...
                 KDUCTS,LK,EXPK,DDK,RCONSN,SCR,...
                 L0,DEF,DD,RDUCLN,HDUCLN,RDUCUN,HDUCUN,...
                 RDUCLS,HDUCLS,RDUCUS,HDUCUS,SIDEDU);
end;

ane0 = dsdens * (ane0/ani(1));	% reset ane0 appropriate for dsdens

%disp( sprintf('dens: dsdens=%g, ane0=%g (dsrlat=%g)', dsdens, ane0, dsrlat ));

nL = length(L);

ce = zeros(nL,1);		% more convenient to calling program
ch = zeros(nL,1);
che = zeros(nL,1);
co = zeros(nL,1);

r = r0 * L .* cos(lamr').^2;	% geocentric radii for all (L,lam) pairs
for i=1:nL,
  z(1) = r(i);
  z(2) = d2r*(90.0-lam(i));

  if nargin < 11,
    ani = denssub(z,rbase,therm,num,rzero,scbot,ane0,alpha0);
  end
  if nargin > 10 & nargin < 17,
    ani = denssub(z,rbase,therm,num,rzero,scbot,ane0,alpha0,...
                  KDUCTS,LK,EXPK,DDK,RCONSN,SCR);
  end;
  if nargin > 16,
    ani = denssub(z,rbase,therm,num,rzero,scbot,ane0,alpha0,...
                  KDUCTS,LK,EXPK,DDK,RCONSN,SCR,...
                  L0,DEF,DD,RDUCLN,HDUCLN,RDUCUN,HDUCUN,...
                  RDUCLS,HDUCLS,RDUCUS,HDUCUS,SIDEDU);
  end;

  ce(i) = ani(1);	% dissect the answer
  ch(i) = ani(2);
  che(i) = ani(3);
  co(i) = ani(4);
end;

return;

% some typical defaults (placed here for reference)
%
KDUCTS = 1;		% knee counts as first duct
LK = 4.5;		% knee location
EXPK = 3;
DDK = .25;
RCONSN = 7000;
SCR = 3000;


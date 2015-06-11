function sigma=BrTot(k,E0,scr,Z,noscale)
%function sigma=BrTot(k,E0,scr,Z,noscale)
%   Total bremsstrahlung total cross-section d(sig)/dk, in cm^2
%   Z - atomic number of the atom which emits bremsstrahlung
%       from the nucleus and electrons
%   k  - photon energy in units of m*c^2 (m is the electron mass)
%   E0 - electron relativistic factor (=1+Energy/(mc^2))
%   k,E0 - matrices of same dimensions
%   noscale - optional boolean (0 or 1) argument. If =1, then give
%               sigma/phi0, where phi0=(Z+1)*r0*r0/137
%   We now take into account the screening:
%   scr -- =1 for screening, =0 for no screening.
% See Koch, H. W. and J. W. Motz, Rev. Mod. Phys., vol. 31, p. 920 (1959).
if(nargin<4)
	error('not enough arguments')
elseif (nargin==4)
	noscale=0;
end
% Adjust the sizes
[k,E0]=meshgrid(k,E0);
e=4.8029e-10;
m=9.1084e-28;
c=2.997923e+10;
mc2=m*c*c;
r0=e*e/mc2; % 2.8179e-13 cm - classic electron radius
phi0=(Z+1)*Z*r0*r0/137.; % scale of cross-section - additional Z from electrons
%  All energy and momentum values are in quantities of "mc^2"
%  "p" is actual momentum multiplied by "c" (also in the units of "mc^2")
%  E0=1/sqrt(1.-b0*b0);
if(any(size(k)~=size(E0)))
	error('Unmatched sizes');
end;
[m n]=size(E0);
if(any(E0<1))
	error('Negative kinetic energy');
end
b0=sqrt(1.-1./E0./E0);
E=E0-k; % Final electron energy
valid=(E>1+1e-5);  % region of validity
E=valid.*E+(1-valid).*(1+1e-5); % make them all valid, kill invalids in the end
b=sqrt(1.-1./E./E);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Heitler cross-section in Born approximation.
coef=.1;
validBorn=((b0*coef>Z/137) & (b*coef>Z/137));
p0=sqrt(E0.*E0-1);
p=sqrt(E.*E-1);
p2=p.*p; p02=p0.*p0; k2=k.*k; pp0=p.*p0; EE0=E.*E0;
p3=p2.*p; p03=p02.*p0;
eps0=2*log(E0+p0);
eps=2*log(E+p);
tmp=EE0+pp0-1; % was EE0+pp0-k2 !!
validLog=tmp>0;
%validBorn.*valid.*(tmp<0)
%if(any(any(validBorn.*valid.*(tmp<0))))
%	error('Born valid');
%end
tmp=tmp.*validLog+(1-validLog).*1; % Get rid of negative log
L=2*log(tmp./k);
phi1=4./3.-2.*EE0.*(p2+p02)./(p2.*p02)+(eps0.*E./p03+eps.*E0./p3-eps.*eps0./pp0);
phi2=(8./3.)*EE0./pp0+...
		k2.*(EE0.*EE0+p02.*p2)./p03./p3+...
		(k./pp0/2.).*(eps0.*(EE0+p02)./p03-eps.*(EE0+p2)./p3+2.*k.*EE0./p2./p02);
%%%%%%%%
sigma3BN=(phi1+L.*phi2).*p./p0./k;
%%%%%%%%
% Born approximation validity
sigma=sigma3BN.*valid.*validBorn.*validLog.*(sigma3BN>0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCREENING
% Screening indicator: gamscr<<1 -- complete screening, gamscr>>1 -- no screening
gamscr=100*k./(E.*E0)*Z^(-1./3);

% Screening factor - only for theta=0 (otherwise too compicated).
q=abs(p0-p-k); % momentum transfered to the nucleus
% Schiff approximation: Thomas-Fermi potential=(Ze/r)*exp(-r/a)
a=111*Z^(-1/3); % atom radius in compton wavelengths h/(mc) units
Fscr=1./(1+(a.*q).^2); % always from 0 to 1
% Complete screening
sigma3BSa=4*((1+(E./E0).^2-(2/3)*E./E0)*log(183*Z^(-1/3))+(1/9)*E./E0)./k;

% The screening
if(scr==1)
	%sigmaShiff=sigma.*(1-Fscr).^2;
	% Choose the maximum of sigma3BSa and sigmaShiff.
	%sigmascr=sigma3BSa+(sigmaShiff>sigma3BSa).*(sigmaShiff-sigma3BSa);
	sigmascr=sigma3BSa;
	% Choose the minimum of the result and no screening formula
	sigma=sigma-(sigma>sigmascr).*(sigma-sigmascr);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(noscale==0)
	sigma=sigma*phi0;
end

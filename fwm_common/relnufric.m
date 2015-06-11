function fric=relnufric(gam)
% nu=relnufric(gam) - Relativistic dynamic friction force /p/Nm
% [f,fric]=FD(Nm,Ee): Nm in 1/m^3; Ee in MeV
% Nm - density of atmospheric (diatomic) molecules
% Ee - electron kinetic energy (mc2)
% f - friction force (Newtons)
% fric - slow-down rate (1/sec) 
% f1 - the friction force with a correction
%      (for ionization at > 1 keV)
global rclass0 me ech clight
if isempty('rclass0')
    loadconstants
end

Zm=14.5;
coef=4*pi*Zm*rclass0^2*clight;


gam2=gam.^2;
gami=1./gam;
gami2=1./gam2;
mag=(me*clight^2/ech)/80.5; % =m*c^2/I
f= gam2./(gam2-1).*(...
	0.5*log((gam2-1).*(gam-1)/2) ...
	+ log(mag)  ...
	- (2*gami-gami2)*log(2)/2 ...
	+ gami2/2 ...
	+ (gam-1).^2.*gami2/16 ...
	);
f=coef*f;
p=sqrt(1-gami2).*gam;

fric=f./p;

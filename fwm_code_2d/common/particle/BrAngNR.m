function sig=BrAngNR(T0,k,cth0)
% Same as BrAng, but with nonrelativistic approximation,
% from (25.17) in Heitler (calculated by me). Also T0 is the
% kinetic energy only (no rest energy included).
% T0,k are in units of mu=mc^2, must be <<1
% k=(p0.^2-p.^2)/2; % photon energy in units of mu
% For the Born condition, \beta,\beta_0 >> 2*pi*Z*alpha, where
% alpha=1/137.
p0=sqrt(2*T0);
T=T0-k;
if any(T(:)<0)
    error('T<0')
end
p=sqrt(2*T);
phi0=1/2/pi/137./k; % if energy, remove ./k
sig=phi0./p0.^4.*(log((p0+p)./(p0-p)).*...
    ((3*p0.^2-p.^2)+cth0.^2.*(3*p.^2-p0.^2))...
    +2*p.*p0.*(1-3*cth0.^2));
% Result must be multiplied by Z^2*rclass0^2

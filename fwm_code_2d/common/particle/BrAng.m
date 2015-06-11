function sig=BrAng(E0,k,cth0)
% Doubly differential bremsstrahlung cross-section for non-relativisitic
% electrons only. It is the integrated over d\Omega 25.13 in Heitler, as
% calculated by Gluckstern and Hull, 1953 (doi:10.1103/PhysRev.90.1030).
% Per dk, d\Omega_0
% E0,k are in units of mu=mc^2, must be <<1
% k=E0-E photon energy in units of mu
% For the Born condition, \beta,\beta_0 >> 2*pi*Z*alpha, where
% alpha=1/137.
phi0=1/2/pi/137./k;
E=E0-k;
p0=sqrt(E0.^2-1);
p=sqrt(E.^2-1);
sth02=1-cth0.^2;
D0=E0-p0.*cth0;
% T=p' in Heitler
T2=p0.^2+k.^2-2*p0.*k.*cth0;
T=sqrt(T2);
L=log((E.*E0-1+p.*p0)./(E.*E0-1-p.*p0));
eT=log((T+p)./(T-p));
e=log((E+p)./(E-p));
Lcoef=4*E0.*sth02.*(3*k-p0.^2.*E)./(p0.^2.*D0.^4)...
    +(4*E0.^2.*(E0.^2+E.^2)-2*(7*E0.^2-3*E.*E0+E.^2)+2)./(p0.^2.*D0.^2)...
    +2*k.*(E0.^2+E.*E0-1)./(p0.^2.*D0);
sig=phi0.*p./p0/4.*(...
    8*sth02.*(2*E0.^2+1)./(p0.^2.*D0.^4)...
    -2*(5*E0.^2+2*E.*E0+3)./(p0.^2.*D0.^2)...
    -2*(p0.^2-k.^2)./(T2.*D0.^2)+4*E./(p0.^2.*D0)...
    +L.*Lcoef./(p.*p0)...
    +eT./(p.*T).*(4./D0.^2-6*k./D0-2*k.*(p0.^2-k.^2)./(T2.*D0))...
    -4*e./(p.*D0));
% Result must be multiplied by Z^2*rclass0^2

function qh=cosmicrayq(h)
% Cosmic-ray source for ion-electron pair creation, in cm^{-3}s^{-1}
global ATM
if isempty(ATM)
    loadconstants
end
 % in kg/m^2
X0=366.6; % rad. length in kg/m^2
t=ATM.TAC/X0;
y=1; % This is a parameter (=E0/Ec for CR showers)
s=3./(1+2*y./t);
Ne=.31/sqrt(y)*exp(t.*(1-1.5*log(s)));
q=Ne.*ATM.Nm;
q=40*q./max(q);
% Doesn't give the right amount at Earth surface (which should be 2 pairs/cm^3/s)
qh=exp(interp1(ATM.h,log(q),h));

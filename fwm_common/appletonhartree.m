function [n2,thg]=appletonhartree(th,X,Y,mode)
% The same as coldplasma(th,X,Y,0)
s=sin(th);
c=cos(th);
P=1-X;
Del=sqrt(Y.^2.*s.^4+4.*P.^2.*c.^2);
denom=2.*P-Y.^2.*s.^2+mode*Y.*Del;
n2=1-(2*P.*X)./denom;

% For ray tracing: the alfa
tana=mode*2*P.*X.*Y.*s.*c./(Del.*denom);
dn2dth=-tana*2*n2;
% The group velocity vector direction
thg=th+atan(tana);
thg(find(n2<0))=nan;
dn2dX=2.*((2.*X-1).*denom-2.*P.*X.*(1+mode*2.*Y.*P.*c.^2./Del))./denom.^2;
dn2dY=4.*X.*P*(-Y.*s.*Del+mode.*(Y.^2.*s.^4+2.*P.^2.*c.^2))./denom.^2./Del;

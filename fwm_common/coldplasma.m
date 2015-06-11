function [n21,n22]=coldplasma(th,X,Y,mM)
s=sin(th);
c=cos(th);
P=1-X;
R=1-X./(1-Y);
L=1-X./(1+Y);
if mM>0
    P=P-mM*X;
    R=R-mM*X./(1+mM*Y);
    L=L-mM*X./(1-mM*Y);
end
S=(R+L)/2;
D=(R-L)/2;
A=S.*s.^2+P.*c.^2;
B=(R.*L).*s.^2+(P.*S).*(1+c.^2);
F=sqrt((R.*L-P.*S).^2.*s.^4+(4*P.^2.*D.^2).*c.^2);
n21=(B+F)./(2*A);
n22=(B-F)./(2*A);

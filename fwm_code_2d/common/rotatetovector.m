function r1=rotatetovector(p,r);
n=p/sqrt(sum(p.^2));
ct=n(3);
st=sqrt(1-ct^2);
phi=atan2(n(2),n(1));
sp=sin(phi); cp=cos(phi);
r1=[ct*cp -sp n(1) ; ct*sp cp n(2) ; -st 0 ct]*r;

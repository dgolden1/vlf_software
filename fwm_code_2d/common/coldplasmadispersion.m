function g=coldplasmadispersion(w,kx,ky,kz,Ne,mM,Bx,By,Bz)
%COLDPLASMADISPERSION 2-component cold plasma dispersion
%
% To be used with ray tracing programs
% The dispersion equation is
%  g(w,kx,ky,kz)=0
% where g=coldplasmadispersion(w,kx,ky,kz,Ne,mM,Bx,By,Bz)
global ech me eps0 clight
if nargin<9 & nargin>6
    error('Please provide all B components');
end
if nargin<=6
    Bx=0; By=0; Bz=0;
end
if nargin<=5
    mM=0;
end
if nargin<=4
    Ne=0;
end
if nargin<4
    error('Not enough arguments');
end
k02=(w/clight)^2;
k2=kx^2+ky^2+kz^2;
if Ne==0
    % Vacuum
    g=(k2-k02)^2;
    dgdk02=-2*(k2-k02);
    dgdw=dgdk02*2*w/clight^2;
    return;
end
% Now we know that we deal with plasma
wp2=ech^2*Ne/(me*eps0);
X=wp2/w^2;
P=1-(1+mM)*X;
B2=Bx^2+By^2+Bz^2;
B=sqrt(B2);
if B2==0
    % Isotropic plasma
    g=P*(k2-P*k02)^2;
    dgdk02=-0; % UNFINISHED!!!!!!!!
    dgdw=dgdk02*2*w/clight^2;
    return
end
% Magneto-active plasma
% Convert k to the coordinate system where B is along z1
kz1=(kx*Bx+ky*By+kz*Bz)/B;
kx1=sqrt(k2-kz1^2);
wH=ech*B/me;
Y=wH/w;
R=1-X./(1-Y);
L=1-X./(1+Y);
if mM>0
    R=R-mM*X./(1+mM*Y);
    L=L-mM*X./(1-mM*Y);
end
S=(R+L)/2;
g=(S*kx1^2+P*kz1^2)*k2...
    -(R*L*kx1^2+P*S*(k2+kz1^2))*k02...
    +P*R*L*k02^2;
% The frequency derivative -- for the absolute value of Vg
% (not necessary for ray tracing)
dgdk02=0; % UNFINISHED!!!!!!!!
dgdw=dgdk02*2*w/clight^2;

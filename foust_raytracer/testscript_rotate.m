e0 = randn(3);
% Ensure skew-symmetry like for the permittivity tensor
e0(2,1) = -e0(1,2);
e0(3,1) = -e0(1,3);
e0(3,2) = -e0(2,3);

% test 1
w=[-1 -.5 5]';

w=w/norm(w);
u=[w(3);w(3);-w(1)-w(2)]/sqrt(2*w(3)^2+(w(1)+w(2))^2);
v=cross(w,u);
R=[u,v,w];

R'*w

R*e0*R'

% test 2
phi = acos(w(3)/norm(w));
theta = atan2(w(2),w(1));
ct = cos(theta);
st = sin(theta);
cp = cos(phi);
sp = sin(phi);
Rz=[ct -st 0; st ct 0; 0 0 1];
Ry=[cp 0 sp; 0 1 0; -sp 0 cp];
R=Rz*Ry;

R'*w

R*e0*R'

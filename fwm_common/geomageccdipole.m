function [b,dip,decl]=geomageccdipole(lat,lon,alt)
% Calculate the conversion to eccentric dipole
% See "Handbook of geophysics", p. 4-26

Re=6371.2; % mean earth radius Re=6371.2 km from IGRF
M=7.9e6; % Earth dipole moment is M=7.9e15 T*m^3 ("Handbook", page 4-25)

th1=pi/2-81.0*pi/180;
ph1=275.3*pi/180;
th2=pi/2+75.0*pi/180;
ph2=120.4*pi/180;

r1=Re*[sin(th1)*[cos(ph1);sin(ph1)];cos(th1)];
r2=Re*[sin(th2)*[cos(ph2);sin(ph2)];cos(th2)];

dr=r1-r2;

n=dr/sqrt(sum(dr.^2));

the=acos(n(3));
phe=atan2(n(2),n(1));

% Displacement
thd=pi/2-15.6*pi/180;
phd=150.9*pi/180;
rd=436*[sin(thd)*[cos(phd);sin(phd)];cos(thd)];

if 0
    % Deviation
    dr=r1-rd;
    dthe1=acos(dr(3)/sqrt(sum(dr.^2)))-the
    dphe1=atan2(dr(2),dr(1))-phe
    
    dr=rd-r2;
    dthe2=acos(dr(3)/sqrt(sum(dr.^2)))-the
    dphe2=atan2(dr(2),dr(1))-phe
    
    % OK, assume we don't care about these (~1e-4)
end

% The radius vector of our point
th=pi/2-lat;
ph=lon;
r=(Re+alt)*[sin(th)*[cos(ph);sin(ph)];cos(th)];
% Relative to the dipole
rr=r-rd;
ra=sqrt(sum(rr.^2));
bm=M/(ra^3);

% Active rotation matrix towards (the,phe) direction
rotmxa=[cos(phe) -sin(phe) 0; sin(phe) cos(phe) 0; 0 0 1]*...
    [cos(the) 0 sin(the); 0 1 0; -sin(the) 0 cos(the)];
% Passive rotation
rotmxp=[cos(the) 0 -sin(the); 0 1 0; sin(the) 0 cos(the)]*...
    [cos(phe) sin(phe) 0; -sin(phe) cos(phe) 0; 0 0 1];

rri=rotmxp*rr;
phi=atan2(rri(2),rri(1));
thi=acos(rri(3)/ra);
Bi=-bm*[3*cos(thi)*sin(thi)*[cos(phi);sin(phi)];3*cos(thi)^2-1];
b=bm*sqrt(3*cos(thi)^2+1);
% Active rotation back
B=rotmxa*Bi;

% Convert to geomagnetic coordinates
% Passive rotation
rotmxp2=[cos(th) 0 -sin(th); 0 1 0; sin(th) 0 cos(th)]*...
    [cos(ph) sin(ph) 0; -sin(ph) cos(ph) 0; 0 0 1];
Bp=rotmxp2*B;
dip=atan2(-Bp(3),-Bp(1));
decl=atan2(Bp(2),-Bp(1));

function [h,az] =  sunAngle(tVec,lat,lon)

%syntax:
%-------
%[h,az] =  sunAngle(tVec,lat,lon)
%
%inputs:
%------
%tVec: [year month day hour minute second] -- UT
%lat: matrix of lats
%lon: matrix of lons
%
%outputs:
%--------
%h: elevation of sun (in degrees)
%az: azimuth of sun from north (in degrees)

slat = size(lat);
slon = size(lon);

if(slat(1)~= slon(1) | slat(2) ~= slon(2))
    error('lat and lon dimensions must be equal');
end


k = pi/180;
rad = 180/pi;

JD = julianDay(tVec);
%Number of Julian Centuries since 2000/01/01 at 12UT:
T = (JD - 2451545.0)/36525;

%Solar Coordinates:
%Mean anomaly:
M = 357.52910 + 35999.05030*T - .0001559*T*T - 0.00000048*T*T*T;    %[deg]
%Mean longitude:
L0 = 280.46645 + 36000.76983*T + 0.0003032*T*T; %[deg]
DL = (1.914600 - 0.004817*T - 0.000014*T*T)*sin(k*M) + ...
    (0.019993 - 0.000101*T)*sin(k*2*M) + 0.000290*sin(k*3*M);

%True longitude:
L = L0 + DL;    %[deg]

%Convert ecliptic longitude L to right ascension RA and declination delta:
eps = 23.43999; %[deg] obliquity of ecliptic
X = cos(k*L);
Y = cos(k*eps)*sin(k*L);
Z = sin(k*eps)*sin(k*L);
R = sqrt(1-Z^2);

delta = rad*atan2(Z,R); %[deg] declination -- latitude position of sun --
RA = 7.63943726841098*atan2(Y,(X+R)); %[hours] right ascension
RA = RA*360/24; %[deg] right ascension

%Compute Sidereal time at Greenwich (only depends on time)
theta0 = 280.46061837 + 360.98564736629*(JD-2451545.0) + 0.000387933*T*T - T*T*T/38710000.0;    %[deg]
theta0 = mod(theta0,360);

%fprintf('RA = %f, theta0 = %f, delta = %f\n',RA,theta0,delta);
delta = delta/rad;
theta = (theta0 + lon)/rad; %rad
tau = theta - RA/rad;	%rad
beta = lat/rad;	%rad
h =   asin(sin(beta).*sin(delta) + cos(beta).*cos(delta).*cos(tau))*rad;	%deg
az =  atan2(-sin(tau),(cos(beta).*tan(delta) - sin(beta).*cos(tau)))*rad; %deg

function [h,az] =  sunAngle(lat,lon,year,month,day,hour,minute,second)

%All times given in UT
%All angles input in degrees
k = 2*pi/360;

%Calculate Julian Day:
JD = JulianDay(year,month,day,hour,minute,second);

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

delta = (180/pi)*atan2(Z,R); %[deg] declination -- latitude position of sun --
RA = (24/pi)*atan2(Y,(X+R)); %[hours] right ascension
RA = RA*360/24; %[deg] right ascension

%Compute Sidereal time at Greenwich (only depends on time)
theta0 = 280.46061837 + 360.98564736629*(JD-2451545.0) + 0.000387933*T*T - T*T*T/38710000.0;    %[deg]
theta0 = mod(theta0,360);   

%---- Now use longitude ---- 
%local sidereal time
theta = theta0 + lon;   %[deg]

%Compute local hour angle: 
tau = theta - RA;   %[deg] degrees from south

tau_sun = modLon(-(theta0-RA));  %-- longitude of sun --

%---- now use longitude and latitude ----
%Compute altitude h, azimuth az:
beta = lat;
h = asin(sin(k*beta).*sin(k*delta) + cos(k*beta).*cos(k*delta).*cos(k*tau))/k;
az = atan2(-sin(k*tau),(cos(k*beta).*tan(k*delta) - sin(k*beta).*cos(k*tau)))/k;

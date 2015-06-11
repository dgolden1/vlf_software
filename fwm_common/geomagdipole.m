function [b,dip,decl]=geomagdipole(lat,lon,alt,doeccentric)
%GEOMAGB Dipole model geomagnetic field
% Calculate geomagnetic field components for a dipole model to accuracy
% of 25%. This is very approximate. Use IGRF for more accuracy.
% Usage:
%  [b,dip,decl]=geomagb(lat,lon,alt,doeccentric)
%  All angles are in radians
% Inputs:
%  lat, lon -- north latitude and east longitude, in radians
%  alt -- altitude in km
%  doeccentric -- flag to use eccentric dipole model, accuracy ~10%.
% Outputs:
%  b -- magnitude
%  dip -- dip angle, also called inclination -- the angle below horizon
%  decl -- declination -- angle clockwise (to the east) from the north pole
% See "Handbook of Geophysics and the Space Environment",
% page 4-2 for definitions. Dip angle is also called inclination.
% Is more accurate than GOEMAGECCDIPOLE at polar regions, but less accurate
% at equatorial regions (from comparison to IGRF)

if nargin<4
    doeccentric=0;
end

Re=6371.2; % mean earth radius from IGRF
% The north geomagnetic pole coordinates (78.5N, 291.0E)
th0=pi/2-78.5*pi/180;
ph0=291.0*pi/180-2*pi;

% Earth dipole moment is M=7.9e15 T*m^3 ("Handbook", page 4-25)
bn=7.9e6/(Re+alt)^3; % =M/r^3

%cp=cos(ph0)
%sp=sin(ph0)
ct=cos(th0);
st=sin(th0);
slo=sin(lon-ph0);
clo=cos(lon-ph0);
sl=sin(lat);
cl=cos(lat);

% Matrix for conversion of a vector in geomagnetic coordinates to
% geographic
% rotm=[[cp*ct,-sp,cp*st],[sp*ct,cp,sp*st],[-st,0,ct]]

% Geomagnetic latitude
sgl=st*cl*clo+ct*sl; % sin(glat)
cgl=sqrt(1-sgl^2); % cos(glat)
% Magnetic field in geomagnetic coordinates
b=bn*sqrt(3*sgl^2+1);
dip=atan2(2*sgl,cgl);
% the declination
decl=atan2(-st*slo,ct*cl-st*sl*clo);

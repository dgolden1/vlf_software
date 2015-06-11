function [x,y,z]=rotate_sph2xy(th0,ph0,theta,phi,R0)
%ROTATE_SPH2XY Convert from spherical coordinates to x,y on flat Earth
% Usage:
%    [x,y]=rotate_ecf2xy(th0,ph0,theta,phi,R0)
% Inputs:
%    th0, ph0 - spherical coordinates of the center point for x,y
%    theta, phi - sperical coordinates of the needed point(s)
%    R0=(h+REarth)*1e3 - height in m
% Outputs:
%    x - West-East coordinate
%    y - South-North coordinate

xs=R0*sin(theta).*cos(phi);
ys=R0*sin(theta).*sin(phi);
zs=R0*cos(theta);
% Rotate to z axis
% 1. Rotate to zero longitude
z1=zs;
x1=xs*cos(ph0)+ys*sin(ph0);
y1=-xs*sin(ph0)+ys*cos(ph0);
% 2. Rotate to zero theta
% Note that after this rotation, we have to rotate 90 deg CCW
x=y1;
y=z1*sin(th0)-x1*cos(th0);
% Project by discarding the value of z
if nargout>2
    z=z1*cos(th0)+x1*sin(th0);
end

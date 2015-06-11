function [theta,phi,xs,ys,zs]=rotate_xy2sph(th0,ph0,x,y,R0)
%ROTATE_XY2SPH Convert from x,y on flat Earth to spherical coordinates
% Usage:
%    [theta,phi]=rotate_ecf2xy(th0,ph0,x,y,R0)
% Inputs:
%    th0, ph0 - spherical coordinates of the center point for x,y
%    x - West-East coordinate
%    y - South-North coordinate
%    R0=(h+REarth)*1e3 - height in m
% Outputs:
%    theta, phi - sperical coordinates of the needed point(s)
% See also: ROTATE_SPH2XY

% Projection on the spherical Earth
z=sqrt(R0^2-(x.^2+y.^2));
% 1. Rotate to the proper latitude
x1=z*sin(th0)-y*cos(th0);
y1=x;
z1=z*cos(th0)+y*sin(th0);
% 2. Rotate to the proper longitude
zs=z1;
xs=x1*cos(ph0)-y1*sin(ph0);
ys=x1*sin(ph0)+y1*cos(ph0);
% Calculate the spherical coordinates
%r=sqrt(xs.^2+ys.^2+zs.^2); % must be constant=R0
theta=acos(zs/R0);
phi=atan2(ys,xs);

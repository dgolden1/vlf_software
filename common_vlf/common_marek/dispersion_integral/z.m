function [z_val] =z(phi)
global L;%L=4.9; %L-shell
global phi1; %Latitude at 1000km altitude in radians
ro=6380e3; %radius of the Earth
r=ro*L*cos(phi).^2; %coordinate radius
M=5.974e24; %mass of the Earth in kg
G=6.672e-11; %Graviational constant
r1=ro+1000e3;%radius at 100km altitude
g1=G*M/r1^2; %accelaration of gravity at 1000 km altitude
Omega=7.272e-5; %rotational speed of Earth
z_val=r1-r1.^2./r-Omega.^2./(2*g1).*(r.^2.*cos(phi).^2-r1.^2.*cos(phi1).^2);

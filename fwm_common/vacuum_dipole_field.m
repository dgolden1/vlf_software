function EH=vacuum_dipole_field(k0,x,y,z)
%VACUUM_DIPOLE_FIELD Field of a verical dipole in vacuum
% Usage:
%    EH=impedance0*Iz0*vacuum_dipole_field(k0,x,y,z);
% Inputs:
%    Iz0 (scalar) - dipole moment in z-direction at the origin, in A*m
%    k0 (scalar) ==w/c
%    x (Nx), y (Ny), z(Nz) - coordinates in m
% Output:
%    EH (6,Nx,Ny,Nz) - field in V/m
Nx=length(x); Ny=length(y); Nz=length(z);
EH=zeros(6,Nx,Ny,Nz);
[xm,ym,zm]=ndgrid(x,y,z);
rm=sqrt(xm.^2+ym.^2+zm.^2);
e=exp(i*k0*rm);
ikr=i*k0*rm;
tmp=(ikr-1).*(ikr-3)./ikr+1;
EH(1,:,:,:)=-1/(4*pi).*e.*zm.*xm./rm.^4.*tmp;
EH(2,:,:,:)=-1/(4*pi).*e.*zm.*ym./rm.^4.*tmp;
EH(3,:,:,:)=-1/(4*pi).*e./rm.^2.*(-ikr+(ikr-1)./ikr+zm.^2./rm.^2.*tmp);
EH(4,:,:,:)= 1/(4*pi).*e.*ym./rm.^3.*(ikr-1);
EH(5,:,:,:)=-1/(4*pi).*e.*xm./rm.^3.*(ikr-1);

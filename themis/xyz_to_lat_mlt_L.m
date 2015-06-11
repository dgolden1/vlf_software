function [lat, MLT, L, R] = xyz_to_lat_mlt_L(xyz_sm)
% Convert SM XYZ coordinates to dipole latitude, MLT and L shell
% 
% [lat, MLT, L, R] = xyz_to_lat_mlt_L(xyz_sm)
% 
% INPUTS
% xyz: Nx3 vector of SM x, y and z coordinates, in Re
% 
% OUTPUTS
% lat: dipole latitude (degrees)
% MLT: magnetic local time (hours)
% L: dipole L-shell (Re)
% R: radial distance (Re)

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

R = sqrt(sum(xyz_sm.^2, 2));
L = R./(1 - (xyz_sm(:,3)./R).^2);
lat = atan(xyz_sm(:,3)./sum(sqrt(xyz_sm(:,1:2).^2), 2))*180/pi;
MLT = mod(atan2(xyz_sm(:,2), xyz_sm(:,1))*24/(2*pi) + 12, 24);

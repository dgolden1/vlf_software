function [ds_dphi_val]=ds_dphi(phi)
global L; %L-shell
ro=6380e3; %radius of the Earth
ds_dphi_val=ro*L*cos(phi).*sqrt(1+3.*sin(phi).^2);

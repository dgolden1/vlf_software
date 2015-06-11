function [palmer_mlt, palmer_mlat] = palmer_const(str_deg_or_rad)
% [palmer_mlt, palmer_mlat] = palmer_const(str_deg_or_rad)
% 
% Return IGRF constants for Palmer
% 
% palmer_mlt is in units of fractions of a day
% palmer_mlat is measured from the equator (not from the +z axis)
% 
% if str_deg_or_rad is 'rad' (default), palmer_mlat is in units of radians;
% otherwise it is in units of degrees

% By Daniel Golden (dgolden1 at stanford dot edu) March 2010
% $Id$

if ~exist('str_deg_or_rad', 'var') || isempty(str_deg_or_rad)
	str_deg_or_rad = 'rad';
end

palmer_mlt = -(4+1/60)/24;

if strcmp(str_deg_or_rad, 'rad')
	palmer_mlat = -49.85*pi/180;
elseif strcmp(str_deg_or_rad, 'deg')
	palmer_mlat = -49.85;
end

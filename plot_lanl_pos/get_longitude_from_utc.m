function az_0 = get_longitude_from_utc(utc)
% Returns counter-clockwise plot-azimuth of the 0-meridian when looking at
% the Earth from the South pole (e.g., if az_0 = 90, then the zero meridian
% will be point to the right)
% 
% INPUTS
% utc: matlab datenum representing the UTC time

% By Daniel Golden (dgolden1 at stanford dot edu) Oct 16, 2007
% $Id$

az_0 = (utc - floor(utc))*360 + 180;

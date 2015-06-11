function rotate_earth(az_0, ax, day_surf, night_surf)
% Rotates the Earth while maintaining the position of the terminator
% 
% INPUTS
% az_0: plot-azimuth of the 0-meridian when looking from the South pole
% ax: handle to figure axis
% day_surf: handle to surf plot for the day side
% night_surf: handle to surf plot for the night side

% By Daniel Golden (dgolden1 at stanford dot edu) Oct 17, 2007
% $Id$

error(nargchk(3, 3, nargin));

view = get(ax, 'View');

error('I abandoned this function... rotating stuff is too hard. Just regenerate the map.');

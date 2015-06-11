function [x, y] = get_fits_line(longitude, img_time, max_L)
% line_pts = draw_fits_line(azim, max_L)
% Get points to draw a line on an IMAGE EUV FITS image
% Longitude in radians, img_time in decimal days (i.e., between 0 and 1)
% Assumes midnight is left and noon is right

% By Daniel Golden (dgolden1 at stanford dot edu) April 2008
% $Id $


theta = mod(longitude + img_time*2*pi + pi, 2*pi); % Get angle between -180 and 180, measured CCW from +x axis
theta(theta > pi) = theta(theta > pi) - 2*pi;

x = [0 0];
y = [0 0];
if abs(theta) > pi/4 && abs(theta) < 3*pi/4 % The line touches the top or bottom of the image
	if theta > 0, y(2) = max_L; else y(2) = -max_L; end
	x(2) = abs(max_L*sin(pi/2 - theta)/sin(theta)); % Law of sines
	if abs(theta) > pi/2, x(2) = -x(2); end
else % The line touches the left or right of the image
	if abs(theta) <= pi/2, x(2) = max_L; else x(2) = -max_L; end
	y(2) = abs(max_L*sin(theta)/sin(pi/2 - theta)); % Law of sines
	if theta < 0, y(2) = -y(2); end
end

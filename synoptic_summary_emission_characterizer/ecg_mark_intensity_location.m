function circle_handle = ecg_mark_intensity_location(x, y, radius, h_ax, color)
% Draw a little circle at the location where the intensity was measured

% By Daniel Golden (dgolden1 at stanford dot edu) December 2007
% $Id$

if ~exist('color', 'var')
	mygreen = [0.75, 1, 0.75];
	color = mygreen;
end


circle_handle = rectangle('Position', [x, y, radius, radius], ...
	'EdgeColor', color, 'Curvature', [1, 1], 'LineWidth', 2);

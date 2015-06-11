function ecg_set_spec_globals(img)
% ecg_set_spec_globals(img)
% Function to set the global variables for the spectrogram
% img is an image variable, like the one returned from imread(filename)

% By Daniel Golden (dgolden1 at stanford dot edu) January 2008
% $Id$

% Values representing the edges of the spectrogram
% x = 1 represents the LEFT of the image
% y = 1 represents the TOP of the image
global spec_x_min spec_x_max spec_y_min spec_y_max

% Figure out what kind of spectrogram this is
if ~exist('img', 'var') || (size(img, 1) == 510 && size(img, 2) == 894)
	% This is the old-style 2-row spectrogram
	spec_x_min = 65;
	spec_x_max = 827;
	spec_y_min = 266;
	spec_y_max = 462;
	
% This is the new-style spectrogram
% In the new spectrogram style, sometimes slightly different image sizes
% are produced on different machines, which is annoying. We'll put some
% tolerance into accepted image sizes
elseif size(img, 1) >= 380 && size(img, 1) <= 390 && ...
		size(img, 2) >= 1019 && size(img, 2) <= 1110
	% Additionally, sometimes, Matlab, in its infinite wisdom, shift the
	% bloody image around even within a known image size. So we'll do some
	% detective work to figure out where the actual spectrogram is in the
	% image.
	
	% Find left and right borders by looking for vertical black lines
	% The first two lines are the spectrogram borders; the second two are
	% the colorbar borders
	lr_borders = find(all(squeeze(sum(permute(img(50:280, :, :), [3 1 2]))) == 0));
	
	% If the left border is more than one pixel thick, pare it down to the
	% highest pixel value (highest spatial pixel)
	while lr_borders(2) == lr_borders(1) + 1, lr_borders(1) = []; end
	
	% Find upper and lower borders the same way
	% The first two lines are the spectrogram borders; the others are
	% the result of some borders being two pixels thick, and the MLT axis
	% border
	ud_borders = find(all(squeeze(sum(permute(img(:, 100:850, :), [3 2 1]))) == 0));
	
	% If the upper border is more than one pixel thick, pare it down to the
	% highest pixel value (lowest spatial pixel)
	while ud_borders(2) == ud_borders(1) + 1, ud_borders(1) = []; end
	
	% x, y max, min is where the spectrogram starts - just inside the
	% borders
	spec_x_min = lr_borders(1) + 1;
	spec_x_max = lr_borders(2) - 1;
	spec_y_min = ud_borders(1) + 1;
	spec_y_max = ud_borders(2) - 1;
	
% 	% Mark the spectrogram so the user knows we found it correctly
% 	plot([spec_x_min, spec_x_min, spec_x_max, spec_x_max], [spec_y_min, spec_y_max, spec_y_min, spec_y_max], 'r.')

else
	error('Weird image size (%dx%d)', size(img, 1), size(img, 2));
end

global spec_db_low spec_db_high bCal
if isempty(bCal) || ~bCal
	spec_db_low = 35;
	spec_db_high = 80;
else
	spec_db_low = -20;
	spec_db_high = 25;
end	

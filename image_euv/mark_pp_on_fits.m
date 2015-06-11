function mark_pp_on_fits(palmer_pp_db_filename_or_struct, img_datenum, h_axis)
% mark_pp_on_fits(palmer_pp_db_filename_or_struct, img_datenum, h_axis)
% 
% palmer_pp_db_filename_or_struct may be either the pp_db filename, or the database
% palmer_pp_db itself

% By Daniel Golden (dgolden1 at stanford dot edu) January 2009
% $Id$

%% Setup
% PALMER_LONGITUDE = -64.05; % Palmer station longitude in degrees
PALMER_MLT = -4; % Palmer MLT offset from UT, in hours

PALMER_L_SHELL = 2.44;
theta = (0:360)*pi/180;

img_time = img_datenum - floor(img_datenum);

l_max = 6; % If something to be plotted is beyond this L-shell, plot it at this L-shell

%% Plot PP location
if isstruct(palmer_pp_db_filename_or_struct)
	palmer_pp_db = palmer_pp_db_filename_or_struct;
else
	load(palmer_pp_db_filename_or_struct, 'palmer_pp_db');
end

db_i = find([palmer_pp_db.img_datenum] == img_datenum);
assert(length(db_i) <= 1)

if ~isempty(db_i)
	old_ax = gca;
	if exist('h_axis', 'var')
		img_ax = h_axis;
	else
		img_ax = findall(0, 'tag', 'img_ax');
		assert(length(img_ax) == 1);
	end
	saxes(img_ax);
	
	% Remove old location
	delete(findobj(img_ax, 'tag', 'fits_pp_loc'));

	thisL = palmer_pp_db(db_i).pp_L;
	if isfinite(thisL)
		theta = PALMER_MLT*2*pi/24+ img_time*2*pi + pi;
		x = thisL*cos(theta);
		y = thisL*sin(theta);
		markerfacecolor = [0.9 0.3 0.7]; % Pink/purple
		h_pp_loc = plot(x, y, 'o', 'MarkerSize', 8, 'markerfacecolor', markerfacecolor, 'markeredgecolor', 'k');
		
		% Also plot second plasmapause location, if it's greater than the
		% first
		thisL2 = palmer_pp_db(db_i).pp_L2;
		
		if thisL2 ~= thisL
			% If the l value is outside the image edge, plot it at the edge
			l_plot = min([thisL2 abs(l_max/sin(theta)) abs(l_max/cos(theta))]);
			x = l_plot*cos(theta);
			y = l_plot*sin(theta);
			markerfacecolor = [1 0.6 0]; % Orange
			h_pp_loc(2) = plot(x, y, 'o', 'MarkerSize', 8, 'markerfacecolor', markerfacecolor, 'markeredgecolor', 'k');
		end
	elseif isnan(thisL)
		h_pp_loc = plot(0, 0, 'd', 'Color', 'r', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
	elseif isinf(thisL)
		h_pp_loc = plot(0, 0, 'o', 'Color', [0.2 0.7 0.6], 'MarkerFaceColor', [0.2 0.7 0.6], 'MarkerSize', 8);
	end
	
	set(h_pp_loc, 'tag', 'fits_pp_loc');

	saxes(old_ax);
end


function marker_handle = ecg_add_single_emission_marker(event, h_ax, bIncludeCaption, color, time_style, marker_handles)
% marker_handle = ecg_add_single_emission_marker(event, h_ax, bIncludeCaption, color, time_style, marker_handles)
% Function to add a single emission marker
% 
% time_style describes the x-axis timing convention of the plot, and should be one of:
% 'bitmap' -- for spectrogram images
% 'sec' -- for time in seconds since an epoch
% 'truetime' -- for accurate datenum-style time

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

%% Setup
if ~exist('color', 'var') || isempty(color), color = 'r'; end
if ~exist('time_style', 'var') || isempty(time_style), time_style = 'bitmap'; end


%%
f_low = event.f_lc;
f_high = event.f_uc;
if bIncludeCaption
	caption = sprintf('(%s, b = %0.1f)', event.emission_type, event.burstiness);
	if ~isempty(event.notes)
		caption = sprintf('%s: %s', caption, event.notes);
	end
else
	caption = '';
end

switch time_style
case 'true_time'
	x_low = event.start_datenum;
	x_high = event.end_datenum;
	
	y_low = f_low;
	y_high = f_high;
	
	jitter_dir = +1;
case 'sec'
	xl = xlim;
	x_low = xl(1);
	x_high = xl(2);

	y_low = f_low;
	y_high = f_high;

	jitter_dir = +1;
case 'bitmap'
	start_hour = (event.start_datenum - floor(event.start_datenum))*24;
	end_hour = (event.end_datenum - floor(event.end_datenum))*24;
	if end_hour < start_hour, end_hour = 24; end

	[x_low, y_high] = ecg_param_to_pix(start_hour, f_low); % Lower left corner
	[x_high, y_low] = ecg_param_to_pix(end_hour, f_high, 'end'); % Upper right corner
	
	jitter_dir = -1;
end

% Add a rectangle
width = x_high - x_low;
height = y_high - y_low;
saxes(h_ax);
r = rectangle('Position', [x_low, y_low, width, height], ...
	'EdgeColor', color, 'LineWidth', 2, 'Curvature', 0.2);
marker_handle.r = r;

% Add caption.
if time_style
	t = text(x_low, y_high, caption, 'Color', 'r', 'BackgroundColor', 'w', 'EdgeColor', 'k');
else
	t = text(x_low, y_low - 8, caption, 'Color', 'r', 'BackgroundColor', 'w', 'EdgeColor', 'k');
end

% Make sure we don't overlap with previous markers if there are any
b_jittered = false;
for kk = 1:length(marker_handles)
	this_extent = get(t, 'extent');
	prev_extent = get(marker_handles(kk).t, 'extent');
	if prev_extent(1) + prev_extent(3) > this_extent(1) && prev_extent(1) < this_extent(1) + this_extent(3) && ...
			prev_extent(2) + prev_extent(4) > this_extent(2) && prev_extent(2) < this_extent(2) + this_extent(4)
		b_jittered = true;
		if time_style
			new_y_pos = (prev_extent(2) + prev_extent(4)*1.25);
		else
			new_y_pos = prev_extent(2) - 1.25*prev_extent(4);
		end
		this_pos = get(t, 'Position');
		set(t, 'Position', [this_pos(1), new_y_pos, this_pos(3)]);
	end
end

marker_handle.t = t;

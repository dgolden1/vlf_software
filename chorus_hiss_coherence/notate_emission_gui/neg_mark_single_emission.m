function marker_handle = neg_mark_single_emission(event, h_ax, color, linewidth, emission_no)
% marker_handle = neg_mark_single_emission(event, h_ax, color, linewidth, emission_no)
% Function to add a single emission marker

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

%% Setup
if ~exist('color', 'var') || isempty(color), color = 'r'; end
if ~exist('linewidth', 'var') || isempty(linewidth), linewidth = 2; end


%% Initialize box parameters
start_sec = event.t_start;
end_sec = event.t_end;
f_low = event.f_lc;
f_high = event.f_uc;

caption = neg_write_emission_caption(event, emission_no, 'short');

%% Draw box
% Add a rectangle
width = end_sec - start_sec;
height = f_high - f_low;
saxes(h_ax);
r = rectangle('Position', [start_sec, f_low, width, height], ...
	'EdgeColor', color, 'LineWidth', linewidth, 'Curvature', 0.0);
marker_handle.r = r;

% Add caption
t = text(start_sec + (end_sec - start_sec)/2, f_high + 0.2, caption, 'Color', 'k', ...
	'BackgroundColor', 'w', 'EdgeColor', 'k', 'HorizontalAlignment', 'center', ...
	'VerticalAlignment', 'bottom');
marker_handle.t = t;

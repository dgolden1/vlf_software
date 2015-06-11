function marker_handle = whTarcsaiMarkSferic(s, time, color)
% whTarcsaiMarkSferic(s, time)
% Marks the sferic on a spectrogram with either a little arrow or a
% vertical line, whichever I haven't commented-out at the moment
% 
% INPUTS
% s: handle to the axes on which the spectrogram is plotted
% time: time, with respect to the START OF THE DATA FILE (i.e., in seconds,
% in the same manner as is plotted on the figure's x-axis) of the sferic
% color: a string describing the line color in the same way that the plot
% function expects it; e.g., 'k' is black, 'w' is white, etc.
% 
% OUTPUTS:
% marker_handle: handle to the marker on the figure (either the line or the
% arrow)

% By Daniel Golden (dgolden1 at stanford dot edu) September 2007
% $Id:whTarcsaiMarkSferic.m 522 2007-09-24 21:29:08Z dgolden $

%% Setup
bUseVerticalLine = true;
axes(s);

%% The vertical line
if bUseVerticalLine
	t = [time time];
	freq = ylim;
	marker_handle = plot(s, t, freq, '--', 'linewidth', 3, 'Color', color, ...
		'Marker', 'diamond', 'MarkerSize', 9, 'MarkerFaceColor', color);
else
	% Get the time in normalized figure units
	xl = xlim;
	pos = get(gca, 'Position');
	left = pos(1);
	bottom = pos(2);
	width = pos(3);
	height = pos(4);
	
	x = ((time - xl(1))/(xl(2) - xl(1)))*width + left;
	
	yt(1) = bottom + height + 0.05;
	yt(2) = yt(1) - 0.05;
	yl(1) = bottom - 0.05;
	yl(2) = yl(1) + 0.05;
	
	marker_handle(1) = annotation('arrow', [x x], yt, 'Color', color);
	marker_handle(2) = annotation('arrow', [x x], yl, 'Color', color);
end

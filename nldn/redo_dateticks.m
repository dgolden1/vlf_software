function redo_dateticks
% redo_dateticks
% Helper function for plotting in nldn_hiss_correlation()

% By Daniel Golden (dgolden1 at stanford dot edu) July 2009
% $Id$

h = findobj('Tag','corr_ax');
for kk = 1:length(h)
	datetick(h(kk), 'x', 'keeplimits');
end

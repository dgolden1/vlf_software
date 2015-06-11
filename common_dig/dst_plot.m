function dst_plot(start_date, end_date, dst_filename, ax)
% dst_plot(start_date, end_date, dst_filename)
% Function to plot DST from a given DST file
% 
% Acquire data from here: http://swdcwww.kugi.kyoto-u.ac.jp/dstae/index.html
% Data format: http://swdcwww.kugi.kyoto-u.ac.jp/dstae/format/dstformat.html

% By Daniel Golden (dgolden1 at stanford dot edu) Feb 2008
% $Id$

%% Setup
error(nargchk(2, 4, nargin));

% Allow user to give date vectors as input
start_date = datenum(start_date);
end_date = datenum(end_date);

%% Plot it
if exist('dst_filename', 'var') && ~isempty(dst_filename)
	[dst_date, dst] = dst_read_datenum(start_date, end_date, dst_filename);
else
  load('dst', 'dst_date', 'dst');
  idx = dst_date >= start_date & dst_date < end_date;
  dst_date = dst_date(idx);
  dst = dst(idx);
end

if exist('ax', 'var')
	saxes(ax);
else
	figure;
end

plot(dst_date, dst, 'LineWidth', 2);
grid on;
datetick2('x', 'keeplimits');
xlabel('Time (UT)');
ylabel('DST (nT)');
title(sprintf('DST from %s to %s', datestr(start_date), datestr(end_date)));

%% Axis wrangling
% Grow the figure
if ~exist('ax', 'var'),
	increase_font(gca);
	figure_grow(gcf, 1.5, 1);
end

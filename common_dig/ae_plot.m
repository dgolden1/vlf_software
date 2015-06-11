function ae_plot(start_date, end_date, year, ax)
% ae_plot(start_date, end_date, year, ax)
% Function to plot AE from a given AE file
% 
% start_date and end_date can be either Matlab date numbers or date vectors
% 
% Acquire data from here: http://swdcwww.kugi.kyoto-u.ac.jp/dstae/index.html
% Data format: http://swdcwww.kugi.kyoto-u.ac.jp/dstae/format/aehformat.html

% By Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id$

%% Setup
error(nargchk(1, 4, nargin));

if length(start_date) == 6
	start_date = datenum(start_date);
end
if length(end_date) == 6
	end_date = datenum(end_date);
end

[y m d hh mm ss] = datevec(start_date);
if ~exist('end_date', 'var') || isempty(end_date)
	end_date = start_date + 1;
end
if ~exist('year', 'var') || isempty(year)
	year = y;
end

%% Plot it
[ae_date, ae] = ae_read_datenum(year);

start_i = find(ae_date >= datenum(start_date), 1);
end_i = find(ae_date <= datenum(end_date), 1, 'last');

if exist('ax', 'var')
	axes(ax);
else
	figure;
end

% face_color = [0.2 0.8 0.2]; % Green
face_color = [1 0.3 0.3]; % Red

if end_date - start_date > 10
	LineWidth = 1;
else
	LineWidth = 2;
end
% plot(ae_date(start_i:end_i), ae(start_i:end_i), 'LineWidth', 2);
area(ae_date(start_i:end_i), ae(start_i:end_i), 'FaceColor', face_color, 'EdgeColor', 'k', 'LineWidth', LineWidth);
grid on;
datetick2('x', 'keeplimits');
xlabel('Time (UTC)');
ylabel('AE (nT)');
title(sprintf('AE from %s to %s', datestr(start_date), datestr(end_date)));

%% Axis wrangling
% Grow the figure
if ~exist('ax', 'var'),
	increase_font(gca);
	figure_grow(gcf, 1.5, 1);
end

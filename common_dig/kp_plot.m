function kp_plot(start_date, end_date, year, ax)
% kp_plot(start_date, end_date, year, ax)
% Function to plot kp from a given kp file
% 
% Aquire data (plain text) from here: http://swdcwww.kugi.kyoto-u.ac.jp/kp/index.html
% Data format: http://swdcwww.kugi.kyoto-u.ac.jp/kp/format.html

% By Daniel Golden (dgolden1 at stanford dot edu) May 2008
% $Id$

%% Setup
error(nargchk(1, 4, nargin));

[y m d hh mm ss] = datevec(start_date);
if ~exist('end_date', 'var') || isempty(end_date)
	end_date = start_date + 1;
end
if ~exist('year', 'var') || isempty(year)
	year = y;
end

%% Get kp data
[kp_date, kp] = kp_read_datenum(year);

start_i = find(kp_date >= datenum(start_date), 1);
end_i = find(kp_date <= datenum(end_date), 1, 'last');

if isempty(start_i) || isempty(end_i)
	error('No kp entries between %s and %s', datestr(start_date), datestr(end_date));
end

%% Plot it
if exist('ax', 'var')
	axes(ax);
else
	figure;
end
bar(kp_date(start_i:end_i), kp(start_i:end_i), 'LineWidth', 2);
grid on;
datetick2('x', 'keeplimits');
xlabel('Time (UTC)');
ylabel('Kp');
title(sprintf('Kp from %s to %s', datestr(start_date), datestr(end_date)));

%% Axis wrangling
% Squish the figure
if ~exist('ax', 'var'),
	increase_font(gca);
% 	figure_squish(gcf, 1, 2);
end

% Make the x-axis tight
xlim([kp_date(start_i) kp_date(end_i)]);

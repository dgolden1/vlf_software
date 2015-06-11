function h = plot_emission(start_times, end_times, thickness, color, em_type, c_min, c_max, c_label)
% h = plot_emission(start_times, end_times, thickness, color, em_type, c_min, c_max, c_label)
% Function to plot emissions by full extent time and intensity

% By Daniel Golden (dgolden1 at stanford dot edu) December 2007
% $Id$

%% Setup
% PALMER_LONGITUDE = -64.05;
% PALMER_T_OFFSET = PALMER_LONGITUDE/360;
PALMER_T_OFFSET = -(4+1/60)/24;

% start_times = start_times + PALMER_LONGITUDE/360;
% end_times = end_times + PALMER_LONGITUDE/360;


if ~exist('c_min', 'var') || isempty(c_min), c_min = min(color); end
if ~exist('c_max', 'var') || isempty(c_max), c_max = min(color); end
color(color < c_min) = c_min;
color(color > c_max) = c_max;


%% Plot stuff
% plot_option = 'scatter_start';
% plot_option = 'scatter_end';
plot_option = 'scatter_lines';

days = floor(start_times);

figure(gcf);
switch plot_option
	case 'scatter_start'
		h = scatter(start_times, days, thickness, color, 'filled');
	case 'scatter_end'
		h = scatter(end_times, days, thickness, color, 'filled');
	case 'scatter_lines'
		hold on;
		for kk = 1:length(start_times)
			y = [days(kk) days(kk)];
			x = [start_times(kk) end_times(kk)] - days(kk);
			plot(x, y, 'Color', assign_color(c_min, c_max, color(kk)), 'LineWidth', 3);
		end
		
		c = colorbar;
		caxis([c_min c_max]);
		set(get(c, 'Ylabel'), 'String', c_label);
		
		h = gca;
		set(h, 'ydir', 'reverse');
	otherwise
		error('Unknown plot_option ''%s'', plot_option');
end

grid on;
[year1 m1] = datevec(min(start_times));
[year2 m2] = datevec(max(start_times));
assert(year1 == year2);
title(sprintf('VLF emission events (%s) %d',  strrep(em_type, '_', '\_'), year1));

xticks = 0:2/24:1;
yticks = zeros(1, 12);
for kk = 1:length(yticks)
	yticks(kk) = datenum([year1 kk 01 0 0 0]);
end
datetick('x', 'HH:MM', 'keeplimits');
ylim([datenum([year1 01 01 0 0 0]) datenum([year1 11 01 0 0 0])]);
set(h, 'YTick', yticks)
datetick('y', 'mmm', 'keepticks');
xlabel('Palmer LT');
ylabel('Month');

increase_font(gca);

function dst_3day_plot(day_datenum)
% Plot a 3-day DST plot centered around day_datenum

% By Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id$

figure;
h_dst_ax = axes;
y_min = -100;
y_max = 20;
ylim([y_min y_max]);

% Shade the before and after days
hold on;
fill([day_datenum-1 day_datenum day_datenum day_datenum-1], [y_min y_min y_max y_max], 0.9*[1 1 1], 'EdgeColor', 'none');
fill([day_datenum+1 day_datenum+2 day_datenum+2 day_datenum+1], [y_min y_min y_max y_max], 0.9*[1 1 1], 'EdgeColor', 'none');

dst_plot(day_datenum-1, day_datenum+2, [], h_dst_ax);
datetick('x', 6, 'KeepLimits');

figure_squish(gcf, 1, 2.3);

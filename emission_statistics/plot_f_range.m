function plot_f_range(events, em_type)
% Plot event frequency span vs time

%% Setup
error(nargchk(2, 2, nargin));

%% Extract data from events
f_lc = [events.f_lc];
f_uc = [events.f_uc];
times = [events.start_datenum] + ([events.end_datenum] - [events.start_datenum])/2;
times = fpart(times); % Convert from day and hour to hour
intensity = [events.intensity];

%% Plot events
c_min = min(intensity);
c_max = max(intensity);


figure(gcf);
color_map = 'jet';
hold on;
for kk = 1:length(times)
	y = [f_lc(kk) f_uc(kk)];
	x = [times(kk) times(kk)];
	plot(x, y, 'Color', assign_color(c_min, c_max, intensity(kk), color_map), 'LineWidth', 3);
end

grid on;

xticks = 0:2/24:1;
datetick('x', 'HH:MM', 'keeplimits');
xlabel('Hour');

ylabel('Frequency (kHz)');

c = colorbar;
colormap(color_map);
caxis([c_min c_max]);
set(get(c, 'YLabel'), 'String', 'Intensity');

title(sprintf('VLF emission events (%s, %d events) 2003', em_type, length(events)));

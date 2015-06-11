function make_24_plots
% Function to make terminator plots for several values of UTC
% By Daniel Golden (dgolden1 at stanford dot edu) Nov 1, 2007

year = 2008;
month = 11;
day = 01;
hour = 0:3:23;
minute = 0;
second = 0;

jpeg_output_path = '/home/dgolden/temp/24_plots/winter';

for kk = 1:length(hour)
	utc = datenum([year month day hour(kk) minute second]);
	az_0 = get_longitude_from_utc(utc);
	[map_ax, fig] = create_map(az_0);
	center_earth(map_ax);

	wd = pwd;
	cd('/home/dgolden/vlf/scripts/newMapTool');
	plotDayNight(datevec(utc), [-90 0], [0 360], 1e4, 0, map_ax);
	cd(wd);

	utc_str = datestr(utc, 'mmm dd, yyyy HH:MM');
	palmer_lt_str = datestr(utc_to_palmer_lt(utc), 'mmm dd, yyyy HH:MM');
	title(map_ax, sprintf('%s UTC\n(%s Palmer LT)', utc_str, palmer_lt_str), ...
		'FontSize', 14, 'FontWeight', 'bold');
	
	set(gcf, 'PaperPositionMode', 'auto'); % Print image same size as it appears on screen
	utc_file_str = datestr(utc, 'yyyy_mm_dd_HHMM');
	print('-dpng', fullfile(jpeg_output_path, sprintf('lanl_pos_%sutc', utc_file_str)));
	
	close;
end

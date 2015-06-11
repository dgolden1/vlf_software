function plot_lanl_data(lanl_filename, bSavePlot, jpeg_output_dir)
% Function to plot LANL satellite data
% Summary plots available here: http://leadbelly.lanl.gov/lanl_ep_data/cgi-bin/ep_plot_choose_3.cgi
% Request data here: http://leadbelly.lanl.gov/lanl_ep_data/request/ep_request.cgi

% By Daniel Golden (dgolden1 at stanford dot edu) Oct 30, 2007
% $Id$

%% Setup
error(nargchk(1, 3, nargin));

if ~exist('bSavePlot', 'var') || isempty(bSavePlot)
	bSavePlot = false;
end
if ~exist('jpeg_output_dir', 'var')
	jpeg_output_dir = [];
end

%% Parse the date and spacecraft name from the filename
[pathstr, name, ext, versn] = fileparts(lanl_filename);
assert(strcmp(ext, '.sopaflux'));

% Date
year = str2double(name(1:4));
month = str2double(name(5:6));
day = str2double(name(7:8));
start_datenum = datenum([year month day 0 0 0]);

% Spacecraft name
spacecraft_name = name(10:end);

%% Read the LANL data
[UT, glat, glon, radius, energies] = lanl_read(lanl_filename);
% lanl_read(lanl_filename);

%% Plot set up the plot command
levels_i = 1:9;
for kk = levels_i
	level_names{kk} = sprintf('%d-%d keV', energies.e_low(kk), energies.e_high(kk));
end

plotstr = 'semilogy(';
for kk = 1:(length(levels_i) - 1)
	plotstr = [plotstr sprintf('UT, energies.flux(:,%d), ', levels_i(kk))];
end
plotstr = [plotstr sprintf('UT, energies.flux(:,%d))', levels_i(end))];

time = start_datenum + UT/24;

%% Make the plot
figure;
eval(plotstr);
grid on;
xlabel('Time (UTC)');
ylabel('Electron Flux (#/cm^2/s/sr/keV');

% datetick('x', 15);
title(sprintf('Electron Flux on spacecraft %s on %s', spacecraft_name, ...
	datestr(start_datenum, 'mmmm dd, yyyy')));

set(gca, 'XTick', 0:2:24);
set(gca, 'YTick', 10.^[-2:6]);

legend(level_names)

increase_font(gca);

%% Save plot
if bSavePlot
	if isempty(jpeg_output_dir)
		jpeg_output_dir = uigetdir(pwd, 'Select directory to save files');
	end
	if ~ischar(jpeg_output_dir), return; end

	filename = fullfile(jpeg_output_dir, sprintf('eflux_%s', datestr(start_datenum, 'yyyy_mm_dd')));
	print('-djpeg', filename);
	disp(sprintf('Wrote %s', filename));
end

function create_palmer_hdd_summary_plots(cont_source_path, synop_temp_path)
% Function to create 24-hour summary plots for VLF data on hard drives

% By Daniel Golden (dgolden1 at stanford dot edu) October 2009
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'vlftool_24_hour_fcn'));

b_ftp_file = false;

if ~exist('cont_source_path', 'var')
    cont_source_path = uigetdir(pwd, 'Choose continuous directory');
    if ~ischar(cont_source_path)
        return;
    end
end
disp(sprintf('Continuous directory: %s', cont_source_path));
% cont_source_path = '/media/VLF Mar 09/VLF/Continuous';
% warning('cont_source_path = %s', cont_source_path);

if ~exist('synop_temp_path', 'var')
    synop_temp_path = uigetdir(pwd, 'Choose temporary directory');
    if ~ischar(cont_source_path)
        return;
    end
end
disp(sprintf('Temp directory: %s', synop_temp_path));
% synop_temp_path = '/home/dgolden/temp/summary_plots_temp';
% warning('synop_temp_path = %s', synop_temp_path);

destin_path = fullfile(cont_source_path, 'summary_plots');
% destin_path = '/home/dgolden/temp/summary_plots';
% warning('destin_path = %s', destin_path);

%% Find dates
d = dir(fullfile(cont_source_path, '*.mat'));

date_start = floor(get_bb_fname_datenum(fullfile(cont_source_path, d(1).name), true));
date_end = floor(get_bb_fname_datenum(fullfile(cont_source_path, d(end).name), true));
dates = date_start:date_end;

%% Make output directory
if ~exist(destin_path, 'dir')
	[status, message] = mkdir(destin_path);
	if status ~= 1
		error('Error creating directory %s: %s', destin_path, message);
	end
end

%% Create 24-hour spectrograms
for kk = 1:length(dates)
	[yy, mm, dd] = datevec(dates(kk));
	yyyy_mm_dd = [yy mm dd];
	vlf_24hrsynspec_from_24hrcont(yyyy_mm_dd, b_ftp_file, cont_source_path, synop_temp_path, destin_path);
end

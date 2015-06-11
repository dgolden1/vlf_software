function batch_nb_summary_plot
% Make 24-hour narrowband plots on scott
% $Id$

[~, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
	case 'quadcoredan.stanford.edu'
		output_dir = '~/temp/nb_summary_plots';
		narrowband_dir = '/media/scott/awesome/narrowband/palmer/2009/01_13';
		nb_summ_dir = '~/temp/nb_summary_plots';
	case 'scott.stanford.edu'
		output_dir = '/data/admin/data_upload';
%		output_dir = '/data/admin/data_upload_temp/nb_24';
		narrowband_dir = '/data/awesome/narrowband';
		nb_summ_dir = '/data/summary_plots/nb_24';
%		nb_summ_dir = '/data/user_data/dgolden/nb_summary_plots';
	otherwise
		error('Unknown host (%s)', hostname(1:end-1));
end

%% Parallel
PARALLEL = true;

if ~PARALLEL
	warning('Parallel mode disabled!');
end

poolsize = matlabpool('size');
if PARALLEL && poolsize == 0
	matlabpool('open');
end
if ~PARALLEL && poolsize ~= 0
	matlabpool('close');
end

%% Process
t_net_start = now;
disp(sprintf('spec_24 processing begun at %s', datestr(t_net_start, 31)));

% Find all mm_dd directories
t_start = now;
find_cmd = sprintf('find %s -regextype posix-extended -type d -regex ".*/\\w+/[0-9]{4}/[0-9]{2}_[0-9]{2}" | sort', narrowband_dir);
[~, dirlist_str] = unix(find_cmd);
dirlist = textscan(dirlist_str, '%s');
dirlist = dirlist{1};
disp(sprintf('Found %d mm_dd directories in %s in %s', length(dirlist), narrowband_dir, time_elapsed(t_start, now)));

% Get system offset from UTC
[~, utc_offset_str] = unix('date +%z'); utc_offset = str2double(utc_offset_str(2:3))/24 + str2double(utc_offset_str(4:5))/3600;
if utc_offset_str(1) == '-', utc_offset = -utc_offset; end

progress_temp_dirname = parfor_progress_init;
% warning('parfor disabled!');
% for kk = 1:length(dirlist)
parfor kk = 1:length(dirlist)
	fclose('all');
	close all;

	this_source_dir = dirlist{kk};
	ctime_datenum_latest = 0;
	d = [dir(fullfile(this_source_dir, '*.mat')); dir(fullfile(this_source_dir, '*.MAT'))];

	% For each input directory, find the file that was changed most recently
	[~, ctime_str] = unix(sprintf('stat --print "%%Z\n" `ls -1 %s`', fullfile(this_source_dir, '*')));
	ctime_scan = textscan(ctime_str, '%s');
	ctime_datenum = datenum([1970 01 01 0 0 0]) + str2double(ctime_scan{1})/86400 + utc_offset;
	ctime_datenum_latest = max(ctime_datenum);
	
	% Determine the output filename
	year_str = this_source_dir(end-9:end-6);
	month_str = this_source_dir(end-4:end-3);
	day_str = this_source_dir(end-1:end);
	[~, station_name] = fileparts(fileparts(fileparts(this_source_dir)));
% 	spec_24_filename = sprintf('%s_%s%s%s.png', station_name, year_str, month_str, day_str);
% 	this_spec_24_dir = fullfile(nb_summ_dir, station_name, year_str);
% 	spec_24_full_filename = fullfile(this_spec_24_dir, spec_24_filename);
	
	% Make a summary plot
% 	d = dir(spec_24_full_filename);
% 	if isempty(d) || d.datenum < ctime_datenum_latest
		t_start = now;
% 		disp(sprintf('Processing %s/%s/%s_%s...', station_name, year_str, month_str, day_str));
		
		% Process this subdirectory. Note that the nb_summ_dir is just used
		% for checking the existence of an old file; files are all output
		% to output_dir
		try
			this_nb_summ_dir = fullfile(nb_summ_dir, station_name, year_str);
			process_single_subdir(this_source_dir, output_dir, this_nb_summ_dir, ctime_datenum_latest);
			iteration_number = parfor_progress_step(progress_temp_dirname, kk);
		catch er
			warning('Error processing %s: %s. Skipping...', this_source_dir, er.message);
			iteration_number = parfor_progress_step(progress_temp_dirname, kk);
			continue;
		end
		
		disp(sprintf('Processed %s/%s/%s_%s (%d of %d) in %s', ...
			station_name, year_str, month_str, day_str, iteration_number, length(dirlist), time_elapsed(t_start, now)));
% 	else
% 		disp(sprintf('Skipping %s/%s/%s_%s; target spectrogram is newer than newest data file', ...
% 			station_name, year_str, month_str, day_str));
% 	end
end

parfor_progress_cleanup(progress_temp_dirname);
disp(sprintf('Processing completed in %s', time_elapsed(t_net_start, now)));

function process_single_subdir(source_dir, output_dir, nb_summ_dir, ctime_datenum_latest)

[~, sitename] = fileparts(fileparts(fileparts(source_dir)));

d = [dir(fullfile(source_dir, '*.mat')); dir(fullfile(source_dir, '*.MAT'))];

nb_start_datenum = cell(size(d));
xmit = cell(size(d));
station = cell(size(d));

b_valid_files = true(size(d));
for kk = 1:length(d)
	try
		[nb_start_datenum{kk}, ~, xmit{kk}, ~, ~] = get_nb_fname_datenum(fullfile(source_dir, d(kk).name));
	catch er
		b_valid_files(kk) = false;
	end
end
nb_start_datenum = nb_start_datenum(b_valid_files);
xmit = xmit(b_valid_files);
station = station(b_valid_files);

xmit_unique = unique(xmit);
xmit_unique(cellfun(@(x) ~isempty(x), strfind(xmit_unique, 'SPH'))) = []; % Delete sferic channel

for kk = 1:length(xmit_unique)
	output_filename = sprintf('%s_nbsummary_%s_%s', sitename, datestr(nb_start_datenum{1}, 'yyyymmdd'), xmit_unique{kk});
	output_full_filename = fullfile(output_dir, output_filename);
	
	% If the output file already exists in the summary directory, and
	% has a later date than the newest narrowband source file, the plot
	% is already up to date
	d_output = dir(fullfile(nb_summ_dir, [output_filename '.png']));
	if ~isempty(d_output) && d_output.datenum > ctime_datenum_latest
		continue;
	end
	
	try
		plotNB_Summary4scott(source_dir, xmit_unique{kk});
	catch er
		fprintf('Error plotting %s/*%s*: %s, skipping\n', source_dir, xmit_unique{kk}, er.message);
		continue;
	end
	
	figure_grow(gcf, 2, 2);
	print('-dpng', output_full_filename);
end

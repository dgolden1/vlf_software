function batch_spec_24(broadband_dir, output_dir)
% Make 24-hour plots as necessary on scott
% batch_spec_24(broadband_dir, output_dir)
%
% INPUTS
% broadband_dir: directory under which to search for data
% output_dir: directory into which to stuff the created summary spectrograms
% spec_24_dir (not an input): directory which should already contain summary spectrograms
%  which is checked so that spectrograms aren't created if they already exist

% By Daniel Golden (dgolden1 at stanford dot edu) December 2009
% $Id$


%% Hostname-specific directories
[~, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
  case 'quadcoredan.stanford.edu'
    default_output_dir = '~/temp/southpole_spec24';
    default_spec_24_dir = '~/temp/southpole_spec24';
    default_broadband_dir = '/media/scott/awesome/broadband/southpole/2001';
  case 'scott.stanford.edu'
    default_output_dir = '/data/admin/data_upload_temp/spec_24';
    default_spec_24_dir = '/data/summary_plots/spec_24';
    default_broadband_dir = '/data/awesome/broadband';
  otherwise
    if nargin < 2
      error('Unknown hostname: %s', hostname(1:end-1));
    end
end

if ~exist('broadband_dir', 'var') || isempty(broadband_dir)
  broadband_dir = default_broadband_dir;
end
if ~exist('output_dir', 'var') || isempty(output_dir)
  output_dir = default_output_dir;
  spec_24_dir = default_spec_24_dir;
else
  spec_24_dir = output_dir;
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
find_cmd = sprintf('find %s -regextype posix-extended -type d -regex ".*/\\w+/[0-9]{4}/[0-9]{2}_[0-9]{2}" | sort', broadband_dir);
[~, dirlist_str] = unix(find_cmd);
dirlist = textscan(dirlist_str, '%s');
dirlist = dirlist{1};
disp(sprintf('Found %d mm_dd directories in %s in %s', length(dirlist), broadband_dir, time_elapsed(t_start, now)));

% Get system offset from UTC
[~, utc_offset_str] = unix('date +%z'); utc_offset = str2double(utc_offset_str(2:3))/24 + str2double(utc_offset_str(4:5))/3600;
if utc_offset_str(1) == '-', utc_offset = -utc_offset; end

% Set up directory for checking parfor progress
unix(sprintf('rm -rf %s', fullfile(output_dir, 'progress')));
unix(sprintf('mkdir %s', fullfile(output_dir, 'progress')));

% warning('parfor disabled!');
% for kk = 1:length(dirlist)
parfor kk = 1:length(dirlist)
  fclose('all');

  % Use files to check parfor progress
  unix(sprintf('touch %s', fullfile(output_dir, 'progress', num2str(kk, '%06d'))));

  this_source_dir = dirlist{kk};
  ctime_datenum_latest = 0;
  d = [dir(fullfile(this_source_dir, '*.mat')); dir(fullfile(this_source_dir, '*.MAT'))];

  % For each directory, find the file that was changed most recently
  [~, ctime_str] = unix(sprintf('stat --print "%%Z\n" `ls -1 %s`', fullfile(this_source_dir, '*')));
  ctime_scan = textscan(ctime_str, '%s');
  ctime_datenum = datenum([1970 01 01 0 0 0]) + str2double(ctime_scan{1})/86400 + utc_offset;
  ctime_datenum_latest = max(ctime_datenum);
  
  % Determine the output spec_24 filename
  year_str = this_source_dir(end-9:end-6);
  month_str = this_source_dir(end-4:end-3);
  day_str = this_source_dir(end-1:end);
  day_datenum = datenum([str2double(year_str) str2double(month_str) str2double(day_str) 0 0 0]);
  [~, sitename] = fileparts(fileparts(fileparts(this_source_dir)));
  spec_24_filename = sprintf('%s_%s%s%s.png', sitename, year_str, month_str, day_str);
  this_spec_24_dir = fullfile(spec_24_dir, sitename, year_str);
  spec_24_full_filename = fullfile(this_spec_24_dir, spec_24_filename);
  
  % Determine desired channel
  switch sitename
    case 'southpole'
      channel_str = 'E/W';
    otherwise
      channel_str = 'N/S';
  end
  
  % Make a spectrogram if either the target spectrogram doesn't exist, or
  % the target spectrogram was created before the latest file change time
  d = dir(spec_24_full_filename);
  if isempty(d) || d.datenum < ctime_datenum_latest
    t_start = now;

    d_prog = dir(fullfile(output_dir, 'progress'));
    disp(sprintf('Processing %s/%s/%s_%s (%d of %d)', ...
      sitename, year_str, month_str, day_str, length(d_prog)-2, length(dirlist)));
    
    % Process this subdirectory. Note that the spec_24_dir is just used
    % for checking the existence of an old file; files are all output
    % to output_dir
    try
      batch_process_single_subdir(this_source_dir, output_dir, 'sitename', sitename, 'day_datenum', day_datenum, 'channel', channel_str);
    catch er
      warning('Error processing %s: %s. Skipping...', this_source_dir, er.message);
      continue;
    end
    
    disp(sprintf('Processed %s/%s/%s_%s (%d of %d) in %s', ...
      sitename, year_str, month_str, day_str, length(d_prog)-2, length(dirlist), time_elapsed(t_start, now)));
  else
    disp(sprintf('Skipping %s/%s/%s_%s; target spectrogram is newer than newest data file', ...
      sitename, year_str, month_str, day_str));
  end
end

% Remove directory for parfor progress
unix(sprintf('rm -rf %s', fullfile(output_dir, 'progress')));

fprintf('Processing completed in %s\n', time_elapsed(t_net_start, now));

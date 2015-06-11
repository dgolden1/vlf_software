function batch_clean_data(proc_type, input_dir, subdirs, output_dir, b_start_over)
% Function to clean a whole lot of data of sferics and hum
% batch_clean_data(proc_type, input_dir, subdirs, output_dir, b_start_over)
% Source is raw data
% Output is 10 seconds of one channel channel of 2-channel
% AWESOME data, cleaned for sferics and hum, downsampled to 20 kHz
% 
% INPUTS
% proc_type is one of:
%  'preprocess' -- only make 10-sec AWESOME broadband files and don't clean
%  them
%  'process_only' -- only process pre-made 10-sec uncleaned broadband files
%  'all' (default) -- do both
% 
% input_dir is a directory containing subdirectories (days) of data to
% process
% subdirs is a cell array of directories, relative to input_dir, to process.
% 
% If input_dir and subdirs are not given, this script instead examines the file
% batch_clean_data_subdirs.txt for the subdirectories to process, which is
% a \n-separated list of directories, e.g.,
% 10_10
% 10_11
% 10_12
% etc...
%
% output_dir is where the processed 10-second snippets will be dumped
% 
% b_start_over: if false (default) won't reprocess any existing output
% directories.  If true, will reprocess the entire year, deleting existing
% output directories.

% By Daniel Golden (dgolden1 at stanford dot edu) September 2009
% $Id$

%% Setup
if ~exist('proc_type', 'var') || isempty(proc_type)
  proc_type = 'all';
end
if ~exist('b_start_over', 'var') || isempty(b_start_over)
  b_start_over = false;
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

%% Set paths
default_input_dir = fullfile(scottdataroot, 'awesome', 'broadband', 'palmer');

[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
%   case 'vlf-alexandria'
  case 'quadcoredan.stanford.edu'
    default_output_dir = '/home/dgolden/temp/clean_temp';
  case 'scott.stanford.edu'
    default_output_dir = '/data/user_data/dgolden/palmer_bb_cleaned';
  case {'amundsen.stanford.edu', 'shackleton.stanford.edu'}
    default_output_dir = '/home/dgolden/temp/palmer_bb_cleaned';
  otherwise
    if ~isempty(regexp(hostname, 'corn[0-9][0-9].stanford.edu'))
      default_input_dir = '/tmp/dgolden1/output';
      default_output_dir = '/tmp/dgolden1/output';
      temp_dir = '/tmp/dgolden1/output';
      mkdir(temp_dir);
    elseif ~exist('input_dir', 'var') || ~exist('output_dir', 'var')
      error('Unknown hostname ''%s''', hostname(1:end-1));
    end
end

if ~exist('input_dir', 'var') || isempty(input_dir)
  input_dir = default_input_dir;
end
[~, year_str] = fileparts(input_dir);
year = str2double(year_str);
if isnan(year) || ~(year > 1950 && year < 3000)
  error('Input directory (%s) must be named by year', year_str);
end
station_name = just_filename(fileparts(input_dir));

if ~exist('output_dir', 'var') || isempty(output_dir)
  output_dir = default_output_dir;
end
output_dir = fullfile(output_dir, year_str);

%% Load list of subdirectories
if ~exist('subdirs', 'var') || isempty(subdirs)
  if exist('batch_clean_data_subdirs.txt', 'file')
    fid = fopen('batch_clean_data_subdirs.txt', 'r');
    subdirs = textscan(fid, '%s');
    subdirs = subdirs{1};
  else
    % Process all subdirectories
    subdir_struct = dir(input_dir);

    % Remove non-directories and directories that start with '.'
    subdir_struct(~[subdir_struct.isdir] | cellfun(@(x) x(1) == '.', {subdir_struct.name})) = [];
    subdirs = {subdir_struct.name};

    fprintf('Processing all (%d) subdirectories in %s\n', length(subdirs), input_dir);
  end
end

%% Remove output directory if we're starting over
if b_start_over && exist(output_dir, 'dir')
  rmdir(output_dir, 's');
end

%% Process
t_net_start = now;
for kk = 1:length(subdirs)
  t_dir_start = now;
  
  fprintf('Begun processing %s at %s\n', subdirs{kk}, datestr(now, 31));
  
  folder_datenum = datenum([year, str2double(subdirs{kk}(1:2)), str2double(subdirs{kk}(4:5)), 0, 0, 0]);
  [start_sec, channel, station_code, fs_dec] = get_station_params(station_name, folder_datenum);

  this_temp_dir = fullfile(output_dir, subdirs{kk}, 'temp');

  if (strcmp(proc_type, 'all') || strcmp(proc_type, 'preprocess')) && ...
      exist(fullfile(output_dir, subdirs{kk}), 'dir')
    fprintf('Output directory %s exists; skipping...\n', fullfile(output_dir, subdirs{kk}));
    continue;
  end
  
  clean_single_subdir(subdirs{kk}, input_dir, output_dir, this_temp_dir, proc_type, start_sec, channel, station_name, station_code, year, fs_dec);
  
  if strcmp(proc_type, 'all') || strcmp(proc_type, 'process_only')
    [status, message] = rmdir(this_temp_dir, 's');
    if status ~= 1
      error('Error deleting %s: %s', this_temp_dir, message);
    end
  end
  
  fprintf('Processed %s in %s\n', subdirs{kk}, time_elapsed(t_dir_start, now));
end

t_net_end = now;
fprintf('Finished processing in %s\n', time_elapsed(t_net_start, t_net_end));


function clean_single_subdir(subdir, input_dir, output_dir, temp_dir, proc_type, start_sec, channel, station_name, station_code, year, fs_dec)
%% Function: clean_single_subdir
% Process a single subdirectory

this_input_dir = fullfile(input_dir, subdir);
this_output_dir = fullfile(output_dir, subdir);

% Get date of this directory
assert(~isempty(regexp(subdir, '^[0-9]{2}_[0-9]{2}$'))); % Make sure input_dir is mm_dd
dir_date = datenum([year str2double(subdir(1:2)) str2double(subdir(4:5)) 0 0 0]);

%% Pare files
if strcmp(proc_type, 'all') || strcmp(proc_type, 'preprocess')
  t_conversion_start = now;
  
  remove_temporary_files(temp_dir);

  % Load and pare list of files
  [input_filenames, file_offsets] = get_synoptic_offsets('pathname', this_input_dir, ...
    'start_sec', start_sec, 'which_channel', channel, 'duration', 10);
  [input_filenames, b_is_interleaved] = determine_interleaved_2chan(input_filenames);

  % Convert to 10-sec AWESOME
  b_decimate = false; % Dan's sferic removal does the decimation
  emission_file_converter(temp_dir, '', input_filenames, file_offsets, ...
    'b_is_interleaved', b_is_interleaved, 'b_decimate', b_decimate, ...
    'start_sec', file_offsets, 'which_channel', channel, 'station_code', station_code);

  fprintf('Finished file conversion in %s\n', time_elapsed(t_conversion_start, now));
end

%% Clean files
if strcmp(proc_type, 'all') || strcmp(proc_type, 'process_only')
  clean_files(temp_dir, this_output_dir, station_name, dir_date, fs_dec, channel);

  fclose all; % I think I might leave a file open somewhere by accident
end

function remove_temporary_files(temp_dir, filenames)
%% Remove temporary files

if ~exist(temp_dir, 'dir') && ~isempty(temp_dir)
  mkdir(temp_dir)
else
  if ~exist('filenames', 'var') || isempty(filenames)
    % Delete all files from temporary directory
    delete(fullfile(temp_dir, '*.mat'));
    delete(fullfile(temp_dir, '*.MAT'));
    fprintf('Deleted temporary uncleaned .mat files from %s\n', temp_dir);
  else
    % Delete specific files from temp directory
    for kk = 1:length(filenames)
      delete(fullfile(temp_dir, filenames{kk}));
    end
  end
end

function [output_filenames, b_is_interleaved] = determine_interleaved_2chan(input_filenames)
%% Determine whether files are interleaved or 2-channel

bb_datenum = nan(size(input_filenames));
channel = nan(size(input_filenames));
for kk = 1:length(input_filenames)
  [bb_datenum(kk), ~, ~, channel(kk)] = get_bb_fname_datenum(input_filenames{kk});
end

output_filenames = input_filenames;

if all(channel == -1)
  % Interleaved data
  b_is_interleaved = true;
elseif all(channel >= 0) || b_converted_cont_files
  % 2-channel AWESOME data
  b_is_interleaved = false;
elseif ~isempty(channel)
  % Great scott, there's BOTH kinds of data in this folder!
  % Take whichever type has more files
  b_files_interleaved = channel == -1;
  fprintf('Directory %s contains both interleaved (%d) and 2-channel AWESOME (%d) data!\n', this_input_dir, sum(b_files_interleaved), sum(~b_files_interleaved));

  if sum(b_files_interleaved) > 0.5*length(b_files_interleaved)
    output_filenames(~b_files_interleaved) = [];
    b_is_interleaved = true;
    fprintf('Retaining only the interleaved files.\n');
  else
    output_filenames(b_files_interleaved) = [];
    b_is_interleaved = false;
    fprintf('Retaining only the 2-channel AWESOME files.\n');
  end
end

function clean_files(input_dir, output_dir, station_name, cal_datenum, fs_dec, channel)
%% Function: clean_files
% Just clean the files in the input directory

d = [dir(fullfile(input_dir, '*.mat')); dir(fullfile(input_dir, '*.MAT'))];
if isempty(d)
  fprintf('No files found for cleaning in %s\n', input_dir);
  return;
end

% Make output directory if necessary
if ~isdir(output_dir)
  [success, msg] = mkdir(output_dir);
  if ~success
    error('Error creating %s: %s', output_dir, msg);
  end
end

input_filenames = {d.name};
% warning('Hardcoded filename SP020303042017_003.mat');
% input_filenames = {'SP020303042017_003.mat'};

progress_temp_dirname = parfor_progress_init;
% warning('parfor disabled!');
% for kk = 1:length(input_filenames)
parfor kk = 1:length(input_filenames)
  t_start = now;
  
  [~, this_just_filename] = fileparts(input_filenames{kk});
  file_datenum = datenum(this_just_filename(3:14), 'yymmddHHMMSS');

  try
    output_filename_cell = remove_sferics_and_hum(output_dir, input_dir, input_filenames(kk), ...
      station_name, cal_datenum, fs_dec, channel);

    iteration_number = parfor_progress_step(progress_temp_dirname, kk);

    fprintf('Processed %s (%d of %d) in %s\n', just_filename(output_filename_cell{1}), ...
      iteration_number, length(input_filenames), time_elapsed(t_start, now));
  catch er
    fprintf('Unable to process %s\n', input_filenames{kk});
    rethrow(er);
  end
end
parfor_progress_cleanup(progress_temp_dirname);

function [start_sec, channel, station_code, fs_dec] = get_station_params(station_name, folder_datenum)
%% Different stations have different intricasies
% We'll hard code in some information about each station

switch station_name
  case 'palmer'
    start_sec = 5; % There's a cal tone from 0-1 sec
    channel = 'N/S'; % The N/S channel is less noisy (pointed away from the station)
    station_code = 'PA';
    fs_dec = 20e3; % Decimate to 20 kHz
  case 'southpole'
    channel = 'E/W'; % The E/W channel is less noisy
    station_code = 'SP';
    fs_dec = 100e3; % Don't decimate
    if folder_datenum < datenum([2001 12 20 0 0 0])
      start_sec = 26; % Early south pole data begins 24 seconds after the minute (who knows why??)
    elseif folder_datenum < datenum([2002 12 26 0 0 0])
      start_sec = 17; % This data begins 15 seconds after the minute
    elseif folder_datenum < datenum([2005 12 06 0 0 0]);
      start_sec = 2; % This data begins on the minute every 5 minutes.  That's nice
    elseif folder_datenum < datenum([2008 02 06 0 0 0]);
      start_sec = 62; % This data begins 1 minute AFTER the synoptic minute.  Why, oh why?
    else
      start_sec = 2; % This data begins on the minute every 5 minutes.  Much better.
    end
  otherwise
    error('Invalid station name: %s', station_name);
end

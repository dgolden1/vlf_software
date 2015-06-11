function batch_find_events(input_dir, subdirs, output_dir, sitename)
% batch_find_events(input_dir, subdirs, output_dir)
% Script to attempt to detect events in cleaned broadband data
% 
% Creates an "events" file listing events for each processed directory
% (day) of data
% 
% INPUTS
% input_dir is a directory containing subdirectories (days) of data to
% process
% subdirs is a cell array of directories, relative to fullpath, to process.
% 
% If input_dir and subdirs are not given, this script instead examines the file
% run_burstiness_analysis_subdirs.txt for the subdirectories to process, which is
% a \n-separated list of directories, e.g.,
% 10_10
% 10_11
% 10_12
% etc...
% 
% Heavily revised beginning September 1, 2010, with filterbank approach
% depreciated

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Setup
b_plot = true;

output_db_filename = 'auto_chorus_hiss_db';
default_year = '2001';

if ~exist('sitename', 'var')
  % If not given, sitename will be determined from the individual files
  sitename = [];
end

%% Set paths
[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
   case 'vlf-alexandria'
    default_input_dir = fullfile('/array/data_products/palmer_bb_cleaned/', default_year);
    default_output_dir = fullfile('/home/dgolden/array_dgolden/output/burstiness', default_year);
    PARALLEL = true;
  case 'quadcoredan.stanford.edu'
%     default_input_dir = '/media/vlf-data/palmer/2003/cleaned/02_02';
    default_input_dir = fullfile('/media/scott/user_data/dgolden/palmer_bb_cleaned', default_year);
    default_output_dir = fullfile('/home/dgolden/temp/burstiness', default_year);
    PARALLEL = false;
  case {'amundsen.stanford.edu', 'scott.stanford.edu', 'shackleton.stanford.edu'}
%     default_input_dir = fullfile('/data/user_data/dgolden/palmer_bb_cleaned/', default_year);
    default_input_dir = '/data/user_data/dgolden/temp/burstiness_input/';
    default_output_dir = fullfile('/data/user_data/dgolden/temp/burstiness/', default_year);
    PARALLEL = true;
  otherwise
    if ~isempty(regexp(hostname, 'corn[0-9][0-9].stanford.edu'))
      default_input_dir = '/tmp/dgolden1/input';
      default_output_dir = '/tmp/dgolden1/output';
      % default_output_dir = '/afs/ir/users/d/g/dgolden1/private/output/burstiness';
      PARALLEL = true;
    else
      error('Unknown hostname ''%s''', hostname(1:end-1));
    end
end

if ~exist('input_dir', 'var') || isempty('input_dir')
  input_dir = default_input_dir;
end
if ~exist('output_dir', 'var') || isempty('output_dir')
  output_dir = default_output_dir;
end


%% Parallel
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


%% Load list of subdirectories
if ~exist('subdirs', 'var') || isempty(subdirs)
  if exist('run_burstiness_analysis_subdirs.txt', 'file')
    fid = fopen('run_burstiness_analysis_subdirs.txt', 'r');
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

%% Loop over subdirectories
t_net_start = now;
for kk = 1:length(subdirs)
  t_dir_start = now;

  full_input_dir = fullfile(input_dir, subdirs{kk});

  this_output_dir = fullfile(output_dir, ['auto_chorus_hiss_' subdirs{kk}]);
  if ~exist(this_output_dir, 'dir')
    [status, msg] = mkdir(this_output_dir);
    if status ~= 1
      error('Error creating %s: %s', this_output_dir, msg);
    end
  else
    d = dir(fullfile(this_output_dir, '*.mat'));
    if length(d) == 1
      fprintf('Output file %s exists; skipping %s (dir %d of %d)\n', d.name, full_input_dir, kk, length(subdirs));
      continue;
    elseif length(d) > 1
      error('Why are there two .mat files in %s?', this_output_dir);
    end
  end
  
  find_events_single_dir(full_input_dir, this_output_dir, output_db_filename, sitename, b_plot);

  fprintf('Processed %s (dir %d of %d) in %s\n', full_input_dir, kk, length(subdirs), time_elapsed(t_dir_start, now));
end

fprintf('Processed %d directories in %s\n', length(subdirs), time_elapsed(t_net_start, now));

function find_events_single_dir(input_dir, output_dir, output_db_filename, sitename, b_plot)
%% Run analysis on all files in source directory
d = dir(fullfile(input_dir, '*.mat'));
if isempty(d)
  if ~exist(input_dir, 'dir')
    fprintf('%s: not a valid directory\n', input_dir);
  else
    fprintf('%s: no files to process\n', input_dir);
  end
  return;
end

events = [];
sferic_lc = zeros(length(d), 1);
sferic_uc = zeros(length(d), 1);

start_datenums = zeros(length(d), 1);

progress_temp_dirname = parfor_progress_init;
warning('parfor disabled!');
for kk = 1:length(d)
% parfor kk = 1:length(d)
  t_start = now;
  this_full_filename = fullfile(input_dir, d(kk).name);
  start_datenum = get_bb_fname_datenum(this_full_filename, false); % This is the TRUE start_datenum, but the SAVED start_datenum is rounded
  start_datenums(kk) = start_datenum;
  [this_emissions, this_sferic_lc, this_sferic_uc] = find_events_single_file(this_full_filename, output_dir, start_datenum, sitename, b_plot);
  
  % Assign other emission parameters
  for jj = 1:length(this_emissions)
    this_emissions(jj).start_datenum = round((start_datenum - 5/1440)*96)/96 + 5/1440; % Round to the nearest synoptic minute
    this_emissions(jj).end_datenum = this_emissions(jj).start_datenum + 1/96; % The next synoptic minute
    this_emissions(jj).notes = '';
    this_emissions(jj).emission_type = 'unchar';
  end
  
  % Add to events struct
  if ~isempty(this_emissions)
    events = [events; this_emissions.'];
  end
  sferic_lc(kk) = this_sferic_lc;
  sferic_uc(kk) = this_sferic_uc;

  iteration_number = parfor_progress_step(progress_temp_dirname, kk);
  fprintf('Processed %s (file %d of %d) in %s\n', just_filename(this_full_filename), iteration_number, length(d), time_elapsed(t_start, now));
end
parfor_progress_cleanup(progress_temp_dirname);

assert(floor(min(start_datenums)) == floor(max(start_datenums)));
start_datenum = floor(start_datenums(1));

% Save emission struct
this_output_db_filename = sprintf('%s_%s.mat', output_db_filename, datestr(start_datenum, 'yyyy_mm_dd'));
save(fullfile(output_dir, this_output_db_filename), 'events', 'sferic_lc', 'sferic_uc');
fprintf('Saved emission struct to %s\n', fullfile(output_dir, this_output_db_filename));


function [event_struct, sferic_lc, sferic_uc] = find_events_single_file(filename, output_dir, start_datenum, sitename, b_plot)
%% Function: find_events_single_file


%% Load file
file_struct = load(filename);
fs = file_struct.Fs;

if isempty(sitename)
  sitename = standardize_sitename(char(file_struct.station_name(:).'));
end

%% Get emission spectral information
[T, F, P, s_periodogram, s_mediogram, s_medio_diff] = get_data_specs(file_struct.data, fs, start_datenum, sitename);

%% Create plots
if b_plot
  % Spectrogram parameters
  spec_dt = 0.0256; % That's 512 pts for 20 kHz sampled signal
  window = 2^nextpow2(0.0256*100e3);
  nfft = window;
  noverlap = window/2;
  clims = [-1 1.25];

  % Do everything in Figure 1. Squish it if we didn't already.
  sfigure(1); clf;
  pos = get(gcf, 'paperposition');
  if abs(pos(3)/pos(4) - (1 + 1/3)*1.7) > 0.1
    figure_grow; figure_grow(gcf, 1.7, 1);
  end
  
  % SPECTROGRAM
  h_spec = subplot(1, 3, 1:2);
  [S_cal, F_spec, T_spec, unit_str, cax] = spectrogram_cal(file_struct.data, window, noverlap, nfft, fs, sitename, start_datenum);
  spectrogram_cal(S_cal, F_spec, T_spec, unit_str, cax);
  colorbar off;
  title(sprintf('%s %s', sitename, datestr(start_datenum, 31)));
  if max(F) <= 10e3
    ytickpts = 0:1e3:max(F);
  else
    ytickpts = 0:5e3:max(F);
  end
  set(gca, 'ytick', ytickpts);
  hold on;

  % MEDIODOGRAM
  h_mediogram = subplot(1, 3, 3);
  plot(s_mediogram, F, 'LineWidth', 2); % Threshold for emission amplitudes
  grid on;
  xlim(cax - 5);
  set(gca, 'xtick', (cax(1):5:cax(end)) - 5, 'ytick', ytickpts);
  title('Mediodogram');
  xlabel('dB-fT/Hz^{1/2}');
  hold on;
  
  % Final plot stuff
  increase_font(gcf, 14);
  linkaxes([h_spec h_mediogram], 'y');
end
%% Detect emissions
[event_struct, sferic_lc, sferic_uc, noise_struct] = ...
  find_single_event(F, T, P, s_mediogram, s_medio_diff, s_periodogram, file_struct.data, fs, start_datenum, sitename);

%% Plot emissions
if b_plot

  % Plot sferic cutoffs and noise on spectrogram
  saxes(h_spec);
  plot([T(1) T(end)], [1 1]*sferic_lc, 'w--', 'LineWidth', 3);
  plot([T(1) T(end)], [1 1]*sferic_uc, 'w--', 'LineWidth', 3);

  purple = [0.8 0 0.8];
  for kk = 1:length(noise_struct)
    plot([T(1) T(end)], [1 1]*noise_struct(kk).f, '--', 'Color', purple, 'LineWidth', 3);
    text(T(1) + (T(end) - T(1))/2, noise_struct(kk).f, ...
      noise_struct(kk).string, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
      'color', purple, 'FontSize', 12, 'FontWeight', 'bold', 'backgroundcolor', 'w');
  end
  
  % Plot sferic cutoffs and noise on mediogram
  saxes(h_mediogram);
  plot(interp1(F, s_mediogram, [sferic_lc sferic_uc]), [sferic_lc sferic_uc], 'kd', 'MarkerFaceColor', 'k', 'MarkerSize', 10);
  
  
  % Plot emissions
  for kk = 1:length(event_struct)
    % Spectrogram
    saxes(h_spec);
    rectangle('Position', [T(1), event_struct(kk).f_lc, T(end) - T(1), event_struct(kk).f_uc - event_struct(kk).f_lc], ...
      'EdgeColor', 'r', 'LineWidth', 2);
    em_text = sprintf('b=%0.2f', event_struct(kk).ec.burstiness);
    text(T(1) + (T(end) - T(1))/2, event_struct(kk).f_lc + (event_struct(kk).f_uc - event_struct(kk).f_lc)/2, ...
      em_text, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
      'color', 'r', 'FontSize', 12, 'FontWeight', 'bold', 'backgroundcolor', 'w');
    
    % Mediogram
    saxes(h_mediogram);
    plot(interp1(F, s_mediogram, event_struct(kk).f_lc), event_struct(kk).f_lc, 'go', 'MarkerFaceColor', 'g');
    plot(interp1(F, s_mediogram, event_struct(kk).f_uc), event_struct(kk).f_uc, 'rs', 'MarkerFaceColor', 'r');
  end
  
  % Save plot
  [pathstr, name, ext] = fileparts(filename);

  output_filename = [name '_burst_norm.png'];
  print('-dpng', '-r75', fullfile(output_dir, output_filename));
  % disp(sprintf('Saved %s', fullfile(output_dir, output_filename)));
end

1;

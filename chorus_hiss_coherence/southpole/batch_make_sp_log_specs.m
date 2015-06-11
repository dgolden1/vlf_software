function batch_make_sp_log_specs(input_dir, output_dir)
% Pre-calulate a bunch of log-spectrograms of south pole data
% 
% batch_make_sp_log_specs(input_dir, output_dir)

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Input arguments
if ~exist('input_dir', 'var')
%   input_dir = '~/output/southpole_cleaned/2001';
  input_dir = '/shared/users/dgolden/process_southpole_data/southpole_cleaned/2002';
end
if ~exist('output_dir', 'var')
%   output_dir = '~/output/southpole_log_specs';
  output_dir = '/shared/users/dgolden/process_southpole_data/southpole_cleaned/log_specs';
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

%% Find all .mat files
t_start = now;
find_cmd = sprintf('find %s -maxdepth 1 -type d -regex ".*/[0-9][0-9]_[0-9][0-9]$"', input_dir);
[~, dirlist_str] = unix(find_cmd);
dirlist = textscan(dirlist_str, '%s');
dirlist = dirlist{1};
fprintf('Found %d mm_dd directories in %s\n', length(dirlist), time_elapsed(t_start, now));

%% Process each directory
for jj = 1:length(dirlist)
  t_dir_start = now;
 
  this_dir = dirlist{jj};
  d = dir(fullfile(this_dir, '*.mat'));
  filenames = {d.name};

  progress_temp_dirname = parfor_progress_init;
%   warning('Parfor disabled!');
%   for kk = 1:length(filenames)
  parfor kk = 1:length(filenames)
    t_start = now;
   
    output_filename = process_one_file(fullfile(this_dir, filenames{kk}), output_dir);
    iteration_number = parfor_progress_step(progress_temp_dirname, kk);
    fprintf('Saved %s (%d of %d) in %s\n', output_filename, iteration_number, length(filenames), time_elapsed(t_start, now));
  end
  parfor_progress_cleanup(progress_temp_dirname);

  fprintf('Processed %s in %s\n', this_dir, time_elapsed(t_dir_start, now));
end

function output_filename = process_one_file(full_filename, output_dir)
fs = 1e5;
sitename = 'southpole';
window = 4096;
noverlap = window/2;
nfft = 100;

start_datenum = get_bb_fname_datenum(full_filename, false);
output_filename = fullfile(output_dir, datestr(start_datenum, 'yyyy'), ...
  datestr(start_datenum, 'mm_dd'), ...
  sprintf('SP_%s_spec.mat', datestr(start_datenum, 'yyyy_mm_dd_HHMM_SS')));

pathstr = fileparts(output_filename);
if ~exist(pathstr, 'dir')
  mkdir(pathstr);
end

if exist(output_filename, 'file')
  fprintf('Output file %s exists; skipping...\n', output_filename);
  return
end

data_uncal = matGetVariable(full_filename, 'data');
[~, f, t, p] = spectrogram(data_uncal, window, noverlap, logspace(log10(300), log10(fs/2), nfft), fs);
spec = 10*log10(p);
s_mediogram = 10*log10(median(p, 2));

% [~, f, t, p] = spectrogram(data_uncal, window, noverlap, 8192, fs);
% idx = min(unique(round(logspace(log10(nearest_dan(f0, 300)), log10(length(f0)), nfft))), length(f0));
% f = f(idx);
% t = t;
% p = p(idx, :);
% spec1 = 10*log10(p);
% s_mediogram1 = 10*log10(median(p, 2));


save(output_filename, 'f', 't', 'spec', 's_mediogram', 'start_datenum', 'sitename');


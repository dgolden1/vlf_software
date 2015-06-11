function batch_collect_log_mediograms
% Function to extract just the mediogram from the log specs on scott and dump them
% into the local case studies directory

% By Daniel Golden (dgolden1 at stanford dot edu) December 2011
% $Id$

%% Setup
log_spec_dir = fullfile(scottdataroot, 'user_data', 'dgolden', 'southpole_bb_cleaned', 'southpole_log_specs');
output_dir = fullfile(vlfcasestudyroot, 'southpole_emissions');

%% Find list of log specs
t_find_start = now;
find_cmd = sprintf('find %s -name "SP*spec.mat"', log_spec_dir);
[~, filelist_str] = unix(find_cmd);
filelist = textscan(filelist_str, '%s');
filelist = filelist{1};

fprintf('Found %d files in %s\n', length(filelist), time_elapsed(t_find_start, now));

%% Parse file times
t_times_start = now;
file_time = nan(size(filelist));
for kk = 1:length(filelist)
  [~, this_filename] = fileparts(filelist{kk});
  file_time(kk) = datenum(this_filename(4:end-5), 'yyyy_mm_dd_HHMM_SS');
end

fprintf('Parsed file times in %s\n', time_elapsed(t_times_start, now));

%% Stuff mediograms in a matrix
t_mediograms_start = now;
load(filelist{1}, 'f');
s_mediogram = nan(100, length(filelist));
for kk = 1:length(filelist)
  t_start = now;
  this_struct = load(filelist{kk}, 's_mediogram');
  s_mediogram(:, kk) = this_struct.s_mediogram;
  fprintf('Loaded %s (%d of %d) in %s\n', just_filename(filelist{kk}), kk, length(filelist), time_elapsed(t_start, now));
end

fprintf('Loaded mediograms in %s\n', time_elapsed(t_mediograms_start, now));

%% Save result
output_filename = fullfile(output_dir, 'log_mediograms.mat');
save(output_filename, 'f', 's_mediogram', 'file_time');
fprintf(sprintf('Saved %s\n', output_filename));

1;

function collect_dfb_mat_files(probe, start_year, end_year)
% Cram a bunch of single-year DFB mat files into one BIG DFB mat file
% 
% collect_dfb_mat_files(probe, start_year, end_year)
% 
% probe is one of 'A', 'B', 'C', 'D', or 'E'
% 
% NOTE: this file ditches all but the top three channels to save memory

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Setup
if ~exist('start_year', 'var') || isempty(start_year)
  start_year = 0;
end
if ~exist('end_year', 'var') || isempty(end_year)
  end_year = Inf;
end

probe = lower(probe);
fb_dir = fullfile(vlfcasestudyroot, 'themis_emissions', 'fb_scm1');
t_start = now;

%% Get source files
% File names of the form tha_fb_scm1_2008.mat

d = dir(fullfile(fb_dir, sprintf('th%s_fb_scm1_*.mat', probe)));

% Ditch files outside of the requested year range
idx_valid = true(size(d));
for kk = 1:length(d)
  file_year = str2double(d(kk).name(13:16));
  if file_year < start_year || file_year > end_year
    idx_valid(kk) = false;
  end
end
d = d(idx_valid);

%% Cram into one file
epoch = [];
fb_scm1 = [];
for kk = 1:length(d)
  t_file_start = now;
  
  this_filename = fullfile(fb_dir, d(kk).name);
  dfb = load(this_filename);
  epoch = [epoch; dfb.epoch];
  fb_scm1 = [fb_scm1; dfb.fb_scm1];
  f_lim = dfb.f_lim;
  
  fprintf('Loaded %s (%d of %d) in %s\n', d(kk).name, kk, length(d), time_elapsed(t_file_start, now));
end

%% Sort and save
[~,idx] = sort(epoch);
epoch = epoch(idx);
fb_scm1 = fb_scm1(idx,1:3);

output_filename = fullfile(fb_dir, sprintf('th%s_fb_scm1.mat', probe));
save(output_filename, 'epoch', 'fb_scm1', 'f_lim');
fprintf('Saved %s in %s\n', output_filename, time_elapsed(t_start, now));

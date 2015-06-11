function pre_slice_them_chorus(b_overwrite)
% Pre-slice the THEMIS/polar data and save the contents of each bin in a
% separate file because otherwise the data takes up too much memory

% By Daniel Golden (dgolden1 at stanford dot edu) April 2012
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'themis'));

output_dir = fullfile(vlfcasestudyroot, 'themis_chorus', 'themis_polar_combined_by_bin');

if ~exist('b_overwrite', 'var')
  b_overwrite = true;
end

%% Choose probes
% probes_used = {'THEMIS', 'Polar'};
probes_used = {'THEMIS'};

%% Set up variables
[L_edges, L_centers, MLT_edges, MLT_centers, lat_edges, lat_centers] = get_bin_edges;
nbins = length(L_centers)*length(MLT_centers)*length(lat_centers);

%% Quit if we've already pre-sliced with these settings
settings_filename = fullfile(output_dir, 'bin_settings.mat');
if exist(settings_filename, 'file')
  old_settings = load(settings_filename);
  if isequal(old_settings.L_edges, L_edges) && isequal(old_settings.MLT_edges, MLT_edges) && ...
      isequal(old_settings.lat_edges, lat_edges) && isequal(old_settings.probes_used, probes_used)
    fprintf('Current sliced bins in %s are equivalent to requested sliced bins; skipping slicing\n', output_dir);
    return;
  end
end

%% Clear output directory
d = dir(fullfile(output_dir, 'bin0*.mat'));
if ~b_overwrite && length(d) > nbins
  error('%s contains a larger number of bins', output_dir);
end

if b_overwrite
  for kk = 1:length(d)
    delete(fullfile(output_dir, d(kk).name));
  end
  if ~isempty(d)
    fprintf('Deleted %d files from %s\n', length(d), output_dir);
  end
else
  if ~isempty(d)
    error('b_overwrite is false and %s is not empty', output_dir);
  end
end

%% Delete old settings file
if exist(settings_filename, 'file')
  delete(settings_filename);
end

%% Load data
if isequal(probes_used, {'THEMIS', 'Polar'})
  % THEMIS and Polar data
  chorus_data = get_combined_them_polar;
  fprintf('Loaded THEMIS/Polar combined data\n');
elseif isequal(probes_used, {'THEMIS'})
  % Just THEMIS data
  [~, them] = get_combined_them_polar;
  chorus_data = them;
  fprintf('Loaded just THEMIS data\n');
end

[lat, MLT, L] = xyz_to_lat_mlt_L(chorus_data.xyz_sm);
lat = abs(lat);

%% Bin data
% Bin by L, MLT and lat
[~, idx_L] = histc(L, L_edges);
[~, idx_MLT] = histc(MLT, MLT_edges);

% Allow a bin that spans midnight, which will start at a negative time
% In this case, the first bin edge is negative, and the last bin edge is
% the same MLT, mod 24, as the first edge
if MLT_edges(1) < 0 && mod(MLT_edges(1), 24) == mod(MLT_edges(end), 24)
  idx_MLT(idx_MLT == 0) = 1;
end
[~, idx_lat] = histc(lat, lat_edges);

%% Pre-slice spacecraft data for subsequent parallel computation
t_net_slice_start = now;
for kk = 1:nbins
  t_slice_start = now;
  
  % Indices of values in this bin
  [this_idx_L, this_idx_MLT, this_idx_lat] = ind2sub([length(L_centers) length(MLT_centers) length(lat_centers)], kk);
  idx = idx_L == this_idx_L & idx_MLT == this_idx_MLT & idx_lat == this_idx_lat;
    
  them_polar_slice.epoch = chorus_data.epoch(idx);
  them_polar_slice.xyz_sm = chorus_data.xyz_sm(idx,:);
  them_polar_slice.Bw = chorus_data.Bw(idx);
  them_polar_slice.MLT = MLT(idx);
  them_polar_slice.probe = chorus_data.probe(idx);
  
  this_filename = fullfile(output_dir, sprintf('bin%04d.mat', kk));
  save(this_filename, '-struct', 'them_polar_slice');
  
  fprintf('Saved bin %d of %d (L=%0.1f, MLT=%0.1f, lat=%0.1f, %d values) in %s\n', ...
    kk, nbins, L_centers(this_idx_L), MLT_centers(this_idx_MLT), lat_centers(this_idx_lat), ...
    sum(idx), time_elapsed(t_slice_start, now));
end

fprintf('Finished slicing in %s\n', time_elapsed(t_net_slice_start, now));

%% Save current settings
save(settings_filename, 'L_edges', 'MLT_edges', 'lat_edges', 'probes_used');


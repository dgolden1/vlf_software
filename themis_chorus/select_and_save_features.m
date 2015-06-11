function select_and_save_features
% Perform feature selection and save output
% 
% Selects different features for COARSE MLT and LATITUDE sectors
% This function is not necessary when doing per-bin feature selection

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

%% Setup
t_net_start = now;

addpath(fullfile(danmatlabroot, 'vlf', 'themis'));

output_dir = fullfile(vlfcasestudyroot, 'themis_chorus');

max_num_features = 20;

%% Load data
% THEMIS and Polar data
% chorus_data = get_combined_them_polar;

% Just THEMIS data
[~, them] = get_combined_them_polar;
chorus_data = them;

%% Get predictors for different MLT sectors
MLT_edges = [21 03; 03 09; 09 15; 15 21];
MLT_names = {'Midnight', 'Dawn', 'Noon', 'Dusk'};
lat_edges = [0 15; 15 90];
lat_names = {'Equatorial', 'High Latitude'};
[MLT_idx_mat, lat_idx_mat] = ndgrid(1:size(MLT_edges, 1), 1:size(lat_edges, 1));
num_regions = numel(MLT_idx_mat);

for kk = 1:num_regions
  t_start = now;
  
  features(kk).region_name = [MLT_names{MLT_idx_mat(kk)} ' ' lat_names{lat_idx_mat(kk)}];
  
  features(kk).MLT_edges = MLT_edges(MLT_idx_mat(kk), :);
  features(kk).lat_edges = lat_edges(lat_idx_mat(kk), :);

  [lat, MLT] = xyz_to_lat_mlt_L(chorus_data.xyz_sm);
  this_region_idx = find(angle_is_between(MLT_edges(MLT_idx_mat(kk), 1)*pi/12, ...
    MLT_edges(MLT_idx_mat(kk), 2)*pi/12, MLT*pi/12, 'rad') & ...
    abs(lat) >= lat_edges(lat_idx_mat(kk), 1) & abs(lat) < lat_edges(lat_idx_mat(kk), 2));

  % Decimate the date, because otherwise, feature selection takes too long
  dec_factor = max(1, floor(length(this_region_idx)/1e5));
  this_region_idx = this_region_idx(1:dec_factor:end);
  
  % Get features for this sector
  [features(kk).selected_idx, features(kk).X_names_selected, features(kk).selected_idx_ordered] = ...
    select_features_by_idx(chorus_data.epoch(this_region_idx), chorus_data.xyz_sm(this_region_idx, :), ...
    chorus_data.Bw(this_region_idx), max_num_features);
  
  fprintf('Determined features for %s sector (%d of %d, %d pts) in %s\n', features(kk).region_name, kk, num_regions, length(this_region_idx), time_elapsed(t_start, now));
end

%% Save
output_filename = fullfile(output_dir, 'themis_chorus_features.mat');
save(output_filename, 'features');
fprintf('Saved %s in %s\n', output_filename, time_elapsed(t_net_start, now));

function debug_per_bin_features
% Click on some plots of the model performance and print out the feature
% names for that bin
% 
% Useful to determine whether per-bin chosen features are totally random,
% or if nearby bins tend to have the same features

% By Daniel Golden (dgolden1 at stanford dot edu) April 2012
% $Id$

%% Setup
close all;

%% Load data
load(fullfile(vlfcasestudyroot, 'themis_chorus', 'themis_polar_chorus_regression.mat'));

%% Plot model performance for a chosen latitude

lat = 0;
lat_idx = interp1(lat_centers, 1:length(lat_centers), lat, 'nearest');
[h_r, h_n_eff] = plot_model_performance(L_edges, L_centers, MLT_edges, MLT_centers, lat_edges, lat_centers(lat_idx), r(:,:,lat_idx), n_eff(:,:,lat_idx));
figure(h_r);

this_lat_feature_names = feature_names(:,:,lat_idx);

%% Select bins
[L_mat, MLT_mat] = ndgrid(L_centers, MLT_centers);

[x, y] = ginput(1);
while ~isempty(x)
  idx = xy_to_l_mlt_idx([x y], L_centers, MLT_centers, false);
  
  % Print feature names in this bin
  bin_feature_names = this_lat_feature_names{idx};
  fprintf('L=%0.2f, MLT=%0.1f, lat=%0.0f:\n', L_mat(idx), MLT_mat(idx), lat);
  if isempty(bin_feature_names)
    fprintf('[No features]\n');
  else
    for kk = 1:length(bin_feature_names)
      fprintf('%s\n', bin_feature_names{kk});
    end
  end
  fprintf('\n');
  
  [x, y] = ginput(1);
end

function per_bin_regress_them_chorus(b_ae_kp_only, output_dir)
% Make a per-bin linear regression model for chorus data from THEMIS and
% Polar

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'themis'));

if ~exist('b_ae_kp_only', 'var')
  b_ae_kp_only = false;
end
if ~exist('output_dir', 'var')
  output_dir = fullfile(vlfcasestudyroot, 'themis_chorus');
end

% Perform feature selection on a bin-by-bin basis, instead of pre-selecting
% the features for large sectors via select_and_save_features.m
b_per_bin_feat_select = true;

%% Set up variables
[L_edges, L_centers, MLT_edges, MLT_centers, lat_edges, lat_centers] = get_bin_edges;

[L_mat, MLT_mat, lat_mat] = ndgrid(L_centers, MLT_centers, lat_centers);
F = TriScatteredInterp(L_mat(:), MLT_mat(:), lat_mat(:), (1:numel(L_mat)).', 'nearest');
% To find an index, do this: F(L, MLT, lat)

% Initialize output matrices
r_train = nan(length(L_centers), length(MLT_centers), length(lat_centers)); % Correlation coefficient between Y_in and Y_hat from model
mat_size = size(r_train);

Y = cell(mat_size);
X = cell(mat_size);
Y_hat = cell(mat_size);
n = nan(mat_size);
n_eff = nan(mat_size);
beta = cell(mat_size); % Regression coefficients on X_in
feature_names = cell(mat_size);
r_pred = nan(mat_size);
rms_err_train = nan(mat_size);
rms_err_pred = nan(mat_size);

r_numel = prod(mat_size);
% r_numel = 5; % For debugging

t_start = now;
progress_temp_dirname = parfor_progress_init;

%% Pre slice bins
pre_slice_them_chorus;

%% Make a different model for each lat/L/MLT bin
% warning('Parfor disabled!');
% for kk = 1:r_numel
parfor kk = 1:r_numel
  t_bin_start = now;

  % Indices of values in this bin
  [this_idx_L, this_idx_MLT, this_idx_lat] = ind2sub(mat_size, kk);
  % idx = idx_L == this_idx_L & idx_MLT == this_idx_MLT & idx_lat == this_idx_lat;

  % Features were selected for different sectors
  % Figure out which sector this bin is in
  this_L_center = L_centers(this_idx_L);
  this_MLT_center = MLT_centers(this_idx_MLT);
  this_lat_center = lat_centers(this_idx_lat);
  
  if b_per_bin_feat_select
    features_precomputed = [];
  else
    features_precomputed = choose_feature_sector(this_MLT_center, this_lat_center);
  end
  
  [n(kk), n_eff(kk), Y{kk}, Y_hat{kk}, r_train(kk), r_pred(kk), rms_err_train(kk), rms_err_pred(kk), beta{kk}, feature_names{kk}] = ...
    model_one_bin(kk, features_precomputed, b_ae_kp_only);

  if isfinite(r_train(kk))
    modeled_str = 'Modeled';
  else
    modeled_str = 'Skipped';
  end

  iteration_number = parfor_progress_step(progress_temp_dirname, kk);
  fprintf('%s bin %d of %d (L=%0.1f, MLT=%0.0f, lat=%0.0f, n_eff=%0.0f, %d features) in %s; r^2=%0.2f\n', ...
    modeled_str, iteration_number, r_numel, this_L_center, this_MLT_center, this_lat_center, ...
    n_eff(kk), length(feature_names{kk}), time_elapsed(t_bin_start, now), r_train(kk)^2);
end
parfor_progress_cleanup(progress_temp_dirname);

fprintf('Modeling complete for %d bins in %s\n', r_numel, time_elapsed(t_start, now));

%% Save
if b_ae_kp_only
  output_filename = fullfile(output_dir, 'themis_chorus_regression_ae_kp.mat');
else
  output_filename = fullfile(output_dir, 'themis_chorus_regression.mat');
end

t_save_start = now;
save(output_filename, 'L_edges', 'L_centers', 'MLT_edges', 'MLT_centers', 'lat_edges', ...
  'lat_centers', 'r_train', 'r_pred', 'rms_err_train', 'rms_err_pred', 'beta', 'Y', ...
  'X', 'Y_hat', 'n', 'n_eff', 'feature_names');
fprintf('Saved %s in %s\n', output_filename, time_elapsed(t_save_start, now));
1;

%% Plot map of correlation coefficients
if length(lat_centers) > 1
  str_plot_plane = 'meridional';
else
  str_plot_plane = 'L-MLT';
end

plot_model_performance(L_edges, L_centers, MLT_edges, MLT_centers, lat_edges, lat_centers, r_train, n_eff, str_plot_plane);

function this_features = choose_feature_sector(MLT_center, lat_center)
%% Function: get features for this MLT/latitude sector

persistent features_struct
if isempty(features_struct)
  feature_filename = fullfile(vlfcasestudyroot, 'themis_chorus', 'themis_polar_features.mat');
  load(feature_filename, 'features');
  features_struct = features;
end

this_features_idx = nan;
for kk = 1:length(features_struct)
  this_MLT_edges = features_struct(kk).MLT_edges;
  this_lat_edges = features_struct(kk).lat_edges;
  if angle_is_between(this_MLT_edges(1)*pi/12, this_MLT_edges(2)*pi/12, MLT_center*pi/12, 'rad') && ...
     angle_is_between(this_lat_edges(1), this_lat_edges(2), lat_center, 'deg')
     
    this_features_idx = kk;
    break;
  end
end
if isnan(this_features_idx)
  error('Unknown MLT sector for feature choice');
end

this_features = features_struct(this_features_idx);

function [X_in, Y_in, feature_names, idx_sample_valid] = get_valid_feature_values(X_all, X_names_all, Bw, X_names_selected)
%% Function: get predictors for a single bin

% Choose only samples for which wave power > 0 and features are finite
idx_sample_valid = Bw > 0 & all(isfinite(X_all), 2);
Y_in = log10(Bw(idx_sample_valid));
X_in_valid = X_all(idx_sample_valid, :);

% Select only features for this MLT/latitude bin; do not include ephemeris features
feature_idx = ismember(X_names_all, X_names_selected) & cellfun(@isempty, regexp(X_names_all, '^eph'));
X_in = X_in_valid(:, feature_idx);
feature_names = X_names_all(feature_idx);


function [n, n_eff, Y, Y_hat, r_train, r_pred, rms_err_train, rms_err_pred, beta, feature_names] = model_one_bin(bin_num, features_precomputed, b_ae_kp_only)
%% Function: Model a single bin

% Load bin data
bin_data_dir = fullfile(vlfcasestudyroot, 'themis_chorus', 'themis_polar_combined_by_bin');
this_bin_filename = fullfile(bin_data_dir, sprintf('bin%04d.mat', bin_num));
load(this_bin_filename, 'epoch', 'xyz_sm', 'Bw', 'MLT', 'probe');

% Specify model
[feature_names, beta, n, n_eff, Y, Y_hat, r_train, rms_err_train] = specify_model(epoch, Bw, features_precomputed, b_ae_kp_only);

% Get prediction error
[r_pred, rms_err_pred] = get_pred_error(epoch, Bw, features_precomputed, b_ae_kp_only);

function [feature_names, beta, n, n_eff, Y, Y_hat, r_train, rms_err] = specify_model(epoch, Bw, features_precomputed, b_ae_kp_only)
%% Function: specify a model, including feature selection if necessary

% Default values to return if we can't run the model
feature_names = {};
beta = nan;
n = nan;
n_eff = nan;
Y = nan;
Y_hat = nan;
r_train = nan;


% Get features and effective number of independent samples
% [X_all, X_names_all] = set_up_predictor_matrix_v2(epoch, 'xyz_sm', xyz_sm, 'b_ae_kp_only', b_ae_kp_only);
[X_all, X_names_all] = set_up_predictor_matrix_v2(epoch, 'b_ae_kp_only', b_ae_kp_only);
idx_sample_valid = Bw > 0 & all(isfinite(X_all), 2);

% Get effective data size
% The AR(1) coefficient isn't defined for fewer than 3 samples
if sum(idx_sample_valid) > 3
  n_eff = effective_data_size(log(Bw(idx_sample_valid)));
else
  return;
end

if b_ae_kp_only
  % Don't choose features for the model which includes only AE* and Kp
  X_names_selected = X_names_all;
elseif ~isempty(features_precomputed)
  % Features have already been chosen for this bin
  X_names_selected = features_precomputed.X_names_selected;
else
  % Perform feature selection for this bin
  max_num_features = floor(n_eff/10);
  max_num_samples = 1e4;
  [~, X_names_selected] = select_features_by_idx(epoch, [], Bw, max_num_features, max_num_samples, false);
end
[this_X_in, this_Y_in, feature_names] = get_valid_feature_values(X_all, X_names_all, Bw, X_names_selected);

n = length(this_Y_in);

% Only make a model if the effective data size is 10 times larger than
% the number of model predictors, or if we did feature selection on this
% bin (which sort-of guarantees not overfitting)
Y = this_Y_in;
if n >= 3 && n_eff >= 10*size(this_X_in, 2) || isempty(features_precomputed)
  [beta, r_train, Y_hat] = regress_fun(this_Y_in, this_X_in);
  % X = this_X_in; Not enough memory to save this
end

rms_err = sqrt(mean((this_Y_in - Y_hat).^2));


function [Y_hat, Y_in] = run_model(epoch, Bw, feature_names, beta, b_ae_kp_only)
%% Function: Run a previously-specified model, presumably on new data

[X_all, X_names_all] = set_up_predictor_matrix_v2(epoch, 'b_ae_kp_only', b_ae_kp_only);
[X_in, Y_in, feature_names, idx_sample_valid] = get_valid_feature_values(X_all, X_names_all, Bw, feature_names);

Y_hat = [ones(size(X_in, 1), 1) X_in]*beta;


function [r, rms_err] = get_pred_error(epoch, Bw, features_precomputed, b_ae_kp_only)
%% Function: determine prediction error by specifying and testing the model on different data

num_partitions = 5;

% If we don't have enough data points to compute the autocorrelation
% function for each partition, then skip it
if sum(Bw > 0) < num_partitions*5
  r = nan;
  rms_err = nan;
  return;
end

[~, partition_idx_cell] = partition_contig_by_epoch(epoch, num_partitions);

for kk = 1:num_partitions
  t_start = now;
  
  % Separate train and test sets
  Bw_train = Bw(~partition_idx_cell{kk});
  Bw_test = Bw(partition_idx_cell{kk});
  epoch_train = epoch(~partition_idx_cell{kk});
  epoch_test = epoch(partition_idx_cell{kk});
  
  % Specify model on train set
  [feature_names, beta] = specify_model(epoch_train, Bw_train, features_precomputed, b_ae_kp_only);
  
  % Run model on test set
  [y_hat_cell{kk, 1}, y_cell{kk, 1}] = run_model(epoch_test, Bw_test, feature_names, beta, b_ae_kp_only);
  
  % fprintf('Ran partition %d of %d in %s\n', kk, num_partitions, time_elapsed(t_start, now));
end

y_vec = cell2mat(y_cell);
y_hat_vec = cell2mat(y_hat_cell);

r = corr(y_vec, y_hat_vec);
rms_err = sqrt(mean((y_vec - y_hat_vec).^2));

function [b, r, Y_hat] = regress_fun(Y_in, X)
%% Function: make a model for a single L/MLT bin

%% Run regression model
b = [ones(size(Y_in)) X]\Y_in;
Y_hat = [ones(size(Y_in)) X]*b;
r = corr(Y_in, Y_hat);

1;

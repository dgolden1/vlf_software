function [selected_idx, X_names_selected, selected_idx_ordered] = select_features_by_idx(epoch, xyz_sm, Bw, max_num_features, max_num_samples, b_verbose)
% Select features from THEMIS/Polar data based on a subset of the data
% 
% [selected_idx, X_names_selected, selected_idx_ordered] = select_features_by_idx(epoch, xyz_sm, Bw, max_num_features)

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

%% Setup
if ~exist('max_num_features', 'var') || isempty(max_num_features)
  max_num_features = Inf;
end
if ~exist('max_num_samples', 'var') || isempty(max_num_samples)
  max_num_samples = Inf;
end
if ~exist('b_verbose', 'var') || isempty(b_verbose)
  b_verbose = true;
end
if ~exist('xyz_sm', 'var')
  xyz_sm = [];
end

%% Set up predictor matrix for this subset of indices
t_pred_mtx_start = now;

if isempty(xyz_sm)
  [X_full, X_names] = set_up_predictor_matrix_v2(epoch);
else
  [X_full, X_names] = set_up_predictor_matrix_v2(epoch, 'xyz_sm', xyz_sm);
end

if b_verbose
  fprintf('Set up predictor matrix in %s\n', time_elapsed(t_pred_mtx_start, now));
end

% Output vector
y_full = log10(Bw);

epoch_full = epoch;

%% Make sure all of X and y are finite
idx_valid = all(isfinite(X_full), 2) & isfinite(y_full);
X = X_full(idx_valid, :);
y = y_full(idx_valid);
epoch = epoch_full(idx_valid);

%% Decimate data if necessary
dec_factor = floor(length(y)/max_num_samples);
if isfinite(max_num_samples) && dec_factor > 1
    idx_dec = 1:dec_factor:length(y);
    y = y(idx_dec);
    X = X(idx_dec, :);
    epoch = epoch(idx_dec);
end

%% Perform feature selection
t_select_features = now;
[selected_idx, X_names_selected, selected_idx_ordered] = them_chorus_select_features(X, X_names, y, epoch, max_num_features, b_verbose);

if b_verbose
  fprintf('Selected features in %s\n', time_elapsed(t_select_features, now));
end

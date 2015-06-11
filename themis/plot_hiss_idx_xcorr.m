function plot_hiss_idx_xcorr
% Plot the cross-correlations betwee hiss and some indices

% By Daniel Golden (dgolden1 at stanford dot edu) December 2011
% $Id$

%% Setup
em_type = 'hiss';

%% Load THEMIS data
t_them_start = now;
[epoch_combined, them_combined] = get_combined_them_power(em_type);
fprintf('Loaded THEMIS data in %s\n', time_elapsed(t_them_start, now));


%% Get indices
[X, X_names] = set_up_predictor_matrix_v1(epoch_combined, 'them_combined', them_combined, 'n_hours_history', 0);

fprintf('Generated predictor matrix in %s\n', time_elapsed(t_pred_start, now));

%% Generate plots
for kk = 1:size(X, 2)
  idx_valid = them_combined.field_power > 0 & isfinite(X(:,kk));
  
  c = xcorr(them_combined.field_power(idx_valid), X(idx_valid, kk), 20, 'coeff');
end

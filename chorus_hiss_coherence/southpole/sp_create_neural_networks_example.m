function [net_chorus_det, net_chorus_freq, net_hiss_det, net_hiss_freq] = sp_create_neural_networks_example(start_datenum, end_datenum)
% Illustration of how to create the four neural networks end-to-end
% This script is really just an example. You should actually run the
% training scripts several times and pick the best one; don't just run this
% script and accept the first output

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

if ~exist('start_datenum')
  start_datenum = [];
end
if ~exist('end_datenum')
  end_datenum = [];
end

[nn_inputs, input_datenums, nn_chorus_targets, nn_hiss_targets] = sp_create_neural_network_inputs(true, start_datenum, end_datenum);
idx_chorus_valid = ~isnan(nn_chorus_targets(1,:));
idx_hiss_valid = ~isnan(nn_hiss_targets(1,:));

% Chorus detection: use all inputs, "validity" is the target
[net_chorus_det, tr_chorus_det] = sp_create_pr_neural_network(nn_inputs, idx_chorus_valid);

% Chorus frequency limits: use only valid inputs, frequency is the target
[net_chorus_freq, tr_chorus_freq] = sp_create_fit_neural_network(nn_inputs(:, idx_chorus_valid), nn_chorus_targets(:, idx_chorus_valid), 'chorus');

% Hiss detection: use all inputs, "validity" is the target
[net_hiss_det, tr_hiss_det] = sp_create_pr_neural_network(nn_inputs, idx_hiss_valid);

% Hiss frequency limits: use only valid inputs, frequency is the target
[net_hiss_freq, tr_hiss_freq] = sp_create_fit_neural_network(nn_inputs(:, idx_hiss_valid), nn_hiss_targets(:, idx_hiss_valid), 'hiss');

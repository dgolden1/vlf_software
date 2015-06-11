function [chorus_datenums, chorus_f, hiss_datenums, hiss_f, input_datenums] = sp_run_neural_network
% Run all the neural networks to create the chorus/hiss database

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Setup
min_freq = 300; % Hz
max_freq = 50e3; % Hz


%% Load data
b_training = false;
years = 2001:2008;
for kk = 1:length(years)
  start_datenum = datenum([years(kk) 1 1 0 0 0]);
  end_datenum = datenum([years(kk)+1 1 1 0 0 0]);
  [nn_inputs_cell{1, kk}, input_datenums_cell{1, kk}] = sp_create_neural_network_inputs(b_training, start_datenum, end_datenum);
end
nn_inputs = cell2mat(nn_inputs_cell);
input_datenums = cell2mat(input_datenums_cell);

%% Load neural network
load('net_2001_2008.mat');

%% Run neural network
chorus_det_outputs = sim(net_chorus_det, nn_inputs);
b_chorus = chorus_det_outputs >= 0.5 & all(isfinite(nn_inputs));
chorus_datenums = input_datenums(b_chorus);
chorus_f = max(min(10.^(sim(net_chorus_freq, nn_inputs(:, b_chorus))), max_freq, min_freq)); % NN operates on log frequency

hiss_det_outputs = sim(net_hiss_det, nn_inputs);
b_hiss = hiss_det_outputs >= 0.5 & all(isfinite(nn_inputs));
hiss_datenums = input_datenums(b_hiss);
hiss_f = max(min(10.^(sim(net_hiss_freq, nn_inputs(:, b_hiss))), max_freq), min_freq);

1;

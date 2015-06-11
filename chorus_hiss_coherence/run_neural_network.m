function events = run_neural_network(net, events, output_db_filename)
% Run the noise-rejecting neural network on the event database that is
% output from the emission detector

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

%% Setup
default_input_db_filename = '/home/dgolden/software/chorus_hiss_coherence/auto_chorus_hiss_db_nn_train_2001.mat';
default_output_db_filename = '/home/dgolden/software/chorus_hiss_coherence/auto_chorus_hiss_db_nn_2001.mat';

if ~exist('output_db_filename', 'var') || isempty(output_db_filename)
  output_db_filename = default_output_db_filename;
end

%% Load events
if ~exist('events', 'var') || isempty(events)
  t_load_start = now;

  events = [];
  load(default_input_db_filename, 'events');

  fprintf('Loaded %s (%d events) in %s\n', ...
    default_input_db_filename, length(events), time_elapsed(t_load_start, now));
end


%% Run neural network
inputs = create_neural_network_inputs(events);

b_is_noise = sim(net,inputs) >= 0.5; % Outputs are doubles between 0 and 1; threshold for logical values

%% Assign types to emissions
for kk = 1:length(events)
  if b_is_noise(kk)
    events(kk).type = 'noise';
  else
    events(kk).type = 'emission';
  end
end

%% Save
% save(output_db_filename, 'events');
% 
% fprintf('Saved %s\n%d events = %d emission + %d noise\n', output_db_filename, ...
%   length(events), sum(~b_is_noise), sum(b_is_noise));

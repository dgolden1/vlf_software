function remove_noise_events
% From each input file of events, remove noise emissions using a neural
% network which has been trained to identify noise.  Resave the noise-free
% events to a new file.

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

%% Setup
input_dir = '/home/dgolden/vlf/case_studies/chorus_hiss_detection/databases';

% Load neural network
load(fullfile(danmatlabroot, 'vlf', 'chorus_hiss_coherence', 'neural_net_noise_full.mat'), 'net');

%% Gather files
find_cmd = sprintf('find %s -regextype posix-extended -type f -regex ".*/auto_chorus_hiss_db_[0-9]{4}\\.mat" | sort', input_dir);

[~, filelist_str] = unix(find_cmd);
filelist = textscan(filelist_str, '%s');
filelist = filelist{1};

%% Remove noise and resave
for kk = 1:length(filelist)
  t_start = now;
  
  DF = load(filelist{kk});
  inputs = create_neural_network_inputs(DF.events);
  outputs = sim(net, inputs);
  b_emission = outputs >= 0.5;
  events = DF.events(b_emission); % Noise is output < 0.5
  
  [pathstr, name, ext] = fileparts(filelist{kk});
  year_str = name(21:24);
  
  new_filename = sprintf('auto_chorus_hiss_db_em_%s.mat', year_str);
  save(fullfile(pathstr, new_filename), 'events');
  
  fprintf('Saved %s (%d of %d) in %s. Found %d emissions in %d events (%0.0f%%)\n', ...
    new_filename, kk, length(filelist), time_elapsed(t_start, now), ...
    sum(b_emission), length(b_emission), sum(b_emission)/length(b_emission)*100);
end

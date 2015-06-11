function detect_chorus_hiss_nn
% From each input file of events, from which noise has been removed via
% remove_noise_events.m, differentiate between chorus and hiss using a
% neural network which has been trained to do so.  Resave the
% differentiated events to a new file.

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

%% Setup
input_dir = '/home/dgolden/vlf/case_studies/chorus_hiss_detection/databases';

% Load neural network
load(fullfile(danmatlabroot, 'vlf', 'chorus_hiss_coherence', 'neural_net_em_full.mat'), 'net');

%% Gather files
find_cmd = sprintf('find %s -regextype posix-extended -type f -regex ".*/auto_chorus_hiss_db_em_[0-9]{4}\\.mat" | sort', input_dir);

[~, filelist_str] = unix(find_cmd);
filelist = textscan(filelist_str, '%s');
filelist = filelist{1};

%% Remove noise and resave
for kk = 1:length(filelist)
  t_start = now;
  
  DF = load(filelist{kk});
  inputs = create_neural_network_inputs(DF.events);
  outputs = sim(net, inputs);
  b_chorus = outputs < 0.5;
  events = DF.events;

  for jj = 1:length(events)
    if b_chorus(jj)
      events(jj).type = 'chorus';
    else
      events(jj).type = 'hiss';
    end
  end
  
  [pathstr, name, ext] = fileparts(filelist{kk});
  year_str = name(24:27);
  
  new_filename = sprintf('auto_chorus_hiss_db_em_char_%s.mat', year_str);
  save(fullfile(pathstr, new_filename), 'events');
  
  fprintf('Saved %s (%d of %d) in %s. Found %d chorus (%0.0f%%) and %d hiss (%0.0f%%) in %d emissions\n', ...
    new_filename, kk, length(filelist), time_elapsed(t_start, now), ...
    sum(b_chorus), sum(b_chorus)/length(b_chorus)*100, ...
    sum(~b_chorus), sum(~b_chorus)/length(b_chorus)*100, length(b_chorus));
end

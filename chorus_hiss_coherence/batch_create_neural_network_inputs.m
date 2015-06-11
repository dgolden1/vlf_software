function [inputs, targets] = batch_create_neural_network_inputs(input_type, nn_type)
% [inputs, targets] = batch_create_neural_network_inputs(input_type, nn_type)
% Function to generate vectors of inputs and targets combined for all of
% the years of detected emissions combined
% 
% input_type can be one of 'train' (for training data), 'emission' (for
% data from which noise has been removed) or 'all' (for all data)
% 
% If nn_type is 'noise', target is 0 (noise) or 1 (emission)
% If nn_type is 'emission', target is 0 (chorus) or 1 (hiss)


% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

%% Setup
error(nargchk(2, 2, nargin))

%% Set paths
[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
  case 'quadcoredan.stanford.edu'
    input_dir = '/home/dgolden/vlf/case_studies/chorus_hiss_detection/databases';
  case {'amundsen.stanford.edu', 'scott.stanford.edu', 'shackleton.stanford.edu'}
    input_dir = '~/temp/databases';
  otherwise
    error('Unknown hostname %s', hostname(1:end-1));
end

%% Gather files
switch input_type
  case 'all'
    find_cmd = sprintf('find %s -regextype posix-extended -type f -regex ".*/auto_chorus_hiss_db_[0-9]{4}\\.mat" | sort', input_dir);
  case 'emission'
    find_cmd = sprintf('find %s -regextype posix-extended -type f -regex ".*/auto_chorus_hiss_db_em_[0-9]{4}\\.mat" | sort', input_dir);
  case 'train'
    find_cmd = sprintf('find %s -regextype posix-extended -type f -regex ".*/auto_chorus_hiss_db_[0-9]{4}_nn_train\\.mat" | sort', input_dir);
  otherwise
    error('Unknown input_type: %s', input_type);
end

[~, filelist_str] = unix(find_cmd);
filelist = textscan(filelist_str, '%s');
filelist = filelist{1};

DF = {};
for kk = 1:length(filelist)
  DF{end+1} = load(filelist{kk});
end


%% Combine and save
events = DF{1}.events;
for kk = 2:length(DF)
  events = [events; DF{kk}.events];
end

[inputs, targets] = create_neural_network_inputs(events, nn_type);

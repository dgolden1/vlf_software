function [data_out, fs] = get_synoptic_data(full_filename, start_sec, num_sec, channel)
% Use get_synoptic_offsets to retrieve data
% data = get_synoptic_data(full_filename, start_sec, num_sec, channel)
% 
% INPUTS
% full_filename
% start_sec is with respect to beginning of file
% channel: either 'N/S' or 'E/W' or 'both'
% 
% OUTPUTS
% data vector or a cell array of data vectors if the file is interleaved
% and channel is 'both'

% By Daniel Golden (dgolden1 at stanford dot edu) April 2011
% $Id$

if ~exist('num_sec', 'var')
  num_sec = [];
end

try
  fs = matGetVariable(full_filename, 'Fs');
  % File is two-channel
  
  data_out = matGetVariable(full_filename, 'data', num_sec*fs, start_sec*fs);
  return  
catch er
  if ~strcmp(er.identifier, 'matGetVariable:varNotFound')
    rethrow(er);
  end    
end

try
  fs = matGetVariable(full_filename, 'channel_sampling_freq');
  fs = fs(1);
  % File is interleaved
  
  if ~exist('channel', 'var') || isempty(channel)
    channel = 'both';
  end
  
  data = matGetVariable(full_filename, 'data', round(num_sec*fs*2), round(start_sec*fs*2));
  
  switch lower(channel)
    case 'n/s'
      data_out = data(1:2:end);
    case 'e/w'
      data_out = data(2:2:end);
    case 'both'
      data_out = {data(1:2:end), data(2:2:end)};
    otherwise
      error('Weird value for channel: %s', channel)
  end
catch er
  if strcmp(er.identifier, 'matGetVariable:varNotFound')
    error('Unable to find either ''Fs'' or ''channel_sampling_freq'' in file %s', full_filename);
  else
    rethrow(er);
  end
end

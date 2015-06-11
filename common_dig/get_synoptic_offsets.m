function [filenames_out, file_offsets, channel_out] = get_synoptic_offsets(varargin)
% Determine start offsets for synoptic intervals in broadband files
% 
% [filenames_out, file_offsets, channel] = get_synoptic_offsets('param', value)
% Examine each input file and determine which synoptic interval they
% contain; return a vector of file_offsets with offsets in seconds into
% each file to find the synoptic segments that that file contains
% 
% PARAMETERS
% pathname: directory which contains the files.  If pathname is omitted, then
% filenames_in is assumed to have full pathnames
% filenames_in: cell array of input filenames.  If filenames_in is omitted,
% then all files are taken from pathname directory
% start_sec: second to start after synoptic minute (default: 5)
% duration: duration of synoptic data segments (default: 10)
% synoptic_start_second_ut: seconds, after UT midnight, of the first
% synoptic interval (default: 300 = 5 min)
% synoptic_interval_seconds: interval, in seconds, between each synoptic
% epoch (default: 900 = 15 min)
% specific_datenums: specify an explicit list of datenums instead of
%  letting this function generate them from the synoptic parameters.  If
%  this parameter is specified, the synoptic parameters (except for
%  duration) are ignored
% which_channel: If filenames_in is not specified, choose the desired
% channels as 'N/S' (default), 'E/W' or 'both'
% 
% OUTPUTS
% filenames_out: cell array of filenames containing the relevant synoptic
% epochs.  This list may contain duplicates if a given file spans more than
% one synoptic epoch.
% file_offsets: offsets into each file (in seconds)
% channel: channel number of each file

%% Process input arguments

p = inputParser;
p.addParamValue('pathname', []);
p.addParamValue('filenames_in', []);
p.addParamValue('start_sec', 5);
p.addParamValue('duration', 10);
p.addParamValue('synoptic_start_second_ut', 5*60);
p.addParamValue('synoptic_interval_seconds', 15*60);
p.addParamValue('which_channel', 'N/S');
p.addParamValue('specific_datenums', []);
p.parse(varargin{:});

which_channel = 'both';

if isempty(p.Results.pathname) && isempty(p.Results.filenames_in)
  error('Must specify either path name or filenames');
elseif ~isempty(p.Results.pathname) && ~isempty(p.Results.filenames_in)
  % Transform filenames into full filenames
  filenames_in = cellfun(@(x) fullfile(p.Results.pathname, x), p.Results.filenames_in, 'uniformoutput', false);
elseif ~isempty(p.Results.filenames_in)
  filenames_in = p.Results.filenames_in;
else
  filenames_in = [dir(fullfile(p.Results.pathname, '*.mat')); dir(fullfile(p.Results.pathname, '*.MAT'))];
  filenames_in = cellfun(@(x) fullfile(p.Results.pathname, x), {filenames_in.name}, 'uniformoutput', false);
  
  % This input only counts if we are gathering the filenames in this
  % function
  which_channel = p.Results.which_channel;
end

if isempty(p.Results.specific_datenums)
  % If specific datenums weren't specified, generate synoptic datenums
  synoptic_start_times = ((p.Results.synoptic_start_second_ut/86400):(p.Results.synoptic_interval_seconds/86400):1) + p.Results.start_sec/86400;
else
  % Otherwise, use the specific datenum
  synoptic_start_times = fpart(p.Results.specific_datenums);
end
synoptic_end_times = synoptic_start_times + p.Results.duration/86400;



%% Get list of files
bb_start_datenum = zeros(size(filenames_in));
bb_end_datenum = zeros(size(filenames_in));
channel = nan(size(filenames_in));
valid_file_mask = true(size(filenames_in));
for kk = 1:length(filenames_in)
  try
    [bb_start_datenum(kk), bb_end_datenum(kk), junk, channel(kk)] = get_bb_fname_datenum(filenames_in{kk}, false);
  catch er
    warning('Skipping %s due to read error : %s', filenames_in{kk}, er.message);
    valid_file_mask(kk) = false;
  end

  % Reject files that span multiple days
  if floor(bb_start_datenum(kk)) ~= floor(bb_end_datenum(kk) - 1/86400)
    valid_file_mask(kk) = false;
  end
end

% If we don't want to use both channels, reject the higher-numbered channel
switch lower(which_channel)
  case 'both'
    % Do nothing
  case 'n/s'
    % Keep even-numbered channels
    valid_file_mask(mod(channel, 2) ~= 0 & channel ~= -1) = false;
  case 'e/w'
    % Keep odd-numbered channels
    valid_file_mask(mod(channel, 2) == 0 & channel ~= -1) = false;
  otherwise
    error('Invalid value for which_channel (%s)', which_channel);
end  

filenames_in = filenames_in(valid_file_mask);
bb_start_datenum = bb_start_datenum(valid_file_mask);
bb_end_datenum = bb_end_datenum(valid_file_mask);
channel = channel(valid_file_mask);


%% Find offsets into files
filenames_out = {};
file_offsets = [];
channel_out = [];
for kk = 1:length(synoptic_start_times)
  % Find a file that contains this synoptic interval
  valid_idx = find(fpart(bb_start_datenum) <= synoptic_start_times(kk) + 1/86400 & fpart(bb_end_datenum) >= synoptic_end_times(kk) - 1/86400);
  if isempty(valid_idx)
    continue;
  end
  
  for jj = 1:length(valid_idx)
    filenames_out{end+1} = filenames_in{valid_idx(jj)};
    file_offsets(end+1) = round((synoptic_start_times(kk) - fpart(bb_start_datenum(valid_idx(jj))))*86400);
    channel_out(end+1) = channel(valid_idx(jj));
  end
end

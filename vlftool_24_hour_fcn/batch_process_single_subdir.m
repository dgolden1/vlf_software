function batch_process_single_subdir(source_dir, output_dir, varargin)
% Make a 24-hour spectrogram of a single subdirectory, saving the result to
% the given output directory
% 
% If output_dir is not specified, the plot is not saved

% By Daniel Golden (dgolden1 at stanford dot edu) December 2009
% $Id$

%% Process input arguments
p = inputParser;
p.addParamValue('b_cont_spec', false);
p.addParamValue('sitename', '');
p.addParamValue('day_datenum', []);
p.addParamValue('channel', 'N/S');
p.parse(varargin{:});
b_cont_spec = p.Results.b_cont_spec;
sitename = p.Results.sitename;
day_datenum = p.Results.day_datenum;
channel_str = p.Results.channel;

%% VLFTool parameters
startSec = 5;
dbOffset = 0;
switch sitename
  case 'southpole'
    dbOffset = -5;
    if ~isempty(day_datenum)
      if day_datenum < datenum([2001 12 20 0 0 0])
        startSec = 26; % Early south pole data begins 24 seconds after the minute (who knows why??)
      elseif day_datenum < datenum([2002 12 26 0 0 0])
        startSec = 17; % This data begins 15 seconds after the minute
      elseif day_datenum < datenum([2005 12 06 0 0 0]);
        startSec = 2; % This data begins on the minute every 5 minutes.  That's nice
      elseif day_datenum < datenum([2008 02 06 0 0 0]);
        startSec = 62; % This data begins 1 minute AFTER the synoptic minute.  Why, oh why?
      else
        startSec = 2; % This data begins on the minute every 5 minutes.  Much better.
      end
    end
end
duration = 5;
endSec = startSec + duration;
bProc24 = true;
if ~b_cont_spec
  numRows = 2;
  f_uc = [40e3 10e3];
  f_lc = [300 300];
else
  numRows = 1;
  f_uc = 10e3;
  f_lc = 300;
end

% Save plot only if output_dir is specified
if exist('output_dir', 'var') && ~isempty(output_dir)
  bSavePlot = true;
else
  output_dir = [];
  bSavePlot = false;
end

%% Get file list
d = dir(source_dir);

mask = true(size(d));
filenames = {};
for jj = 1:length(d)
  [pathstr, name, ext] = fileparts(d(jj).name);
  if strcmpi(ext, '.mat')
    filenames{end+1} = fullfile(source_dir, [name ext]);
  end
end

[~, ~, ~, channels] = get_bb_fname_datenum(filenames);

if isempty(filenames)
  error('Directory ''%s'' is empty', source_dir);
end

%% Set channel
try
  fs = matGetVariable(filenames{1}, 'Fs');
  is_interleaved = false;
catch er
  if strcmp(er.identifier, 'matGetVariable:varNotFound')
    is_interleaved = true;
  else
    rethrow(er);
  end
end

switch lower(channel_str)
  case 'n/s'
    channel = 1;
  case 'e/w'
    if is_interleaved
      channel = 2;
    else
      % for two channel data, vlftoolfcn requires channel to be 1
      channel = 1;
    end
  otherwise
    error('Weird value for channel: %s', channel_str)
end

filenames(channels ~= -1 & channels + 1 ~= channel) = [];

%% Get proper offsets into files
[filenames_out, file_offsets] = get_synoptic_offsets('filenames_in', filenames, ...
  'start_sec', startSec, 'duration', duration, 'which_channel', channel_str);

if isempty(filenames_out)
  error('No valid files in %s', source_dir);
end

%% Run vlftoolfcn
vlftoolfcn(filenames_out, file_offsets, file_offsets + endSec - startSec, bSavePlot, ...
  output_dir, numRows, f_uc, f_lc, b_cont_spec, bProc24, dbOffset, channel);

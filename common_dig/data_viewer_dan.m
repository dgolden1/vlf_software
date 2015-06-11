function varargout = data_viewer_dan(sitename, start_datenum, varargin)
% DF = data_viewer_dan(sitename, start_datenum, 'param', value, ...)
% Dan's data viewer
% Make a spectrogram of some data from a broadband file, either interleaved
% or two-channel
% 
% If the data is interleaved, the spectrogram is of the N/S (first) channel
% 
% INPUTS
% sitename: sitename (scott folder name) of site
% start_datenum: datenum of start time, plus or minus 5 seconds
% 
% PARAMETERS
% duration: duration in seconds (default: 10)
% dec_factor: data will be decimated by this factor (default: 1)
% channel: one of 'N/S', 'E/W' or 'both' (default: 'both')
% h_ax: axis in which to plot (if missing, opens a new figure)
% 
% OUTPUTS
% DF: struct containing the data with update time, sampling frequency, etc.
% deltaf: the frequency bin resolution of the spectrogram.  The total power
% in an emission is bandwidth/deltaf*PSD

%% Process input arguments
p = inputParser;
p.addParamValue('duration', 10);
p.addParamValue('dec_factor', 1);
p.addParamValue('channel', 'both');
p.addParamValue('h_ax', []);
p.parse(varargin{:});

duration = p.Results.duration;
dec_factor = p.Results.dec_factor;
which_channel = p.Results.channel;
h_ax = p.Results.h_ax;

%% Setup
if length(start_datenum == 6) % start_datenum is a datevec
  start_datenum = datenum(start_datenum);
end

%% Process each channel
[filename, file_offset, channel] = get_data_server_file_offsets(sitename, start_datenum, duration, which_channel);
idx_ns = mod(channel, 2) == 0;
switch lower(which_channel)
  case 'both'
    if all(channel == -1)
      DF(1) = plot_one_channel(filename{1}, file_offset, start_datenum, duration, 'N/S', dec_factor, h_ax);
      DF(2) = plot_one_channel(filename{1}, file_offset, start_datenum, duration, 'E/W', dec_factor, h_ax);
    else
      if sum(idx_ns) ~= 0
        plot_one_channel(filename{idx_ns}, file_offset(idx_ns), start_datenum, duration, 'N/S', dec_factor, h_ax);
      end
      if sum(~idx_ns) ~= 0
        plot_one_channel(filename{~idx_ns}, file_offset(~idx_ns), start_datenum, duration, 'E/W', dec_factor, h_ax);
      end
    end
  case 'n/s'
    DF = plot_one_channel(filename{idx_ns}, file_offset(idx_ns), start_datenum, duration, which_channel, dec_factor, h_ax);
  case 'e/w'
    DF = plot_one_channel(filename{~idx_ns}, file_offset(~idx_ns), start_datenum, duration, which_channel, dec_factor, h_ax);
  otherwise
    error('Invalid channel: %s', which_channel);
end

%% Outputs
if nargout > 0
  varargout{1} = DF;
end

function DF = plot_one_channel(filename, file_offset, start_datenum, duration, which_channel, dec_factor, h_axes)
%% Function: plot_one_channel

if isempty(filename)
  error('No files found');
end

%% Load data variables
vars = matLoadExcept(filename, 'data');

%% Is this an interleaved file?
if isfield(vars, 'Fs')
  fs = vars.Fs;
  sitename = vars.station_name;
  
  b_is_interleaved = false;
elseif isfield(vars, 'channel_sampling_freq')
  fs = vars.channel_sampling_freq(1);
  sitename = vars.siteName;
  
  b_is_interleaved = true;
else
  error('No frequency variable?');
end

%% Load data
data = load_one_channel(filename, vars, fs, b_is_interleaved, file_offset, duration, which_channel);

data = decimate(data, dec_factor);
fs = fs/dec_factor;

fprintf('Loaded %s\n', filename);

%% File info
[site_name, site_prettyname] = standardize_sitename(sitename);

%% Spectrogram
window = 512;
noverlap = window*3/4;
nfft = window;
deltaf = fs/nfft;

if exist('h_axes', 'var') && ~isempty(h_axes)
  saxes(h_axes);
else
  figure;
end

spectrogram_cal(data, window, noverlap, nfft, fs, site_name, start_datenum);

title(sprintf('%s %s  %s', site_prettyname, which_channel, datestr(start_datenum, 'yyyy-mm-dd  HH:MM:SS')));

%% Outputs
DF = vars;
DF.fs = fs;
DF.data = data;
DF.start_time = start_datenum;
DF.deltaf = deltaf;

function data = load_one_channel(filename, vars, fs, b_is_interleaved, file_offset, duration, which_channel)
%% Function: load one channel of data
if b_is_interleaved
  skip_factor = 2;
else
  skip_factor = 1;
end

if b_is_interleaved && strcmpi(which_channel, 'e/w')
  first_sample = 2;
else
  first_sample = 1;
end

data = matGetVariable(filename, 'data', duration*fs*skip_factor, round(file_offset*fs*skip_factor));
data = data(first_sample:skip_factor:end);

function vlf_spec_single(filename, bMakeSpec, bMakeTime, axesHandle, ...
	startOffsetSec, lengthSec, channel, fMax, dbLow, dbRange)
% vlf_spec_single(filename, bMakeSpec, bMakeTime, axesHandle, startOffsetSec, ...
%                 lengthSec, channel, fMax, dbLow, dbRange)
% Takes in a data file name and creates a spectrogram or time-series plot

% INPUTS
% filename: file name of broadband data file
% bMakeSpec: if true, a spectrogram is created
% bMakeTime: if true, a time-series plot is created
% axesHandle: a 1 or 2-element array containing the axis handles on which
% to make the plots. If 2 elements, the first is the spectrogram axis
% handle, and the second is the time axis handle. If axesHandle is empty or
% nonexistent, a new figure will be created which will contain one or both
% plots
% startOffsetSec: seconds after beginning of file to start plot
% lengthSec: number of seconds in plot
% channel: data channel to plot
% fMax: maximum frequency to plot (Hz)
% dbLow: the low level of the spectrogram colorscale
% dbRange: the range of the spectrogram colorscale

% By Daniel Golden (dgolden1 at stanford dot edu) September 2007

% $Id$

%% Argument Check

error(nargchk(1, 10, nargin));

if ~exist('bMakeSpec', 'var') || isempty(bMakeSpec), bMakeSpec = true; end
if ~exist('bMakeTime', 'var') || isempty(bMakeTime), bMakeTime = false; end
if ~exist('axesHandle', 'var') || isempty(axesHandle), axesHandle = []; end
if ~exist('startOffsetSec', 'var') || isempty(startOffsetSec), startOffsetSec = 0; end
if ~exist('lengthSec', 'var') || isempty(lengthSec), lengthSec = 30; end
if ~exist('channel', 'var') || isempty(channel), channel = 1; end
if ~exist('fMax', 'var') || isempty(fMax), fMax = 15e3; end
if ~exist('dbLow', 'var'), dbLow = []; end
if ~exist('dbRange', 'var'), dbRange = []; end

assert(channel >= 1 && channel <= 2);
assert(fMax >= 100);


%% Setup

% Open file
[fid, message] = fopen(filename);
if fid == -1
	error(message);
end

% Create a figure if axes were not provided
if isempty(axesHandle)
	h = figure;
end


%% Set up the axes
if bMakeSpec && bMakeTime
	if ~isempty(axesHandle) && ~(ndims(axesHandle) == 2 && length(axesHandle) == 2)
		error('Incorrect size for axesHandle (%s)', num2str(size(axesHandle)));
	end
	
	if isempty(axesHandle)
		ax_spec = subplot(2, 1, 1);
		ax_time = subplot(2, 1, 2);
		linkaxes([ax_spec ax_time], 'x');
	else
		ax_spec = axesHandle(1);
		ax_time = axesHandle(2);
	end
elseif bMakeSpec
	if isempty(axesHandle)
		ax_spec = axes;
	elseif all(size(axesHandle == 1))
		ax_spec = axesHandle;
	else
		error('Incorrect size for axesHandle (%s)', num2str(size(axesHandle)));
	end
elseif bMakeTime
	if isempty(axesHandle)
		ax_time = axes;
	elseif all(size(axesHandle == 1))
		ax_time = axesHandle;
	else
		error('Incorrect size for axesHandle (%s)', num2str(size(axesHandle)));
	end
else
	error('Either bMakeSpec or bMakeTime must be true');
end


%% Load the data
[fid, message] = fopen(filename, 'r');
if fid == -1, error('Error opening %s: %s', filename, message); end;

matLoadExcept(fid, 'data');
[varNames, varTypes, varOffsets, varDimensions] = matGetVarInfo(fid);

if ~exist('fs', 'var')
	if exist('channel_sampling_freq', 'var')
		fs = channel_sampling_freq(1);
	elseif exist('Fs', 'var')
		fs = Fs(1);
	end
end
% In Summer 2004 data, fs is reported as being 20 kHz, which is wrong; it's
% actually 100 kHz (verified with Chistochina 2004-07-23 0300).
if fs == 20000
	fs = 100e3;
end

if ~exist('siteName', 'var')
	warning('siteName parameter not found');
	siteName = 'UNKNOWN SITE';
end

% Is the data interleaved? If so, we actually need to load twice as many
% data points (since we'll be getting two channels instead of one)
dataIndex = find(strcmp(varNames, 'data'));
dataDims = varDimensions(dataIndex,:);
if min(dataDims) == 1 && exist('num_channels', 'var') && num_channels == 2
	isInterleaved = true;
else
	% This line may not be true; the num_channels variable may not exist or
	% may be called something else.
	warning('''num_channels'' variable does not exist; assuming non-interleaved data (without proof)'); %#ok<WNTAG>
	isInterleaved = false;
end
	

% Actually load the data
nElements = fs*lengthSec;
startOffset = fs*startOffsetSec;
if isInterleaved
	nElements = nElements*2;
	startOffset = startOffset*2;
end
data = matGetVariable(fid, 'data', nElements, startOffset);


% Trim out the desired channel from the data
if ndims(data) > 2, error('Error: maximum of two channels supported'); end
if size(data, 2) > 2, data = data.'; end % Make sure data goes down the rows, and channel goes down the columns

% Parse out our desired channel
if isInterleaved
	data = data(channel:2:end);
else
	data = data(:, channel);
end

% Downsample
data = resample(data, round(fMax*2), round(fs));
fs = fMax*2;

% Remove low frequencies
Hd = power_line_filter(fs);
data = filter(Hd, data);

%% Create string for file start time
startdate = datenum(start_year, start_month, start_day, start_hour, start_minute, start_second);
fileStartString = datestr(startdate, 31);
% fileStartString = sprintf('%04d-%02d-%02d  %02d:%02d:%02d', ...
% 	start_year, start_month, start_day, start_hour, start_minute, start_second);


%% Make spectrogram
if bMakeSpec
	window = 512;
	noverlap = window*3/4;
	nfft = window*2;
	
	[S, F, T] = spectrogram(data, window, noverlap, nfft, fs);
	axes(ax_spec);
	imagesc(T + startOffsetSec, F, db(S));
	set(gca, 'YDir', 'normal');
	
	if ~isempty(dbLow) && ~isempty(dbRange)
		caxis([dbLow dbLow + dbRange]);
	end
	
	colorbar;
	
	xlabel(['Seconds after ' fileStartString]);
	ylabel('Frequency (Hz)');
	xlim(round(xlim*10)/10);
	title(siteName);
	increase_font(gca);
end


%% Make time series
if bMakeTime
	t = linspace(startOffsetSec, startOffsetSec + lengthSec, length(data));
	
	axes(ax_time);
	plot(t, data, 'Parent', ax_time);
	grid on;
	
	xlabel(['Seconds after ' fileStartString]);
	ylabel('Amplitude');
	title(siteName);
	increase_font(gca);
end

disp('');

function vlftoolfcn(filenames, startSec, endSec, bSavePlot, destinPath, numRows, f_uc, f_lc, bContSpec, bProc24, dbOffset, channel, h_axes)
% vlftoolfcn(filenames, startSec, endSec, bSavePlot, destinPath, numRows, f_uc, f_lc, bContSpec, bProc24, dbOffset, channel, h_axes)
% Function to run the VLFtool spectrogram generator without the VLFtool
% GUI
% 
% INPUTS
% filenames: input filenams with full path
% startSec, endSec: start and end seconds for each file; can be either
% scalar or a vector with the same length as filenames
% bSavePlot: true to save the plot as a png
% destinPath: output path for saved image
% numRows: legacy variable; set to 1
% f_uc, f_lc: upper and lower frequency cutoffs, in Hz
% bContSpec: true to plot a continuous spectrogram instead of many little
% spectrograms (looks better, saves memory, easier to zoom in)
% bProc24: I think this only applies if bContSpec is false. Shows gaps in
% data where files are missing.
% dbOffset: add an offset to the color scale
% channel: 1 = N/S (default), 2 = E/W
% h_axes: draw on this axes handle; otherwise, open a new figure

% By Daniel Golden (dgolden1 at stanford dot edu) January 2008
% $Id$

%% Setup
error(nargchk(1, 12, nargin));

global DF
DF = [];

vlfDefaults;

if ~iscell(filenames)
	filenames = {filenames};
end

DF.sourcePath = fileparts(filenames{1});

DF.wildcard{1} = '*.mat';

if exist('startSec', 'var') && ~isempty(startSec)
	DF.startSec = startSec;
end
if ~exist('endSec', 'var') || isempty(endSec)
	DF.endSec = DF.startSec + 5;
else
	DF.endSec = endSec;
end

if ~exist('bSavePlot', 'var') || isempty(bSavePlot)
	DF.bSavePlot = false;
else
	DF.bSavePlot = bSavePlot;
end

if ~exist('destinPath', 'var') || isempty(destinPath)
	DF.destinPath = '';
else
	DF.destinPath = destinPath;
end

if exist('numRows', 'var') && ~isempty(numRows)
	DF.numRows = numRows;
end

if ~exist('f_uc', 'var') || isempty(f_uc)
	f_uc = 10e3;
end
if ~exist('f_lc', 'var') || isempty(f_lc)
	f_lc = 300;
end

if ~exist('channel', 'var') || isempty(channel)
  channel = 1; % N/S
end

if DF.numRows == 1
	% If we're plotting just one row, zoom it to 10 kHz
	row = 1;
	DF.channel(row, 1) = channel;
	DF.maxFreq(row, 1) = f_uc;
	DF.minFreq(row, 1) = f_lc;
	DF.nfft(row, 1) = 1024;
	DF.window(row, 1) = DF.nfft(row, 1)/2;
	DF.noverlap(row, 1) = DF.nfft(row, 1)/4;
	
	if ~exist('bContSpec', 'var') || isempty(bContSpec) || ~bContSpec
		bContSpec = false;
	end
	DF.bContSpec = bContSpec;
else
	for kk = 1:DF.numRows
		row = kk;
		DF.channel(row, 1) = channel;
		DF.maxFreq(row, 1) = f_uc(kk);
		DF.minFreq(row, 1) = f_lc(kk);
		DF.nfft(row, 1) = 1024;
		DF.window(row, 1) = DF.nfft(row, 1)/2;
		DF.noverlap(row, 1) = 0;
	end
	if bContSpec
		error('Continuous spectrogram not supported with more than one row');
	end
	DF.bContSpec = false;
end

if ~exist('bProc24', 'var') || isempty(bProc24)
	DF.process24 = false;
else
	DF.process24 = bProc24;
end

if ~exist('dbOffset', 'var') || isempty(dbOffset)
	dbOffset = 0;
end
DF.dbScale = DF.dbScale + dbOffset;

if isscalar(DF.startSec)
	DF.startSec = repmat(DF.startSec, size(filenames));
end

if isscalar(endSec)
	DF.endSec = repmat(DF.endSec, size(filenames));
end

if ~exist('h_axes', 'var')
  h_axes = [];
else
  DF.showMLT = false; % Can't show an additional MLT axis if using a preset axis
end
DF.h_axes = h_axes;

DF.useCal = 1;

%% A little bit of bounds checking
assert(all(f_uc > f_lc));
assert(all(f_uc > 300));

%% Run VLFTool
vlfProcess(1, filenames);

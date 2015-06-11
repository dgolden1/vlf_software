function vlfSaveSettings(DF_full, settingsFileName)
% vlfSaveSettings(DF_full, settingsFileName)
% Saves vlfTool settings
% 
% INPUTS
%   DF_full: the full DF struct
%   settingsFileName: file name string for the settings file (default = 'settings.mat')
% 
% By Daniel Golden (dgolden1 at stanford dot edu) April 25 2007

% $Id$

%% Setup
error(nargchk(1, 2, nargin));

if ~exist('settingsFileName', 'var'), settingsFileName = 'settings.mat'; end

%% Extract the important parts of the DF struct
DF.sourcePath = DF_full.sourcePath;
DF.destinPath = DF_full.destinPath;
DF.dirChar = DF_full.dirChar;

DF.maxPlots = DF_full.maxPlots;
DF.wildcard = DF_full.wildcard;
DF.startSec = DF_full.startSec;
DF.endSec = DF_full.endSec;

DF.savePlot = DF_full.savePlot;
DF.saveType = DF_full.saveType;
DF.numRows = DF_full.numRows;

DF.channel = DF_full.channel;
DF.maxFreq = DF_full.maxFreq;
DF.nfft = DF_full.nfft;
DF.window = DF_full.window;
DF.noverlap = DF_full.noverlap;

DF.dbScale = DF_full.dbScale;

DF.colorScale = DF_full.colorScale;

DF.mltLabel = DF_full.mltLabel;
DF.siteMap = DF_full.siteMap;
DF.cal = DF_full.cal;
DF.useCal = DF_full.useCal;
DF.units = DF_full.units;

DF.process24 = DF_full.process24;
DF.calcPSD = DF_full.calcPSD;
DF.savePlot = DF_full.savePlot;

eval(sprintf('save %s DF', settingsFileName));
disp(sprintf('Settings saved to %s', settingsFileName));

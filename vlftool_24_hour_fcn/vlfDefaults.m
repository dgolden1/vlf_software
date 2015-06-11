function vlfDefaults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VLFDEFAULTS: sets up the structure DEFAULTS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DF;

if( isunix )
	DF.sourcePath = '/media/scott/awesome/broadband/palmer/';
	DF.destinPath = '/home/dgolden/temp';
	DF.dirChar = '/';
else
	DF.sourcePath = 'E:\';
	DF.destinPath = 'C:\';
	DF.dirChar = '\';
end;

DF.maxPlots = -1;
DF.wildcard = {'*.mat', '*.MAT'};

DF.startSec = 5;
DF.endSec = 10;

DF.bSavePlot = 1;
DF.saveType = 'png';
DF.hideFigure = 0;
DF.useMLT = 0;

DF.numRows = 2;

%%%% ROW 1
row = 1;
DF.channel(row, 1) = 1;

DF.maxFreq(row, 1) = 40e3;
DF.minFreq(row, 1) = 300;

DF.nfft(row, 1) = 1024;
DF.window(row, 1) = DF.nfft(row, 1)/2;
DF.noverlap(row, 1) = DF.nfft(row, 1)/4;

DF.dbScale(row,1) = 35;
DF.dbScale(row,2) = 80;

%%%% ROW 2
row = 2;
DF.channel(row, 1) = 1;

DF.maxFreq(row, 1) = 10e3;
DF.minFreq(row, 1) = 300;

DF.nfft(row, 1) = 1024;
DF.window(row, 1) = DF.nfft(row, 1)/2;
DF.noverlap(row, 1) = DF.nfft(row, 1)/4;

% HIGH RES
%DF.nfft(row, 1) = 1024;
%DF.window(row, 1) = 128
%DF.noverlap(row, 1) = 64;

DF.dbScale(row,1) = 35;
DF.dbScale(row,2) = 80;


DF.process24 = 0;
DF.useCal = 1;

DF.bContSpec = true;

DF.bCombineChannels = false;

% Show MLT and UTC labels
DF.showMLT = false;

% Axes on which to draw; empty means make a new figure
DF.h_axes = [];

function DF = vlfDefaults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VLFDEFAULTS: sets up the structure DEFAULTS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Modified by Daniel Golden (dgolden1@stanford.edu) Feb 2007

% $Id$

DansDefaults = true; % Junk just for Dan Golden

if (DansDefaults)
	DF.sourcePath = '/home/dgolden/vlf-nobackup/example_data/PA040723';
	DF.destinPath = '/home/dgolden/vlf-nobackup/example_data/PA040723/vlftool_output';
	DF.dirChar = '/';
elseif( isunix )
	DF.sourcePath = '/mnt/cdrom1/';
	DF.destinPath = '~/VLF/PlotsTemp/';
	DF.dirChar = '/';
else
	DF.sourcePath = 'E:\';
	DF.destinPath = 'Z:\vlfTool\';
	DF.dirChar = filesep;
end;

DF.maxPlots = 1;
DF.wildcard = 'BB*.mat';
DF.startSec = 0;
DF.endSec = 60;

DF.savePlot = 0;
DF.saveType = 'jpg';

DF.numRows = 1;

row = 1;
DF.channel(row, 1) = 1;

DF.maxFreq(row, 1) = 15e3;

DF.nfft(row, 1) = 1024;
DF.window(row, 1) = DF.nfft(row, 1)/2;
DF.noverlap(row, 1) = DF.nfft(row, 1)/8;

DF.dbScale(row,1) = 30;
DF.dbScale(row,2) = 70;


row = 2;
DF.channel(row, 1) = 1;

DF.maxFreq(row, 1) = 12.5e3;

DF.nfft(row, 1) = 2056;
DF.window(row, 1) = DF.nfft(row, 1)/4;
DF.noverlap(row, 1) = DF.nfft(row, 1)/8;

% HIGH RES
%DF.nfft(row, 1) = 1024;
%DF.window(row, 1) = 128
%DF.noverlap(row, 1) = 64;

DF.dbScale(row,1) = 30;
DF.dbScale(row,2) = 70;

% USE ROW SETTINGS
DF.colorScale = 1;


DF.mltLabel = 1;
%load('palmerMap_21Mar2002.mat');
load('palmerMap_01Nov2003.mat');
DF.siteMap = palmer;
%load('palmerCal_Jul2000.mat');
%load('palmerbbCal_01Nov2003.mat');
%load('palmerCal_01Nov2003.mat');
load('palmerCal_20Jul2004.mat');
DF.cal = cal;

% USE ROW SETTINGS
DF.useCal = 0;
DF.units = 'uncal';


DF.process24 = 0;
DF.calcPSD = 0;
DF.savePlot = 1;

%% Reading data from 1136 file
% File: ReadDataFile_1136.m
% -------------------------------------------------------------------------
% Output:
% 
% Efield
% LatSpline - approximation used as f = ppval(LatSpline,x)
% LongSpline
% AltSpline
% LThourSpline
% LSpline
% first - structure with info about first data point
% last  - structure with info about last data point
% first.second
% last.second
% BlockSecond
% 
% Input:
% 
% SampleFreq
% 
% -------------------------------------------------------------------------
% The program need next functions:
%
% -> GetDataTiming1131.m
% -> IsDataContinuous1131.m
% -> readLevel1Block1.m
% -> readLevel1Block2.m
% -> readLevel1Block4_1131.m
%
% The program is called by next programs:
%
% <- plot_DEMETER_1131_1136_ground.m

global SampleFreq1131 AllBlockSize1131 FrameNumber1131 BlockDuaration1131

%initail parameters
SampleFreq1131 = SampleFreq;

DataFile = dir('DMT_N1_1136_*.DAT'); 
FileToOpen = DataFile.name;
FileSize = DataFile.bytes;
AllBlockSize1131 = 33063;
nBlockElements1131 = 8192;
FrameNumber1131 = FileSize/AllBlockSize1131;
BlockDuaration1131 = nBlockElements1131/SampleFreq1131;

fid = fopen(FileToOpen,'r','b');

if fid < 0
    disp(['Cannot open file ',DataFile.name]);
end

% check for continuity of data
if ~IsDataContinuous1131(fid)
    disp('Orbit data are not continuous');
end

% initialization
Bfield = zeros(FrameNumber1131*nBlockElements1131,1,'single');
Lat = zeros(FrameNumber1131,1,'single');
Long = zeros(FrameNumber1131,1,'single');
Alt = zeros(FrameNumber1131,1,'single');
LThour = zeros(FrameNumber1131,1,'single');
L = zeros(FrameNumber1131,1,'single');

% time of first and last data points in file
[first, last] = GetDataTiming1131(fid);
BlockSecond = (first.second:BlockDuaration1131:(last.second-BlockDuaration1131/2))';

for iFrame = 1:FrameNumber1131
    fseek(fid,38,'cof'); % skip block 1
    [Lat(iFrame), Long(iFrame), Alt(iFrame), LThour(iFrame), L(iFrame)] =...
        readLevel1Block2(fid);
    fseek(fid,76,'cof'); % skip block 3
    Bfield(((iFrame-1)*nBlockElements1131+1):iFrame*nBlockElements1131) =...
        readLevel1Block4_1131(fid);
end

fclose(fid);

Bfield = 1000*Bfield; % conversion from nT to pT

%% Spline approximation of attitude parameters
LatSpline = spline(BlockSecond(1:end),double(Lat(1:end)));
LongSpline = spline(BlockSecond(1:end),double(Long(1:end)));
AltSpline = spline(BlockSecond(1:100:end),double(Alt(1:100:end)));
LThourSpline = spline(BlockSecond(1:100:end),double(LThour(1:100:end)));
LSpline = spline(BlockSecond(1:10:end),double(L(1:10:end)));
clear Lat Long Alt LThour L

% Projection of DEMETER path onto the ground along B field
% You should have toolbox "TraceAlongB",
projSec = first.second:4:last.second;
numbProjSec = length(projSec);
if numbProjSec < 2
    error('Projection of trajectory with less than 2 points is impossible')
end

LatP = zeros(numbProjSec,1);
LongP = zeros(numbProjSec,1);

for iS=1:numbProjSec
[Mess, LatP(iS), LongP(iS), NumberSteps] =...
    trace(1+670/6370,ppval(LatSpline,projSec(iS)),ppval(LongSpline,projSec(iS)),...
    -0.2*sign(ppval(LatSpline,projSec(iS))),1,1+90/6370,[first.year, first.month, 1, 1, 1, 1]);
end

LatPSpline = spline(projSec,LatP);
LongPSpline = spline(projSec,LongP);

clear projSec numbProjSec LatP LongP Mess NumberSteps iS

% Example of usage
% x = 76300:0.01:76600;
% f = ppval(LatSpline,x);
% figure; plot(BlockSecond,Lat,'.',x,f,'r-')

%% Screen output
disp(['B field has been read from file ',DataFile.name])
disp(['Start time of data: ',datestr(datenum(first.year,first.month,first.day,0,0,first.second),'yyyy-mm-dd HH:MM:SS')])
disp(['Stop time of data:  ',datestr(datenum(last.year,last.month,last.day,0,0,last.second),'yyyy-mm-dd HH:MM:SS')])


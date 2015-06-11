function [SpectrumTime, SpectrumFrequency, PowerSpectrum, Lat, Long, Alt, LThour, L, OrbitN] = read_survey_efield_1132(filename)
% read_survey_efield_1132(varargin)
% Read DEMETER e-field survey data (data product 1132)
% 
% Note: data gaps may be present in the data.  Examine SpectrumTime to be
% sure.

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% Based on code by Denys Piddyachiy
% $Id$

%% Setup


%% Get data
DataFile = dir(filename); 
FileToOpen = filename;
FileSize = DataFile.bytes;

fid = fopen(FileToOpen,'r','b','US-ASCII');

if fid < 0
    disp(['Cannot open file ',DataFile.name]);
end

fseek(fid,204,'cof'); % skip common blocks 1, 2 and 3

[DataType, Status, DataCoordinateSystem, ComponentName, DataUnit, Nb, Nbf, ...
  TotalTimeDuration, FrequencyResolution, FrequencyRange, FirstSpectrumUT] = readLevel1Block4_1132_header(fid);

AllBlockSize1132 = 204 + 114 + Nb*Nbf*4;
%nBlockElements1132 = Nb;
FrameNumber1132 = FileSize/AllBlockSize1132;
BlockDuration1132 = TotalTimeDuration;
SpectrumDuration = double(TotalTimeDuration)/double(Nb);

% initialization of output
PowerSpectrum = zeros(FrameNumber1132*Nb,Nbf);
Lat = zeros(FrameNumber1132,1);
Long = zeros(FrameNumber1132,1);
Alt = zeros(FrameNumber1132,1);
LThour = zeros(FrameNumber1132,1);
L = zeros(FrameNumber1132,1);
Year = zeros(FrameNumber1132,1);
Month = zeros(FrameNumber1132,1);
Day = zeros(FrameNumber1132,1);
SecondBlock1 = zeros(FrameNumber1132,1);
SpectrumSecond = zeros(FrameNumber1132*Nb,1);

% reading main data
fseek(fid,0,'bof');
for iFrame = 1:FrameNumber1132
    [Year(iFrame), Month(iFrame), Day(iFrame), SecondBlock1(iFrame), OrbitN, OrbitType] = readLevel1Block1(fid);
    [Lat(iFrame), Long(iFrame), Alt(iFrame), LThour(iFrame), L(iFrame)] =...
        readLevel1Block2(fid);
    fseek(fid,76,'cof'); % skip block 3
    fseek(fid,114,'cof'); % skip block 4 header
    for iNb = 1:Nb
        PowerSpectrum((iFrame-1)*Nb+iNb,1:Nbf) = fread(fid,Nbf,'float32');
        SpectrumSecond((iFrame-1)*Nb+iNb) = SecondBlock1(iFrame) + (double(iNb)-1)*SpectrumDuration;
    end
end

fclose(fid);

%% Set up output arguments
BlockSecond = SecondBlock1;
SpectrumFrequency = FrequencyRange(1):FrequencyResolution:FrequencyRange(2);
SpectrumTimeOrig = datenum(double([Year Month Day zeros(length(Year), 2) SecondBlock1]));

% Interpolate output variables so they have the same length as PowerSpectrum
SpectrumTime = interp1(1:length(SpectrumTimeOrig), SpectrumTimeOrig, 1:(1/Nb):(length(SpectrumTimeOrig) + 1/Nb), 'linear', 'extrap');
for arg = {'Lat', 'Long', 'Alt', 'LThour', 'L'}
  eval(sprintf('%s = interp1(SpectrumTimeOrig, %s, SpectrumTime, ''linear'', ''extrap'');', ...
    arg{1}, arg{1}));
end

PowerSpectrum = PowerSpectrum.'; % Rotate so time goes down columns and frequency goes down rows

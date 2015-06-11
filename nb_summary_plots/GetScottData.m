% =========================================================================
% Inputs:
%       fullDataDir:    Directory and filename where data is saved
%
% Outputs:
%       LRdataStruct: the Low res data, start time, transmitter, fs
%
% Date Created:     Feb 12, 2010
% Date Modified:
% =========================================================================
function [LRdataStruct,chNum,isAmp] = GetScottData(fullDataDir)

% if lr file is < minSize kB it is too small and we will skip it
% this will also take care of many problems with trying to load "bad" files
% as they are normally small.
minSize = 1; % kB
thisFile = dir(fullDataDir);
if thisFile.bytes/1024 < minSize
    LRdataStruct = struct('Tx',[],'station',[],'data',[],'len',[],'fs',[],'isAmp',[],'startTime',0);
    return;
end

try
    [fsL, start_time, lowresdata, StationName, TxName, chNum, isAmp] = ...
        Load_Scott_Data(fullDataDir);
catch me
    fprintf('Caught Error: %s\n',me.message);
    fprintf('Error loading file: \n%s\nreturning empty values\n',fullDataDir);
    LRdataStruct = struct('Tx',[],'station',[],'data',[],'len',[],'fs',[],'isAmp',[],'startTime',0);
    chNum = NaN;
    isAmp = NaN;
return;    
end

if chNum == 0; chName = 'NS'; else chName = 'EW'; end

LRdataStruct = struct(...
    'Tx',[chName TxName],...
    'station',StationName,...
    'data',lowresdata,...
    'len',length(lowresdata),...
    'fs',fsL,...
    'isAmp',isAmp,...
    'startTime',datenum(start_time));

%% Function to load in data (in case there is an error)
function [Fs, start_time, data, station_name, call_sign, chNum, is_amp] = Load_Scott_Data(fullDataDir)
% =========================================================================
% Inputs:
%       fullDataDir:   Path to the file 
%
% Outputs:
%       Fs:             Sampling Frequency: 1x1 double
%       start_time:     vector of start time datevec [yy mm dd HH MM SS]
%       data:           loaded data: 1xn double
%       station_name:   Name of station: String, e.g. 'Cheyenne'
%       call_sign:      Transmitter name: String, e.g. 'NAA'
%       chNum:          Channel number (0=NS, 1=EW assumed)
%       is_amp:         amplitude vs phase (1=amplitude, 0=phase)
%
% Date Created:     February, 2010
% =========================================================================

load(fullDataDir,'Fs','start_year','start_month','start_day',...
    'start_hour','start_minute','start_second','data',...
    'adc_channel_number','station_name','call_sign','is_amp');
if exist('data','var')
    start_time = datenum(start_year, start_month, start_day, start_hour,...
        start_minute, start_second); %#ok<*NODEF>
    chNum = adc_channel_number;
    call_sign = char(call_sign)';
    station_name = char(station_name)';
%     % option to correct phase if this is changed, also need to change line 106 of CreateScott_Summary
%     if ~is_amp
%         data = phasefix(data,Fs);
%     end
    return;
end

%% phasefix Function
function dataOut = phasefix(data,fs,thresh) %#ok<DEFNU>
% input data in degrees, 
if ~exist('thresh','var'); thresh = 80; end

% locate any "jumps" in phase data which are > thresh (threshold value)
rng = find(~isnan(data));
dataIn = data(rng);
diffData = diff(dataIn); % find the difference between points
jumps = find(abs(diffData) > thresh); %locate the "jumps" > thresh
diffVec = zeros(size(dataIn));
diffVec(jumps+1) = diffData(jumps); % create a vector of the size of the jumps (in the right index spot)
diffVec2 = cumsum(diffVec); % cumulatively sum the jumps
dataIn = dataIn-diffVec2; % remove the jumps from the data
% figure; plot(newData)

remove = testSlope(dataIn,fs); %test for a consistent slope
if ~remove; dataOut = data; return; end
Slope = (dataIn-dataIn(1))\(0:length(dataIn)-1)'; %best-fit line of slope
tmp = ((0:length(dataIn)-1)'/Slope); % create the slope
dataOut = data;
dataOut(rng) = dataIn - tmp; % subtract out the slope

%% testSlope Function
function remove = testSlope(dataIn,fs,chunks,stdThresh)
if ~exist('chunks','var'); chunks = 10; end % chunks in [min]
if ~exist('stdThresh','var'); stdThresh = 2; end
% look at X-minute long chunks, if they all have similar slopes, then
% remove the overall slope

m = length(dataIn);
sec = m/fs;
slopes = zeros(ceil(sec/(chunks*60)),1);
for k = 1:length(slopes)-1
    range = (k-1)*chunks*60*fs+1:k*chunks*60*fs;
%     [(k-1)*60*chunks*fs+1 k*chunks*60*fs]
    slopes(k) = (dataIn(range)-dataIn(range(1)))\(0:length(range)-1)';
end
k = length(slopes);
range = (k-1)*chunks*60*fs+1:m;
slopes(k) = (dataIn(range)-dataIn(range(1)))\(0:length(range)-1)';

remove = 0; % default to not removing slope
% a low standard deviation in the slope means that there is a fairly
% constant slope offset in the phase data, and it needs to be removed.
if abs(std(slopes(~isnan(slopes)))) < stdThresh;
    remove = 1;
end

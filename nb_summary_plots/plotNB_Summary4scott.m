function f1 = plotNB_Summary4scott(pathIn,tx)
% f1 = plotNB_Summary4scott(pathIn,tx)
% 
% Make a narrowband summary plot for a given folder and transmitter pair

% Originally by Ben Cotts
% Modified by Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

if ~exist('pathIn','var'); pathIn = 'Z:\raw_data\narrowband\palmer\2009\01_13\';end
if ~exist('tx','var'); tx = 'HWU'; end

aFiles = dir(fullfile(pathIn, ['*' tx '*A.mat'])); la = length(aFiles);
pFiles = dir(fullfile(pathIn, ['*' tx '*B.mat'])); lp = length(pFiles);

allNames = cell(1,la+lp);
[allNames{1:la}] = deal(aFiles.name);
[allNames{la+1:la+lp}] = deal(pFiles.name);

%% loop over each type of data (NSamp,EWamp,NSphase,EWphase)

% initialize the struct required by plotting routine
allLoaded = struct('Tx',{},'station',{},'data',{},'len',{},'fs',{},'isAmp',{},'startTime',{});

ap = NaN*zeros(1,la+lp); % vector to save whether loaded file is amplitude/phase
nsew = ap; % vector to save whether loaded file is north-south or east-west
for k = 1:length(allNames)
    fullDir = fullfile(pathIn,allNames{k});
    [tmp,chNum,isAmp] = GetScottData(fullDir);
    if tmp.startTime ~= 0 && ~isempty(tmp.startTime);
        allLoaded(k) = tmp;
        ap(k) = isAmp;
        nsew(k) = chNum;
    else
        [~,b] = fileparts(fullDir);
        fprintf(['\t\t\t No Data for ' b ' found\n'])
    end
end

c = 1;
indx = and(ap,nsew);
if sum(indx); Data2Plot(c) = concatScottData(allLoaded(indx)); c = c+1; end    % NS-amplitude
indx = and(ap,~nsew);
if sum(indx); Data2Plot(c) = concatScottData(allLoaded(indx)); c = c+1; end    % NS-amplitude
indx = and(~ap,nsew);
if sum(indx); Data2Plot(c) = concatScottData(allLoaded(indx)); c = c+1; end    % NS-amplitude
indx = and(~ap,~nsew);
if sum(indx); Data2Plot(c) = concatScottData(allLoaded(indx)); c = c+1; end    % NS-amplitude

% do actual plotting
f1 = CreateScott_SummaryPlot(Data2Plot,24);

function concatData = concatScottData(DataStruct)

%% Concatenate data for each GCP
if exist('DataStruct','var')
    %         keepIndices = find(
    startTimes = ([DataStruct.startTime]);
    dataLength = [DataStruct.len];
    allData = NaN*zeros(1,24*3600);
    for ii = 1:length(DataStruct)
        beginIndx = round(1+diff([floor(startTimes(1)) startTimes(ii)])*24*3600);
        allData(beginIndx:beginIndx+dataLength(ii)-1) = DataStruct(ii).data;
    end
    %debug check:
    % figure; plot(1:length(allData),20*log10(allData),eventWThresh,20*log10(allData(eventWThresh)),'ro')
    concatData = DataStruct(1);
    concatData.data = allData;
    concatData.len = length(allData);
    concatData.startTime = floor(DataStruct(1).startTime); % floored so that we start at the beginning of the day
end

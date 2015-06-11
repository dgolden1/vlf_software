% =========================================================================
% Inputs:
%       plotData:   Structure of data of arbitrary length.  Will Plot all 
%                   data passed in on the same plot.
%       Example of plotData
%                Tx: 'NAA'
%              data: [1x43200 double]
%         startTime: 7.365804166666667e+004
%                fs: 1
%             abrev: 'CH'
%           station: 'Cheyenne'
%               len: 43200
%      eventWThresh: [1x30 double]  % indices of "events" with good SNR
%     eventNoThresh: [1x100 double] % indices of "events"
%
%       plotLength: lenght of time in Hours of the plot, generate enough
%                   plots to plot entire dataset
% Outputs:
%       figHdl:    Handle to figure(s) figHdl = [numFigs x numTxPlots]
%
% Date Created:     February, 2010
% Date Modified:    
% =========================================================================

% $Id$

function figHdl = CreateScott_SummaryPlot(plotData,plotLength)
if ~exist('plotLength','var'); plotLength = 24; end
if ~exist('plotData','var'); error('Must input loaded data to plot'); end

myFont = 'Times';
myFontSize = 16;
myTitleFontSize = 18;
maxTxPerPlot = 4; % max number of "pannels" per figure (if there are more the function will create multiple figures)

lenA = max([plotData.len]);
fs = plotData(1).fs; % assume all have the same sample frequency

% determine the number of figures (ie for 12 hrs of data, and plotLength of
% 2 hrs, we will create 6 figures of 2 hours each
numFigs = ceil(lenA/(fs*plotLength*3600));
if isnan(numFigs)
    numFigs = 1;
    eachFigLength = lenA;
    plotLength = lenA/fs/3600;
else
    eachFigLength = fs*plotLength*3600;
end

%% Setup for figure(s):
% dimensions of the plot
totalPlotHeight = .8;		% w.r.t. the entire figure
bottomMarginHeight = .1;	% w.r.t. the entire figure
PlotMarginRatio = 19;		% height ratio of the subplot to interplot margins

numTxPlots = ceil(length(plotData)/maxTxPerPlot);
for kk = 1:numTxPlots
    txIndices{kk,:} = kk:numTxPlots:length(plotData); %#ok<AGROW>
end

figHdl = zeros(numFigs,numTxPlots); % matrix for all created figures
for jj = 1:numTxPlots % Biggest Loop...count number of plots

numPlots = length(txIndices{jj,:});

left = .05;
bottom = linspace(totalPlotHeight,0,numPlots+1);
bottom = bottom(2:end) + totalPlotHeight*(bottomMarginHeight + 1/numPlots/PlotMarginRatio);
width = .9;
height = totalPlotHeight/numPlots * PlotMarginRatio/(PlotMarginRatio+1);

for ii = 1:numFigs % main Loop, plot each figure (hour)
%% now plot all data:
% Create the figure and set it off the screen for faster "rendering"
f1 = sfigure(1); clf(f1); figHdl(ii,jj) = f1;

% figure_grow(f1, 2, 2);

c = 1; % counter for subplots
for k = txIndices{jj,:} % main Loop...plot each subplot (GCP)
    currData = plotData(k).data;
    isAmp = plotData(k).isAmp;
    fs = plotData(k).fs;
    subplotHdl = subplot('position',[left bottom(c) width height]);
    Tx = [plotData(k).Tx];
    currDate = plotData(k).startTime;

    dataRange = [(ii-1)*eachFigLength+1, min(ii*eachFigLength,length(currData))];
    if diff(dataRange) < 10;
        return;
    end
    
    if isAmp;
        [databit,datarate] = FiltSummaryData(...
            currData(dataRange(1):dataRange(2)),fs);
        fs = fs*datarate;
        plotDataBit = 20*log10(databit);
        plot(0:length(databit)-1,plotDataBit); hold on;
        ylabel('Amplitude (dB)','fontSize',myFontSize,'fontName',myFont)

    else
        databit = unwrap(currData(dataRange(1):dataRange(2))*pi/180);
%         databit = (currData(dataRange(1):dataRange(2)));
        [databit,datarate] = FiltSummaryData(...
            databit,fs);
        fs = fs*datarate;
        plot(0:length(databit)-1,(databit));
        ylabel('Phase (deg)','fontSize',myFontSize,'fontName',myFont)
    end
    
%    apstr = char(112-isAmp*15); % string to designate amplitude/phase ('a' or 'p')
	if isAmp, apstr = 'ampl'; else, apstr = 'phase'; end
    % put transmitter-receiver note on the plot
%    text(0,0,[Tx apstr],...
    text(0,0,sprintf('%s %s/%s %s', Tx(3:end), Tx(1), Tx(2), apstr),...
        'units','normalized','position',[.01 .8], ...
        'fontsize',14,'fontname','times','color','red');
    axis tight
	grid on;
    
    % create the x-axis ticks (6 per figure right now)
    nTicks = 6;
    dt = (floor(length(databit)/nTicks));
    if dt == 0; dt = 1; end
    xAxis = 0:dt:length(databit);
    xAxis(end) = xAxis(end)-1;
    xAxis = unique(xAxis);

    set(gca,'XTick',xAxis,'FontName',myFont,...
        'FontSize',myFontSize)
    if c<numPlots
        set(subplotHdl,'xticklabel',[])
        if (c==1) % put title information above first plot
			title_str = sprintf('Stanford VLF  %s  Narrowband Summary  %s', ...
				plotData(k).station, datestr(currDate+(ii-1)*plotLength/24/2, 'yyyy mmm dd'));
            title(title_str,'fontsize',myTitleFontSize,'fontname',myFont)
        end;
    else %on bottom plot put the axis
        xAxis(end) = xAxis(end)+1;
        set(gca,'XTickLabel',datestr(datenum(plotData(k).startTime)...
            + xAxis/24/3600/fs + (dataRange(1)-1)*datarate/fs/24/3600,15),...
            'FontName',myFont,'FontSize',myFontSize);
        xlabel('Time (UT)','fontsize',myFontSize,'fontname',myFont);
    end
%     set(subplotHdl,'fontname',myFontName,'fontsize',myFontSize);
    c = c+1; % location of bottom of "subplot"
end %main loop do each subplot

end % number of different plots of same time (i.e. plotting more than maxTxPerPlot transmitters
end % loop over numFigs (i.e. how many figs to make 24 hrs)


%% Additional Functions:

%% FiltSummaryData
function [databit,datarate] = FiltSummaryData(databit,datarate)

%============================================================
% Determine data samplerate settings.
order = ceil(length(databit)/3600); %(keep f=1 info);
% order = ceil(length(databit)/2500);
databit = blockAvgData(databit,order);
datarate = datarate/order;

%% blockAverageData
function dataOut = blockAvgData(dataIn,N)
if N==1
    dataOut = dataIn;
    return
end
M = floor(length(dataIn)/N);
dataOut = reshape(dataIn(1:M*N),N,M)';
dataOut = median(dataOut,2);
if ne(M*N,length(dataIn))
    dataOut = [dataOut; median(dataIn(M*N+1:end))];
end

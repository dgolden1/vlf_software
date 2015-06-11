%% Narrowband proccessing
% % you can comment out this and next cells if do not need narrowband
% % proccesing

% % FirstFrequency
% NarrowbandCenterF = 613;
% PulseLength = 0.9; %s
% StartOffset = 0; %s
% Period = 1; %s
% 
% Duration = round(StopSec-StartSec); %s
% PulseLengthIndex = round(PulseLength*SampleFreq/NFFT); %for numoverlap = 0
% StartOffsetIndex = round(StartOffset*SampleFreq/NFFT);
% PeriodIndex = round(Period*SampleFreq/NFFT);
% [waste, NarrowbandCenterFIndex] = min(abs(SpecFreq-NarrowbandCenterF));
% [waste, MaxTindex] = size(Espectr);
% PulseEfield = [];
% for t = StartOffset:Duration-2
%     ti_start = 1 + round(t*SampleFreq/NFFT);
%     ti_end = round((t+PulseLength)*SampleFreq/NFFT);
%     PulseEfield = [PulseEfield, mean(sqrt(sum(abs(Espectr(NarrowbandCenterFIndex-1:NarrowbandCenterFIndex+1,ti_start:ti_end)).^2,1))/NFFT)];
% end
% 
% % Plot narrowband
% FirstTickInd = 3;
% TickIntervInd = 4;
% TimeVector = 1:Duration-1;
% StartIndex = find(TimeSec == StartSec);
% StopIndex = find(TimeSec == StopSec);
% DistHAARP = round(deg2km(distance(DataMatrix(StartIndex+1:StopIndex-1,7),DataMatrix(StartIndex+1:StopIndex-1,8),62.4*ones(length(DataMatrix(StartIndex+1:StopIndex-1,7)),1),214.8*ones(length(DataMatrix(StartIndex+1:StopIndex-1,7)),1))));
% TimeTickVector = TimeVector(FirstTickInd:TickIntervInd:end);
% DistHAARPTickVector = DistHAARP(FirstTickInd:TickIntervInd:end);
% 
% TickVector = TimeTickVector;
% XaxisText = 'Serial number of the averaged second';
% 
% % for time ticks on x axis uncomment next block
% TickVector = DistHAARPTickVector;
% XaxisText = 'Distance from HAARP, km';
% 
% fig01 = figure('Position',[0 50 1280 400],'Color','white')
% area(TimeVector,PulseEfield,'BaseValue',0.1,'FaceColor','r','EdgeColor','r','LineWidth',2);
% set(gca,'YScale','log');
% %semilogy(PulseEfield,'.-');
% xlim([TimeVector(1) TimeVector(end)])
% ylim([0.1 30]);
% % axis([1 length(DistHAARP) 0.1 50])
% ylabel('E_{aver}, microvolt/meter')
% xlabel(XaxisText)
% % %fig0 = plot(PulseEfield);
% grid on
% % set(gca,'XTick',FirstTickInd:TickInterv:length(DistHAARP))
% set(gca,'XTick',TimeTickVector)
% set(gca,'XTickLabel',TickVector)
% set(gca,'TickDir','out')
% set(gca,'TickLength',[0.005 0])
% % set(gca,'XTickLabel',[])
% % for i = FirstTickInd:TickInterv:length(DistHAARP)
% %     text(i,0.05,num2str(DistHAARP(i),3),'Rotation',90)
% % end
% Title([datestr(TimeMatrix(1:6)',1),' from ',datestr(datenum([0,0,0,0,0,WaveTimeSec(StartIndexEfield)+StartOffset]),13),...
%     ' to ',datestr(datenum([0,0,0,0,0,WaveTimeSec(StartIndexEfield)+StartOffset+Duration]),13),...
%     ' UTC',', f = ',num2str(NarrowbandCenterF),' Hz, \Deltaf = ',num2str(deltaF,3),' Hz'])
% 
% 
% 
% % SecondFrequency
% NarrowbandCenterF2 = 2011;
% PulseLength = 0.9; %s
% StartOffset = 0; %s
% Period = 1; %s
% Duration = round(StopSec-StartSec);
% PulseLengthIndex = round(PulseLength*SampleFreq/NFFT); %for numoverlap = 0
% StartOffsetIndex = round(StartOffset*SampleFreq/NFFT);
% PeriodIndex = round(Period*SampleFreq/NFFT);
% [waste, NarrowbandCenterFIndex] = min(abs(SpecFreq-NarrowbandCenterF2));
% [waste, MaxTindex] = size(Espectr);
% PulseEfield = [];
% for t = StartOffset:Duration-2
%     ti_start = 1 + round(t*SampleFreq/NFFT);
%     ti_end = round((t+PulseLength)*SampleFreq/NFFT);
%     PulseEfield = [PulseEfield, mean(sqrt(sum(abs(Espectr(NarrowbandCenterFIndex-1:NarrowbandCenterFIndex+1,ti_start:ti_end)).^2,1))/NFFT)];
% end
% 
% % Plot narrowband
% FirstTickInd = 4;
% TickIntervInd = 4;
% TimeVector = 1:Duration-1;
% StartIndex = find(TimeSec == StartSec);
% StopIndex = find(TimeSec == StopSec);
% DistHAARP = round(deg2km(distance(DataMatrix(StartIndex+1:StopIndex-1,7),DataMatrix(StartIndex+1:StopIndex-1,8),62.4*ones(length(DataMatrix(StartIndex+1:StopIndex-1,7)),1),214.8*ones(length(DataMatrix(StartIndex+1:StopIndex-1,7)),1))));
% TimeTickVector = TimeVector(FirstTickInd:TickIntervInd:end);
% DistHAARPTickVector = DistHAARP(FirstTickInd:TickIntervInd:end);
% 
% TickVector = TimeTickVector;
% XaxisText = 'Serial number of the averaged second';
% 
% % for time ticks on x axis uncomment next block
% TickVector = DistHAARPTickVector;
% XaxisText = 'Distance from HAARP, km';
% 
% fig02 = figure('Position',[0 550 1280 400],'Color','white')
% area(TimeVector,PulseEfield,'BaseValue',0.1,'FaceColor','r','EdgeColor','r','LineWidth',2);
% set(gca,'YScale','log');
% %semilogy(PulseEfield,'.-');
% xlim([TimeVector(1) TimeVector(end)])
% ylim([0.1 5]);
% % axis([1 length(DistHAARP) 0.1 50])
% ylabel('E_{aver}, microvolt/meter')
% xlabel(XaxisText)
% % %fig0 = plot(PulseEfield);
% grid on
% % set(gca,'XTick',FirstTickInd:TickInterv:length(DistHAARP))
% set(gca,'XTick',TimeTickVector)
% set(gca,'XTickLabel',TickVector)
% set(gca,'TickDir','out')
% set(gca,'TickLength',[0.005 0])
% % set(gca,'XTickLabel',[])
% % for i = FirstTickInd:TickInterv:length(DistHAARP)
% %     text(i,0.05,num2str(DistHAARP(i),3),'Rotation',90)
% % end
% Title([datestr(TimeMatrix(1:6)',1),' from ',datestr(datenum([0,0,0,0,0,WaveTimeSec(StartIndexEfield)+StartOffset]),13),...
%     ' to ',datestr(datenum([0,0,0,0,0,WaveTimeSec(StartIndexEfield)+StartOffset+Duration]),13),...
%     ' UTC',', f = ',num2str(NarrowbandCenterF2),' Hz, \Deltaf = ',num2str(deltaF,3),' Hz'])



%% Exporting DEMETER VLF 1137 to mat file
% File: export_DEMETER_1137.m
% -------------------------------------------------------------------------
% Output:
%
% mat and png files in the working directory
% 
% Input:
% Data file in working directory
% DMT_N1_1137_*.DAT
% 
% ------------------------------------------------------------------------- 
% Author: Denys Piddyachiy (depi@stanford.edu)
%
% -------------------------------------------------------------------------

clear all
close all

%% Initial parameters
logmin = -9; % just for plotting. Does not affect exporting of data
logmax = -7;
Units = 'log(nT^{2}/Hz)';

%% Exporting
display('BEGINNING OF PROCCESSING===================================================')
ReadDataFile_1137;
save('VLF_B_spectrum_1137.mat',...
'PowerSpectrum','Units','SpectrumSecond','SpectrumFrequency',...
'LatSpline','LongSpline','AltSpline','LThourSpline','LSpline',...
'-mat')
display('B-field Power Spectrum is saved to "VLF_B_spectrum_1137.mat"')

%% Map plotting
% Parameters
MinLat = -90;
MaxLat = 90;
MinLong = -180;
MaxLong = 180;

Ncircles = 10;
LocOfIntLat = 62.39;
LocOfIntLong = 214.85;

load coast

fig01 = figure('Position',[200 200 800 600],'DefaultAxesFontSize',14);
h = worldmap([MinLat MaxLat],[MinLong MaxLong]);
setm(h,'mapprojection','bsam');
title(['DEMETER ',...
     datestr(datenum(Year,Month,Day,0,0,0),1), ' ',...
     datestr(datenum(0,0,0,0,0,SpectrumSecond(1)),13),' - ',...
     datestr(datenum(0,0,0,0,0,SpectrumSecond(end)),13),' UT'])

% Plot coastline
plotm(lat,long,'k-')

% % 100-km circles around a location of interest (LocOfIntLat,LocOfIntLong)
% plotm(LocOfIntLat, LocOfIntLong,'b','Marker','o','MarkerSize',4,'MarkerFaceColor','c');
% for i = 1:Ncircles
%     sca = scircle1(LocOfIntLat, LocOfIntLong, i*0.898); %circle of r = 0.898 degree (100 km)
%     linem(sca(:,1), sca(:,2),'g','LineWidth',1); %plot of this circle
% end

%DEMETER path
linem(ppval(LatSpline,SpectrumSecond),ppval(LongSpline,SpectrumSecond),'r-','LineWidth',2)

set(findall(gcf, '-Property', 'FontSize'), 'FontSize', 14);

%% Plotting
fig02 = figure('Position',[100 100 800 600],'DefaultAxesFontSize',14);
spectrplot = imagesc(SpectrumSecond,SpectrumFrequency/1000,PowerSpectrum',[logmin,logmax]);
axis xy;
xlabel('UT');
ylabel('Frequency [kHz]');
title(['DEMETER - Onboard spectrogram of B-field component (df = ',...
     num2str(FrequencyResolution,3),' Hz), ',...
     datestr(datenum(Year,Month,Day,0,0,0),1)])
XTickOrig = get(gca,'XTick');
set(gca,'XTickLabel',datestr(datenum(0,0,0,0,0,XTickOrig),13))
%set(gca,'XTickLabel',time2str(XTickOrig,'24','hms','sec'))
 
h1=colorbar;
set(get(h1,'YLabel'),'String',Units)
set(h1,'YAxisLocation', 'right')
set(gca,'TickDir','out')
%set(gca,'TickLength',[0.01 0])

set(findall(gcf, '-Property', 'FontSize'), 'FontSize', 14);

%% Saving of figure into .png files
StartTimeToPrint = datestr(datenum(Year,Month,Day,0,0,SpectrumSecond(1)),'yyyy-mm-dd_HH.MM.SS');
StopTimeToPrint = datestr(datenum(Year,Month,Day,0,0,SpectrumSecond(end)),'yyyy-mm-dd_HH.MM.SS');
set(fig01,'PaperPositionMode','auto')
print(fig01, '-zbuffer', '-r300','-dpng',['DEMETER_map_',StartTimeToPrint,'_',StopTimeToPrint,'.png'])
set(fig02,'PaperPositionMode','auto')
print(fig02, '-zbuffer', '-r300','-dpng',['DEMETER_VLF_B_spectrum_1137_',StartTimeToPrint,'_',StopTimeToPrint,'.png'])
display('Figures have been saved as png')

cd('C:\VLF_DAQ\VLFData\Narrowband')
[filename0, pathname, filterindex] = uigetfile('.mat', 'Amplitude filename');


cd(pathname)
channel_sampling_freq0 =matGetVariable(filename0,'Fs',1,0);
fclose all;
data_amp = matGetVariable(filename0, 'data',999999999,0);
fclose all;
callsign0 = filename0(15:17);
start_day0 = matGetVariable(filename0,'start_day',1,0);
fclose all;
start_hour0 = matGetVariable(filename0,'start_hour',1,0);
fclose all;
start_minute0 = matGetVariable(filename0,'start_minute',1,0);
fclose all;
start_month0 = matGetVariable(filename0,'start_month',1,0);
fclose all;
start_second0 = matGetVariable(filename0,'start_second',1,0);
fclose all;
start_year0 = matGetVariable(filename0,'start_year',1,0);
fclose all;
station_name0=matGetVariable(filename0,'station_name',11,0);
fclose all;
startdate0 = datenum(start_year0, start_month0,  start_day0, start_hour0, start_minute0, start_second0);
fclose all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[filename1, pathname, filterindex] = uigetfile('.mat', 'Phase filename');
cd(pathname)

channel_sampling_freq1 = matGetVariable(filename1,'Fs',1,0);
fclose all;
data_phase = matGetVariable(filename1, 'data',999999999,0);
fclose all;
callsign1 = filename1(15:17);
start_day1 = matGetVariable(filename1,'start_day',1,0);
fclose all;
start_hour1 = matGetVariable(filename1,'start_hour',1,0);
fclose all;
start_minute1 = matGetVariable(filename1,'start_minute',1,0);
fclose all;
start_month1 = matGetVariable(filename1,'start_month',1,0);
fclose all;
start_second1 = matGetVariable(filename1,'start_second',1,0);
fclose all;
start_year1 = matGetVariable(filename1,'start_year',1,0);
fclose all;
station_name1=matGetVariable(filename1,'station_name',11,0);
fclose all;
startdate1 = datenum(start_year1, start_month1,  start_day1, start_hour1, start_minute1, start_second1);

figure;

subplot(2,1,1);
plot((1:length(data_amp))/channel_sampling_freq0/60,data_amp)
axis xy;
ylabel('Amplitude','FontSize',16)
title_text=sprintf(' %s %s Amplitude',datestr(startdate0,'dd-mmm-yyyy'),callsign0);
title([char(station_name0) title_text],'FontSize',18);
xlabel(sprintf('Time (minutes) after %s UT',datestr(startdate0,13)),'FontSize',16);
%axis0 = get(gca,'CurrentAxes');
set(gca,'FontSize',16)

subplot(2,1,2);
plot((1:length(data_phase))/channel_sampling_freq1/60,data_phase)
axis xy;
ylabel('Phase (degrees)','FontSize',16)
title_text=sprintf(' %s %s Phase',datestr(startdate1,'dd-mmm-yyyy'),callsign1);
title([char(station_name1) title_text],'FontSize',18);
xlabel(sprintf('Time (minutes) after %s UT',datestr(startdate1,13)),'FontSize',16);
%axis1 = get(gca,'CurrentAxes');
set(gca,'FontSize',16)

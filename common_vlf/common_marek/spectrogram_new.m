%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quick  tool for creating spectrograms from Matlab workspace data files jpegs
% Works with MatGEtVariable.m and MatReadHeader.m
%Author: Mark Golkowski
%Stanford University
%Nominal use is intended for two files from a single site, (N/S, E/W
%antennas) however, files from different sites and times can also be input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



cd('E:\EzVLF')                               %Specify path
filename0 = 'PA070325133500_002.mat';        % specify file name for first file
filename1 = 'PA070325133500_003.mat';        % specify file name for second file

start_sec0 =0*60;		 		                 % start second for each file
start_sec1=0*60;
stop_sec0 = start_sec0+30;                       %end second  for each file
stop_sec1=start_sec1+30;								 

low_freq = .1;								 	 % Lower frequency bound in kHz
high_freq =1;                                    % Upper Frequency Bound in kHz
fignum=5;                                        % Figure number

downsample=1;                                     %If you desire to downsample the data to
new_freq=12500 %in Hz                             %new_freq make downsample =1 



NFFT=1024;                                      %Fourier Transform length, 
window=hamming(NFFT/2,'periodic');              %Window length
                                                % these determines frequency
                                                % and time resolution


calfac_ns=1;                    %Calibration factors in case you want spectrogram in DB-pT, if not just leave as 1
calfac_ew=1;                        


%%%%% For optional extracting specific frequencies (mixing down and filtering)
% need to have extract_freq.m
mix=0;              %yes or no
new_freq2=12500;    % additional downsampling if possible
fmix=[2010];        %frequency to extract
bw=20;              %one-sided bandwidth for low pass filter, 
ntaps=1024          %taps for low pass filtering, set to zero if don't want filtering

%%%%% For optional hum filtering 
filter_hum=0; % yes or no
fhum=1860; % hum harmonic to use as estimate for actual hum frequency
n2=4*1024; %number of taps for hum filter 

%%%%% For optional arrival azimuth and eccentricity spectrogram 
azimuth=0; %yes or no

% Shouldn't need to touch code below here unless you are a MATLAB jockey
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Read in variables from data files 

channel_sampling_freq0 =matGetVariable(filename0,'Fs',1,0);
channel_sampling_freq1 =matGetVariable(filename1,'Fs',1,0);
%channel_sampling_freq=[100000 100000];
fclose all;

start_day0 = matGetVariable(filename0,'start_day',1,0);
fclose all;
start_day1 = matGetVariable(filename1,'start_day',1,0);
fclose all;
start_hour0 = matGetVariable(filename0,'start_hour',1,0);
fclose all;
start_hour1 = matGetVariable(filename1,'start_hour',1,0);
fclose all;
start_minute0 = matGetVariable(filename0,'start_minute',1,0);
fclose all;
start_minute1 = matGetVariable(filename1,'start_minute',1,0);
fclose all;
start_month0 = matGetVariable(filename0,'start_month',1,0);
fclose all;
start_month1 = matGetVariable(filename1,'start_month',1,0);
fclose all;
start_second0 = matGetVariable(filename0,'start_second',1,0);
fclose all;
start_second1 = matGetVariable(filename1,'start_second',1,0);
fclose all;
start_year0 = matGetVariable(filename0,'start_year',1,0);
fclose all;
start_year1 = matGetVariable(filename1,'start_year',1,0);
fclose all;

station_name0 = matGetVariable(filename0,'station_name',11,0);
fclose all;
station_name1 = matGetVariable(filename1,'station_name',11,0);
fclose all;
adc_channel0 = matGetVariable(filename0,'adc_channel_number',11,0);
fclose all;
adc_channel1 = matGetVariable(filename1,'adc_channel_number',11,0);
fclose all;

data_ns = matGetVariable(filename0, 'data',(stop_sec0-start_sec0)*channel_sampling_freq0,start_sec0*channel_sampling_freq0);
fclose all;
data_ew = matGetVariable(filename1, 'data',(stop_sec1-start_sec1)*channel_sampling_freq1,start_sec1*channel_sampling_freq1);
fclose all;
data_ns=data_ns.*calfac_ns;
data_ew=data_ew.*calfac_ew;
if calfac_ns==1
    label='(rel)'; Cmin=-20;Cmax=40
else
    label='pT'; Cmin=-50; Cmax=10;
end

gps_quality0  = matGetVariable(filename0,'gps_quality',11,0);
gps_quality1  = matGetVariable(filename1,'gps_quality',11,0);
char(gps_quality0);
char(gps_quality1);

%filter and downsample
%Most data is sampled at 100kHz, for looking at frequencies below 10kHz
%such a high resolution is not necessary and is very computationaly
%expensive, here we downsample to 12500 Hz

if downsample==1
    
    ndata_ns = resample(data_ns,new_freq,100000);
    ndata_ew = resample(data_ew,new_freq,100000);
    
else

    new_freq=channel_sampling_freq0(1);
    ndata_ns = data_ns;
    ndata_ew = data_ew;
end
clear data_ns;
clear data_ew;

if filter_hum==1
            %Estimate exact frequency of hum
            NS=20*log(abs(fftshift(fft(ndata_ns))));
            EW=20*log(abs(fftshift(fft(ndata_ew))));

            df=new_freq/length(ndata_ew);
            freq=[-new_freq/2:df:new_freq/2-df]';

            f1860=round(length(ndata_ns)/2+fhum/df);
            [peak_ns ind_ns]=max(NS(f1860-20:f1860+20));
            [peak_ew ind_ew]=max(EW(f1860-20:f1860+20));
            f_ns=freq(f1860-20+ind_ns)/(fhum/60);
            f_ew=freq(f1860-20+ind_ew)/(fhum/60);
            [f_ns f_ew]
            Mult1=f_ns*[floor(low_freq*1000/60):ceil(high_freq*1000/60)]; %Chistochina 59.92
            Mult2=f_ew*[floor(low_freq*1000/60):ceil(high_freq*1000/60)]; %Valdez 60.05
            jj=1;
            clear Wn1; clear Wn2;
            for ik=1:length(Mult1)
                Wn1(jj)=Mult1(ik)-2.0-ik*.08;
                Wn1(jj+1)=Mult1(ik)+2.0+ik*.08;
                Wn2(jj)=Mult2(ik)-2.0-ik*.08;
                Wn2(jj+1)=Mult2(ik)+2.0+ik*.08;
                jj=jj+2;
            end
            hfs=new_freq/2;
            Wn1=Wn1./hfs;
            Wn2=Wn2./hfs;
           % n2=floor(length(ndata_ns)/3-100);

            B1=fir1(n2,Wn1,'stop');
            B2=fir1(n2,Wn2,'stop');
           

            ndata_ns=filtfilt(B1,1,ndata_ns);
            ndata_ew=filtfilt(B2,1,ndata_ew);

end

ndata_ns=ndata_ns-mean(ndata_ns);
ndata_ew=ndata_ew-mean(ndata_ew);



%specgram of downsampled data, this is a matlab function that automatically
%does short time FFT's 
[B1, F1, T1] = specgram(ndata_ns,NFFT,new_freq,window,[]);

[B2, F2, T2] = specgram(ndata_ew,NFFT,new_freq,window,[]);


%Covert to dB 
COUT1 = 20*log10(abs(B1)./(sum(window)/2));
COUT2 = 20*log10(abs(B2)./(sum(window)/2));

clear B1;
clear B2;

%Code to elegantly represent the start time 
%For jpeg title, 
start_second_temp0=start_second0+start_sec0;
  hour0=start_hour0;
if start_second_temp0>59
    second0=rem(start_second_temp0,60);
    minute0=start_minute0+floor(start_second_temp0/60);
    if minute0>59
        minute0=minute0-60;
        hour0=start_hour0+1;
    end
else
    second0=start_second_temp0;
    minute0=start_minute0;
    hour0=start_hour0;
end

start_second_temp1=start_second1+start_sec1;
  hour1=start_hour1;
if start_second_temp1>59
    second1=rem(start_second_temp1,60);
    minute1=start_minute1+floor(start_second_temp1/60);
    if minute1>59
        minute1=minute1-60;
        hour1=start_hour1+1;
    end
else
    second1=start_second_temp1;
    minute1=start_minute1;
    hour1=start_hour1;
end

jpegtitle=sprintf('%02d%02d%02d%02d%02d',mod(start_year0,10),start_month0,start_day0,hour0,minute0,0);
startdate0 = datenum(start_year0 , start_month0,  start_day0, hour0, minute0, 0);
startdate1 = datenum(start_year1 , start_month1,  start_day1, hour1, minute1, 0);

%extract_freq;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Here we make the plots

figure(fignum);
subplot(2,1,1)
imagesc(T1+second0,F1/1000,COUT1,[Cmin,Cmax]); %These last two numbers in brackets are the colorscale
                                       %this is important in how the plot
                                       %looks, we want to set them to
                                       %illustrate the signals we want most
                                       %clearly

axis xy;
colormap(jet);
a = axis;
axis([a(1) a(2) low_freq high_freq]);


title([station_name0 sprintf(' %s UT   %s Antenna',datestr(startdate0,'dd-mmm-yyyy'),'N/S')],'FontSize',14);
xlabel(sprintf('Time (seconds) after %s UT',datestr(startdate0,13)),'FontSize',14);
ylabel('Frequency (kHz)','FontSize',14);
set(gca,'FontSize',16)
colorbar;
h=colorbar;
set(get(h,'XLabel'),'String',['dB-' label],'FontSize',16)
set(h,'XAxisLocation', 'top')

set(h,'FontSize',16)


subplot(2,1,2)
imagesc(T2+second1,F2/1000,COUT2,[Cmin,Cmax]);
axis xy;
colormap(jet);

a = axis;
axis([a(1) a(2) low_freq high_freq]);


title([station_name1 sprintf(' %s UT   %s Antenna',datestr(startdate1,'dd-mmm-yyyy'),'E/W')],'FontSize',14);
xlabel(sprintf('Time (seconds) after %s UT',datestr(startdate1,13)),'FontSize',14);
ylabel('Frequency (kHz)','FontSize',14);
set(gca,'FontSize',16)
colorbar
h=colorbar;
set(get(h,'XLabel'),'String',['dB-' label],'FontSize',16)
set(h,'XAxisLocation', 'top')

set(h,'FontSize',16)

if azimuth==1
    j=sqrt(-1);
  A0=ndata_ns+j*ndata_ew;
 
  [mags0,ecc0,angles0,F0,T0] = specgram_azimuth(A0,NFFT,new_freq,hamming(NFFT/4,'periodic'),NFFT/8);


  figure(2)
  subplot(211)
  imagesc(T0+second0,F0,180/pi*angles0,[-90,90]);
  axis xy;
 colormap(jet);
 a = axis;
 axis([a(1) a(2) low_freq*1000 high_freq*1000]);
 title([station_name0 sprintf(' %s   Arrival Azimuth',datestr(startdate1,'dd-mmm-yyyy'))],'FontSize',14);
 h=colorbar;
 set(get(h,'XLabel'),'String','Angle','FontSize',14)
 set(h,'XAxisLocation', 'top')
subplot(212)
 imagesc(T0+second0,F0,ecc0,[.5,1]);
 axis xy;
colormap(jet);
a = axis;
axis([a(1) a(2) low_freq*1000 high_freq*1000]);
title([station_name0 sprintf(' %s  Eccentricity',datestr(startdate1,'dd-mmm-yyyy'))],'FontSize',14);

h=colorbar;
set(get(h,'XLabel'),'String','Ecc','FontSize',14)
set(h,'XAxisLocation', 'top')

  
end

if mix==1
   
     data_ns=resample(ndata_ns,new_freq2,new_freq);
     data_ew=resample(ndata_ew,new_freq2,new_freq);
     fchan1=extract_freq(ndata_ns,fmix,new_freq2,bw,ntaps);
     fchan2=extract_freq(ndata_ew,fmix,new_freq2,bw,ntaps);
      dchan1=resample(2*(abs(fchan1)), 25, new_freq2);
        dchan2=resample(2*(abs(fchan2)), 25, new_freq2);
     combined=sqrt((2*(abs(fchan1))).^2+(2*(abs(fchan2))).^2);
        combined=resample(combined,25,new_freq2);
        dt=1/new_freq2;
        dt2=1/25;
        t1=[0+second1:dt:round((stop_sec0-start_sec0)+second1)-dt];
        t2=[0+second1:dt2:round((stop_sec0-start_sec0)+second1)-dt2];
     figure(2)
       subplot(311)
    plot(t1,2*(abs(fchan1)));set(gca,'FontSize',14);axis([t1(1) t1(end) 0  6*median(dchan1)]);ylabel(label);title([station_name0 sprintf(' %s UT %s ',datestr(startdate0,'dd-mmm-yyyy'),'N/S') num2str(round(2*bw)) ' Hz bandwidth Around ' num2str(fmix/1000) 'kHz'],'FontSize',14);grid on;
    hold on; plot(t2, medfilt1(dchan1,20),'r', 'LineWidth', 2);hold off;
    subplot(312)
    plot(t1,2*(abs(fchan2)));set(gca,'FontSize',14);axis([t1(1) t1(end) 0 6*median(dchan2)]);ylabel(label);title([station_name0 sprintf(' %s UT %s ',datestr(startdate0,'dd-mmm-yyyy'),'E/W') num2str(round(2*bw)) ' Hz bandwidth Around ' num2str(fmix/1000) 'kHz'],'FontSize',14);grid on;
    hold on; plot(t2, medfilt1(dchan2,20),'r', 'LineWidth', 2);hold off;
    subplot(313)
    plot(t1,sqrt((2*(abs(fchan1))).^2+(2*(abs(fchan2))).^2));hold on; 

    plot(t2, medfilt1(combined,20),'r', 'LineWidth', 2);
    axis([t1(1) t1(end) 0 6*median(combined)]);set(gca,'FontSize',14);ylabel(label);title(['Combined Channel Amplitude ' num2str(round(2*bw)) ' Hz bandwidth Around ' num2str(fmix/1000) 'kHz'],'FontSize',14);
    xlabel(sprintf('Time (seconds) after %s UT',datestr(startdate0,13)),'FontSize',14);grid on;hold off;
    %mkdir('E:\Broadband JPEGs\',station_name0);
    %mkdir(['E:\Broadband JPEGs\' station_name0 '\'],[datestr(startdate1,11) datestr(startdate1,5) datestr(startdate1,7)])
    % mkdir(['E:\Broadband JPEGs\' station_name0 '\' datestr(startdate1,11) datestr(startdate1,5) datestr(startdate1,7) '\'],['m' num2str(fmix)])
%jpegtitle2=['E:\Broadband JPEGs\' station_name0 '\' datestr(startdate1,11) datestr(startdate1,5) datestr(startdate1,7) '\' 'm' num2str(fmix) '\m' jpegtitle];
 %set(3,'PaperPosition',[0.25 2.5 10 5])
 %print('-djpeg', jpegtitle2)
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Save the figure as a jpeg for later viewing

 %jpegtitle=['C:\Documents and Settings\Mark Golkowski\My Documents\Alaska_Site_Setup\Chistochina\' jpegtitle];
 %jpegtitle=['D:\Chisto_jpegs\direction\' jpegtitle];

 %set(3,'PaperPosition',[0.25 2.5 10 5])
 %print('-djpeg', jpegtitle)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% df=new_freq/length(ndata_ew);
% freq=[-new_freq/2:df:new_freq/2-df]';
% figure(10)
% subplot(211)
% plot(freq,20*log(abs(fftshift(fft(ndata_ns)))))
% title('Frequency spectrum N/S')
% subplot(212)
% plot(freq,20*log(abs(fftshift(fft(ndata_ew)))))
% title('Frequency spectrum E/W')
% xlabel('Frequency (Hz)')


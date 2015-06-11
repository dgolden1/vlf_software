function htf = plot_specgram_azimuth_2ch(dataStruct,NFFT,dbMin,dbMax,db_thr,figureNo,addTimeFreq);
%syntax: htf = plot_specgram_azimuth_2ch(dataStruct,NFFT,dbMin,dbMax,db_thr,figureNo,addTimeFreq);
%
%Expected fields in dataStruct: example:
% dataStruct = 
%             data: [2x500000 double]
%               Fs: 100000
%        startTime: [2006 6 29 19 1 7.0000]
%     station_name: [6x1 char]
%            units: 'raw'
%
%NFFT: fft length for each column
%dbMin: minumum dB value to plot in magnitude respose
%dbMax: maximum dB value to plot in magnitude response
%db_thr: minimum magnitude in db for azimuth and eccentricity calculation
%Note: 2^15-1 = 90.3 dB
%
%addTimeFreq: 0 to plot 3 images, 1 to plot the first with
%time and frequency plots, 2 to plot the second with time and frequency
%plots, 3 to plot the third with time and frequency plots, -1 to plot only
%magnitude

%add specgram parameters to dataStruct attached to figure figureNo;
dataStruct.NFFT = NFFT;
dataStruct.dbMin = dbMin;
dataStruct.dbMax = dbMax;
dataStruct.db_thr = db_thr;
figure(figureNo);clf; 
set(figureNo,'UserData',dataStruct);

if(addTimeFreq==2);
   colormap(myColormap('azimuth'));
else
   colormap(myColormap('magWithWhite')); 
   colormap('jet');
end

z = dataStruct.data(1,:) + sqrt(-1)*dataStruct.data(2,:);

win = hanning(NFFT);
noverlap = NFFT/2;
noverlap = round(NFFT*5/6);

[mags,ecc,angles,F,T] = specgram_azimuth(z,NFFT,dataStruct.Fs,win,noverlap);

if(round(addTimeFreq)~=addTimeFreq | addTimeFreq>3 | addTimeFreq < -1)
    addTimeFreq=0;  %in case addTimeFreq is not -1,0, 1, 2, or 3
end

if(addTimeFreq==-1)
    ax = subplot(1,1,1);
    htf = ax;
elseif(addTimeFreq==0);   
    ax(1) = subplot(311);
    htf = ax(1);
elseif(addTimeFreq==1)
    htf = time_freq_tfd_structure(z,dataStruct.Fs,win,dbMin,dbMax,dataStruct.units,['dB' dataStruct.units],figureNo);
    axes(htf);
end

if(addTimeFreq==0 | addTimeFreq==1 | addTimeFreq==-1)
	imagesc(T,F/1e3,20*log10(mags/sum(win)),[dbMin,dbMax]); axis xy;    %sets CDataMapping to scaled, Clim to [dbMin,dbMax]
	xlabel(['Seconds after ' datevecToString(dataStruct.startTime) ' [UT]'])
	ylabel('Frequency [kHz]')
	title(['Signal magnitude: ' dataStruct.station_name(:)']);
end

if(addTimeFreq==0 | addTimeFreq==-1)
    h = colorbar;
    setColorbarTitle(h,['dB' dataStruct.units])
end


if(addTimeFreq==0)
    ax(2) = subplot(312);
elseif(addTimeFreq==2)
    htf = time_freq_tfd_structure(z,dataStruct.Fs,win,-91,90,dataStruct.units,'\theta [deg]',figureNo);
    axes(htf);
end

if(addTimeFreq==0 | addTimeFreq==2)
	angles = mod180(angles*180/pi)*pi/180; angles(find(20*log10(mags/sum(win))<db_thr)) = -91;
	imagesc(T,F/1e3,angles*180/pi,[-91,90]); axis xy;
	title(['Arrival Azimuth, Threshold = ' num2str(db_thr) ' [dB' dataStruct.units ']']);
	xlabel(['Seconds after ' datevecToString(dataStruct.startTime) ' [UT]'])
	ylabel('Frequency [kHz]')
end

if(addTimeFreq==0)
	h = colorbar;
	setColorbarTitle(h,'\theta [deg]');
end

if(addTimeFreq==0)
    ax(3) = subplot(313);
elseif(addTimeFreq==3)
    htf = time_freq_tfd_structure(z,dataStruct.Fs,win,.95,1+eps,dataStruct.units,'Maj/Min [.]',figureNo);
    axes(htf);
end

if(addTimeFreq==0 | addTimeFreq==3)
	ecc(find(20*log10(mags/sum(win))<db_thr)) = NaN;
	imagesc(T,F/1e3,(1-ecc.^2).^(-1/2),[0,10]); axis xy;
	title(['Maj/Min axis, Threshold = ' num2str(db_thr) ' [dB' dataStruct.units ']']);
	xlabel(['Seconds after ' datevecToString(dataStruct.startTime) ' [UT]'])
	ylabel('Frequency [kHz]')
end

if(addTimeFreq==0)
	h = colorbar;
	setColorbarTitle(h,'Maj/Min [.]')
end

if(addTimeFreq==0)
   linkaxes(ax);
end
   

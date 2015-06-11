function [tfdAxis,timeAxis,freqAxis] = plot_specgramRA_irr_grid_2ch(dataStruct,NFFT,dbMin,dbMax,db_thr,figureNo,addTimeFreq);
%syntax: [tfdAxis,timeAxis,freqAxis] = plot_specgramRA_irr_grid_2ch(dataStruct,NFFT,dbMin,dbMax,db_thr,figureNo,addTimeFreq);
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

z = dataStruct.data(1,:) + sqrt(-1)*dataStruct.data(2,:);

window = hamming(NFFT);
noverlap = NFFT/2;
[mags,angles,ecc,F,T,F_RA,T_RA] = specgramRA_cmplx(z,NFFT,dataStruct.Fs,window,noverlap);
mags = 20*log10(mags/(sum(window)));

if(round(addTimeFreq)~=addTimeFreq | addTimeFreq>3 | addTimeFreq < 0)
    addTimeFreq=0;  %in case addTimeFreq is not 0, 1, 2, or 3
end

if(addTimeFreq==0);
    figure(figureNo);clf;
    subplot(211);
elseif(addTimeFreq==1)
    [tfdAxis,timeAxis,freqAxis] = time_freq_tfd_structure(z,dataStruct.Fs,window,dbMin,dbMax,dataStruct.units,['dB' dataStruct.units],figureNo);
    axes(tfdAxis);
end

magst = mags;
if(addTimeFreq==0 | addTimeFreq==1);
    mags(find(mags < dbMin)) = NaN;
    scatter3(T_RA(:),F_RA(:)/1e3,mags(:),5,mags(:),'filled');
    colormap(myColormap);
    caxis([dbMin,dbMax]);
    axis([0,(max(size(dataStruct.data))-1)/dataStruct.Fs,0,dataStruct.Fs/2/1e3,dbMin,dbMax])
    view(0,90);
    xlabel(['Time (s) after ' datevecToString(dataStruct.startTime) ' [UT]'])
    ylabel('Frequency [kHz]')
    title([dataStruct.station_name(:)' '.  Reassigned Spectrogram - 2 channel']);
end

if(addTimeFreq==0)
    h = colorbar;
    setColorbarTitle(h,['dB' dataStruct.units])
end


if(addTimeFreq==0)
    subplot(212);
elseif(addTimeFreq==2)
     [tfdAxis,timeAxis,freqAxis] = time_freq_tfd_structure(z,dataStruct.Fs,window,-93,90,dataStruct.units,'\theta [deg]',figureNo);
    axes(tfdAxis);
end


if(addTimeFreq==0 | addTimeFreq==2)
    colormap(myColormap);
    angles(find(magst < db_thr)) = NaN;
    scatter3(T_RA(:),F_RA(:)/1e3,angles(:)*180/pi,5,angles(:)*180/pi,'filled');
    caxis([-93,90]);
    axis([0,(max(size(dataStruct.data))-1)/dataStruct.Fs,0,dataStruct.Fs/2/1e3,min(angles(:)*180/pi),max(angles(:)*180/pi)])
    view(0,90);
    xlabel(['Time (s) after ' datevecToString(dataStruct.startTime) ' [UT]'])
    ylabel('Frequency [kHz]')
    title(['Reassigned Azimuths, 2-channel, dB cutoff = ' num2str(db_thr) ' [dB' dataStruct.units ']']);
end

if(addTimeFreq==0)
    h = colorbar;
    setColorbarTitle(h,'\theta [deg]');
end


% 
% if(addTimeFreq==0)
%     subplot(313);
% elseif(addTimeFreq==3)
%     [tfdAxis,timeAxis,freqAxis] = time_freq_tfd_structure(z,dataStruct.Fs,window,.95,1+eps,dataStruct.units,'Maj/Min [.]',figureNo);
%     axes(tfdAxis);
% end
% 
% if(addTimeFreq==0 | addTimeFreq==3)
%     colormap(myColormap);
%     ecc(find(mags < db_thr)) = NaN;
%     M_m = (1-ecc.^2).^(-1/2);
%     scatter3(T_RA(:),F_RA(:)/1e3,M_m(:),5,M_m(:),'filled');
%     caxis([1,40]);
%     axis([0,(max(size(dataStruct.data))-1)/dataStruct.Fs,0,dataStruct.Fs/2/1e3,0,1])
%     view(0,90);
%     xlabel(['Time (s) after ' datevecToString(dataStruct.startTime) ' [UT]'])
%     ylabel('Frequency [kHz]')
%     title(['Reassigned Maj/Min ratio, 2-channel, dB cutoff = ' num2str(db_thr) ' [dB' dataStruct.units ']']);
% end
% 
% if(addTimeFreq==0)
%     h = colorbar;
%     setColorbarTitle(h,'Maj/Min [.]')
% end

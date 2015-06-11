function [tfdAxis,timeAxis,freqAxis] = time_freq_tfd_structure(x,Fs,window,tfdMin,tfdMax,units,tfdunits,figureNo);
%syntax: [tfdAxis,timeAxis,freqAxis] = time_freq_tfd_structure(x,Fs,window,tfdMin,tfdMax,units,tfdunits,figureNo);
%
%Plots time and frequency domain of signal x and creates the axes for
%plotting a time-frequency display plot in the calling function.  

figure(figureNo); clf;
timeWidth = .55;
freqHeight = .55;
bottomStart = .1;
timeStart = .3;

cmplexFlag = 0;
if(any(imag(x)))
    cmplexFlag = 1;
end

%Time domain
timeAxis = axes('Position',[timeStart,.73,timeWidth,.2]);
if(cmplexFlag)
    plot(timeAxis,[0:length(x)-1]/Fs,abs(x));
    ylabel(['|Magnitude| [' units ']']);
else
    plot(timeAxis,[0:length(x)-1]/Fs,x);
    ylabel(['[' units ']']);
end
axis([0,max(size(x))/Fs,ylim]);
hold on; plot(timeAxis,[0:length(window)-1]/Fs,window*max(abs(x)),'r'); hold off;
xlabel('Time [s]'); grid on;

%Freq domain:
freqAxis = axes('Position',[.1,bottomStart,.15,freqHeight]);
tempNFFT = 2^nextpow2(length(x));
W = fft(window,tempNFFT);
if(cmplexFlag)
    [mags,ecc,angles,phi,ff] = bb_azimuth_calc_freq2(x,tempNFFT,Fs);
    XdB = 20*log10(mags/length(x));
    WdB = 20*log10(abs(W(2:tempNFFT/2)));
else
    X = fft(x,tempNFFT);
    ff = [0:tempNFFT/2-1]/tempNFFT*Fs;
    XdB = 20*log10(abs(X(1:tempNFFT/2))) - 20*log10(length(x)/2);
    WdB = 20*log10(abs(W(1:tempNFFT/2)));
end

WdB = WdB -max(WdB)+max(XdB);
WdB(find(WdB < max(WdB) - 50)) = NaN;
%plot(freqAxis,ff/1e3,XdB,ff/1e3,WdB,'r'); grid on;
%axis([0,Fs/2/1e3,max(XdB)-70,max(XdB)])
plot(freqAxis,XdB,ff/1e3,WdB,ff/1e3,'r'); grid on;
axis([max(XdB)-70,max(XdB),0,Fs/2/1e3]);
ylabel('Frequency [kHz]')
xlabel(['[dB' units ']']);
%set(freqAxis,'View',[-90,90]);

%Time-Freq domain:
tfdAxis = axes('Position',[timeStart,bottomStart,timeWidth,freqHeight]);
%insert time-freq domain image in calling function

%Link time axes:
linkaxes([timeAxis,tfdAxis],'x');
%Link freq axes:
linkaxes([freqAxis,tfdAxis],'y');

%colorbar:
colorbarAxis = axes('Position',[timeStart + timeWidth + .02,bottomStart,.04,freqHeight],'Visible','off');
imagesc(1,1,1); %trick so that I can use caxis;
caxis([tfdMin,tfdMax]);
colorbar(colorbarAxis);
title(colorbarAxis,[tfdunits]);

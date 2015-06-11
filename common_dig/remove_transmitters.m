function [NS_clean,EW_clean] = remove_transmitters(NS,EW,fs,scaleCh1,scaleCh2,samplesToDelayCh2,plotFlag);
%syntax: [NS_clean,EW_clean] = remove_transmitters(NS,EW,fs,scaleCh1,scaleCh2,samplesToDelayCh2,plotFlag);
%
%Inputs:
%NS - NS channel (row vector)
%EW - EW channel (row vector)
%fs - sampling frequency [samples/sec]
%scaleCh1 - amount to scale NS channel by (may be just 1)
%scaleCh2 - amount to scale EW channel by
%samplesToDelayCh2 - corrects for sampling offset (usually ~.5)
%plotFlag - set to 0 for no plotting, set to >0 to plot NB channel
%selection on plot plotFlag.  
%
%Outputs:
%NS_clean - NS channel with NB channels removed (low frequencies still present)
%EW_clean - EW channel with NB channels removed (low frequencies still present)
%
% ---- Ryan Said, 8/7/2006 ----

dataStruct.data(1,:) = NS;
dataStruct.data(2,:) = EW;
dataStruct.Fs = fs;


data_clean = remove_transmitters_helper(dataStruct,scaleCh1,scaleCh2,samplesToDelayCh2,plotFlag);
NS_clean = data_clean.data(1,:);
EW_clean = data_clean.data(2,:);


function data_clean = remove_transmitters_helper(dataStruct,scaleCh1,scaleCh2,samplesToDelayCh2,plotFlag);


plotFlagNBFreqs = plotFlag;

dataStruct = calibrateData(dataStruct,scaleCh1,scaleCh2,samplesToDelayCh2);

fc = 2000; M = 300; rail_limit = 1.8; plotFlag = 0;
railedData = hpFilt_rail(dataStruct,fc,M,rail_limit,plotFlag);

fmin = 2e3; db_thr = 5; nfft_max = 2^11; 
[freqs,A] = findNarrowbandFreqs(railedData,fmin,nfft_max,db_thr,plotFlagNBFreqs);

%Notch filter to isolate NB transmitters:
plotFlag = 0;%Note: in notches_filter, choose fft of filter method
BW = 300;%[Hz]
trnsmttrs_only = notches_filter(railedData,freqs,BW*ones(size(freqs)),plotFlag);

data_clean = subtract_signals(dataStruct,trnsmttrs_only);


function dataStructa = subtract_signals(dataStructa,dataStructb)
%syntax: dataStructC = subtract_signals(dataStructa,dataStructb)
%result is c = a - b;

dataStructa.data = dataStructa.data - dataStructb.data;

     
     
     
function dataStruct = notches_filter(dataStruct,freqs,widths,figureNo);
%syntax: dataStruct = notches_filter(dataStruct,freqs,widths,figureNo);

fc(1:2:2*length(freqs)-1) = freqs - widths/2;
fc(2:2:2*length(freqs)) = freqs + widths/2;

%if two segments overlap, just combine:
remove = find(diff(fc)<0);
remove = [remove,remove + 1];
z = ones(1,length(fc));
z(remove) = 0;
fc = fc(find(z==1));


if(0)
    %method 1: full FFT
    L = size(dataStruct.data,2);
    N = 2^nextpow2(L);
    H = 1-idealFreqFilter(fc,dataStruct.Fs,N,0,'nnotch');
    %         Nh = 4*1024;
    %         H =
    %         real(fft(ifft(H).*fftshift([zeros((N-Nh)/2,1);hamming(Nh);zeros((N-Nh)/2,1)]')));
    for ii = 1:size(dataStruct.data,1)
        temp = real(ifft(fft(dataStruct.data(ii,:),N).*H));
        dataStruct.data(ii,:) = temp(1:L);
    end
    if(figureNo>0)
        figure(figureNo); clf;
        f = [0:N-1]/N*dataStruct.Fs;   %[Hz]
        plot(f/1e3,H); xlabel('f [kHz]');
    end

else

    %method 2: window:
    N = 2^10;
    b = fir1(N,fc/dataStruct.Fs*2,'DC-0');
    for ii = 1:size(dataStruct.data,1);
        dataStruct.data(ii,:) = fftfilt_ND(b,dataStruct.data(ii,:));
    end
    if(figureNo>0)
        figure(figureNo); clf;
        freqz(b,1,2*N,dataStruct.Fs)
    end
end     
     
     
function dataStruct = hpFilt_rail(dataStruct,fc,M,rail_limit,plotFlag);
%syntax: dataStruct = hpFilt_rail(dataStruct,fc,M,rail_limit,plotFlag);
%
%rail_limit is in units of the standard deviation of the HP filtered data
%
%plotFlag: 0 to not plot filter response, >0 to plot filter response on
%figure plotFlag and plotFlag + 1.  
%
%Performs HP filter and limit on each row in dataStruct.data

%filter:
DF = 50;
h_hp = firFilter(fc,DF,dataStruct.Fs,M,'highpass',0,0);

for ii = 1:size(dataStruct.data,1)
    dataStruct.data(ii,:) = fftfilt_ND(h_hp,dataStruct.data(ii,:));
    railLim = rail_limit*sqrt(var(dataStruct.data(ii,:)));
    dataStruct.data(ii,find(dataStruct.data(ii,:) > railLim)) = railLim;
    dataStruct.data(ii,find(dataStruct.data(ii,:) < -railLim)) = -railLim;
end
     
     
function dataStruct = calibrateData(dataStruct,h1,h2,delayCh2);
%syntax: dataStruct = calibrateData(dataStruct,h1,h2,delayCh2);
%
%h1: filter coefficients for channel 1 filter (scalar for just a scaling)
%h2: filter coefficients for channel 2 filter (scalar for just a scaling)
%delayCh2: number of samples to delay channel 2
%
%---- Ryan Said, 8/3/2006 ----

%For delay of channel 2 filter:
M = 400;
plotFlag = 0;

dataStruct.data(1,:) = fftfilt_ND(h1,dataStruct.data(1,:));
dataStruct.data(2,:) = fftfilt_ND(...
    conv(h2,firFilterWithOffset(0,0,dataStruct.Fs,M,delayCh2,'allpass',plotFlag,0)),...
    dataStruct.data(2,:));


function y = fftfilt_ND(h,x)
%syntax: y = fftfilt_ND(h,x)
%
%fft filt but with no delay
%
% ---- Ryan Said ----

%h must be odd:
M = length(h);
if(~mod(M,2))
    error('Error: h must have odd number of taps');
end

y = fftfilt(h,x);
if(size(x,1) > size(x,2)) %column
    y = [y((M+1)/2:length(y));zeros((M-1)/2,1)];
else    %row
    y = [y((M+1)/2:length(y)),zeros(1,(M-1)/2)];
end


function h = firFilterWithOffset(fc,df,fs,M,delay,filterType,plotFlag,equiripple)
%syntax: h = firFilterWithOffset(fc,df,fs,M,delay,filterType,plotFlag,equiripple)
%
%Example:
%h = firFilter([300,1500],20,100000,1000,'bandpass',1,0);
%
%fc is cutoff frequencies
%df is transition bandwidth
%fs is sample frequency
%M is filter length
%delay is the extra amount to delay (-1 < delay < 1)
%Filter type: lowpass, highpass, bandpass, or allpass
%plotFlag: 0 for no plot, >0 to plot on figure plotFlag.  
%equiripple = 1, then use equiripple, otherwise use fir2 (uses hamming window)
%
%returns filter response h, where length(h) = M + 1;
%M must be even (type I filter)
%Will have delay of M/2

switch filterType
    case 'allpass'
        h = [zeros(1,M/2),1,zeros(1,M/2)];
    case 'lowpass'
        if(length(fc)~=1)
            error('fc needs to have length 1 for lowpass filters')
        end
        wp = (fc - df/2)*2/fs;  %*pi rad/sample
        ws = (fc + df/2)*2/fs;  %*pi rad/sample
        if(equiripple)
            h = FIRPM(M,[0,wp,ws,1],[1,1,0,0]);
        else
            h = fir2(M,[0,wp,ws,1],[1,1,0,0]);
        end

    case 'highpass'
        if(length(fc)~=1)
            error('fc needs to have length 1 for highpass filters')
        end
        ws = (fc - df/2)*2/fs;  %*pi rad/sample
        wp = (fc + df/2)*2/fs;  %*pi rad/sample
        if(equiripple)
            h = FIRPM(M,[0,ws,wp,1],[0,0,1,1]);
        else
            h = fir2(M,[0,ws,wp,1],[0,0,1,1]);
        end
    case 'bandpass'
        if(length(fc)~=2)
            error('fc needs to have length 2 for bandpass filters')
        end
        ws1 = (fc(1) - df/2)*2/fs;
        wp1 = (fc(1) + df/2)*2/fs;
        wp2 = (fc(2) - df/2)*2/fs;
        ws2 = (fc(2) + df/2)*2/fs;
        if(equiripple)
            h = FIRPM(M,[0,ws1,wp1,wp2,ws2,1],[0,0,1,1,0,0]);
        else
            h = fir2(M,[0,ws1,wp1,wp2,ws2,1],[0,0,1,1,0,0]);
        end
    otherwise
        error('Not a valid filter type')
end

m = length(h);
%generate phase factor for extra delay
N = 2^(nextpow2(m));
Hphase = idealFreqFilter(fc,fs,N,delay,'allpass');
h = real(ifft(fft(h,N).*Hphase));
h = h(1:m);

if(plotFlag>0)
    figure(plotFlag); clf;
    [H,W,s] = freqz(h,1,2^(nextpow2(M)+1),fs);
    freqzplot(H,W,s)
    subplot(211)
    title([filterType ' filter, fc = (' num2str(fc) ') [Hz], \Delta f = ' num2str(df) ' [Hz], number of taps = ' num2str(M+1)]);
    axis([xlim,-70,10])
    figure(plotFlag+1); clf;
    plot(W,-fs/(2*pi*(W(2)-W(1)))*[0;diff(unwrap(angle(H)))]);
    axis([xlim,M/2 - 2,M/2+2])
    xlabel('Frequency [Hz]')
    ylabel('-d(\phi)/d\omega = delay [samples]')
    grid on;
    pause;
end



function H = idealFreqFilter(fc,fs,N,delay,filterType)

%returns H in fft format
%N must be a power of 2
%use only for entire sequence lengths less than or equal to N.  

H = ones(1,N);

phaseFactor = ifftshift(exp(-sqrt(-1)*2*pi*delay*[-N/2:N/2-1]/N));

switch filterType
case 'allpass'
    ;
case 'lowpass'
    if(length(fc)~=1)
        error('fc needs to have length 1 for lowpass filters')
    end
    index_c = round((fc/fs)*N + 1);
    H(1:index_c) = ones(1,index_c);
    H(index_c+1:N/2+1) = zeros(1,N/2+1-index_c);
    H(N/2+2:N) = H(N/2:-1:2);
case 'highpass'
    if(length(fc)~=1)
        error('fc needs to have length 1 for highpass filters')
    end
    index_c = round((fc/fs)*N + 1);
    H(1:index_c-1) = zeros(1,index_c-1);
    H(index_c:N/2+1) = ones(1,N/2+1-index_c+1);
    H(N/2+2:N) = H(N/2:-1:2);
case 'bandpass'
    if(length(fc)~=2)
        error('fc needs to have length 2 for bandpass filters')
    end
    index_c1 = round((fc(1)/fs)*N + 1);
    index_c2 = round((fc(2)/fs)*N + 1);
    H(1:max(1,index_c1-1)) = zeros(1,max(1,index_c1-1));
    H(index_c1:index_c2) = ones(1,index_c2-index_c1+1);
    H(index_c2+1:N/2+1) = zeros(1,N/2+1-index_c2);
    H(N/2+2:N) = H(N/2:-1:2);
case 'nnotch'    
    %notch out every range of fc, so fc must be multiple of 2
    %example: notch out fc(3) through fc(4)
    index_c = min(max(1,round((fc/fs)*N + 1)),N/2);
    for ii = 1:2:length(fc)
       H(index_c(ii):index_c(ii+1)) = 0;
    end
    H(N/2+2:N) = H(N/2:-1:2);
otherwise
    error('Not a valid filter type')
end

H = H.*phaseFactor;


function h = firFilter(fc,df,fs,M,filterType,plotFlag,equiripple)
%syntax: h = firFilter(fc,df,fs,M,filterType,plotFlag,equiripple)
%
%Example:
%h = firFilter([300,1500],20,100000,1000,'bandpass',1,0);
%
%fc is cutoff frequencies
%df is transition bandwidth
%fs is sample frequency
%M is filter length
%Filter type: lowpass, highpass, bandpass, or allpass
%plotFlag: 0 not to plot, >0 to plot on figure figureNo;
%equiripple = 1, then use equiripple, otherwise use fir2 (uses hamming window)
%
%returns filter response h, where length(h) = M + 1;
%M must be even (type I filter)
%Will have delay of M/2
%
%---- Ryan Said ----

switch filterType
    case 'allpass'
        h = [zeros(1,M/2),1,zeros(1,M/2)];
    case 'lowpass'
        if(length(fc)~=1)
            error('fc needs to have length 1 for lowpass filters')
        end
        wp = (fc - df/2)*2/fs;  %*pi rad/sample
        ws = (fc + df/2)*2/fs;  %*pi rad/sample
        if(equiripple)
            h = FIRPM(M,[0,wp,ws,1],[1,1,0,0]);
        else
            h = fir2(M,[0,wp,ws,1],[1,1,0,0]);
        end

    case 'highpass'
        if(length(fc)~=1)
            error('fc needs to have length 1 for highpass filters')
        end
        ws = (fc - df/2)*2/fs;  %*pi rad/sample
        wp = (fc + df/2)*2/fs;  %*pi rad/sample
        if(equiripple)
            h = FIRPM(M,[0,ws,wp,1],[0,0,1,1]);
        else
            h = fir2(M,[0,ws,wp,1],[0,0,1,1]);
        end
    case 'bandpass'
        if(length(fc)~=2)
            error('fc needs to have length 2 for bandpass filters')
        end
        ws1 = (fc(1) - df/2)*2/fs;
        wp1 = (fc(1) + df/2)*2/fs;
        wp2 = (fc(2) - df/2)*2/fs;
        ws2 = (fc(2) + df/2)*2/fs;
        if(equiripple)
            h = FIRPM(M,[0,ws1,wp1,wp2,ws2,1],[0,0,1,1,0,0]);
        else
            h = fir2(M,[0,ws1,wp1,wp2,ws2,1],[0,0,1,1,0,0]);
        end
    otherwise
        error('Not a valid filter type')
end


if(plotFlag>0)
    figure(plotFlag); clf;
    [H,W,s] = freqz(h,1,2^(nextpow2(M)+6),fs);
    freqzplot(H,W,s)
    subplot(211)
    title([filterType ' filter, fc = (' num2str(fc) ') [Hz], \Delta f = ' num2str(df) ' [Hz], number of taps = ' num2str(M+1)]);
    axis([xlim,-70,10])
    figure(plotFlag+1);clf;
    plot(W,-fs/(2*pi*(W(2)-W(1)))*[0;diff(unwrap(angle(H)))]);
    axis([xlim,M/2 - 2,M/2+2])
    xlabel('Frequency [Hz]')
    ylabel('-d(\phi)/d\omega = delay [samples]')
    grid on;
    pause;
end



function [freqs,A] = findNarrowbandFreqs(dataStruct,fmin,nfft_max,db_thr,plotFlag)
%syntax: [freqs,A] = findNarrowbandFreqs(dataStruct,fmin,nfft_max,db_thr,plotFlag)
%
%fmin: minimum frequency below which there are no channels [Hz]
%nfft_max: maximum fft length for each time snapshot

nspec = min(nfft_max,2^(nextpow2(size(dataStruct.data,2))-1));
noverlap = nspec/2;
win = hanning(nspec);

if(size(dataStruct.data,1)==1)  %one channel
    [X,F,T] = mySpecgram(dataStruct.data,nspec,dataStruct.Fs,win,noverlap,0);
    Amps = 20*log10(mean(abs(X')/sum(win)*2));
else    %two channels
    [B,ecc,angles,F,T] = specgram_azimuth(...
        dataStruct.data(1,:) + sqrt(-1)*dataStruct.data(2,:),...
        nspec,dataStruct.Fs,win,noverlap);
    %note: size(B) = num_freq_bins x num_time_bins
    Amps = 20*log10(eps + mean([zeros(1,size(B,2));B/sum(win)]'));
    F = [0;F];
end



[indicesP] = findLocalPeaks(Amps);
[indicesT] = findLocalTroughs(Amps);
allIndices = sort([indicesP,indicesT]);

allIndices = [1,allIndices,length(Amps)];

peak = [0];
jj = 1;
for ii = 2:length(allIndices)-1
    if(Amps(allIndices(ii)) > Amps(allIndices(ii-1))+db_thr &...
            Amps(allIndices(ii)) > Amps(allIndices(ii+1))+db_thr)
        peak(jj) = Amps(allIndices(ii));
        index(jj) = allIndices(ii);
        jj = jj + 1;
    end
end

for jj = 1:length(peak)
    alpha = Amps(index(jj)-1);
    beta = Amps(index(jj));
    gamma = Amps(index(jj)+1);
    p = .5*(alpha-gamma)/(alpha-2*beta+gamma);
    realIndices(jj) = index(jj) + p;
    realPeaks(jj) = beta - .25*(alpha-gamma)*p;
end

%convert realIndices into actual frequencies:
freqs = (realIndices-1)*dataStruct.Fs/nspec;   %[kHz]

%keep only peaks above fmin:
A = 10.^(realPeaks(find(freqs>fmin))/20);
freqs = freqs(find(freqs > fmin));


if(plotFlag>0)
    figure(plotFlag); clf;
    plot(F/1e3,Amps,F(allIndices)/1e3,Amps(allIndices),'.',...
        (realIndices-1)*dataStruct.Fs/nspec/1e3,realPeaks,'o',freqs/1e3,20*log10(A),'x');%F(index)/1000,peak,'o',
    axis([xlim,max(Amps)-60,max(Amps)+1]);
    legend('Averaged Magnitude','Peaks and troughs','Chosen (~exact) peaks')
    xlabel('Frequency [kHz]')
    ylabel('Amplitude [dB]')
    title(['Threshold = ' num2str(db_thr) ' [dB], NFFT = ' num2str(nspec) ...
        ', # time averages = ' num2str(length(T))]);
    grid on;
end


function [indices] = findLocalPeaks(x);

indices = find(x > [-inf,x(1:end-1)] & x >= [x(2:end),inf]);

if(indices(1)==1)
    indices = indices(2:end);
end
if(indices(end)==length(x))
    indices = indices(1:end-1);
end


function [indices] = findLocalTroughs(x);

indices = find(x < [-inf,x(1:end-1)] & x <= [x(2:end),-inf]);

if(length(indices)>0)
    if(indices(1)==1)
        indices = indices(2:end);
    end
    if(indices(end)==length(x))
        indices = indices(1:end-1);
    end
end

function [B,F,T] = mySpecgram(x,nfft,Fs,window,noverlap,fullFFTflag)
%syntax: [B,F,T] = mySpecgram(x,nfft,Fs,window,noverlap,fullFFTflag)
%accepts one channel (real) or complex channel

nx = length(x);
nwind = length(window);
if nx < nwind    % zero-pad x if it has length less than the window length
    x(nwind)=0;  nx=nwind;
end
x = x(:); % make a column vector for ease later
window = window(:); % be consistent with data set

ncol = fix((nx-noverlap)/(nwind-noverlap));
colindex = 1 + (0:(ncol-1))*(nwind-noverlap);
rowindex = (1:nwind)';
if length(x)<(nwind+colindex(ncol)-1)
    x(nwind+colindex(ncol)-1) = 0;   % zero-pad x
end

y = zeros(nwind,ncol);

% put x into columns of y with the proper offset
% should be able to do this with fancy indexing!
y(:) = x(rowindex(:,ones(1,ncol))+colindex(ones(nwind,1),:)-1);

% Apply the window to the array of offset signal segments.
y = window(:,ones(1,ncol)).*y;

% now fft y which does the columns
y = fft(y,nfft);
if ~any(any(imag(x))) & ~fullFFTflag    % x purely real and don't want full FFT
    select = 1:nfft/2+1;
    y = y(select,:);    %comment this out if want full FFT for real signals
else
    select = 1:nfft;
end
f = (select - 1)'*Fs/nfft;

%t = (colindex-1)'/Fs; ORIGINAL
t = ((colindex-1) + (nwind-1)/2)'/Fs;  %centered around window
B = y;
F = f;
T = t;

function [mags,ecc,angles,F,T] = specgram_azimuth(z,NFFT,Fs,win,noverlap);
%syntax: [mags,ecc,angles,F,T] = specgram_azimuth(z,NFFT,Fs,win,noverlap);
%
%computes magnitude, eccentricity, and angles [rad] of complex signal z in
%a time-frequency grid with time, frequency vectors given by T, F.  

[B,F,T] = mySpecgram(z,NFFT,Fs,win,noverlap,1);
angles = (angle(B(2:NFFT/2,:)) + angle(B(NFFT:-1:NFFT/2+2,:)))/2; %[rad]
mags = (abs(B(2:NFFT/2,:)) + abs(B(NFFT:-1:NFFT/2+2,:)));
mm = abs(abs(B(2:NFFT/2,:)) - abs(B(NFFT:-1:NFFT/2+2,:)));
ecc = sqrt(1-((mm+eps)./(mags+eps)).^2);%add eps so origin has ecc of 0 instead of NaN
F = F(2:NFFT/2);

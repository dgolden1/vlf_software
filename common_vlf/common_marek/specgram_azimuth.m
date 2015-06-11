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



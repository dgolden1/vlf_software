function [mags,ecc,angles,diff_delays,diff_delays_1c,F,T] = specgram_azimuth(z,NFFT,Fs,win,noverlap)
%syntax: [mags,ecc,angles,diff_delays,diff_delays_1c,F,T] = specgram_azimuth(z,NFFT,Fs,win,noverlap)
%
%computes magnitude, eccentricity, and angles [rad] of complex signal z in
%a time-frequency grid with time, frequency vectors given by T, F.  

[B,F,T] = mySpecgram(z,NFFT,Fs,win,noverlap,1);

angles = (angle(B(2:NFFT/2,:)) + angle(B(NFFT:-1:NFFT/2+2,:)))/2; %[rad]

delays = -diff(unwrap(angle(B(2:NFFT/2,:)) - angle(B(NFFT:-1:NFFT/2+2,:)))/2)/(Fs/NFFT)/(2*pi); % [sec]
diff_delays = [zeros(1, size(delays, 2)); diff(delays); zeros(1, size(delays, 2))]/(Fs/NFFT); % [sec/Hz]

delays_1c = -diff(unwrap(angle(B(2:NFFT/2,:)))/2)/(Fs/NFFT)/(2*pi); % [sec]
diff_delays_1c = [zeros(1, size(delays_1c, 2)); diff(delays_1c); zeros(1, size(delays_1c, 2))]/(Fs/NFFT); % [sec/Hz]

mags = (abs(B(2:NFFT/2,:)) + abs(B(NFFT:-1:NFFT/2+2,:)));

mm = abs(abs(B(2:NFFT/2,:)) - abs(B(NFFT:-1:NFFT/2+2,:)));

ecc = sqrt(1-((mm+eps)./(mags+eps)).^2); %add eps so origin has ecc of 0 instead of NaN

F = F(2:NFFT/2);

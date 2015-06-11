% function debug_synthetic_emissions
% A test function to synthesize some "canonical" chorus and hiss, and then
% to try to differentiate between them

% Canonical hiss: "broadband white noise carrier" at a few kHz with a few
%  100 Hz bandwidth
% Canonical chorus: same as hiss with ELF modulation of a few Hz

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

%% Setup
close all;
clear;

fs = 20e3; % Hz
t_max = 10; % sec
t = (0:1/fs:t_max).';

% Spectrogram parameters
nfft = 1024;
window = 1024;
noverlap = 512;

%% Make a lowpass filter to bandlimit hiss
Fpass = 100;    % Passband Frequency
Fstop = 250;    % Stopband Frequency
Apass = 1;      % Passband Ripple (dB)
Astop = 5;      % Stopband Attenuation (dB)
Fs    = 20000;  % Sampling Frequency
h = fdesign.lowpass('fp,fst,ap,ast', Fpass, Fstop, Apass, Astop, Fs);
Hlp_100hz = design(h, 'butter', 'MatchExactly', 'stopband');


%% Make some hiss
s = RandStream('mcg16807', 'Seed', 0); % Nice, replicatable results
RandStream.setDefaultStream(s);
hiss_baseband = randn(size(t)); % Full spectrum hiss

% Bandlimit
hiss_baseband = filter(Hlp_100hz, hiss_baseband);

% Mix up
hiss = hiss_baseband.*cos(2*pi*3000*t)*2;

figure;
spectrogram_dan(hiss, window, noverlap, nfft, fs);
caxis([-30 30])
xlabel('sec');
ylabel('Hz');
title('Synthetic hiss');
colorbar;

%% Make a lowpass filter for the chorus modulation
Fpass = 3;    % Passband Frequency
Fstop = 5;    % Stopband Frequency
Apass = 1;      % Passband Ripple (dB)
Astop = 10;     % Stopband Attenuation (dB)
Fs    = 20000;  % Sampling Frequency
h = fdesign.lowpass('fp,fst,ap,ast', Fpass, Fstop, Apass, Astop, Fs);
Hlp_5hz = design(h, 'butter', 'MatchExactly', 'stopband');

%% Apply modulation
s = RandStream('mcg16807', 'Seed', 83); % Nice, replicatable results
RandStream.setDefaultStream(s);
gaussian_elf_modulation = filter(Hlp_5hz, randn(size(t)))*sqrt((10e3/3));
chorus = hiss .* gaussian_elf_modulation;

figure;
spectrogram_dan(chorus, window, noverlap, nfft, fs);
caxis([-30 30])
xlabel('sec');
ylabel('Hz');
title('Synthetic hiss');
colorbar;

%% Recover modulation
[b, a] = cheby1(8, 0.05, 800/10000);
chorus_processed = filter(b, a, chorus.^2);
hiss_processed = filter(b, a, hiss.^2);

chorus_processed = chorus_processed - mean(chorus_processed);
hiss_processed = hiss_processed - mean(hiss_processed);

% Does the recovered modulation have a similar spectrum to the original
% modulation?

clear s;

figure;
s(1) = subplot(2, 1, 1);
pwelch(decimate(chorus_processed - mean(chorus_processed), fs/100), 64, 32, 64, 100);
title('Original');

s(2) = subplot(2, 1, 2);
pwelch(decimate(hiss_processed - mean(hiss_processed), fs/100), 64, 32, 64, 50);
title('Recovered');

linkaxes(s);

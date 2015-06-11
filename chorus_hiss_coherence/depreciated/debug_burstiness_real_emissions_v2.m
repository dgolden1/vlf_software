% function debug_burstiness_real_emissions_v2
% Debug some methods for determining burstiness from real emissions
% 
% Try in this version not to use a bandpass filter and do as much stuff as
% possible with decimated signals

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

%% Setup
close all;
clear;

% 2001 data
% chorus = load('/media/amundsen/user_data/dgolden/temp/palmer_bb_cleaned/2001/03_20/PA_2001_03_20T0535_05_002_cleaned.mat'); % 1.8-3.5 kHz
% hiss = load('/media/amundsen/user_data/dgolden/temp/palmer_bb_cleaned/2001/03_20/PA_2001_03_20T1135_05_002_cleaned.mat'); % 4-6 kHz
% hiss = load('/media/amundsen/user_data/dgolden/temp/palmer_bb_cleaned/2001/03_20/PA_2001_03_20T0005_05_002_cleaned.mat'); % 1.8-3 kHz

% 2003 data from my 2009 AGU poster
chorus = load('/media/scott/user_data/dgolden/palmer_bb_cleaned/2003/02_27/PA_2003_02_27T0850_05_002_cleaned.mat'); % 1.5-3 kHz
hiss = load('/media/scott/user_data/dgolden/palmer_bb_cleaned/2003/01_30/PA_2003_01_30T2205_05_002_cleaned.mat'); % 1.5-3.5 kHz


Fs = chorus.Fs;

%% Plot spectrograms

figure;
subplot(1, 2, 1);
spectrogram_dan(chorus.data(1:(20e3*3-1)), 1024, 512, 1024, Fs); caxis([25 70]);
title('Chorus');
subplot(1, 2, 2);
spectrogram_dan(hiss.data(1:(20e3*3-1)), 1024, 512, 1024, Fs); caxis([25 70]);
title('Hiss');

increase_font;

%% Filter
t = (0:length(chorus.data)-1).'/Fs;

% Mix to baseband (this overlaps the spectrum with a frequency-reversed
% version of itself)
chorus_cos = chorus.data .* cos(2*pi*2250*t);
hiss_cos = hiss.data .* cos(2*pi*2500*t);

% Decimate half as much as we need to to avoid aliasing when squaring the
% signal
chorus_dec_factor1 = ceil(Fs/1500/2);
hiss_dec_factor1 = ceil(Fs/2000/2);

% Filter out everything outside the emission; the decimate antialiasing
% filter will be too broad, since we decimated halfway to the emission
[b, a] = cheby1(8, 0.05, 0.8*1500/Fs);
chorus_cos = filter(b, a, chorus_cos);
[b, a] = cheby1(8, 0.05, 0.8*2000/Fs);
hiss_cos = filter(b, a, hiss_cos);

chorus_dec = decimate(chorus_cos, chorus_dec_factor1);
hiss_dec = decimate(hiss_cos, hiss_dec_factor1);

% Square and decimate again
chorus_dec_factor2 = floor(Fs/chorus_dec_factor1/100);
hiss_dec_factor2 = floor(Fs/hiss_dec_factor1/100);
chorus_sq = chorus_dec.^2;
hiss_sq = hiss_dec.^2;
chorus_sq_elf = decimate(chorus_sq - mean(chorus_sq), chorus_dec_factor2);
hiss_sq_elf = decimate(hiss_sq - mean(hiss_sq), hiss_dec_factor2);

%% Plot full spectrums
[P_chorus, f_full] = pwelch(chorus.data, 1024, 512, 1024, Fs);
P_hiss = pwelch(hiss.data, 1024, 512, 1024, Fs);

[P_chorus_dec, f_chorus_dec] = pwelch(chorus_dec, 1024, 512, 1024, Fs/chorus_dec_factor1);
[P_hiss_dec, f_hiss_dec] = pwelch(hiss_dec, 128, 64, 1024, Fs/hiss_dec_factor1);

[P_chorus_elf, f_chorus_elf] = pwelch(chorus_sq_elf, 128, 64, 1024, Fs/chorus_dec_factor1/chorus_dec_factor2);
[P_hiss_elf, f_hiss_elf] = pwelch(hiss_sq_elf, 128, 64, 1024, Fs/hiss_dec_factor1/hiss_dec_factor2);

% Normalize to 1
P_chorus_elf = P_chorus_elf/max(P_chorus_elf);
P_hiss_elf = P_hiss_elf/max(P_hiss_elf);

% Get ELF centroid
chorus_centroid = centroid(f_chorus_elf, P_chorus_elf);
hiss_centroid = centroid(f_hiss_elf, P_hiss_elf);

figure;
s(1) = subplot(3, 1, 1);
plot(f_full, 10*log10(P_chorus), f_full, 10*log10(P_hiss), 'LineWidth', 2);
grid on
ylim([-30 30])
ylabel('dB');
title('Original');
legend('Chorus', 'Hiss');

s(2) = subplot(3, 1, 2);
plot(f_chorus_dec, 10*log10(P_chorus_dec), f_hiss_dec, 10*log10(P_hiss_dec), 'LineWidth', 2);
grid on
ylim([-20 0]);
ylabel('dB');
title('Mixed and Decimated');

s(3) = subplot(3, 1, 3);
plot(f_chorus_elf, P_chorus_elf, f_hiss_elf, P_hiss_elf, 'LineWidth', 2);
hold on;
plot(chorus_centroid, interp1(f_chorus_elf, P_chorus_elf, chorus_centroid), '^', 'markerfacecolor', 'b', 'markersize', 8);
plot(hiss_centroid, interp1(f_hiss_elf, P_hiss_elf, hiss_centroid), '^', 'markerfacecolor', [0 0.5 0], 'markersize', 8);
grid on
ylabel('Power');
xlabel('Hz');
title('Squared and Decimated to ELF');

increase_font;
figure_grow(gcf, 1, 1.5);

% function debug_burstiness_real_emissions
% Debug some methods for determining burstiness from real emissions

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

%% Setup
close all;
clear;

% 2001 data
chorus = load('/media/amundsen/user_data/dgolden/temp/palmer_bb_cleaned/2001/03_20/PA_2001_03_20T0535_05_002_cleaned.mat'); % 1.8-3.5 kHz
% hiss = load('/media/amundsen/user_data/dgolden/temp/palmer_bb_cleaned/2001/03_20/PA_2001_03_20T1135_05_002_cleaned.mat'); % 4-6 kHz
hiss = load('/media/amundsen/user_data/dgolden/temp/palmer_bb_cleaned/2001/03_20/PA_2001_03_20T0005_05_002_cleaned.mat'); % 1.8-3 kHz

% 2003 data from my 2009 AGU poster
chorus = load('/media/scott/user_data/dgolden/palmer_bb_cleaned/2003/02_27/PA_2003_02_27T0850_05_002_cleaned.mat'); % 1.5-3 kHz
hiss = load('/media/scott/user_data/dgolden/palmer_bb_cleaned/2003/01_30/PA_2003_01_30T2205_05_002_cleaned.mat'); % 1.5-3.5 kHz

%% Bandpass for chorus
Fpass1 = 1500;   % First Passband Frequency
Fpass2 = 3000;   % Second Passband Frequency
Fstop1 = Fpass1 - 300;   % First Stopband Frequency
Fstop2 = Fpass2 + 300;   % Second Stopband Frequency
Astop1 = 60;     % First Stopband Attenuation (dB)
Apass  = 0.05;   % Passband Ripple (dB)
Astop2 = 60;     % Second Stopband Attenuation (dB)
Fs     = 20000;  % Sampling Frequency

h = fdesign.bandpass('fst1,fp1,fp2,fst2,ast1,ap,ast2', Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass, Astop2, Fs);
Hbp_chorus = design(h, 'cheby1', 'MatchExactly', 'passband');

%% Bandpass for hiss
Fpass1 = 1500;   % First Passband Frequency
Fpass2 = 3500;   % Second Passband Frequency
Fstop1 = Fpass1 - 300;   % First Stopband Frequency
Fstop2 = Fpass2 + 300;   % Second Stopband Frequency
Astop1 = 60;     % First Stopband Attenuation (dB)
Apass  = 0.05;   % Passband Ripple (dB)
Astop2 = 60;     % Second Stopband Attenuation (dB)
Fs     = 20000;  % Sampling Frequency

h = fdesign.bandpass('fst1,fp1,fp2,fst2,ast1,ap,ast2', Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass, Astop2, Fs);
Hbp_hiss = design(h, 'cheby1', 'MatchExactly', 'passband');

%% Plot spectrograms

figure;
subplot(1, 2, 1);
spectrogram_dan(chorus.data, 1024, 512, 1024, chorus.Fs); caxis([25 70]);
title('Chorus');
subplot(1, 2, 2);
spectrogram_dan(hiss.data, 1024, 512, 1024, chorus.Fs); caxis([25 70]);
title('Hiss');

increase_font;

%% Filter
chorus_bp = filter(Hbp_chorus, chorus.data);
hiss_bp = filter(Hbp_hiss, hiss.data);

% Square and remove DC
chorus_bp_sq = chorus_bp.^2;
chorus_bp_sq = chorus_bp_sq - mean(chorus_bp_sq);
hiss_bp_sq = hiss_bp.^2;
hiss_bp_sq = hiss_bp_sq - mean(hiss_bp_sq);

% Get ELF spectrums
chorus_elf = decimate(chorus_bp_sq, Fs/100);
hiss_elf = decimate(hiss_bp_sq, Fs/100);

%% Plot full spectrums
[P_chorus, f_full] = pwelch(chorus.data, 1024, 512, 1024, Fs);
P_hiss = pwelch(hiss.data, 1024, 512, 1024, Fs);
P_chorus_bp = pwelch(chorus_bp, 1024, 512, 1024, Fs);
P_hiss_bp = pwelch(hiss_bp, 1024, 512, 1024, Fs);
P_chorus_bp_sq = pwelch(chorus_bp_sq, 1024, 512, 1024, Fs);
P_hiss_bp_sq = pwelch(hiss_bp_sq, 1024, 512, 1024, Fs);

figure;
s(1) = subplot(2, 1, 1);
plot(f_full, 10*log10(P_chorus), f_full, 10*log10(P_chorus_bp), f_full, 10*log10(P_chorus_bp_sq), 'LineWidth', 2);
ylim([-30 20]);
grid on
ylabel('dB');
title('Chorus');
legend('Orig', 'BP Filt', 'BP-Squared');

s(2) = subplot(2, 1, 2);
plot(f_full, 10*log10(P_hiss), f_full, 10*log10(P_hiss_bp), f_full, 10*log10(P_hiss_bp_sq), 'LineWidth', 2);
ylim([-30 20]);
grid on
ylabel('dB');
xlabel('Hz');
title('Hiss');

increase_font;

%% Plot subsampled ELF spectrums
[P_chorus_elf, f_elf] = pwelch(chorus_elf, 128, 64, 1024, 100);
P_hiss_elf = pwelch(hiss_elf, 128, 64, 1024, 100);

% Normalize
P_chorus_elf = P_chorus_elf/max(P_chorus_elf);
P_hiss_elf = P_hiss_elf/max(P_hiss_elf);

chorus_centroid_lin = centroid(f_elf, P_chorus_elf);
hiss_centroid_lin = centroid(f_elf, P_hiss_elf);
chorus_centroid_log = centroid(f_elf, 10*log10(P_chorus_elf));
hiss_centroid_log = centroid(f_elf, 10*log10(P_hiss_elf));


figure;
s(1) = subplot(2, 1, 1);
plot(f_elf, 10*log10(P_chorus_elf), f_elf, 10*log10(P_hiss_elf), 'LineWidth', 2);
hold on;
plot(chorus_centroid_log, interp1(f_elf, 10*log10(P_chorus_elf), chorus_centroid_log), '^', 'markerfacecolor', 'b', 'markersize', 8);
plot(hiss_centroid_log, interp1(f_elf, 10*log10(P_hiss_elf), hiss_centroid_log), '^', 'markerfacecolor', [0 0.5 0], 'markersize', 8);
grid on;
ylabel('dB');
title(sprintf('Chorus centroid: %0.1f Hz, Hiss centroid: %0.1f Hz', ...
  chorus_centroid_log, hiss_centroid_log));
legend('Chorus', 'Hiss');

s(2) = subplot(2, 1, 2);
plot(f_elf, P_chorus_elf, f_elf, P_hiss_elf, 'LineWidth', 2);
hold on;
plot(chorus_centroid_lin, interp1(f_elf, P_chorus_elf, chorus_centroid_lin), '^', 'markerfacecolor', 'b', 'markersize', 8);
plot(hiss_centroid_lin, interp1(f_elf, P_hiss_elf, hiss_centroid_lin), '^', 'markerfacecolor', [0 0.5 0], 'markersize', 8);
grid on;
ylabel('power');
xlabel('Hz');
title(sprintf('Chorus centroid: %0.1f Hz, Hiss centroid: %0.1f Hz', ...
  chorus_centroid_lin, hiss_centroid_lin));

increase_font;

% Script to compare my and Jeremie's sferic removal methods
% Hopefully mine is better!

% By Daniel Golden (dgolden1 at stanford dot edu) August 2010
% $Id$

%% Setup
close all;
clear;

addpath(fullfile(danmatlabroot, 'vlf', 'jeremie_sferic_removal'));


%% Load and decimate data
BB = load('PA010415110505_002.mat'); % Has some chorus

data_dec = decimate(BB.data, 5);
data_dec = data_dec - mean(data_dec);
fs_dec = BB.Fs/5;

%% Highpass filter to remove slowtails
% load('Hhp_16600_fir.mat', 'Hhp'); % Passband > 500 Hz, Stopband < 300 Hz, Fs = 1e5/6 Hz, FIR = EXPENSIVE
% data_dec = filtfilt(Hhp.Numerator, 1, data_dec);

load('Hhp_20000.mat', 'Hhp'); % Passband > 500 Hz, Stopband < 300 Hz, Fs = 1e5/5 Hz, IIR = NONLINEAR PHASE
data_dec = filter(Hhp, data_dec);

%% My sferic removal
t_start = now;

thresh = 0.01;
[t_imp_start, t_imp_end, det_sig, det_fs, det_thresh] = find_sferics(BB.data, BB.Fs, thresh);
data_cleaned = remove_sferics(data_dec, fs_dec, t_imp_start, t_imp_end);

fprintf('Dan''s method: cleaned %d sferics in %s\n', length(t_imp_start), time_elapsed(t_start, now));

%% Jeremie's sferic removal
sf_rem_pulse_width = 40;
sf_rem_thresh = 20;

% Pass 1
t_start1 = now;
b_slowtail_filter = true;
imp_locs = find_impulse_locs(data_dec, sf_rem_pulse_width, sf_rem_thresh, fs_dec, b_slowtail_filter);
data_cleaned_j = remove_impulses(data_dec, imp_locs, 100, 100, sf_rem_pulse_width);

n1 = length(imp_locs);
fprintf('Pass 1: cleaned %d impulses (threshold=%d) in %s\n', length(imp_locs), sf_rem_thresh, time_elapsed(t_start1, now));

% Pass 2
t_start2 = now;
imp_locs = find_impulse_locs(data_cleaned_j, sf_rem_pulse_width, sf_rem_thresh/2, fs_dec, b_slowtail_filter);
data_cleaned_j = remove_impulses(data_cleaned_j, imp_locs, 100, 100, sf_rem_pulse_width);

n2 = length(imp_locs);
fprintf('Pass 2: cleaned %d impulses (threshold=%d) in %s\n', length(imp_locs), sf_rem_thresh/2, time_elapsed(t_start2, now));

fprintf('Jeremie''s method: cleaned %d sferics in %s\n', n1 + n2, time_elapsed(t_start1, now));

%% Plot results
% Spectrogram
s = [];

figure;
s(end+1) = subplot(3, 1, 1);
spectrogram_cal(data_dec, 512, 256, 512, fs_dec, 'palmer', 2003);
title('Original');

s(end+1) = subplot(3, 1, 2);
spectrogram_cal(data_cleaned, 512, 256, 512, fs_dec, 'palmer', 2003);
title('Dan Cleaned');

s(end+1) = subplot(3, 1, 3);
spectrogram_cal(data_cleaned_j, 512, 256, 512, fs_dec, 'palmer', 2003);
title('Jeremie Cleaned');

increase_font(gcf, 14);
linkaxes(s);

% Periodograms
[p_original, f] = pwelch(data_dec, 512, 256, 512, fs_dec);
p_dan = pwelch(data_cleaned, 512, 256, 512, fs_dec);
p_jeremie = pwelch(data_cleaned_j, 512, 256, 512, fs_dec);

figure;
plot(f, 10*log10(p_original), f, 10*log10(p_dan), f, 10*log10(p_jeremie), 'LineWidth', 2);
xlabel('Hz');
ylabel('PSD (dB/Hz)');
grid on;
legend('Original', 'Dan cleaned', 'Jeremie cleaned', 'location', 'best');
increase_font;

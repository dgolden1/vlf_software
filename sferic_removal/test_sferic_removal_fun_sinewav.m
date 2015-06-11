function test_sferic_removal_fun_sinewav(p)
% Script to test my sferic removal functions with a sine wave

% By Daniel Golden (dgolden1 at stanford dot edu) August 2010
% $Id$

%% Setup
% clear;

b_debug = true;

if b_debug
%   close all;
  s = []; % Vector of handles to axes
end

%% Create some sample data
% Pure cosine at 3 kHz
fs_bb = 1e5;
t_data_bb = (0:1/fs_bb:0.2).';
% data_bb = t_data_bb;
% data_bb = cos(2*pi*3e3*t_data_bb);
data_bb = cos(2*pi*3e3*t_data_bb) + cos(2*pi*5e3*t_data_bb) + cos(2*pi*1e3*t_data_bb).*cos(2*pi*300*t_data_bb);
data_bb = (data_bb - mean(data_bb))*100;


%% Clean data
b_slowtail_filter = false;
t_imp_mid = 0.1;
% t_imp_length = 50/fs_bb;
t_imp_length = 0.1;
t_imp_start = t_imp_mid - t_imp_length/2;
t_imp_end = t_imp_mid + t_imp_length/2;
data_cleaned = remove_sferics_test(data_bb, fs_bb, t_imp_start, t_imp_end, b_slowtail_filter);

%% Plot spectrograms
window = 256;
noverlap = 128;
nfft = 256;

% Original Spectrogram
h_spec = figure;
s(end+1) = subplot(2, 1, 1);
%   spectrogram_dan(data_bb, window, noverlap, nfft, fs_bb);
%   caxis([15 70]);
spectrogram_cal(decimate(data_bb, 5), window, noverlap, nfft, fs_bb/5, 'palmer', datenum([2003 01 01 0 0 0]));
s(1) = gca;
title('Original');
increase_font;
zoom xon;

% Cleaned spectrogram
s(end+1) = subplot(2, 1, 2);
%   spectrogram_dan(data_cleaned, window, noverlap, nfft, fs_bb);
%   caxis([15 70]);
s(end+1) = gca;
spectrogram_cal(decimate(data_cleaned, 5), window, noverlap, nfft, fs_bb/5, 'palmer', datenum([2003 01 01 0 0 0]));
title('Result');
increase_font;


%% Plot spectrum (Welch periodograms)
% [p_orig, f] = pwelch(data_bb, window, noverlap, nfft, fs_bb);
% p_cleaned = pwelch(data_cleaned, window, noverlap, nfft, fs_bb);
% 
% figure;
% plot(f, 10*log10(p_orig), f, 10*log10(p_cleaned), 'Linewidth', 2);
% xlabel('Hz');
% ylabel('PSD (dB/Hz)');
% grid on;
% legend('Original', 'Cleaned', 'Location', 'Best');
% increase_font;


%% Plot time domain

% Show data that was replaced
b_good_data = true(size(t_data_bb));
for kk = 1:length(t_imp_start)
  b_good_data(t_data_bb >= t_imp_start(kk) & t_data_bb < t_imp_end(kk)) = false;
end
data_bad = data_bb;
data_bad(b_good_data) = nan;
data_replaced = data_cleaned;
data_replaced(b_good_data) = nan;

h_td = figure;
s(end+1) = subplot(2, 1, 1);
plot(t_data_bb, data_bb, 'b', t_data_bb, data_bad, 'r');
grid on;
legend('Original', 'Sferics')

s(end+1) = subplot(2, 1, 2);
plot(t_data_bb, data_bb, 'b', t_data_bb, data_replaced, 'r');
grid on;
legend('Cleaned', 'Replaced');
increase_font;

linkaxes(s, 'x');

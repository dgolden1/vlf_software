% function test_sferic_removal_fun
% Script to test my sferic removal functions

% By Daniel Golden (dgolden1 at stanford dot edu) August 2010
% $Id$

%% Setup
clear;

b_debug = true;

if b_debug
%   close all;
  s = []; % Vector of handles to axes
end

%% Load some sample data
BB = load('PA031010000505_002.mat'); % More noisy
% BB = load('PA031010103505_002.mat'); % Less noisy
% BB = load('PA010415110505_002.mat'); % Has some chorus
data_bb = BB.data - mean(BB.data);
% data_bb = data_bb(1:ceil(end/10)); % Only take 1/10 of the data
fs_bb = BB.Fs;
t_data_bb = (0:length(data_bb)-1).'/BB.Fs;

% % Pure cosine at 3 kHz
% fs_bb = 1e5;
% t_data_bb = (0:1/fs_bb:0.2).';
% data_bb = cos(2*pi*3e3*t_data_bb);
% % data_bb = cos(2*pi*3e3*t_data_bb) + cos(2*pi*5e3*t_data_bb) + cos(2*pi*1e3*t_data_bb).*cos(2*pi*300*t_data_bb);
% data_bb = (data_bb - mean(data_bb))*100;
% 
% % Stick a spike at 0.1 sec
% data_bb(find(t_data_bb >= 0.1, 1)) = 1000;

% We only need data below ~8 kHz.  Decimating saves computation time.
bb_dec_factor = 6;
data_dec = decimate(data_bb, bb_dec_factor);
fs_dec = fs_bb/bb_dec_factor;
t_data_dec = t_data_bb(1:bb_dec_factor:end);

%% Clean data
thresh = 0.01;
b_slowtail_filter = true;
[t_imp_start, t_imp_end, det_sig, det_fs, det_thresh] = find_sferics(data_bb, fs_bb, thresh);
data_cleaned = remove_sferics(data_dec, fs_dec, t_imp_start, t_imp_end, b_slowtail_filter);

%% Plot output
if b_debug
%   window = 32;
%   noverlap = 16;
%   nfft = 256;
  window = 256;
  noverlap = 128;
  nfft = 256;
  
  % Original Spectrogram
  h_spec = figure;
  s(end+1) = subplot(2, 1, 1);
%   spectrogram_dan(data_dec, window, noverlap, nfft, fs_dec);
%   caxis([15 70]);
  spectrogram_cal(data_dec, window, noverlap, nfft, fs_dec, 'palmer', datenum([2003 01 01 0 0 0]));
  s(1) = gca;
  title('Original');
  increase_font;
  zoom xon;
  
  % Cleaned spectrogram
  s(end+1) = subplot(2, 1, 2);
%   spectrogram_dan(data_cleaned, window, noverlap, nfft, fs_dec);
%   caxis([15 70]);
  s(end+1) = gca;
  spectrogram_cal(data_cleaned, window, noverlap, nfft, fs_dec, 'palmer', datenum([2003 01 01 0 0 0]));
  title('Result');
  increase_font;

  % Time domain
  
  % Show data that was replaced
  b_good_data = true(size(t_data_dec));
  for kk = 1:length(t_imp_start)
    b_good_data(t_data_dec >= t_imp_start(kk) & t_data_dec < t_imp_end(kk)) = false;
  end
  data_bad = data_dec;
  data_bad(b_good_data) = nan;
  data_replaced = data_cleaned;
  data_replaced(b_good_data) = nan;
  
  det_t = (0:length(det_sig)-1)/det_fs;
  
  h_td = figure;
  s(end+1) = subplot(3, 1, 1);
  semilogy(det_t, det_sig, det_t([1 end]), det_thresh*[1 1]);
  grid on;
  legend('Det. sig.', 'Thresh');

  s(end+1) = subplot(3, 1, 2);
  plot(t_data_dec, data_dec, 'b', t_data_dec, data_bad, 'r');
  grid on;
  legend('Original', 'Sferics')

  s(end+1) = subplot(3, 1, 3);
  plot(t_data_dec, data_cleaned, 'b', t_data_dec, data_replaced, 'r');
  grid on;
  legend('Cleaned', 'Replaced');
  increase_font;
  
  linkaxes(s, 'x');
  
  % Welch periodograms
  [p_orig, f] = pwelch(data_dec, window, noverlap, nfft, fs_dec);
  p_cleaned = pwelch(data_cleaned, window, noverlap, nfft, fs_dec);
  
  figure;
  plot(f, 10*log10(p_orig), f, 10*log10(p_cleaned), 'Linewidth', 2);
  xlabel('Hz');
  ylabel('PSD (dB/Hz)');
  grid on;
  legend('Original', 'Cleaned', 'Location', 'Best');
  increase_font;
end

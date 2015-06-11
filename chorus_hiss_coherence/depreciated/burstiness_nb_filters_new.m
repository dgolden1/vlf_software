function [t_nb, s_nb, fc, f_nb, fs_nb, p_welch_mat, p_welch_log_norm] = burstiness_nb_filters(data, fs, f_lc, f_uc)
% Function to get narrowband swaths (filterbank) of input broadband data
% 
% INPUTS
% data, fs: data and sampling frequency (Hz)
% f_lc, f_uc: frequency cutoffs (Hz) -- only perform the filtering within this
% range (roughly)
% 
% OUTPUTS
% t_nb: time index (seconds) of s_nb
% s_nb: time-domain output of filterbanks, sampled at fs_nb.  Index as
%  s_nb(fc, t_nb)
% 
% fc: center frequencies of filterbanks
% f_nb: frequency index (Hz) of Welch matrices
% fs_nb: narrowband sampling frequency
% p_welch_mat: Welch periodograms of normalized absolute values of
%  narrowband swaths.  Index as p_welch_mat(fc, f_nb)
% p_welch_log_norm: Logarithm of above, normalized so that values are
%  between 0 and 1.  Index as p_welch_log_norm(fc, f_nb)

% By Daniel Golden (dgolden1 at stanford dot edu) originally written
% February 2010, heavily modified September 2010
% $Id$

%% Setup
if ~exist('f_lc', 'var') || ~exist('f_uc', 'var') || isempty(f_lc) || isempty(f_uc)
  f_lc = 100;
  f_uc = fs/2 - 100;
end

t = (0:length(data)-1).'/fs;

bw_optimal = 100; % Hz
f_hop = 100; % What frequency to hop over

fc_low = round(f_lc/100)*100;
fc_high = round(f_uc/100)*100;

fc = (fc_low:f_hop:fc_high);

decimate_factor = floor(fs/bw_optimal);
fs_nb = fs/decimate_factor;
nb_sig_length = ceil(length(data)/decimate_factor);
t_nb = (0:nb_sig_length-1).'/fs_nb;

% p_welch_window = 2^floor(log2(nb_sig_length/8));
p_welch_window = 2^nextpow2(nb_sig_length/8);


%% Filter data
p_welch_mat = zeros(length(fc), p_welch_window/2+1);
s_nb = zeros(length(fc), nb_sig_length);
% warning('parfor disabled!');
% for kk = 1:length(fc)
for kk = 1:length(fc)
  % Mix down to baseband. 
  s_mix = data .* exp(-j*2*pi*fc(kk)*t);

  % Decimate
  s_nb(kk, :) = decimate(s_mix, decimate_factor);
  p_welch_slice = pwelch(abs(s_nb(kk, :)) - mean(abs(s_nb(kk, :))), p_welch_window, p_welch_window/2, p_welch_window, fs_nb).';
  
  p_welch_mat(kk, :) = p_welch_slice.';
end
f_nb = linspace(0, fs_nb/2, size(p_welch_mat, 2)); % Frequencies for each pwelch slice

%% Create usable output products
% Normalize each log welch periodogram so that the values are between 0 and
% 1
p_welch_log = log(p_welch_mat);
p_welch_log_norm = (p_welch_log - repmat(min(p_welch_log, 2), 1, length(f_nb)))./repmat(max(p_welch_log, 2) - min(p_welch_log, 2), 1, length(f_nb));

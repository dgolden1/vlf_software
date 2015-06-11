function [s_nb, t_nb, fc, fs_nb, f_hop, p_welch_mat, w, p_welch_norm, w_cut] = burstiness_nb_filters(data, fs)
% Function to get narrowband swaths of input broadband data

% By Daniel Golden (dgolden1 at stanford dot edu) February 2010
% $Id$

%% Setup
t = (0:length(data)-1).'/fs;

bw = 100; % Hz
f_hop = 200; % What frequency to hop over

fc = (200:f_hop:8000);

decimate_factor = floor(fs/bw);
nb_sig_length = ceil(length(data)/floor(fs/bw));
fs_nb = fs/decimate_factor;
t_nb = (0:nb_sig_length-1).'/fs_nb;

p_welch_window = 2^floor(log2(nb_sig_length/8));

OLD_WAY = true; % Set to true to get results that are probably not optimal, but are consistent with published results


%% Filter data
p_welch_mat = zeros(length(fc), p_welch_window/2+1);
s_nb = zeros(length(fc), nb_sig_length);
% warning('parfor disabled!');
% for kk = 1:length(fc)
parfor kk = 1:length(fc)
  % Mix down to baseband. 
  if OLD_WAY
    s_mix = data .* exp(-j*2*pi*fc(kk)*t);
  else
    % Multiply by a factor of 2 to account for the fact that we're
    % discarding half of the spectrum
    s_mix = 2*data .* exp(-j*2*pi*fc(kk)*t);
  end

  % Decimate
  s_nb(kk, :) = decimate(s_mix, decimate_factor);
  if OLD_WAY
    % Don't remove DC
    p_welch_slice = pwelch(abs(s_nb(kk, :)), p_welch_window, p_welch_window/2, p_welch_window, fs_nb).';
  else
    % Remove DC
    p_welch_slice = pwelch(abs(s_nb(kk, :)) - mean(abs(s_nb(kk, :))), p_welch_window, p_welch_window/2, p_welch_window, fs_nb).';
  end
  
  p_welch_slice = p_welch_slice(1:p_welch_window/2+1);
%   p_welch_mat(kk, :) = p_welch_slice/mean(p_welch_slice);
  p_welch_mat(kk, :) = p_welch_slice.';
end
w = linspace(0, fs_nb/2, size(p_welch_mat, 2)); % Frequencies for each pwelch slice

%% Create usable output products
% Normalize each log welch periodogram so that the values are between 0 and
% 1
if OLD_WAY
  % Throw out first two frequencies
  p_welch_log_rot = log10(p_welch_mat(:, 3:end).');
  w_cut = w(3:end);
else
  % Throw out DC and the nyquist frequencies
  p_welch_log_rot = log10(p_welch_mat(:, 2:end-1).');
  w_cut = w(2:end-1);
end
p_welch_norm = (p_welch_log_rot - repmat(min(p_welch_log_rot), length(w_cut), 1))./repmat(max(p_welch_log_rot) - min(p_welch_log_rot), length(w_cut), 1);

function [mean_burstiness, peak_burstiness] = burstiness_characterize_emission(fc, p_welch_norm, w, emission_struct, peak_idx)
% Function to characterize the burstiness of an emission
% 
% INPUT
% fc: center frequency for each narrowband filter (length = size(s_nb, 1)),
% p_welch_norm: matrix where each row i is the positive pwelch
%  periodogram for the corresponding narrowband filter
% w: frequencies for p_welch_norm
% emission_struct: array of structures with the following fields,
%  representing the different emissions:
%   f_uc, inclusive, Hz
%   f_lc, inclusive, Hz
%   amplitude (average median amplitude), dB-fT/Hz^(1/2)
% peak_idx: index into fc of the emission's peak amplitude (used to
% determine peak burstiness)
% 
% OUTPUT
% burstiness: from 0 to 1, 1 being the most bursty

% By Daniel Golden (dgolden1 at stanford dot edu) September 2009
% $Id$

OLD_WAY = true;

assert(all(size(p_welch_norm) == [length(w) length(fc)])); % Make sure p_welch_norm isn't rotated or something
if OLD_WAY
  assert(max(w) == 50); % 100 Hz bandwidth
else
  assert(max(w) == 50*length(w)/(length(w)+1)); % 100 Hz bandwidth, but with dc and nyquist frequencies deleted
end

idx_emission = fc >= emission_struct.f_lc & fc <= emission_struct.f_uc;

% Get average welch periodogram across this emissions frequency range
pwelch_avg = mean(p_welch_norm(:, idx_emission), 2);
p_welch_centroid = 1/sum(pwelch_avg)*sum(w.'.*pwelch_avg);

pwelch_peak = p_welch_norm(:, peak_idx);
p_welch_peak_centroid = 1/sum(pwelch_peak)*sum(w.'.*pwelch_peak);

%% Assign burstiness value
% Let's say, semi-arbitrarily, that a centroid at 25 Hz is the least bursty
% (burstiness == 0), and a centroid at 20 Hz is the most bursty (burstiness
% == 1)
mean_burstiness_raw = p_welch_centroid;
peak_burstiness_raw = p_welch_peak_centroid;
mean_burstiness = (25 - mean_burstiness_raw)/5;
peak_burstiness = (25 - peak_burstiness_raw)/5;

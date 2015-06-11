function burstiness = get_burstiness(data, fs, f_lc, f_uc)
% burstiness = get_burstiness(data, fs, f_lc, f_uc)
% Function to characterize the burstiness of an emission

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

%% Setup
t = (0:length(data)-1).'/fs; % Time (sec)
fc = mean([f_lc, f_uc]); % Center frequency (Hz)
bw = f_uc - f_lc; % Bandwidth (Hz)

%% Filter
% Mix to baseband (this overlaps the emission's spectrum with a
% frequency-reversed version of itself)
data_mix = data .* cos(2*pi*fc*t);

% Lowpass to make the emission full bandwidth
dec_factor1 = ceil(fs/bw);
data_dec = decimate_filter_only(data_mix, dec_factor1);

% Square and decimate
dec_factor2 = fs/100; % Decimate to 100 Hz (ELF)
if fpart(dec_factor2) ~= 0
  error('Sampling frequency (%f) must be a multiple of 100 Hz', fs);
end
data_sq = data_dec.^2;
data_sq_elf = decimate(data_sq - mean(data_sq), dec_factor2);

% Welch periodogram of ELF signal
[P, f] = pwelch(data_sq_elf, 128, 64, 256, fs/dec_factor2);

% Only compute the centroid below 40 Hz, which is below the antialiasing
% filter cutoff.
P = P(f < 40);
f = f(f < 40);

P_norm = P/max(P);
P_centroid = centroid(f, P_norm);

%% Determine burstiness
% This should be a number between 0 and 50
% Lower numbers indicate (more ELF below 25 Hz) indicates greater burstiness

burstiness = P_centroid;

function ec = get_event_characteristics(data, fs, f, idx_lc, idx_uc, s_mediogram, medio_diff, s_periodogram, t_spec, spec, start_datenum)
% Get a mass of characteristics about an emission
% These will be used via some clever approach to categorize the emission as
% chorus, hiss, noise, or whatever
% 
% INPUTS
% data: broadband data
% fs: sampling frequency (Hz)
% f: vector of frequencies (independent variable for various following
% dependent variables)
% s_mediogram: mediogram
% medio_diff: diff(s_mediogram)/df, df = diff(f(1:2))
% s_periodogram: periodogram
% t_spec: independent time variable for spectrogram
% spec: spectrogram
% start_datenum: datenum at which this data starts


% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

%% Setup
P_LAT = -64.77;
P_LON = -64.05;

% Indices into s_mediogram/s_periodogram of emission
idx_this_em = idx_lc:idx_uc;
[~, idx_peak] = max(s_mediogram(idx_this_em));
idx_peak = idx_peak + idx_lc - 1;

ec = struct('f_peak', [], ...
            'f_uc', [], ...
            'f_lc', [], ...
            'bw', [], ...
            'max_lower_slope', [], ...
            'max_upper_slope', [], ...
            'burstiness', [], ...
            'ampl_avg_medio', [], ...
            'ampl_avg_perio', [], ...
            'ampl_peak_medio', [], ...
            'ampl_peak_perio', [], ...
            'ampl_true', [], ...
            'time_to_term', [], ...
            'year', [], ...
            'doy', [], ...
            'xc_slope', [], ...
            'xc_vcorr', [], ...
            'xc_mean', [], ...
            'xc_std', [] ...
            );

%% Burstiness
ec.burstiness = get_burstiness(data, fs, f(idx_lc), f(idx_uc));

%% Vertical correlation and dominant slope
df = f(2) - f(1);
dt = t_spec(2) - t_spec(1);

% Maximum number of lags to compute in the cross correlation
% (lower=faster).  Min_slope is the minimum slope that can be seen with
% this many lags
min_slope = 1000; % +/- Hz/sec 
maxlags = round(df/(dt*min_slope));

xc = zeros(length(idx_this_em) - 1, maxlags*2 + 1);
xc_centroid = zeros(length(idx_this_em) - 1, 1);
xc_centroid_ampl = zeros(length(idx_this_em) - 1, 1);
lags = (-maxlags:maxlags)*dt; % sec (positive lag = xc(k+1,:) advanced wrt. xc(k,:), i.e., positive slope)
slopes = lags/df; % sec/Hz

% Cross-correlate each row of the spectrogram with its adjacent rows.  This
% gives a measure of (a) how much one row relates to the next and (b) what
% the "dominant slope" of the spectrogram is
for kk = 1:(length(idx_this_em) - 1)
  this_ampl = log(spec(idx_this_em(kk), :)).';
  next_ampl = log(spec(idx_this_em(kk+1), :)).';
  xc(kk, :) = xcorr(next_ampl - mean(next_ampl), this_ampl - mean(this_ampl), maxlags, 'coeff');
  xc_centroid(kk) = centroid(lags, xc(kk, :));
  xc_centroid_ampl(kk) = interp1(lags, xc(kk, :), xc_centroid(kk));
end

xc_centroid_slope = centroid(slopes, mean(xc, 1)); % sec/Hz
xc_centroid_val = mean(interp1(slopes, xc.', xc_centroid_slope)); % unitless (mean correlation coefficient)

ec.xc_slope = 1/xc_centroid_slope; % convert slope to Hz/sec
ec.xc_vcorr = xc_centroid_val;
ec.xc_mean = mean(xc(:)); % Higher xc_mean with respect to xc_vcorr indicates correlation over a range of lags (a "wide" emission)
ec.xc_std = mean(std(xc, 0, 2)); % Average std of each row

%% Time to terminator
% Get the minimum number of hours between this emission and the
% terminator (either before or after). If this hour is sunlit, the number
% is negative
ec.time_to_term = get_time_to_terminator(P_LAT, P_LON, start_datenum);

%% Others
ec.f_peak = f(idx_peak); % Peak frequency
ec.f_lc = f(idx_lc); % Lower cutoff
ec.f_uc = f(idx_uc); % Upper cutoff
ec.bw = f(idx_uc) - f(idx_lc); % Bandwidth

% Max upper and lower slope (dB/Hz)
ec.max_lower_slope = max([0; medio_diff(idx_lc:idx_peak-1)]);
ec.max_upper_slope = min([0; medio_diff(idx_peak:idx_uc-1)]);

ec.ampl_avg_medio = mean(s_mediogram(idx_this_em));
ec.ampl_avg_perio = mean(s_periodogram(idx_this_em));
ec.ampl_peak_medio = s_mediogram(idx_peak);
ec.ampl_peak_perio = s_periodogram(idx_peak);

[this_year, ~] = datevec(start_datenum);
ec.year = this_year;
ec.doy = floor(start_datenum) - datenum([this_year 0 0 0 0 0]); % Current date minus Dec 31 of the previous year

%% True emission amplitude
ec.ampl_true = get_true_emission_amplitude(f, s_mediogram, idx_lc, idx_uc);

1;

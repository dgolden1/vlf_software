function [b_is_tweek, tweek_params, rej_str] = ...
  emission_test_tweek(peak, f, s_mediogram, s_periodogram, medio_diff, start_datenum, thresh)
% Function to determine whether a given emission is likely a tweek or not
% 
% Helper function for find_single_event.m

% By Daniel Golden (dgolden1 at stanford dot edu) originally written
% September 2009, heavily revised September 2010

P_LAT = -64.77;
P_LON = -64.05;

b_is_tweek = false;
rej_str = '';
tweek_params = struct('time_to_term', [], 'med_mean_peak', [], 'med_mean_avg', [], 'max_lower_slope', [], 'max_upper_slope', []);

idx_this_em = peak.idx_lc:peak.idx_uc;

% Abort if the peak of the emission is not within a certain range
if f(peak.idx) < thresh.tweek_f_min || f(peak.idx) > thresh.tweek_f_max
  return;
end

% Get the minimum number of hours between this emission and the
% terminator (either before or after). If this hour is sunlit, the number
% is negative
term_altitude = 100e3;
[dawn_datenum, dusk_datenum] = find_terminator(P_LAT, P_LON, term_altitude, start_datenum);
dawn_diff = dawn_datenum - start_datenum;
dusk_diff = dusk_datenum - start_datenum;

% find_terminator always returns the hour following the terminator; make
% sure we have the hour that's across the terminator from start_datenum
if dawn_diff <= 0
  dawn_diff = dawn_diff - 1/24;
end
if dusk_diff <= 0
  dusk_diff = dusk_diff - 1/24;
end

% start_datenum is sunlit
if (dawn_diff < 0 && dusk_diff > 0) || (sign(dawn_diff) == sign(dusk_diff) && dusk_diff < dawn_diff)
  tweek_params.time_to_term = -min(abs(dawn_diff), abs(dusk_diff));
% start_datenum is in darkness
elseif (dusk_diff < 0 && dawn_diff > 0) || (sign(dawn_diff) == sign(dusk_diff) && dawn_diff < dusk_diff)
  tweek_params.time_to_term = min(abs(dawn_diff), abs(dusk_diff));
else
  error('Didn''t find dawn/dusk');
end

% Median - mean of the peak, and averaged across the emission
tweek_params.med_mean_peak = s_periodogram(peak.idx) - s_mediogram(peak.idx);
tweek_params.med_mean_avg = mean(s_periodogram(idx_this_em) - s_mediogram(idx_this_em));

% Does the amplitude roll off at a high enough rate above and below the
% tweek?
tweek_params.max_lower_slope = abs(max(medio_diff(peak.idx_lc:peak.idx-1)));
tweek_params.max_upper_slope = abs(min(medio_diff(peak.idx:peak.idx_uc-1)));

% Is the burstiness value high?
tweek_params.burstiness = peak.burstiness;

% If we meet a certain set of conditions, then it's a tweek
b_time_to_term_cutoff = tweek_params.time_to_term > 0;
b_high_lower_slope = tweek_params.max_lower_slope > thresh.tweek_slope_lower;
b_high_upper_slope = tweek_params.max_upper_slope > thresh.tweek_slope_upper;
b_mean_med_thresh = tweek_params.med_mean_avg > thresh.tweek_median_minus_mean_avg;
b_burstiness_thresh = tweek_params.burstiness < thresh.tweek_max_burstiness; % As long as burstiness is in units of frequency, lower is burstier

if b_time_to_term_cutoff && b_high_lower_slope && ...
    (b_high_upper_slope + b_mean_med_thresh + b_burstiness_thresh >= 2)
  b_is_tweek = true;
  rej_str = 'tweeks!';
end

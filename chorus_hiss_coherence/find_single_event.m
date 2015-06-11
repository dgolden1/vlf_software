function [event_struct, sferic_lc, sferic_uc, noise_struct] = ...
  find_single_event(f, t_spec, spec, s_mediogram, s_medio_diff, s_periodogram, data, fs, start_datenum, sitename)
% [event_struct, sferic_lc, sferic_uc, noise_struct] = find_single_event(f, t_spec, spec, s_mediogram, s_medio_diff, s_periodogram, data, fs, start_datenum, sitename)
% 
% Heavily revised September 2010 with filterbank approach depreciated

% By Daniel Golden (dgolden1 at stanford dot edu) September 2009
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'Terminator_V7')); % Ryan's terminator code

sferic_uc = 8e3; % Upper cutoff - extent of sferics
sferic_lc = 0; % Lower cutoff - extent of sferic slowtails
event_struct = struct('f_lc', {}, 'f_uc', {}, 'ec', {});
noise_struct = struct('f', {}, 'string', {}); % Tweeks, sferics and whistlers
rej_strings = {}; % String of reasons why emissions were rejected

df = f(2) - f(1); % Hz/sample

idx_all = (1:length(s_mediogram)).';

%% Load settings for this site/year
[year, ~] = datevec(start_datenum);
thresh = get_event_thresholds(sitename, year);


%% Determine sferic lower cutoff
% There's always an initial hump in the data where after the slowtail
% filter ends, when there's still some slowtail energy, around 400 Hz.  The
% lower frequency cutoff of the sferics is either this first valley or the
% first time after the hump that s_medio_diff goes above thresh.sf_lc_slope
idx_first_peak = find(s_medio_diff(1:end-1) > 0 & s_medio_diff(2:end) <= 0, 1, 'first') + 1;
idx_first_valley = find(s_medio_diff(1:end-1) < 0 & s_medio_diff(2:end) >= 0, 1, 'first') + 1;

idx_slope_above_thresh = find((1:length(s_medio_diff)).' > idx_first_peak & s_medio_diff > thresh.sf_lc_slope, 1, 'first');

% Minimum of (a) the first valley, (b) the first time after the first peak
% that the slope is low, or (c) the nearest index to thresh.sf_lc_max
idx_sferic_lc = min([idx_first_valley, idx_slope_above_thresh, nearest(thresh.sf_lc_max, f)]);
assert(~isempty(idx_sferic_lc));
sferic_lc = f(idx_sferic_lc);

%% Determine sferic upper cutoff
% The upper sferic frequencies are more gradual and variable than the lower
% ones.  Let's say that the sferic upper cutoff is the maximum of either
% thresh.sf_uc_min or the beginning of the last period where s_medio_diff
% was positive when averaged over thresh.sf_uc_frange which includes 8 kHz
% - thresh.sf_uc_frange/2.

if strcmp(sitename, 'southpole')
  % There is no sferic upper cutoff in 100 kHz southpole data
  idx_sferic_uc = nearest_dan(f, 40e3);
  sferic_uc = f(idx_sferic_uc);
else
  % Find the last period where s_medio_diff turned positive when averaged over
  % threshold thresh.sf_uc_frange
  nsamples_avg = round(thresh.sf_uc_frange/df);
  medio_diff_avg_uc = smooth(s_medio_diff, nsamples_avg) + 2e-3; % A "positive" slope is one that's greater than -2 dB/kHz
  idx_sferic_uc = find(diff(medio_diff_avg_uc > 0) == 1, 1, 'last') + 1;

  % Find the index after the above point where the slope starts to turn
  % downwards again
  if ~isempty(idx_sferic_uc)
    idx_end_sferic_uc_increasing = find(diff(medio_diff_avg_uc > 0) == -1 & f(2:end-1) > f(idx_sferic_uc), 1, 'first') + 1;
  end

  % % Determine whether 8 kHz is a relative maximum between 7 and 9 kHz
  % sferic_ampl_8k = max(s_mediogram(f > 7800 & f < 8200));
  % sferic_ampl_max_79k = max(s_mediogram(f > 7000 & f < 9000));
  % b_sferic_peak_8k = sferic_ampl_8k >= sferic_ampl_max_79k - 0.5;

  % If there was frequency that matched this criteria, or the frequency
  % was above our minimum sferic upper cutoff threshold, or the slope started
  % to turn downards again before reaching 8 kHz, use the minumum sferic
  % upper cutoff threshold
  if isempty(idx_sferic_uc) || f(idx_sferic_uc) > thresh.sf_uc_min || isempty(idx_sferic_uc) || idx_end_sferic_uc_increasing < nearest(8000 - thresh.sf_uc_frange/2, f)
    idx_sferic_uc = nearest(thresh.sf_uc_min, f);
  end

  % There's always a chance that the upper cutoff will be lower than the
  % lower cutoff; if so, make them the same
  if idx_sferic_uc < idx_sferic_lc
    idx_sferic_uc = idx_sferic_lc;
  end

  sferic_uc = f(idx_sferic_uc);
end

%% Find peaks of height 3 dB or greater
% Minimum mediogram value between the sferic cutoffs
medio_min_within_cutoffs = min(s_mediogram(idx_sferic_lc:idx_sferic_uc));

% Indices of peaks
idx_peaks = find(idx_all(2:end-1) > idx_sferic_lc & idx_all(2:end-1) < idx_sferic_uc & ... % Within sferic cutoffs
                 s_medio_diff(1:end-1) > 0 & s_medio_diff(2:end) <= 0 & ... % Is a peak (slope goes from positive to negative)
                 s_mediogram(2:end-1) >= medio_min_within_cutoffs + thresh.min_rel_emission_peak_db) ... % Peak amplitude is high enough above minimum mediogram value
              + 1;

% Delete peaks which are not above an absolute threshold amplitude
idx_valid = s_mediogram(idx_peaks) >= thresh.min_aps_peak_ampl;
idx_peaks(~idx_valid) = [];
            
% The sferic lower cutoff gets to be a default peak... if its amplitude is
% above a certain threshold
if s_mediogram(idx_sferic_lc) > thresh.min_emission_sf_lc_db
  idx_peaks = [idx_sferic_lc; idx_peaks];
end

% A struct to hold information about each peak
peaks = struct('idx', {}, 'idx_3db_uc', {}, 'idx_3db_lc', {}, ...
  'f_uc_3db', {}, 'f_lc_3db', {}, 'fwhm', {}, 'idx_uc', {}, 'idx_lc', {}, ...
  'burstiness', {});

for kk = 1:length(idx_peaks)
  peaks(kk).idx = idx_peaks(kk);
end


% Determine the peak widths as the full-width half maximum
idx_valid = true(size(idx_peaks));
for kk = 1:length(peaks)
  % 3 dB below event peak for lower frequencies
  peaks(kk).idx_3db_lc = find(idx_all < peaks(kk).idx & ... % f less than f_peak
             idx_all >= idx_sferic_lc & ... % f above sferic lower cutoff
             s_mediogram <= s_mediogram(peaks(kk).idx) - 3, ... % 3 dB below peak
             1, 'last');
  
  % 3 dB below event peak for higher frequencies
  peaks(kk).idx_3db_uc = find(idx_all > peaks(kk).idx & ... % f greater than f_peak
             idx_all <= idx_sferic_uc & ... % f below sferic upper cutoff
             s_mediogram <= s_mediogram(peaks(kk).idx) - 3, ... % 3 dB below peak
             1, 'first');
  
  % If we could find NEITHER an upper or lower 3dB point, reject this peak
  if isempty(peaks(kk).idx_3db_lc) && isempty(peaks(kk).idx_3db_uc)
    idx_valid(kk) = false;
  end
end
peaks(~idx_valid) = [];

% Determine actual FWHM by interpolating.  The upper and lower cutoffs
% determined above actually overshoot the 3 dB point.  Interpolate between
% those points and the previous point to find the true 3 dB point.  If the
% upper or lower cutoff is empty, just use the existing cutoff to estimate
% the FWHM.
idx_valid = true(size(peaks));
for kk = 1:length(peaks)
  % Does this event have a valid lower cutoff?
  if ~isempty(peaks(kk).idx_3db_lc)
    peaks(kk).f_lc_3db = interp1(s_mediogram(peaks(kk).idx_3db_lc + [0 1]), f(peaks(kk).idx_3db_lc + [0 1]), s_mediogram(peaks(kk).idx) - 3);
  else
    peaks(kk).fwhm = peaks(kk).f_uc_3db - f(peaks(kk).idx);
  end
  
  % Does this event have a valid upper cutoff?
  if ~isempty(peaks(kk).idx_3db_uc)
    peaks(kk).f_uc_3db = interp1(s_mediogram(peaks(kk).idx_3db_uc + [-1 0]), f(peaks(kk).idx_3db_uc + [-1 0]), s_mediogram(peaks(kk).idx) - 3);
  else
    peaks(kk).fwhm = f(peaks(kk).idx) - peaks(kk).f_lc_3db;
  end
  
  % Determine FWHM for event with BOTH valid cutoffs
  if ~isempty(peaks(kk).idx_3db_lc) && ~isempty(peaks(kk).idx_3db_uc)
    peaks(kk).fwhm = (peaks(kk).f_uc_3db - peaks(kk).f_lc_3db)/2;
  end

  % Reject peaks whose FWHM is too low
  if peaks(kk).fwhm < thresh.min_emission_width_fwhm
    idx_valid(kk) = false;
  end
end
peaks(~idx_valid) = [];

%% Determine event extents
% For each peak, define the event extent as follows:
% Nearest points that are thresh.min_emission_peak_db_local down from the
% peak that are not beyond another peak or the sferic cutoffs
% 
% Otherwise, choose at the extent the furthest valley from this peak that
% we can get to without going higher than this peak, or the sferic cutoffs,
% whichever comes first

for kk = 1:length(peaks)
  [peaks(kk).idx_lc, peaks(kk).idx_uc] = find_peak_extents(peaks(kk).idx, ...
                                                           s_mediogram, idx_sferic_lc, idx_sferic_uc, ...
                                                           thresh.min_emission_peak_db_local);
end

% Discard emissions with low bandwidths
peaks(f([peaks.idx_uc]) - f([peaks.idx_lc]) < thresh.min_emission_bandwidth) = [];

% If any peaks are contained in a higher amplitude event, delete them
idx_valid = true(size(peaks));
for kk = 1:length(peaks)
  % If this peak has already been declared invalid, ignore it
  if idx_valid(kk)
    % True for any peak that is within this event's cutoffs
    idx_contained_emissions = [peaks.idx] >= peaks(kk).idx_lc & [peaks.idx] <= peaks(kk).idx_uc;
    idx_contained_emissions(kk) = false; % Don't count this event
  end
  
  idx_valid = idx_valid & ~idx_contained_emissions;
end
peaks(~idx_valid) = [];


%% Save remaining emissions

for kk = 1:length(peaks)
  event_struct(kk).f_lc = f(peaks(kk).idx_lc);
  event_struct(kk).f_uc = f(peaks(kk).idx_uc);

  event_struct(kk).ec = get_event_characteristics(data, fs, f, ...
    peaks(kk).idx_lc, peaks(kk).idx_uc, ...
    s_mediogram, s_medio_diff, s_periodogram, t_spec, spec, start_datenum);
end

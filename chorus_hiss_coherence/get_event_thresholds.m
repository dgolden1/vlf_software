function thresh = get_event_thresholds(sitename, year)
% settings_struct = get_event_thresholds(sitename, year)
% Function to determine certain settings for the burstiness detector for
% different sites and years

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

% All originally optimized for Palmer data (all years)

thresh.sf_lc_slope = -20e-3; % (dB/Hz) sferic lower cutoff occurs when medio_diff is higher than this
thresh.sf_lc_max = 600; % (Hz) maximum frequency for sferic lower cutoff
thresh.min_emission_sf_lc_db = -3; % (dB) if the amplitude at the sferic lower cutoff is above this (ABSOLUTE) value, we'll consider it as an emission
thresh.sf_uc_min = 8000; % (Hz) sferic upper cutoff can be no higher than this
thresh.sf_uc_frange = 1000; % (Hz) period over which to average when testing for sferic upper cutoff
thresh.min_rel_emission_peak_db = 5; % (dB) emission peak amplitude must be this many dB above the lowest value between the sferic cutoffs
thresh.min_emission_width_fwhm = 100; % (Hz) emission width must be at least this much (full width half maximum = width from peak to 3 dB below peak)
thresh.min_emission_peak_db_local = 9; % (dB) emission ends when amplitude has dropped this far below the peak
thresh.min_emission_bandwidth = 300; % (Hz) discard emissions with lower bandwidths than this
thresh.min_aps_peak_ampl = -inf; % (dB/Hz) ABOLUTE minimum PSD of a peak
thresh.tweek_f_min = 1800; % (Hz) lower frequency limit of peak to be considered as a tweek false positive
thresh.tweek_f_max = 4000; % (Hz) upper frequency limit of peak to be considered as a tweek false positive
thresh.tweek_slope_lower = 15e-3; % (dB/Hz) tweek lower slope must be at least this high
thresh.tweek_slope_upper = 10e-3; % (dB/Hz) tweek upper slope must be at least this high
thresh.tweek_median_minus_mean_avg = 5; % (dB) the periodogram minus the mediogram value must be at least this high over over the tweek
thresh.tweek_max_burstiness = 15; % (Hz) a tweek must be burstier than this value
thresh.sferic_min_corr = 0.75; % (unitless) minimum correlation coefficient for an emission to be considered whistlers/sferics
thresh.sferic_max_slope = 50; % (Hz/sec) max slope for an emission to be considered whistlers/sferics

switch sitename
  case 'palmer'
    % Keep defaults
  case 'southpole'
    thresh.min_emission_sf_lc_db = inf;
    thresh.min_rel_emission_peak_db = 20;
    thresh.min_aps_peak_ampl = -5;
    thresh.min_emission_width_fwhm = 85;
    thresh.min_abs_ahiss_ampl = -17; % If the PSD is above this ABSOLUTE threshold for some frequency range, it could be auroral hiss
  otherwise
    error('thresh.min_emission_sf_lc_db is an absolute threshold and must be determined on a site-by site basis');
end

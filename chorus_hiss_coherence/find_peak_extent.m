function [idx_lc, idx_uc] = find_peak_extents(peak_idx, s_mediogram, idx_lbound, idx_ubound, min_emission_peak_db_local)
% Determine event extent
% For each peak, define the event extent as follows:
% Nearest points that are thresh.min_emission_peak_db_local down from the
% peak that are not beyond another peak or the sferic cutoffs
% 
% Otherwise, choose as the extent the furthest valley from this peak that
% we can get to without going higher than this peak, or the sferic cutoffs,
% whichever comes first
% 
% INPUTS
% peak_idx: index of the peak frequency
% s_mediogram: signal mediogram (dB)
% idx_lbound, idx_ubound: upper and lower index bounds allowed for the
%  peak extent (these were originally the sferic lower and upper cutoffs in
%  Palmer data)
% min_emission_peak_db_local: see above function description
% 
% OUTPUTS
% idx_lc, idx_uc: the upper and lower cutoff frequency indices of the event

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

%% Setup
if ~exist('idx_lbound', 'var') || isempty(idx_lbound)
  idx_lbound = 1;
end
if ~exist('idx_ubound', 'var') || isempty(idx_ubound)
  idx_ubound = length(f);
end

% Make sure that peak_idx is a real peak
if ~((peak_idx == 1 || s_mediogram(peak_idx-1) < s_mediogram(peak_idx)) || ...
     (peak_idx == length(s_mediogram) || s_mediogram(peak_idx+1) < s_mediogram(peak_idx)))
   error('Index %d is not a local maximum', peak_idx);
end

%% Lower cutoff

% Index of the first f below the peak where the amplitude is above the
% peak
idx_low_overampl = find(idx_all < peak_idx & ... % f less than f_peak
                        s_mediogram >= s_mediogram(peak_idx), ... % amplitude above peak
                        1, 'last');
idx_low_belowthresh = find(idx_all < peak_idx & ... % f less than f_peak
                           idx_all > idx_lbound & ... % f greater than sferic lower cutoff
                           s_mediogram <= s_mediogram(peak_idx) - thresh.min_emission_peak_db_local, ... % amplitude below threshold from peak
                           1, 'last');

if isempty(idx_low_overampl) && isempty(idx_low_belowthresh)
  % If there are no emissions and no low-enough values between this
  % emission peak and the the sferic lower cutoff, the use the sferic
  % lower cutoff
  idx_lc = idx_lbound;
elseif ~isempty(idx_low_belowthresh) && (isempty(idx_low_overampl) || idx_low_belowthresh > idx_low_overampl)
  % If we found a low-enough value, use it
  idx_lc = idx_low_belowthresh;
else
  % Otherwise, look for a minimum in the data between the peak and the
  % sferic lower cutoff.  If we find one, use it; otherwise, use the
  % sferic lower cutoff.
  idx_valid = find(idx_all < peak_idx & ... % f less than f_peak
             idx_all > idx_low_overampl & ... % f greater than the next place where the amplitude is above this peak
             idx_all >= idx_lbound); % f greater than sferic lower cutoff
  [~, idx] = min(s_mediogram(idx_valid));

  % Did we find a minimum above the sferic lower cutoff?
  if isempty(idx_valid)
    idx_lc = idx_lbound;
  else
    idx_lc = idx_valid(idx);
  end
end

%% Upper cutoff

% Index of the first f above the peak where the amplitude is above the
% peak
idx_high_overampl = find(idx_all > peak_idx & ... % f greater than f_peak
                         s_mediogram >= s_mediogram(peak_idx), ... % amplitude above peak
                         1, 'first');
idx_high_belowthresh = find(idx_all > peak_idx & ... % f greater than f_peak
                            idx_all < idx_ubound & ... % f less than sferic upper cutoff
                            s_mediogram <= s_mediogram(peak_idx) - thresh.min_emission_peak_db_local, ... % amplitude below threshold from peak
                            1, 'first');

if isempty(idx_high_overampl) && isempty(idx_high_belowthresh)
  % If there are no emissions and no low-enough values between this
  % emission peak and the the sferic upper cutoff, the use the sferic
  % upper cutoff
  idx_uc = idx_ubound;
elseif ~isempty(idx_high_belowthresh) && (isempty(idx_high_overampl) || idx_high_belowthresh < idx_high_overampl)
  % If we found a low-enough value, use it
  idx_uc = idx_high_belowthresh;
else
  % Otherwise, look for a minimum in the data between the peak and the
  % sferic upper cutoff.  If we find one, use it; otherwise, use the
  % sferic upper cutoff.
  idx_valid = find(idx_all > peak_idx & ... % f greater than f_peak
             idx_all < idx_high_overampl & ... % f less than the next place where the amplitude is above this peak
             idx_all <= idx_ubound); % f less than sferic upper cutoff
  [~, idx] = min(s_mediogram(idx_valid));

  % Did we find a minimum below the sferic upper cutoff?
  if isempty(idx_valid)
    idx_uc = idx_ubound;
  else
    idx_uc = idx_valid(idx);
  end
end

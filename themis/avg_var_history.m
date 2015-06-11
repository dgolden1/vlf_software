function var_history = avg_var_history(epoch, var, epoch_dest, time_range)
% Get a 1-hour average of a variable some number of hours in the past
% 
% INPUTS
% epoch: epochs for original samples of variable
% var: variable that we're getting the averages of
% epoch_dest: history will be with respect to these "destination epochs"
% time_range: time range, in days, with respect to destination epochs over
%  which to average variable. E.g., if time_range is [-1 0], then the
%  result will be the average value of the variable between [epoch_dest - 1
%  day : epoch_dest]. If the time range is [0 0] then the result will be
%  the exact value of the variable at epoch_dest. Et cetera.
% 
% OUTPUTS
% var_history: variable history on epoch_dest epochs

% By Daniel Golden (dgolden1 at stanford dot edu) July 2011
% $Id$

%% Setup
if length(time_range) ~= 2
  error('time_range should be a two-element vector of days over which to average');
end
if diff(time_range) < 0
  error('time_range should be monotonically increasing');
end

% Make sure epoch is continuous... but allow a single gap (for the
% case of combined THEMIS and Polar data)
% A gap is allowed by sorting the epoch_diffs and ignoring the last
% (largest) diff (which is the gap)
epoch_diff = diff(epoch);
epoch_diff_sort = sort(epoch_diff);
if 1 - min(epoch_diff_sort(1:end-1))/max(epoch_diff_sort(1:end-1)) > 1e-3
  error('epoch must be continuous');
end

epoch_interval = median(epoch_diff); % num days between epoch samples
num_epochs = abs(time_range)/epoch_interval;
if any(fpart(num_epochs)./num_epochs > 1e-5)
  error('time_range values must be a multiple of diff(epoch)');
end

%% Calculate history
if all(time_range == 0)
  var_history = interp1(epoch, var, epoch_dest);
else
  num_taps = round(diff(time_range)/epoch_interval) + 1;
  assert(num_taps > 0);
  filter_taps = ones(1, num_taps)/num_taps;

  var_smoothed = filter(filter_taps, 1, var);
  var_history = interp1(epoch - time_range(2), var_smoothed, epoch_dest);
end

%% Set invalid values to NaN
% If we requested values that depend on values that span the gap, set those
% values to NaN
if max(epoch_diff) < 1.1*min(epoch_diff)
  % Don't do anything if there's no gap
  return;
end
[~, gap_start_idx] = max(epoch_diff); % Assume there's only one gap!
gap_start_time = epoch(gap_start_idx); % Time right before gap
gap_end_time = epoch(gap_start_idx+1); % Time right after gap

% Invalidate anything in the gap or after the gap plus the time range of
% the filtering
idx_invalid = epoch_dest > gap_start_time & epoch_dest <= gap_end_time + -time_range(1);
var_history(idx_invalid) = nan;

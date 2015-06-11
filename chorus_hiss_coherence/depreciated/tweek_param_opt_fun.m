function val = tweek_param_opt_fun(x, b_is_tweek, events_t)
% val = tweek_param_opt_fun(x, b_is_tweek, events_t)
% 
% Function to optimize thresholds for determining whether a given event is
% a tweek or emission

% By Daniel Golden (dgolden1 at stanford dot edu) October 2009
% $Id$

%% Setup
tweek_params = [events_t.tweek_params];

% Default x: [0.4, 0.012, 0.5]

med_mean_avg_thresh = x(1);
lower_slope_thresh = x(2);
burstiness_thresh = x(3);

% lower_slope_cutoff = 0.021;
lower_slope_cutoff = x(4);
time_to_term_cutoff = 0;
% burstiness_cutoff = 0.25;
burstiness_cutoff = x(5);

%% Detect
b_auto_tweek = ...
  ([tweek_params.lower_slope] > lower_slope_cutoff) | ...
  ([tweek_params.time_to_term] > time_to_term_cutoff) & ...
  ([tweek_params.burstiness] > burstiness_cutoff) & ...
  (([tweek_params.med_mean_avg] < med_mean_avg_thresh) + ...
  ([tweek_params.lower_slope] > lower_slope_thresh) + ...
  ([tweek_params.burstiness] > burstiness_thresh) >= 2);
b_auto_tweek = b_auto_tweek(:);

false_positives = b_auto_tweek & ~b_is_tweek;
false_negatives = ~b_auto_tweek & b_is_tweek;

val = sum(false_positives) + sum(false_negatives);

function num_events = count_events_at_freq(interval_lc, interval_uc, events)
% num_events = count_events_at_time(interval_lc, interval_uc, events)
% Count the number of events that intersect the given frequency interval
% [interval_lc, interval_uc)

% By Daniel Golden (dgolden1 at stanford dot edu) October 2008
% $Id$

f_lc = [events.f_lc];
f_uc = [events.f_uc];

idx = (f_uc >= interval_lc & f_uc < interval_uc) | ...   % End time is within window
	(f_lc >= interval_lc & f_lc < interval_uc) | ... % Start time is within window
	(f_lc < interval_lc & f_uc >= interval_uc);        % Event spans window

num_events = sum(idx);

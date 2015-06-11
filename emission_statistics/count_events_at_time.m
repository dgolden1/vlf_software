function num_events = count_events_at_time(interval_start, interval_end, events)
% num_events = count_events_at_time(interval_start, interval_end, events)
% Count the number of events that intersect the given time interval

% By Daniel Golden (dgolden1 at stanford dot edu) December 2007
% $Id$

em_start = fpart([events.start_datenum]);
em_end = fpart([events.end_datenum]);
em_end(em_end == 0) = 1;

idx = em_end > interval_start & em_start < interval_end;
% idx = (em_end >= interval_start & em_end < interval_end) | ...   % End time is within window
% 	(em_start >= interval_start & em_start < interval_end) | ... % Start time is within window
% 	(em_start < interval_start & em_end >= interval_end);        % Event spans window

num_events = sum(idx);

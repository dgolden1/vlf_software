function events = ecg_sort_events(events)
% events = ecg_sort_events(events)
% Sort events by start time

% By Daniel Golden (dgolden1 at stanford dot edu) December 2007
% $Id$

[junk, ix] = sort([events.start_datenum]);
events = events(ix);

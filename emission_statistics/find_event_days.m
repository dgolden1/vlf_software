function event_days = find_event_days(these_events, days, em_int_start, em_int_end)
% event_days = find_event_days(these_events, days, em_int_start, em_int_end)
% 
% INPUTS
% these_events: events of a given type
% days: list of days that we're examining
% em_int_start: datenum giving the start of the emission interval
% em_int_end: datenum giving the end of the emission interval
% 
% OUTPUT
% list of boolean values: true if event occurred in the emission interval
% on this day, false otherwise

% By Daniel Golden (dgolden1 at stanford dot edu) September 2008
% $Id$

event_days = false(1, length(days));
for kk = 1:length(event_days)
	this_days_events = these_events(floor([these_events.start_datenum]) == days(kk));
	for ii = 1:length(this_days_events)
		event_end_time = fpart(this_days_events(ii).end_datenum);
		if event_end_time == 0, event_end_time = 1; end % Events can end at midnight
		event_start_time = fpart(this_days_events(ii).start_datenum);

		if ~(event_end_time < em_int_start || event_start_time > em_int_end)
			event_days(kk) = true;
			continue;
		end
	end
end

function event = ecg_find_event_time_overlap(events, event)
% ecg_find_event_time_overlap(events, event)
% Function to find overlap in event times (which may screw statistics up)

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

events_after = find([events.end_datenum] > event.start_datenum);
events_before = find([events.start_datenum] < event.end_datenum);

overlap_events = intersect(events_after, events_before);
if isempty(overlap_events)
	return;
end

for kk = 1:length(overlap_events)
	overlap_event = events(overlap_events(kk));

	msg = sprintf('Event on %s from %s to %s overlaps with existing event from %s to %s; time was adjusted', ...
		datestr(event.start_datenum, 'mm/dd/yyyy'), ...
		datestr(event.start_datenum, 'HH:MM'), ...
		datestr(event.end_datenum, 'HH:MM'), ...
		datestr(overlap_event.start_datenum, 'HH:MM'), ...
		datestr(overlap_event.end_datenum, 'HH:MM'));


	if event.start_datenum < overlap_event.end_datenum && event.end_datenum > overlap_event.end_datenum
		event.start_datenum = overlap_event.end_datenum;
		disp(sprintf('Warning: %s', msg));
% 		warning('ecg_find_event_time_overlap:FoundOverlappingEvent', msg);
	elseif event.end_datenum > overlap_event.start_datenum && event.start_datenum < overlap_event.start_datenum
		event.end_datenum = overlap_event.start_datenum;
		disp(sprintf('Warning: %s', msg));
% 		warning('ecg_find_event_time_overlap:FoundOverlappingEvent', msg);
	else
		error('ecg_find_event_time_overlap:FoundOverlappingEvent', msg);
	end
end

function these_events = emission_time_parser(events, em_type, bAllEvents, start_datenum, end_datenum)
% Extract events for a given time period and type

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

if bAllEvents
	events_i = 1:length(events);
else
	events_i = find([events.start_datenum] >= start_datenum & [events.end_datenum] <= end_datenum);
end
these_events = events(events_i);

if ~strcmp(em_type, 'all');
	switch em_type
		case 'chorus'
			events_i = strcmp({events.type}, 'chorus');
		case 'hiss'
			events_i = strcmp({events.type}, 'hiss');
		otherwise
			error('Weird emission type: %s', em_type);
	end
	
	these_events = these_events(events_i);
end

if isempty(these_events)
	error('No events of type ''%s'' found!', em_type);
end

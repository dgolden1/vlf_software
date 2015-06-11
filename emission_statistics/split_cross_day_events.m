function events = split_cross_day_events(events)
% events = split_cross_day_events(events)
% Function to take events that span multiple days (e.g., an event that
% starts on one day and ends the following day) and split them

% By Daniel Golden (dgolden1 at stanford dot edu) Dec 2007
% $Id$

%% Setup
error(nargchk(1, 1, nargin));

% Sort events
events = ecg_sort_events(events);

% Find events that span midnight (but don't end AT midnight)
cross_day_i = find((floor([events.start_datenum]) < floor([events.end_datenum])) & (fpart([events.end_datenum]) ~= 0));

%% Split emissions
for kk = cross_day_i
	% Copy the event
	events(end+1) = events(kk);
	
	% Modify the times
	midnight = ceil(events(kk).start_datenum);
	events(kk).end_datenum = midnight;
	events(end).start_datenum = midnight;
end

% Sort emissions
events = ecg_sort_events(events);

function events = convert_from_utc_to_palmerlt(events)
% events = convert_from_utc_to_palmerlt(events)
% Convert event times from utc to palmer lt
% Splits events that span midnight into separate events, which can then be
% combined with combine_cross_day_events()

% By Daniel Golden (dgolden1 at stanford dot edu) December 2007
% $Id$

%% Setup
PALMER_MLT = -(4+1/60)/24;

start_datenum = [events.start_datenum];
end_datenum = [events.end_datenum];

%% Convert times
start_datenum = start_datenum + PALMER_MLT;
end_datenum = end_datenum + PALMER_MLT;

for kk = 1:length(events)
	events(kk).start_datenum = start_datenum(kk);
	events(kk).end_datenum = end_datenum(kk);
end

%% Split events that span midnight into separate events
% midnight_events_i = find(floor(end_datenum) > floor(start_datenum));
% 
% for kk = midnight_events_i
% 	if isempty(kp), this_kp = []; else this_kp = kp(kk); end
% 	if isempty(dst), this_dst = []; else this_dst = dst(kk); end
% 	
% 	% New event, beginning at midnight of the second day
% 	new_event = struct('start_datenum', floor(end_datenum(kk)), ...
% 		               'end_datenum', end_datenum(kk), ...
% 					   'f_lc', f_lc(kk), ...
% 					   'f_uc', f_uc(kk), ...
% 					   'emission_type', emission_type{kk}, ...
% 					   'intensity', intensity(kk), ...
% 					   'particle_event', particle_event{kk}, ...
% 					   'kp', this_kp, ...
% 					   'dst', this_dst, ...
% 					   'notes', notes{kk});
% 	events(end+1) = new_event;
% 	
% 	% Truncate original event to end at midnight of the first day
% 	events(kk).end_datenum = floor(end_datenum(kk));
% end

%% Sorts events
events = ecg_sort_events(events);

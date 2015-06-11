function events = ecg_add_event(events, event)
% events = ecg_add_event(events, event)
% Tack on a single event to the list of events

% By Daniel Golden (dgolden1 at stanford dot edu) November, 2007
% $Id$

% NEW WAY (array of structures)
events(end+1, 1).start_datenum = event.start_datenum;
events(end, 1).end_datenum = event.end_datenum;
events(end, 1).f_lc = event.f_lc;
events(end, 1).f_uc = event.f_uc;
events(end, 1).emission_type = event.emission_type;
events(end, 1).intensity = event.intensity;
events(end, 1).particle_event = event.particle_event;
events(end, 1).kp = event.kp;
events(end, 1).dst = event.dst;
events(end, 1).notes = event.notes;

% OLD WAY (structure of arrays)
% if ~isstruct(events)
% 	events.start_datenum(1) = event.start_datenum;
% 	events.end_datenum(1) = event.end_datenum;
% 	events.f_lc(1) = event.f_lc;
% 	events.f_uc(1) = event.f_uc;
% 	events.emission_type{1} = event.emission_type;
% 	events.intensity(1) = event.intensity;
% 	events.particle_event{1} = event.particle_event;
% 	events.kp(1) = event.kp;
% 	events.dst(1) = event.dst;
% 	events.notes{1} = event.notes;
% end
% 
% events.start_datenum(end+1, 1) = event.start_datenum;
% events.end_datenum(end+1, 1) = event.end_datenum;
% events.f_lc(end+1, 1) = event.f_lc;
% events.f_uc(end+1, 1) = event.f_uc;
% events.emission_type{end+1, 1} = event.emission_type;
% events.intensity(end+1, 1) = event.intensity;
% events.particle_event{end+1, 1} = event.particle_event;
% events.kp(end+1, 1) = event.kp;
% events.dst(end+1, 1) = event.dst;
% events.notes{end+1, 1} = event.notes;

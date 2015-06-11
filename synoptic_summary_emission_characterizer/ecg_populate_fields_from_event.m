function ecg_populate_fields_from_event(handles, event)
% ecg_populate_fields_from_event(handles, event)
% Populate the GUI fields with values from an event
% The 'date' field is assumed to be already populated

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

set(handles.edit_start_time, 'String', datestr(event.start_datenum, 'HH:MM'));
set(handles.edit_end_time, 'String', datestr(event.end_datenum, 'HH:MM'));
set(handles.edit_f_lc, 'String', num2str(event.f_lc, '%0.1f'));
set(handles.edit_f_uc, 'String', num2str(event.f_uc, '%0.1f'));
set(handles.edit_intensity, 'String', num2str(event.intensity, '%02d'));

% Get the emission type
emission_type = event.emission_type;
while ~isempty(emission_type)
	[token, emission_type] = strtok(emission_type, ',');
	token = strtrim(token); % trim white space
	switch token
		case 'chorus'
			set(handles.checkbox_em_chorus, 'Value', 1);
		case 'hiss'
			set(handles.checkbox_em_hiss, 'Value', 1);
		case 'whistlers'
			set(handles.checkbox_em_whistlers, 'Value', 1);
		case 'unchar'
			% Do nothing
		otherwise
			set(handles.checkbox_em_other, 'Value', 1);
			set(handles.edit_em_other, 'String', token);
			set(handles.edit_em_other, 'Enable', 'on');
	end
end

% Notes
set(handles.edit_notes, 'String', event.notes);

% Particle event
particle_events = get(handles.popupmenu_particle_event, 'String');
bFoundEventType = false;
for kk = 1:length(particle_events)
	if strcmp(event.particle_event, particle_events{kk})
		set(handles.popupmenu_particle_event, 'Value', kk);
		bFoundEventType = true;
		break;
	end
end
if ~bFoundEventType
	error('Unknown particle event type (%s)', event.particle_event);
end

% WARNING: KP and DST NOT IMPLEMENTED

function ecg_save_emission(handles)
% ecg_save_emission(handles)
% Save emission to db file

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

% Validate values
ecg_validity_check(handles);

% Start and end times
try
	event.start_datenum = ecg_get_datenum_from_fields(get(handles.edit_date, 'String'), get(handles.edit_start_time, 'String'));
	event.end_datenum = ecg_get_datenum_from_fields(get(handles.edit_date, 'String'), get(handles.edit_end_time, 'String'), true);
	
	% If the either time is within 7.5 minutes of midnight, round it to
	% midnight
	if event.start_datenum - floor(event.start_datenum) <= 7.5/1440
		event.start_datenum = floor(event.start_datenum);
	end
	if event.end_datenum - floor(event.end_datenum) >= 1432.5/1440
		event.end_datenum = ceil(event.end_datenum);
	end
catch
	er = lasterror;
	error(er.identifier, 'Unable to parse date and/or time');
end

% Cutoff frequencies
event.f_lc = str2double(get(handles.edit_f_lc, 'String'))*1e3;
event.f_uc = str2double(get(handles.edit_f_uc, 'String'))*1e3;

% Emission type
% emission_type_choices = get(handles.popupmenu_emission_type, 'String');
% event.emission_type = emission_type_choices{get(handles.popupmenu_emission_type, 'Value')};
emissions = {};
if get(handles.checkbox_em_chorus, 'Value'), emissions{end+1} = 'chorus'; end
if get(handles.checkbox_em_hiss, 'Value'), emissions{end+1} = 'hiss'; end
if get(handles.checkbox_em_whistlers, 'Value'), emissions{end+1} = 'whistlers'; end
if get(handles.checkbox_em_other, 'Value'), emissions{end+1} = get(handles.edit_em_other, 'String'); end
if isempty(emissions)
	emissions_str = 'unchar';
else
	emissions_str = '';
	for kk = 1:length(emissions)-1
		emissions_str = [emissions_str emissions{kk} ', ']; %#ok<AGROW>
	end
	emissions_str = [emissions_str emissions{end}];
end
event.emission_type = emissions_str;

% Intensity
intensity = str2double(get(handles.edit_intensity, 'String'));
if isnan(intensity), error('Please specify a valid intensity'); end
event.intensity = str2double(get(handles.edit_intensity, 'String'));

% Particle events and geomagnetic indices
particle_event_choices = get(handles.popupmenu_particle_event, 'String');
event.particle_event = particle_event_choices{get(handles.popupmenu_particle_event, 'Value')};
event.kp = str2double(get(handles.edit_kp, 'String'));
if isnan(event.kp), event.kp = []; end
event.dst = str2double(get(handles.edit_dst, 'String'));
if isnan(event.dst), event.dst = []; end

% Notes
event.notes = get(handles.edit_notes, 'String');

% Write the file
output_filename = get(handles.edit_output_db, 'String');
if exist(output_filename, 'file')
	load(output_filename, 'events');
	assert(exist('events', 'var') == 1)
	try
		event = ecg_find_event_time_overlap(events, event); %#ok<NODEF>
		events = ecg_add_event(events, event); %#ok<NASGU>
		
		ecg_clear_fields(handles, false); % Clear fields
	catch er
		if strcmp(er.identifier, 'ecg_find_event_time_overlap:FoundOverlappingEvent')
			errordlg(er.message, 'Unable to save event');
		else
			rethrow(er);
		end
	end
else
	events = ecg_add_event([], event); %#ok<NASGU>
end

save(output_filename, 'events');

disp(sprintf('Updated file %s', output_filename));

% Mark emission
UD = get(handles.emission_char_gui, 'UserData');
h_ax = UD.img_axis;
bIncludeCaption = get(handles.checkbox_incl_notes, 'Value');
marker_handle = ecg_add_single_emission_marker(event, h_ax, bIncludeCaption);

% Save the marker handle
if ~isfield(UD, 'marker_handles'), UD.marker_handles = []; end
UD.marker_handles = [UD.marker_handles; marker_handle];
set(handles.emission_char_gui, 'UserData', UD);

function [event, event_i, marker_handle, marker_num] = ecg_user_select_emission(handles)
% [event, event_i, markerHandle, markerNo] = ecg_user_select_emission(handles)
% 
% Let the user click on a highlighted emission and return information about
% it
% 
% marker_handle is a handle to the box and text, and marker_num is the
% number of the marker in the UD.marker_handles struct array (for if the
% calling function wants to remove it from the list or something)

% By Daniel Golden (dgolden1 at stanford dot edu) April 2008
% $Id$

%% Load UserData
UD = get(handles.emission_char_gui, 'UserData');
axes(UD.img_axis);

%% Get click
[x,y] = ginput(1);

%% Find marker
bFoundMarker = false;
for kk = 1:length(UD.marker_handles)
	rect_pos = get(UD.marker_handles(kk).r, 'Position');
	r_x = rect_pos(1);
	r_y = rect_pos(2);
	r_width = rect_pos(3);
	r_height = rect_pos(4);
	
	% Is this the box we clicked inside? If so, we've found it.
	if x >= r_x && x <= (r_x + r_width) && y >= r_y && y <= (r_y + r_height)
		bFoundMarker = true;
		break;
	end
end
if ~bFoundMarker
% 	error('ECGModEmission:NoEmissionOnClick', 'No emissions exist at that time and frequency')
	uiwait(errordlg('No emissions exist at that time and frequency', 'Invalid Selection'));
	return;
end

%% Look up event and get info
% Convert x and y coordinates into time
[hour, minute, freq] = ecg_pix_to_param([x, y]);
date_str = get(handles.edit_date, 'String');
date = datenum(date_str, 'mm/dd/yyyy') + hour/24 + minute/1440;

% Find the event in the database
load(get(handles.edit_output_db, 'String'), 'events');
event_i = find([events.start_datenum] <= date & [events.end_datenum] >= date & ...
	[events.f_lc] <= freq & [events.f_uc] >= freq);
if length(event_i) > 1
	error('Multiple events found for %s, f = %0.1f (database error)', datestr(date), freq);
elseif isempty(event_i)
	error('No events found for %s, f = %0.1f (database error)', datestr(date), freq);
end
event = events(event_i);

%% Save output parameters
marker_handle = UD.marker_handles(kk);
marker_num = kk;

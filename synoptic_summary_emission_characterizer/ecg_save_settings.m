function ecg_save_settings(handles, filename)
% ecg_save_settings(handles, filename)
% Function to save settings

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

if ~exist('filename', 'var')
	filename = 'ecg_settings.mat';
end

settings.edit_input_jpeg = get(handles.edit_input_jpeg, 'String');
settings.edit_output_db = get(handles.edit_output_db, 'String');
settings.checkbox_mark_on_load = get(handles.checkbox_mark_on_load, 'Value');
settings.checkbox_incl_notes = get(handles.checkbox_mark_on_load, 'Value');

full_settings_filename = fullfile(danmatlabroot, 'vlf', 'synoptic_summary_emission_characterizer', filename);
save(full_settings_filename, 'settings');
disp(sprintf('Saved settings to %s', full_settings_filename));

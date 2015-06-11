function ecg_load_settings(handles, filename)
% ecg_load_settings(handles, filename)
% Function to save settings

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

if ~exist('filename', 'var')
	filename = fullfile(danmatlabroot, 'vlf', 'synoptic_summary_emission_characterizer', 'ecg_settings.mat');
end

if ~exist(filename, 'file')
	error('ecg_load_settings:SettingsNotFound', 'Settings file %s not found', filename);
end
load(filename, 'settings');

set(handles.edit_input_jpeg, 'String', settings.edit_input_jpeg);
set(handles.edit_output_db, 'String', settings.edit_output_db);
set(handles.checkbox_mark_on_load, 'Value', settings.checkbox_mark_on_load);
set(handles.checkbox_incl_notes, 'Value', settings.checkbox_incl_notes);

disp(sprintf('Loaded settings from %s', filename));

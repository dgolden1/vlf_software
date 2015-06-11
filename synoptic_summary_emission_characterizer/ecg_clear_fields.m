function ecg_clear_fields(handles, bClearDate)
% ecg_clear_fields(handles)
% Don't clear date field if bClearDate is false
% Function to clear all fields

% By Daniel Golden (dgolden1 at stanford dot edu)

if ~exist('bClearDate', 'var'), bClearDate = true; end;

if bClearDate, set(handles.edit_date, 'String', ''); end
set(handles.edit_start_time, 'String', '');
set(handles.edit_end_time, 'String', '');
set(handles.edit_f_lc, 'String', '');
set(handles.edit_f_uc, 'String', '');
set(handles.checkbox_em_chorus, 'Value', 0);
set(handles.checkbox_em_hiss, 'Value', 0);
set(handles.checkbox_em_whistlers, 'Value', 0);
set(handles.checkbox_em_other, 'Value', 0);
set(handles.edit_em_other, 'Enable', 'off', 'String', '');
set(handles.edit_intensity, 'String', '');
set(handles.popupmenu_particle_event, 'Value', 1);
set(handles.edit_kp, 'String', '');
set(handles.edit_dst, 'String', '');
set(handles.edit_notes, 'String', '');

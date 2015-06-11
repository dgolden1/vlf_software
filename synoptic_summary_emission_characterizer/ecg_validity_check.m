function ecg_validity_check(handles);
% ecg_validity_check(handles);
% Function to determine that all the values are valid

date_str = get(handles.edit_date, 'String');
assert(length(date_str) == 10);
assert(date_str(3) == '/');
assert(date_str(6) == '/');
month = str2double(date_str(1:2));
assert(month >= 0 && month <= 12);
day = str2double(date_str(4:5));
assert(day >= 1 && day <= 31);
year = str2double(date_str(7:10));
assert(year >= 1900 && year <= 2100);

start_time = ecg_get_datenum_from_fields(get(handles.edit_date, 'String'), get(handles.edit_start_time, 'String'));
end_time = ecg_get_datenum_from_fields(get(handles.edit_date, 'String'), get(handles.edit_end_time, 'String'), true);
assert(end_time > start_time);

f_lc = str2double(get(handles.edit_f_lc, 'String'));
f_uc = str2double(get(handles.edit_f_uc, 'String'));
assert(f_lc < f_uc);

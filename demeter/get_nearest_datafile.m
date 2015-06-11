function [filename, start_datenum, end_datenum] = get_nearest_datafile(date_datenum)
% filename = get_nearest_datefile(date_datenum)
% 
% Get nearest data filename to data_datenum

date_datenum = datenum(date_datenum); % Allows passing a datevec argument

[year, ~] = datevec(date_datenum);

[filenames, start_datenums, end_datenums] = get_datafile_list('efield_survey', year);

idx = find(start_datenums <= date_datenum & end_datenums >= date_datenum);
assert(length(idx) < 2);


if isempty(idx)
  idx_before = find(end_datenums < date_datenum, 1, 'last');
  idx_after = find(start_datenums > date_datenum, 1, 'first');
  
  error('No files found spanning %s; nearest files are %s to %s and %s to %s', ...
    datestr(date_datenum, 31), ...
    datestr(start_datenums(idx_before), 31), datestr(end_datenums(idx_before), 31), ...
    datestr(start_datenums(idx_after), 31), datestr(end_datenums(idx_after), 31));
else
  filename = filenames{idx};
  start_datenum = start_datenums(idx);
  end_datenum = end_datenums(idx);
end

function [time, freq, P, lat, lon] = extract_survey_efield_1132_by_time(start_datenum, end_datenum)
% extract_survey_efield_1132_by_time(start_datenum, end_datenum)
% 
% Plot e-field on a map given a time range
% 
% Best to combine this plot with that from plot_ground_track(start_datenum,
% end_datenum, 'time') so that the time of the measurements is clear
% 
% Time does NOT have inter-file data gaps included; if you plot
% imagesc(time, freq, P), the data gaps between successive files will end
% up smushed together

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

%% Setup
[years, ~] = datevec([start_datenum; end_datenum]);
if years(1) ~= years(2)
  error('Year of start time (%d) and end time (%d) must be equal', ...
    years(1), years(2));
end

%% Parse data files
[filenames, start_datenums, end_datenums] = get_datafile_list('efield_survey', years(1));

%% Get list of valid files
valid_file_idx = find(end_datenums > start_datenum & start_datenums < end_datenum);

if isempty(valid_file_idx)
  error('DEMETER:NoFilesInTimeRange', 'No DEMETER survey_efield_1132 files found in %s between %s and %s', ...
    data_dir, datestr(start_datenum, 31), datestr(end_datenum, 31));
end

%% Extract data from valid files
time = [];
lat = [];
lon = [];
P = zeros(1024, 0);
for kk = 1:length(valid_file_idx)
  this_full_filename = filenames{valid_file_idx(kk)};
  
  [this_time, this_freq, this_P, this_lat, this_lon, this_alt, this_MLT, this_L] = extract_survey_efield_1132_with_gaps(this_full_filename);
  time = [time this_time(:).'];
  freq = this_freq(:);
  lat = [lat this_lat(:).'];
  lon = [lon this_lon(:).'];
  P = [P this_P];
  
%   fprintf('Extracted %s\n', just_filename(this_full_filename));
end

%% Chop off ends of data that are outside desired range
idx = time >= start_datenum & time <= end_datenum;

P = P(:, idx);
time = time(idx);
lat = lat(idx);
lon = lon(idx);

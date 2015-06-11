function ec = get_emission_stats_post_facto(start_datenum, f_lc, f_uc)
% Function to get emission statistics outside the context of the emission
% detector

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

%% Set paths
[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
%   case 'vlf-alexandria'
  case 'quadcoredan.stanford.edu'
    cleaned_data_dir = '/media/scott/user_data/dgolden/palmer_bb_cleaned';
  case 'scott.stanford.edu'
    cleaned_data_dir = '/data/user_data/dgolden/palmer_bb_cleaned';
  case {'amundsen.stanford.edu', 'shackleton.stanford.edu'}
    cleaned_data_dir = '~/scott/user_data/dgolden/palmer_bb_cleaned';
  otherwise
    error('Unknown hostname ''%s''', hostname(1:end-1));
end

%% Load data
[yy, mm, dd, HH, MM, SS] = datevec(start_datenum);
data_filename = fullfile(cleaned_data_dir, sprintf('%04d', yy), sprintf('%02d_%02d', mm, dd), ...
  sprintf('PA_%04d_%02d_%02dT%02d%02d_*_002_cleaned.mat', yy, mm, dd, HH, MM));
d = dir(data_filename);
if isempty(d)
  error('%s not found', data_filename);
elseif length(d) > 1
  error('Multiple files found matching %s', data_filename);
end
pathstr = fileparts(data_filename);

DF = load(fullfile(pathstr, d.name));
data_uncal = DF.data;
fs = DF.Fs;
sitename = standardize_sitename(char(DF.station_name(:).'));

%% Get spectrogram data and event characteristics
[T, F, P, s_periodogram, s_mediogram, s_medio_diff, data_cal] = get_data_specs(data_uncal, fs, start_datenum, sitename);
idx_lc = nearest(f_lc, F);
idx_uc = nearest(f_uc, F);
ec = get_event_characteristics(data_cal, fs, F, idx_lc, idx_uc, s_mediogram, s_medio_diff, s_periodogram, T, P, start_datenum);

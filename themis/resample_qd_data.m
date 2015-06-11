function resample_qd_data(num_min)
% Function to take the 1-minute Qin-Denton solar wind parameters and save
% only the parameters that I care about
% 
% INPUTS
% num_min: number of minutes between epochs (15 for synoptic epochs
%  (default), otherwise 1 or 5 are good choices)
% 
% Data received from http://virbo.org/QinDenton
% Information: http://www.dartmouth.edu/~rdenton/magpar/index.html

% By Daniel Golden (dgolden1 at stanford dot edu) July 2011
% $Id$

%% Setup

if ~exist('num_min', 'var') || isempty(num_min)
  num_min = 1;
end

if fpart(num_min) ~= 0 || num_min < 1
  error('num_min (%f) must be an integer greater or equal to 1', num_min);
end

% qd_source_dir = fullfile(scottdataroot, 'spacecraft', 'solarwind');
qd_source_dir = fullfile(vlfcasestudyroot, 'indices');
output_filename = fullfile(qd_source_dir, sprintf('QinDenton_%02dmin_pol_them.mat', num_min));


%% Qin Denton data
if mod(num_min, 60) == 0
  qd_filename = fullfile(qd_source_dir, 'QinDenton_hour_merged_20101229-v4.mat');
  qd_min_orig = 60;
elseif mod(num_min, 5) == 0
  qd_filename = fullfile(qd_source_dir, 'QinDenton_5min_merged_20101229-v2.mat');
  qd_min_orig = 5;
elseif num_min < 5
  qd_filename = fullfile(qd_source_dir, 'QinDenton_1min_merged_20120206-v3.mat');
  qd_min_orig = 1;
end

% Load the QD data, but exclude a bunch of variables that we don't need
% This is worth doing since the file is bloody huge
qd_orig = load(qd_filename, '-regexp', ['^(?!Bz[0-9]|'...
                                        'DOY|'...
                                        'Den_P|'...
                                        'G|'...
                                        'W|'...
                                        'Year|'...
                                        'akp|'...
                                        'hour|'...
                                        'min).*|'...
                                        ]);
                                      
% In the original version of the file I received, Time was missing one
% value, probably its last value
if length(qd_orig.Time) == length(qd_orig.Dst_v3) - 1
  qd_orig.Time(end+1) = qd_orig.Time(end) + diff(qd_orig.Time(end-1:end));
end
                                      
qd_orig.Dst_v3(qd_orig.Dst_v3 == 99999) = nan; % What the hell is this 99999 crap?  This seems to be a replacement for NaN
qd_orig.Kp_v3(qd_orig.Kp_v3 == 99) = nan; % Ditto for Kp and 99

%% Epochs onto which we're interpolating the data
end_datenum = max(qd_orig.Time(isfinite(qd_orig.Pdyn_v3))) + 15/1440;
% epoch = [datenum([1996 03 23 0 0 0]):num_min/1440:datenum([1997 09 17 0 0 0]) ... % Polar
%          datenum([2008 05 30 0 0 0]):num_min/1440:end_datenum].'; % THEMIS
epoch = datenum([1995 01 01 0 0 0]):num_min/1440:datenum(end_datenum); % All Qin-Denton time

%% Mess with QD epochs so they represent beginning of averaging period
% Add time to the Qin-Denton epochs because, at their epochs, they average
% over -dt/2 min and +dt/2 min with respect to the epoch; we want the
% average in the last dt min
time_shift = qd_min_orig/2/1440;
qd_orig.Time = qd_orig.Time + time_shift;

%% Perform the averaging
% Number of samples over which to average the original QD data
num_taps = num_min/qd_min_orig;
assert(fpart(num_taps) == 0);

fields = {'ByIMF', ...
          'BzIMF', ...
          'Pdyn', ...
          'V_SW', ...
          'Dst', ...
          'Kp', ...
         };

time_distance = distance_from_a_to_b(epoch, qd_orig.Time);
       
warning('off', 'MATLAB:interp1:NaNinY');
for kk = 1:length(fields)
  this_field = qd_orig.([fields{kk} '_v3']);
  
  if ~strcmp(fields{kk}, 'Dst') && ~strcmp(fields{kk}, 'Kp')
    this_field_status = qd_orig.([fields{kk} '_status_v3']);

    % If status is 0 (value completely unknown), throw away this value
    % Keep it if status is 1 (derived) or 2 (known)
    this_field(this_field_status < 1) = nan;
  end
  
  qd_new.(fields{kk}) = interp1(qd_orig.Time, filter(ones(1, num_taps)/num_taps, 1, this_field), epoch, 'nearest');
  
  % If time to nearest qd value is more than 10% more than the inter-sample
  % time, set this field value to nan
  qd_new.(fields{kk})(abs(time_distance) > num_min/1440*1.1) = nan;
end
warning('on', 'MATLAB:interp1:NaNinY');

qd_new.epoch = epoch;

%% AE data
ae_1min = load(fullfile(vlfcasestudyroot, 'indices', 'ae_1min.mat'));

num_taps_ae = num_min;
ae_1min_smooth = filter(ones(1, num_taps_ae)/num_taps_ae, 1, ae_1min.ae);
qd_new.AE = interp1(ae_1min.epoch, ae_1min_smooth, epoch, 'nearest');

%% Save
save(output_filename, '-struct', 'qd_new');
fprintf('Saved %s\n', output_filename);

1;

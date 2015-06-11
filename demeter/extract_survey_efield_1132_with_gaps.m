function [time, freq, P, lat, lon, alt, MLT, L] = extract_survey_efield_1132_with_gaps(filename)
% [time, freq, P, units] = extract_survey_efield_1132_with_gaps(filename)
% 
% Extract survey e-field data, interpolated with NaNs where there are data
% gaps

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

[time_orig, freq, P_orig, lat, lon, alt, MLT, L] = read_survey_efield_1132(filename);


%% Find data gaps
max_dt = 1e-4;

dt = diff(time_orig);
gap_start_time = time_orig(dt > max_dt);
gap_end_time = time_orig(find(dt > max_dt) + 1);

%% Replace data gaps with NaN
time1 = time_orig;
P1 = P_orig;
for kk = 1:length(gap_start_time)
  idx = nearest(gap_start_time(kk), time1);
  time1 = [time1(1:idx) time1(idx) + 1/86400/100 time1(idx+1:end)];
  P1 = [P1(:, 1:idx), nan(length(freq), 1), P1(:, idx+1:end)];
end

time = linspace(time1(1), time1(end), 1024);

% Intentionally interpolate across the NaNs to stuff NaNs in the data gap
warning off MATLAB:interp1:NaNinY
P = interp1(time1, P1.', time).';
warning on MATLAB:interp1:NaNinY

%% Interpolate other output arguments to new time vector
for arg = {'lat', 'lon', 'alt', 'MLT', 'L'}
  eval(sprintf('%s = interp1(time_orig, %s, time);', arg{1}, arg{1}));
end

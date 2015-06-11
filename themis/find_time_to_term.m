function [idx_darkness, time_to_term] = find_time_to_term(epoch)
% Find the time to terminator for a bunch of Palmer epochs
% 
% idx_darkness is true for epochs in darkness
% time_to_term is the time (in days) to the closest terminator, and is
%  negative if the current epoch is in daylight (idx_darkness is false)

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'chorus_hiss_coherence')); % For find_terminator.m
lat = -64.77;
lon = -64.05;
term_altitude = 100e3; % 100 km

start_datenum = floor(min(epoch));
end_datenum = floor(max(epoch))+1;

%% Termine dawn and dusk datenums over a course grid because find_terminator is expensive
epoch_week = start_datenum:7:end_datenum;
if epoch_week(end) ~= end_datenum, epoch_week(end+1) = end_datenum; end

for kk = 1:length(epoch_week)
  [dawn_datenum_week(kk), dusk_datenum_week(kk), b_sunlit_week(kk)] = ...
    find_terminator(lat, lon, term_altitude, epoch_week(kk));
end

%% Linear interpolation over days
% dawn_datenum_week and dusk_datenum_week will be nan if the station is all
% in darkness or all in sunlight for this epoch; that's ok, we want the
% resulting value to be NaN, and we'll figure out whether it's sunlit or
% not using the b_sunlit_week variable
warning('off', 'MATLAB:interp1:NaNinY');

% Time of day is cyclical, so we interpolate a complex exponential and get
% its angle; otherwise, interpolating between two numbers which span 0
% would give the wrong answer
epoch_day = start_datenum:end_datenum;
dawn_datenum_day = mod(angle(interp1(epoch_week, exp(i*fpart(dawn_datenum_week)*2*pi), epoch_day))/(2*pi), 1);
dusk_datenum_day = mod(angle(interp1(epoch_week, exp(i*fpart(dusk_datenum_week)*2*pi), epoch_day))/(2*pi), 1);

dawn_datenum = mod(angle(interp1(epoch_day, exp(i*dawn_datenum_day*2*pi), floor(epoch)))/(2*pi), 1);
dusk_datenum = mod(angle(interp1(epoch_day, exp(i*dusk_datenum_day*2*pi), floor(epoch)))/(2*pi), 1);

warning('on', 'MATLAB:interp1:NaNinY');

%% A complicated method of figuring out the time to the closest terminator
time_to_dawn = angledist(fpart(epoch)*2*pi, fpart(dawn_datenum)*2*pi, 'rad', true)/(2*pi);
time_to_dusk = angledist(fpart(epoch)*2*pi, fpart(dusk_datenum)*2*pi, 'rad', true)/(2*pi);
time_dawn_to_dusk = angledist(fpart(dawn_datenum)*2*pi, fpart(dusk_datenum)*2*pi, 'rad', true)/(2*pi);
start_datenum_is_between = angle_is_between(fpart(dawn_datenum)*2*pi, fpart(dusk_datenum)*2*pi, fpart(epoch)*2*pi, 'rad');

% For each epoch, find the two nearest samples of the terminator
nearest_epoch_week_idx = zeros(length(epoch), 2);
for kk = 1:length(epoch)
  nearest_epoch_week_idx(kk,:) = find(abs(epoch_week - epoch(kk)) <= 7, 2);
end

% If this epoch is all sunlit or in darkness and the nearest epoch for
% which we determined the terminator is all dark
idx_darkness = (time_dawn_to_dusk < 0 & start_datenum_is_between) | ...
  (time_dawn_to_dusk > 0 & ~start_datenum_is_between) | ...
  (isnan(dawn_datenum) & any(~b_sunlit_week(nearest_epoch_week_idx), 2));
time_to_term = min(abs(time_to_dawn), abs(time_to_dusk));
time_to_term(~idx_darkness) = -time_to_term(~idx_darkness);


function time_to_term = get_time_to_terminator(lat, lon, epoch)
% Get time until the nearest terminator
% time_to_term = get_time_to_terminator(lat, lon, epoch)
% 
% Get the minimum number of hours between this epoch and the nearest
% terminator (either before or after this epoch). If this hour is sunlit,
% the number is negative; if the hour is in darkness, the number is
% positive
% 
% INPUTS
% lat: latitude (degrees)
% lon: longitude (degrees)
% epoch: matlab datenum

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

altitude = 100e3; % 100 km

[dawn_datenum, dusk_datenum] = find_terminator(lat, lon, altitude, epoch);

time_to_dawn = angledist(fpart(epoch)*2*pi, fpart(dawn_datenum)*2*pi, 'rad', true)/(2*pi);
time_to_dusk = angledist(fpart(epoch)*2*pi, fpart(dusk_datenum)*2*pi, 'rad', true)/(2*pi);
time_dawn_to_dusk = angledist(fpart(dawn_datenum)*2*pi, fpart(dusk_datenum)*2*pi, 'rad', true)/(2*pi);

start_datenum_is_between = angle_is_between(fpart(dawn_datenum)*2*pi, fpart(dusk_datenum)*2*pi, fpart(epoch)*2*pi, 'rad');

if (time_dawn_to_dusk < 0 && start_datenum_is_between) || ... % day is longer than night
    (time_dawn_to_dusk > 0 && ~start_datenum_is_between) % day is shorter than night
  % In darkness
  time_to_term = min(abs(time_to_dawn), abs(time_to_dusk));
else
  % In sunlight
  time_to_term = -min(abs(time_to_dawn), abs(time_to_dusk));
end

function [dawn_datenum, dusk_datenum, b_sunlit] = find_terminator(lat, lon, altitude, this_datenum)
% [dawn_datenum dusk_datenum, b_sunlit] = find_terminator(lat, lon, altitude, this_datenum)
% Function to find the dawn and dusk terminators in days with respect to
% the given time at a given lat, lon

% INPUTS
% Altitude is in METERS
% lat, lon in degrees
% 
% OUTPUTS
% The nearest dawn and dusk datenums for each input datenum
% If the location is in all darkness or all sunlight, dawn_datenum and
%  dusk_datenum will be NaN and b_sunlit will be true if the location is in
%  all sunlight
% 
% Dawn and dusk are defined as the epoch where the sun value
% (true/false) has changed from the previous minute. So the given minute will
% actually be one minute or less AFTER dawn or dusk


% By Daniel Golden (dgolden1 at stanford dot edu) September 2009
% $Id$

%% Setup
if ~exist('altitude', 'var') || isempty(altitude)
  altitude = 0; % 0 km altitude
end

addpath(fullfile(danmatlabroot, 'vlf', 'Terminator_V7')); % Ryan's terminator code

time_resolution_days = 1/1440; % Time resolution, in fractions of a day
search_dates = (-12:time_resolution_days*24:13)/24 + this_datenum;
s = zeros(size(search_dates));
for kk = 1:length(s)
  [yy mm dd HH MM SS] = datevec(search_dates(kk));
  s(kk) = sunshine(lat, lon, altitude, false, yy, mm, dd, HH, MM, SS);
end

% s_diff is +1 when going from dark to light, -1 when going from light to
% dark, 0 otherwise
s_diff = diff(s);

% Find dawn
dawn_datenum_i = find(s_diff == 1);
if isempty(dawn_datenum_i)
  dawn_datenum = nan;
else
  if length(dawn_datenum_i) > 1
    assert(length(dawn_datenum_i) == 2);
    dawn_dist = abs(search_dates(dawn_datenum_i) - this_datenum);
    dawn_datenum_i = dawn_datenum_i(find(dawn_dist == min(dawn_dist), 1, 'first'));
  end
  dawn_datenum = search_dates(dawn_datenum_i);
end

% Find dusk
dusk_datenum_i = find(s_diff == -1);
if isempty(dusk_datenum_i)
  dusk_datenum = nan;
else
  if length(dusk_datenum_i) > 1
          assert(length(dusk_datenum_i) == 2);
          dusk_dist = abs(search_dates(dusk_datenum_i) - this_datenum);
          dusk_datenum_i = dusk_datenum_i(find(dusk_dist == min(dusk_dist), 1, 'first'));
  end
  dusk_datenum = search_dates(dusk_datenum_i);
end

if any(s)
  b_sunlit = true;
else
  b_sunlit = false;
end

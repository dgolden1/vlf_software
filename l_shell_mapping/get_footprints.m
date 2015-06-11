function [lat_n, lon_n, lat_s, lon_s] = get_footprints(date_datenum, L, MLT, footprint_altitude)
% [lat_n, lon_n, lat_s, lon_s] = get_footprints(date_datenum, L, MLT, footprint_altitude)
% Get field line footprints on the Earth's surface given an L-shell and MLT
% 
% [lat_n, lon_n, lat_s, lon_s] = get_footprints(date_datenum, L, MLT, altitude)
% 
% In SM coordinates, MLT is defined as mod(atant(sm_y, sm_x)*24/(2*pi) +
% 12, 24)
% 
% INPUTS
% date_datenum: date (scalar, matlab datenum)
% L: L-shell (vector, earth radii)
% MLT: magnetic local time (vector, hours).  In SM coordinates, MLT is defined as
%  mod(atant(sm_y, sm_x)*24/(2*pi) + 12, 24)
% altitude: altitude of the footprint (scalar, km)
% 
% OUTPUTS
% latitudes and longitudes of the footprints in the northern and southern
% hemispheres

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

%% Check arguments
assert(isscalar(date_datenum));
assert(isscalar(footprint_altitude));
assert(all(size(L) == size(MLT)));

if any(L > 15)
  error('CGM is totally not valid for L > ~10');
end

%% Setup
R0 = 6371; % km
delta_pt = .1;

lon_sm_in = repmat(mod(MLT(:) + 12, 24)*360/24, 2, 1).'; % Make row vector and copy so we have values for both north and south
lat_sm_in = zeros(size(lon_sm_in));
geo_sm_flag = zeros(size(lon_sm_in)); % 0 meaning sm coordinates

ds = delta_pt*[-ones(1,length(lon_sm_in)/2),ones(1,length(lon_sm_in)/2)];

alt_start = repmat(R0*(L(:) - 1).', 1, 2); % altitude at the equator at this L shell, km
alt_terminate = footprint_altitude*ones(size(lon_sm_in));

r_start = 1 + alt_start/R0; % km
r_finish = 1 + alt_terminate/R0; % km

%% Run trace
[L_out, lat_out, lon_out, num_steps] = trace_L_shell(r_start, lat_sm_in, lon_sm_in, ds, geo_sm_flag, r_finish, datevec(date_datenum));

%% Reshape output
lat_n = reshape(lat_out(1:end/2), size(L));
lon_n = reshape(lon_out(1:end/2), size(L));

lat_s = reshape(lat_out(end/2+1:end), size(L));
lon_s = reshape(lon_out(end/2+1:end), size(L));

function [palmer_distances, l_lats, l_lons] = palmer_distance_to_l(l_shells, viewing_angle)
% Function to determine the distance from Palmer to near L-shells
% 
% INPUTS
% l_shells: list of L-shells to calculate distances to
% viewing_angle: determine the furthest distance for a given viewing angle
% (e.g., don't give the closest point, but give a point n degrees off from
% it)
% 
% OUTPUTS
% distances: in km
% l_lats: latitudes of the point on the l-shell to which we're measuring
% l_lons: longitudes of the point on the l-shell to which we're measuring

% By Daniel Golden (dgolden1 at stanford dot edu) February 25
% $Id$

%% Setup
error(nargchk(1, 2, nargin));

if ~exist('viewing_angle', 'var') || isempty(viewing_angle)
	viewing_angle = 0;
elseif viewing_angle ~= 0
	error('Viewing angles other than 0 are not supported at this time');
end

L_SHELL_MAP_PATH = '/home/dgolden/vlf/vlf_software/dgolden/l_shell_mapping';

% Palmer's geocentric coordinates
PALMER_LAT = -64.77;
PALMER_LON = -64.05;

num_pts = 500; % Number of points to plot for each l-shell
alt = 100; % Altitude of l-shell
irgrf_date = [2001 01 01 0 0 0]; % Date for IGRF model

%% Get L-shell lines and calculate distances and angles
distances = zeros(length(l_shells), num_pts);
azimuths = zeros(length(l_shells), num_pts);

% Although we collect lats and lons for north and south L-shells, we'll
% only work with the south ones
curdir = pwd;
cd(L_SHELL_MAP_PATH);
[lats_n,lons_n,lats_s,lons_s] = LShell_lines(irgrf_date,l_shells,num_pts,alt);
cd(curdir);

earth_ellipsoid = almanac('earth','grs80','degrees');
for kk = 1:length(l_shells)
% 	for ll = 1:num_pts
		[distances(kk, :), azimuths(kk, :)] = distance(PALMER_LAT, PALMER_LON, lats_s(kk, :), lons_s(kk, :), ...
			earth_ellipsoid, 'degrees');
		distances(kk, :) = distdim(distances(kk,:), 'degree', 'km');
% 	end
end

%% Find the distances based on an azimuth filter
nearest_dist = zeros(length(l_shells), 1);
nearest_az = zeros(length(l_shells), 1);
spec_dist = zeros(length(l_shells), 1);
spec_az = zeros(length(l_shells), 1);
palmer_distances = zeros(length(l_shells), 1);
l_lats = zeros(length(l_shells), 1);
l_lons = zeros(length(l_shells), 1);

for kk = 1:length(l_shells)
	% First, find the closest point on each l-shell
	nearest_i = find(distances(kk,:) == min(distances(kk,:)));
	nearest_dist(kk) = distances(kk,nearest_i);
	nearest_az(kk) = azimuths(kk,nearest_i);
	
% 	% Find the distance to the azimuth at the viewing angle
% 	minaz = min([angledist(azimuths(kk,:), nearest_az(kk) + viewing_angle); ...
% 		angledist(azimuths(kk,:), nearest_az(kk) - viewing_angle)]);
	
	
% 	spec_i = find(minaz == min(minaz), 1, 'first');

% 	window_az = angledist(azimuths(kk,:), nearest_az(kk)) <= viewing_angle;
% 	spec_i = find(distances(~window_az) == min(distances(~window_az)), 1, 'first');

% 	palmer_distances(kk) = distances(kk,spec_i);

	palmer_distances(kk) = nearest_dist(kk);
	spec_i = nearest_i;

	l_lats(kk) = lats_s(kk, spec_i);
	l_lons(kk) = lons_s(kk, spec_i);
end

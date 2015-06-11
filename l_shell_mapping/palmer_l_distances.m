% Script to map L-shells and show various distances from Palmer

% By Daniel Golden (dgolden1 at stanford dot edu) April 2008
% $Id$

%% Setup
close all;
clear;

% Palmer lat and lon
p_lat = -64.77;
p_lon = -64.05;

%% Create map
figure
axesm('MapProjection', 'eqaazim', 'flatlimit', [-Inf 22], 'Origin', [p_lat p_lon 0], 'Frame', 'on');
land = shaperead('landareas.shp', 'UseGeoCoords', true);
geoshow([land.Lat], [land.Lon], 'Color', [0.1 0.1 0.1]);

% Political boundaries
[pol_lat, pol_lon] = get_pol_lat_lon;
geoshow(pol_lat, pol_lon, 'Color', [0.5 0.5 0.5]);

% Plot Palmer
plotm(p_lat, p_lon, 'r+', 'MarkerSize', 10);


%% Plot distances
dist_vec = [200 500 1000 1500 2000];

azimuths = [0:5:360];
lats = zeros(size(azimuths));
lons = zeros(size(azimuths));
for kk = 1:length(dist_vec)
	dist_deg = km2deg(dist_vec(kk));
	for jj = 1:length(azimuths)
		[lats(jj), lons(jj)] = reckon(p_lat, p_lon, dist_deg, azimuths(jj));
	end
	
	plotm(lats, lons, 'r');
% 	hold on;
	textm(lats(azimuths == 15), lons(azimuths == 15), sprintf('%d km', dist_vec(kk)), 'Color', 'r');
end

% Make the figure window square
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1:2) max(pos(3:4)) max(pos(3:4))]);

%% Overlay L-shells
l_shells = [2 3 4 5 6];
[lats_n,lons_n,lats_s,lons_s] = LShell_lines([2001 1 1 0 0 0],l_shells,100,100);
for kk = 1:length(l_shells)
	plotm(lats_s(kk,:), lons_s(kk,:), 'b-');
	
	i = find(angledist(lons_s(kk,:), p_lon) == min(angledist(lons_s(kk,:), p_lon)), 1);
	textm(lats_s(kk,i), lons_s(kk,i), sprintf('L=%d', l_shells(kk)), 'Color', 'b');
end

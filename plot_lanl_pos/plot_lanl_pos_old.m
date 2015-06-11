% Plot LANL satellite locations with respect to Palmer
% By Daniel Golden (dgolden1 at stanford dot edu) Oct 15, 2007

% $Id:plot_lanl_pos_old.m 19 2007-10-25 23:00:38Z dgolden $

%% Setup

close all;
clear;

az_0 = 270; % Azimuth of the 0-meridian when looking from the South pole

%% Create the map

% h = worldmap('south pole');
h = worldmap('world');
setm(h, 'Origin', [-90 0 az_0]);
% setm(h, 'mapprojection', 'ortho');
% setm(h, 'mapprojection', 'eqaazim');
setm(h, 'mapprojection', 'eqaazim', 'flatlimit', [-inf 90]);
% setm(h, 'maplatlimit', [-90 0]);
land = shaperead('landareas.shp', 'UseGeoCoords', true);
geoshow([land.Lat], [land.Lon], 'Color', 'k');
% mat = getm(h);

setm(gca,'FFaceColor','w');
set(gcf, 'Color', 'w');

%% Mark Palmer
plotm(-64.77, -64.05, 'r*', 'MarkerSize', 12);
textm(-64.77, -64.05, '  Palmer');


%% Mark satellites

sat_names = {'LANL-01A', 'LANL-02A', 'LANL-97A', '1994-084', '1991-080', '1990-095'};
sat_lon =   [ 7.92        69.47       103.66      144.77      -164.88     -38.25]; % Accurate on July 1, 2003
sat_altitudes = repmat(6.6, 1, length(sat_lon)); % R_geo = 6.6*Re
% sat_lat = repmat(-61, 1, length(sat_lon));
% plotm(sat_lat, sat_lon, 'b*', 'MarkerSize', 8);

% Kooky stuff to convert from map coordinates to x-y coordinates so we can
% plot off of the globe
Re = sqrt(2); % Found using [x, y] = projfwd(defaultm('eqaazim'), -90, 0)
r = 1.5*Re; % An aesthetically pleasing radius
sat_x = r*sin((sat_lon + az_0)*pi/180);
sat_y = r*cos((sat_lon + az_0)*pi/180);

leading_spaces = 2;
for kk = 1:length(sat_names)
	plot(sat_x(kk), sat_y(kk), 'b*', 'MarkerSize', 8);
% 	textm(sat_lat(kk), sat_lon(kk), [repmat(' ', 1, leading_spaces) sat_names{kk}]);
	text(sat_x(kk), sat_y(kk), [repmat(' ', 1, leading_spaces) sat_names{kk}]);
end

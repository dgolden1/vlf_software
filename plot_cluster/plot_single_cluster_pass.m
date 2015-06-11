function plot_single_cluster_pass(cluster_filename)
% Plot a single day of cluster passing... near Palmer?

% By Daniel Golden (dgolden1 at stanford dot edu) May 2009
% $Id$

% close all;
% clear;

%% Setup
output_dir = '/home/dgolden/vlf/case_studies/cluster_palmer_2001_2002/cluster_position/maps';

%% Get cluster positions
if ~exist('cluster_filename', 'var') || isempty(cluster_filename)
	cluster_filename = '2001-02-23_cluster';
end
pos_struct = load_cluster_file(cluster_filename);

%% Create world map
sfigure(1); clf;
h = worldmap('world');
hold on;
setm(gca,'FFaceColor','w');
setm(h,'gcolor',[.2,.2,.2])
land = shaperead('landareas.shp', 'UseGeoCoords', true);
geoshow([land.Lat], [land.Lon], 'Color', [0.1 0.1 0.1]);
[pol_lat, pol_lon] = get_pol_lat_lon;
plotm(pol_lat, pol_lon, 'Color', [0.5 0.5 0.5]);
set(gca, 'Position', [0.05 0 0.9 0.97]); % Let the map fill the entire figure

%% Plot Palmer, Palmer conjugate, and a few distances
% Plot Palmer and conjugate
p_lat = [-65.30, 40.06];
p_lon = [-64.43, -69.43];
plotm(p_lat, p_lon, 'ro', 'MarkerSize', 10, 'markerfacecolor', 'r');

% Plot some distances
dist_vec = [500 1000 2000];

azimuths = [0:5:360];
lats = zeros(size(azimuths));
lons = zeros(size(azimuths));
for ii = 1:2
	for kk = 1:length(dist_vec)
		dist_deg = km2deg(dist_vec(kk));
		for jj = 1:length(azimuths)
			[lats(jj), lons(jj)] = reckon(p_lat(ii), p_lon(ii), dist_deg, azimuths(jj));
		end

		plotm(lats, lons, 'g');
	% 	hold on;
		textm(lats(azimuths == 30), lons(azimuths == 30), sprintf('%d km', dist_vec(kk)), 'Color', 'k');
	end
end

%% Plot cluster paths
for kk = 1:4
	% Extract data for this satellite
	this_pos_struct = pos_struct([pos_struct.sat] == kk);
	
	% Get ground traces in north and south hemispheres; discard invalid
	% (NaN) values. There's no need to differentiate between north and
	% south traces. It's syntactically complicated to convert from a
	% multidimensional struct field to get what we want, but this works.
	northbtrace = cell2mat({this_pos_struct.northbtrace}.');
	southbtrace = cell2mat({this_pos_struct.southbtrace}.');
	
	valid_nbt_i = find(~isnan(northbtrace(:,3)));
	valid_sbt_i = find(~isnan(southbtrace(:,3)));
	valid_bt_i = [valid_nbt_i; valid_sbt_i];
	btrace = [northbtrace(valid_nbt_i, :); southbtrace(valid_sbt_i, :)];
	dates = [this_pos_struct(valid_bt_i).date];
	
	% Assign color and size values to points based on path length and time
	color_values = fpart(dates);
	distances = min(btrace(:,3), 20); % Clip path lengths at 20 Re
	size_values = 20./distances*10;
	
	h = scatterm(btrace(:,1), btrace(:,2), size_values, color_values);
end
caxis([0 1]);
c = colorbar;
datetick(c, 'y', 'keeplimits');
title(strrep(cluster_filename, '_', '\_'));

%% Save png
if ~isempty(output_dir)
	print('-dpng', fullfile(output_dir, cluster_filename));
end

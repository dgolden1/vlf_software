function plot_pcolor_map(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, mapstr, X_matrix, cax, clabel, cmap)
% plot_pcolor_map(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, mapstr, X_matrix, cax, clabel, cmap)
% Support function for hiss_nldn_superposed_epoch

% By Daniel Golden (dgolden1 at stanford dot edu) July 2009
% $Id$

%% Setup
% Palmer conjugate coords
p_lat = 40.06;
p_lon = -69.43;

%% Play with colors and other stuff
% colormap(jet_with_white);
% caxis([-6 -2]);
if ischar(cmap) && strcmp(cmap, 'hotcold')
	cmap = str2func(cmap); cmap = cmap(); % Now cmap is an nx3 index of color values (the literal colormap)
	assert(size(cmap, 1) == 64);
	
	% Colorbar surrounding data
	cax = max(abs(X_matrix(isfinite(X_matrix))))*[-1*33/32 1]; % Surround all the data, plus a little extra for the nans
	
% 	% Fixed colorbar
% 	cax = [-1*33/32 1]; % Surround all the data, plus a little extra for the nans
% 	X_matrix(X_matrix < -1) = -1;
% 	X_matrix(X_matrix > 1) = 1;
	
	cmap = [[0.8 0.8 0.8]; cmap];
	X_matrix_withnans = X_matrix;
	X_matrix_withnans(isnan(X_matrix_withnans)) = cax(1);
elseif ~isempty(cax)
	X_matrix_withnans = X_matrix;
else
	X_matrix_withnans = X_matrix;
	cax = [min(flatten(X_matrix(isfinite(X_matrix)))), max(flatten(X_matrix(isfinite(X_matrix))))];
end

%% Load map and plot pcolor
figure('Color','white');
% Matlab has a bug where it turns cells of a pcolor plot that are touching
% the border white; egads! We'll extend the range of the map lat and lon limits a little
axesm('MapProjection', 'lambert', 'MapLatLimit', [lat_min - 0.5, lat_max + 0.5], 'MapLonLimit', [lon_min - 0.5, lon_max + 0.5], ...
	'frame', 'on', 'grid', 'on', 'meridianlabel', 'on', 'parallellabel', 'on');
tightmap on;
axis off;

p = pcolorm(bin_lat, bin_lon, X_matrix_withnans);
% pcolorm(bin_lat, bin_lon, N_norm_total);

%% Plot country and state boundaries
geoshow('landareas.shp', 'FaceColor',  'none');
geoshow('usastatelo.shp', 'FaceColor',  'none');

%% Plot Palmer conjugate point (IGRF)
% Plot Palmer conjugate
plotm(p_lat, p_lon, 'kx', 'MarkerSize', 10);

% Plot some distance circles
dist_vec = [500 1000 2000];

azimuths = 0:5:360;
lats = zeros(size(azimuths));
lons = zeros(size(azimuths));

for kk = 1:length(dist_vec)
	dist_deg = km2deg(dist_vec(kk));
	for jj = 1:length(azimuths)
		[lats(jj), lons(jj)] = reckon(p_lat, p_lon, dist_deg, azimuths(jj));
	end

	plotm(lats, lons, 'color', [0.5 0.5 0.5]);
% 	hold on;
	textm(lats(azimuths == 200), lons(azimuths == 200), sprintf('%d km', dist_vec(kk)), 'Color', 'k');
end

%% Final messing with figure color, title and size
caxis(cax);
colormap(cmap);
c = colorbar;
ylabel(c,  clabel);

title(mapstr);

figure_squish(gcf, 0.8, 1);

increase_font(gcf, 14);

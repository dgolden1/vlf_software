function hiss_nldn_sp_epoch_plotter_diff(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, mapstr, N_norm_total_hiss, N_norm_total_nohiss)
% Support function for hiss_nldn_superposed_epoch for plotting the
% difference between maps when there is and isn't hiss

% By Daniel Golden (dgolden1 at stanford dot edu) July 2009
% $Id$


figure('Color','white');
axesm('MapProjection', 'lambert', 'MapLatLimit', [lat_min lat_max], 'MapLonLimit', [lon_min lon_max], ...
	'frame', 'on', 'grid', 'on', 'meridianlabel', 'on', 'parallellabel', 'on');
tightmap on;
axis off;

p = pcolorm(bin_lat, bin_lon, log10(N_norm_total_hiss) - log10(N_norm_total_nohiss));
% pcolorm(bin_lat, bin_lon, N_norm_total);
geoshow('landareas.shp', 'FaceColor',  'none');
geoshow('usastatelo.shp', 'FaceColor',  'none');

colormap(jet_with_white);
cax = caxis;
caxis(max(abs(cax))*[-1 1]);
colormap(hotcold);
c = colorbar;
ylabel(c, 'log_{10} num flashes/km^2/hour');

title(mapstr);

figure_squish(gcf, 0.8, 1);

increase_font(gcf, 14);

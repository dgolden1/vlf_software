% function plot_gnd_power(f_vec, L_vec)
% plot_gnd_power(f_vec, L_vec)
% Plot ground power from whistler FWM code

% -X IS POLEWARD

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Setup
input_dir = '/home/dgolden/vlf/vlf_software/dgolden/fwm_whistler';
% input_dir = '/media/vlf-alexandria-array/data_products/dgolden/output';

input_file = 'fwm3d_f0750_l300.mat';

b_do_3d_gnd_plot = 1;
b_do_3d_slice_plot = 1;
b_do_2d_plot = 1;
b_do_global_gnd_plot = 1;

load(fullfile(input_dir, input_file));

%% P2, P3 Params
lat_p2 = -85.67;
lon_p2 = 313.62;
lat_p3 = -82.75;
lon_p3 = 28.59;
dist_p2_p3 = deg2km(distance(lat_p2, lon_p2, lat_p3, lon_p3));

lat_spole = -63.5;
lon_spole = 138;

% x_min = xkm(1);
% x_max = xkm(end);
% y_min = ykm(1);
% y_max = ykm(end);
% 
% [north_edge(1) north_edge(2)] = reckon(lat_p2, lon_p2, km2deg(abs(x_max)), 0);
% [east_edge(1) east_edge(2)] = reckon(lat_p2, lon_p2, km2deg(abs(y_min)), 90);
% [south_edge(1) south_edge(2)] = reckon(lat_p2, lon_p2, km2deg(abs(x_min)), 180);
% [west_edge(1) west_edge(2)] = reckon(lat_p2, lon_p2, km2deg(abs(y_max)), 270);

% Bearing from P2 to south geomagnetic pole
azim_p2_pole = azimuth(lat_p2, lon_p2, lat_spole, lon_spole);

[Xkm, Ykm] = meshgrid(xkm, ykm);
lats = zeros(size(Xkm));
lons = zeros(size(Xkm));

% Align -x axis with direction of south magnetic pole
[lats, lons] = reckon(lat_p2, lon_p2, km2deg(sqrt(Xkm.^2 + Ykm.^2)), -(atan2(Xkm, Ykm) - pi/2)*180/pi + azim_p2_pole - 180);


%% 3-D Slice plot
	x_p2 = 0;
	y_p2 = 0;
	direc_p2_north = -azim_p2_pole;
	direc_p2_p3 = azimuth(lat_p2, lon_p2, lat_p3, lon_p3);
	direc_xy_p2_p3 = direc_p2_p3 - direc_p2_north;
	
	start_pt = [x_p2, y_p2];
	end_pt = [x_p2 + dist_p2_p3*cos(direc_xy_p2_p3*pi/180), y_p2 + dist_p2_p3*sin(direc_xy_p2_p3*pi/180)];
	

	B_log_mag = squeeze(10*log10(sum(abs(B/1e-15).^2))); % dB-fT
	
	xvals = linspace(start_pt(1), end_pt(1), 50);
	yvals = linspace(start_pt(2), end_pt(2), 50);
	zvals = zkm;
	dvals = linspace(0, dist_p2_p3, 50);
	
	[Xkm, Zkm, Ykm] = meshgrid(xkm, zkm, ykm);
	[Xvals, Zvals, Yvals] = meshgrid(xvals, zvals, yvals);
	B_slice = interp3(Xkm, Zkm, Ykm, B_log_mag, xvals, zvals, yvals);
	B_slice = B_slice(:, logical(eye(50)));
	
if b_do_3d_slice_plot
	figure;
	imagesc(dvals, zvals, B_slice.');
	axis xy equal tight;
	xlabel('distance (km)');
	ylabel('z (km)');
	title(sprintf('B-field on ground (f = %04d Hz, L = %0.2f)', f, L));
	c = colorbar;
	set(get(c, 'ylabel'), 'string', 'dB-fT');
	increase_font(gcf, 16);
	figure_squish(gcf, 1/2, 2);
end

%% 3-D Ground Plot
if b_do_3d_gnd_plot
	B_gnd = squeeze(B(:,1,:,:)); %#ok<COLND>

	figure;
	imagesc(xkm, ykm, squeeze(10*log10(sum(abs(B_gnd/1e-15).^2))).');
	axis xy equal tight;
	xlabel('x (km)');
	ylabel('y (km)');
	title(sprintf('B-field on ground (f = %04d Hz, L = %0.2f)', f, L));
	c = colorbar;
	set(get(c, 'ylabel'), 'string', 'dB-fT');
	increase_font(gcf, 16);
end

%% Global ground plot
if b_do_global_gnd_plot
	figure
	axesm('MapProjection', 'eqaazim', 'flatlimit', [-Inf 22], 'Origin', [lat_p2 lon_p2 0], 'Frame', 'on');
	land = shaperead('landareas.shp', 'UseGeoCoords', true);
	geoshow([land.Lat], [land.Lon], 'Color', [0.1 0.1 0.1]);

	pcolorm(lats, lons, squeeze(10*log10(sum(abs(B(:,1,:,:)/1e-15).^2))).');

	% Plot p2, p3
	p = plotm(lat_p2, lon_p2, 'ko', 'MarkerFaceColor', 'b', 'MarkerSize', 8);
	textm(lat_p2, lon_p2, '  P2');
	p = plotm(lat_p3, lon_p3, 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 8);
	textm(lat_p3, lon_p3, '  P3');
	
	gridm on;
	
	c = colorbar;
	set(get(c, 'ylabel'), 'string', 'dB-fT');
	increase_font(gcf, 16);
	
	title(sprintf('750-Hz wave injected at P2 (dip angle=%0.1f deg)', 90-thB*189/pi));
end

%% 2-D superimposed plot
if b_do_2d_plot
	figure;
	plot(dvals, B_slice(1,:), 'LineWidth', 2);

	grid on;
	xlabel('distance (km)');
	ylabel('db-fT');
	title('Ground power from P2 to P3');
	increase_font(gcf, 16);
end

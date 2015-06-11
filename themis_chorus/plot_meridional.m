function plot_meridional(L_edges, L_centers, lat_edges, lat_centers, value, varargin)
% Plot some quantity in a meridional plane using imagesc and a regular grid
% plot_meridional(L_edges, L_centers, lat_edges, lat_centers, value, 'param', value, ...)
% 
% PARAMETERS
% cax: color axis
% b_interp: if true, plot values as cartesian linear interpolation between
%  bin centers; if false (default), plot each bin as its own color
% outer_direc: direction of higher L shells; either 'right' (default) or
%  'left'
% earth_color: color of the solid earth (default: 'k')
% h_ax: axis on which to plot

% Value should have L down the rows and lat across the columns; it should
% not have an index for MLT

%% Parse input parameters
p = inputParser;
p.addParamValue('cax', quantile(value(:), [0 1]));
p.addParamValue('b_interp', false);
p.addParamValue('outer_direc', 'right');
p.addParamValue('earth_color', 'k');
p.addParamValue('h_ax', []);
p.parse(varargin{:});
cax = p.Results.cax;
b_interp = p.Results.b_interp;
outer_direc = p.Results.outer_direc;
earth_color = p.Results.earth_color;
h_ax = p.Results.h_ax;

%% Set up regular grid
n_grid_pts = 250;
grid_x = linspace(0, 10, n_grid_pts);
grid_y = linspace(0, 10, n_grid_pts);
[grid_X, grid_Y] = meshgrid(grid_x, grid_y);

%% Get latitude and L for each pixel
grid_Lat = atan2(grid_Y, grid_X)*180/pi; % Degrees
grid_R = sqrt(grid_X.^2 + grid_Y.^2);
grid_L = grid_R./cos(grid_Lat*pi/180).^2;

%% Get the L and latitude bins that each pixel falls in
[~, bin_L_idx] = histc(grid_L, L_edges);
[~, bin_lat_idx] = histc(grid_Lat, lat_edges);
bin_L_idx(bin_L_idx == 0 | bin_L_idx == length(L_edges)) = nan;
bin_lat_idx(bin_lat_idx == 0 | bin_lat_idx == length(lat_edges)) = nan;
bin_mat_idx = sub2ind(size(value), bin_L_idx, bin_lat_idx);
idx_valid = isfinite(bin_mat_idx);

%% Set grid values
if b_interp
  [L_mat, lat_mat] = ndgrid(L_centers, lat_centers);
  R_mat = L_mat.*cos(lat_mat*pi/180).^2;
  X_mat = R_mat.*cos(lat_mat*pi/180);
  Y_mat = R_mat.*sin(lat_mat*pi/180);
  F = TriScatteredInterp(X_mat(:), Y_mat(:), value(:), 'linear');
  grid_val = F(grid_X, grid_Y);
else
  % Set the value of each pixel to be the value of its bin
  grid_val = nan(size(grid_X));
  grid_val(idx_valid) = value(bin_mat_idx(idx_valid));
end

%% Plot using colormap with white background (for NaNs)
if isempty(h_ax)
  figure;
else
  saxes(h_ax);
end

grid_val(grid_val < cax(1)) = cax(1); % Clip small values of the data, or else they'll show up as white
[new_image_data, new_color_map, new_cax] = colormap_white_bg(grid_val, jet(64), cax);

if strcmp(outer_direc, 'left')
  grid_x = -grid_x;
end

imagesc(grid_x, grid_y, new_image_data);
colormap(new_color_map);
caxis(new_cax);
axis xy equal;

%% Overlay R/L/lat grid
r_max = 10;
make_lat_plot_grid('h_ax', gca, 'R_max', r_max, 'R_gridlines', 2:10, 'lat_gridlines', 0:10:90, ...
  'L_gridlines', 2:10, 'outer_direc', outer_direc, 'earth_color', earth_color);

if strcmp(outer_direc, 'left')
  axis([-1 0 0 0.5]*r_max);
else
  axis([0 1 0 0.5]*r_max);
end

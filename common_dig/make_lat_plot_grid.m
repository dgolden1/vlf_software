function h_ax = make_lat_plot_grid(varargin)
% h_ax = make_lat_plot_grid('param', value)
% Make a grid background for plotting something vs. L and latitude
% 
% PARAMETERS
% R_max: max R to plot (default: 6)
% lat_gridlines: array of R values on which to plot grid lines (default: 2:6)
% lat_gridlines: array of latitudes on which to plot grid lines (default: -90:15:90)
% L_gridlines: array of L shells on which to plot grid lines (default:
%  none)
% solid_lines_R: some R lines to make solid (default: [])
% linecolor: line style
% earth_color: color of the solid earth (default: 'k')
% outer_direc: direction of higher L shells; either 'right' (default) or
%  'left'
% h_ax: axis handle on which to plot (makes a new figure by default)
% 
% OUTPUT
% h_ax: axis handle

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Parse arguments
p = inputParser;
p.addParamValue('R_max', 6);
p.addParamValue('R_gridlines', nan);
p.addParamValue('lat_gridlines', -90:15:90);
p.addParamValue('L_gridlines', []);
p.addParamValue('solid_lines_R', []);
p.addParamValue('linecolor', 'k');
p.addParamValue('earth_color', 'k');
p.addParamValue('outer_direc', 'right');
p.addParamValue('h_ax', []);
p.parse(varargin{:});
R_max = p.Results.R_max;
R_gridlines = p.Results.R_gridlines;
lat_gridlines = p.Results.lat_gridlines;
L_gridlines = p.Results.L_gridlines;
solid_lines_R = p.Results.solid_lines_R;
linecolor = p.Results.linecolor;
earth_color = p.Results.earth_color;
outer_direc = p.Results.outer_direc;
h_ax = p.Results.h_ax;

if ~all(isfinite(R_gridlines))
  R_gridlines = 2:R_max;
end

%% Make figure if requested
if isempty(h_ax)
  figure;
else
  saxes(h_ax);
end

%% Overlay grids
hold on; 

theta_R = linspace(min(lat_gridlines), 90, 50)*pi/180;
if strcmp(outer_direc, 'left')
  theta_R = -theta_R + pi;
end

% R grid
for kk = 1:length(R_gridlines)
	plot(R_gridlines(kk)*cos(theta_R), R_gridlines(kk)*sin(theta_R), '--', 'color', linecolor);
end
for kk = 1:length(solid_lines_R)
  plot(solid_lines_R(kk)*cos(theta_R), solid_lines_R(kk)*sin(theta_R), '-', 'color', linecolor, 'LineWidth', 2);
end

% L grid
for kk = 1:length(L_gridlines)
  R_L = L_gridlines(kk)*cos(theta_R).^2;
  idx_L = R_L > 1 & R_L < R_max;
  plot(R_L(idx_L).*cos(theta_R(idx_L)), R_L(idx_L).*sin(theta_R(idx_L)), '-.', 'color', linecolor);
end

theta_lat = lat_gridlines*pi/180;
if strcmp(outer_direc, 'left')
  theta_lat = -theta_lat + pi;
end

% latitude grid
for kk = 1:length(theta_lat)
  if isempty(R_gridlines) && ~isempty(L_gridlines)
    % Only extend the latitude line to the biggest L shell, or else it
    % looks weird
    lat_R_max = max(1, max(L_gridlines)*cos(theta_lat(kk))^2);
  else
    lat_R_max = R_max;
  end
  
	plot([1 lat_R_max]*cos(theta_lat(kk)), [1 lat_R_max]*sin(theta_lat(kk)), '--', 'color', linecolor);
end

axis equal

%% Draw earth
theta_earth = [linspace(min(lat_gridlines), 90, 50) 0 min(lat_gridlines)].'*pi/180;
if strcmp(outer_direc, 'left')
  theta_earth = -theta_earth + pi;
end

r_earth = [ones(50, 1); 0; 1];
% plot(cos(theta_earth), sin(theta_earth), 'k', 'linewidth', 2);
fill(r_earth.*cos(theta_earth), r_earth.*sin(theta_earth), earth_color, 'linewidth', 2);

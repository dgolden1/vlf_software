function h_ax = make_mlt_plot_grid(varargin)
% h_ax = make_mlt_plot_grid('param', value)
% Make a grid background for plotting something vs. L and MLT
% 
% PARAMETERS
% L_max: max L to plot (default is 6)
% MLT_gridlines: array of MLTs on which to plot grid lines (default: 0:23)
% h_ax: axis handle on which to plot (makes a new figure by default)
% sun_dir: directions of sun (noon MLT); one of 'right' (default), 'left', 'up'
% or 'down'
% solid_lines_L: some L lines to make solid (default: [])
% 
% OUTPUT
% h_ax: axis handle

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Parse arguments
p = inputParser;
p.addParamValue('L_max', 6);
p.addParamValue('MLT_gridlines', 0:23);
p.addParamValue('h_ax', []);
p.addParamValue('sun_dir', 'right');
p.addParamValue('solid_lines_L', []);
p.parse(varargin{:});

%% Make figure if requested
if isempty(p.Results.h_ax)
  figure;
else
  saxes(p.Results.h_ax);
end

%% Overlay grids
L_max = p.Results.L_max;

hold on; 
theta_L = linspace(0, 2*pi, 100);
L_grid = 2:L_max;

% L grid
for kk = 1:length(L_grid)
	plot(L_grid(kk)*cos(theta_L), L_grid(kk)*sin(theta_L), 'k--');
end
for kk = 1:length(p.Results.solid_lines_L)
  plot(p.Results.solid_lines_L(kk)*cos(theta_L), p.Results.solid_lines_L(kk)*sin(theta_L), 'k-', 'Linewidth', 2);
end

theta_MLT = p.Results.MLT_gridlines/24*2*pi;
% MLT grid
for kk = 1:length(theta_MLT)
	plot([1 L_max]*cos(theta_MLT(kk)), [1 L_max]*sin(theta_MLT(kk)), 'k--');
end

% Rectangular grid at 0, 6, 12, 18 MLT
plot([-L_max -1], [0 0], 'k-', [1 L_max], [0 0], 'k-', [0 0], [-L_max -1], 'k-', [0 0], [1 L_max], 'k-');

axis equal square

%% Plot day/night terminator
switch p.Results.sun_dir
  case 'right'
    t_offset = 0;
  case 'up'
    t_offset = pi/2;
  case 'left'
    t_offset = pi;
  case 'down'
    t_offset = 3*pi/2;
  otherwise
    error('Invalid value for ''sun_dir'': %s', p.Results.sun_dir);
end

patch(cos(linspace(-pi/2, pi/2, 25) + t_offset), sin(linspace(-pi/2, pi/2, 25) + t_offset), 'w');
patch(cos(linspace(pi/2, 3*pi/2, 25) + t_offset), sin(linspace(pi/2, 3*pi/2, 25) + t_offset), 'k');

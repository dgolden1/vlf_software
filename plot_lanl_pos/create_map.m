function [map_ax, fig] = create_map(az_0, bShowSats)
% [map_ax, fig] = create_map(az_0)
% Create a map showing the south pole and orbiting LANL satellites
% 
% INPUTS
% az_0: plot-azimuth of the 0-meridian when looking from the South pole
% (e.g., if az_0 = 90, then the zero meridian will be point to the right)
% bShowSats: true to show satellite positions, false otherwise
% 
% OUTPUTS
% map_ax: axis handle for the map
% fig: figure handle for the figure

% By Daniel Golden (dgolden1 at stanford dot edu) Oct 16, 2007
% $Id$

%% Setup
error(nargchk(0, 2, nargin));

if ~exist('az_0', 'var') || isempty(az_0), az_0 = 0; end
if ~exist('bShowSats', 'var') || isempty(bShowSats), bShowSats = true; end

%% Create the map
fig = sfigure;
set(fig, 'Tag', 'sat_map_fig');

map_ax = worldmap('world');
set(map_ax, 'Tag', 'sat_map_ax');


setm(map_ax, 'Origin', [-90 0 az_0]);
setm(map_ax, 'mapprojection', 'eqaazim', 'flatlimit', [-inf 90]);
land = shaperead('landareas.shp', 'UseGeoCoords', true);
geoshow([land.Lat], [land.Lon], 'Color', 'k');

setm(gca,'FFaceColor','w'); % Make the map background white
set(gcf, 'Color', 'w'); % Make the figure background white

set(gca, 'Position', [0.05 0 0.9 0.97]); % Let the map fill the entire figure

% Make the figure window square
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1:2) max(pos(3:4)) max(pos(3:4))]);


%% Mark Palmer
plotm(-64.77, -64.05, 'r*', 'MarkerSize', 12);
textm(-64.77, -64.05, '  Palmer');

%% Mark satellites
if ~bShowSats
	return;
end

sat_names = {'LANL-01A', 'LANL-02A', 'LANL-97A', '1994-084', '1991-080', '1990-095'};
sat_lon =   [ 7.92        69.47       103.66      144.77      -164.88     -38.25]; % Accurate on July 1, 2003

% Kooky stuff to convert from map coordinates to x-y coordinates so we can
% plot off of the globe
Re = sqrt(2); % Found using [x, y] = projfwd(defaultm('eqaazim'), -90, 0)
r = 1.8*Re; % An aesthetically pleasing radius
sat_x = r*sin((sat_lon + az_0)*pi/180);
sat_y = r*cos((sat_lon + az_0)*pi/180);

leading_spaces = 2;
for kk = 1:length(sat_names)
	plot(sat_x(kk), sat_y(kk), 'b*', 'MarkerSize', 8);
	text(sat_x(kk), sat_y(kk), [repmat(' ', 1, leading_spaces) sat_names{kk}], 'FontSize', 12);
end

% axis tight;
% ax = axis;
% axis([ax(1:2) 1.1*ax(3:4)]); % Make the axis a little less tight

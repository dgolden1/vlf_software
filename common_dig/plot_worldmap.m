function h_fig = plot_worldmap(b_states, h_ax)
% h_fig = plot_worldmap(b_states, h_ax)
% 
% Plot a map of the world.  Saves coast areas as a persistent variable,
% since they're huge and loading them takes a while

%% Setup
persistent land pol_lat pol_lon usastate

if ~exist('b_states', 'var') || isempty(b_states)
  b_states = false;
end

%% Load, if necessary
if isempty(land)
  land = shaperead('landareas.shp', 'UseGeoCoords', true);
  [pol_lat, pol_lon] = get_pol_lat_lon; % Political boundaries
end
if b_states && isempty(usastate)
  usastate = shaperead('usastatelo.shp', 'UseGeoCoords', true);
end

%% Plot
if exist('h_ax', 'var') && ~isempty(h_ax)
	saxes(h_ax);
else
	figure('Color','w');
end

worldmap('world');
plotm(pol_lat, pol_lon, 'Color', 0.3*[1 1 1]);
geoshow([land.Lat], [land.Lon], 'Color', 0*[1 1 1]);

if b_states
  geoshow([usastate.Lat], [usastate.Lon], 'Color', 0.3*[1 1 1]);
end

%% Output figure handle
h_fig = gcf;

function plot_ground_track(start_datenum, end_datenum, varargin)
% plot_ground_track(start_datenum, end_datenum, 'param', value)
% Plot DEMETER ground track on a map
% 
% PARAMETERS
% 'color_type' is an optional argument and may either be 'time' (default)
% to show progression in time or 'track' to show constant color for the
% track
% 'axis' is a handle of an axis on which to plot

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

%% Setup
persistent eph

addpath(fullfile(danmatlabroot, 'vlf', 'l_shell_mapping'));

%% Parse arguments
p = inputParser;
p.addRequired('start_datenum');
p.addRequired('end_datenum');
p.addOptional('color_type', 'time');
p.addOptional('axis', []);
p.parse(start_datenum, end_datenum, varargin{:});

color_type = p.Results.color_type;
h_ax = p.Results.axis;

%% Load ephemeris
ephemeris_filename = fullfile(scottdataroot, 'spacecraft', 'demeter', 'ephemeris', ...
  'processed', 'demeter_ephemeris.mat');
if isempty(eph)
  eph = load(ephemeris_filename);
end

%% Create world map
% figure;
% h = worldmap('world');
% setm(gca,'FFaceColor',[0.5 0.7 1]); % Looks like water
% setm(h,'gcolor',[.2,.2,.2])
% g = geoshow('landareas.shp');
% set(findobj(g, '-property', 'facecolor'), 'facecolor', [0.6 1 0.6]);
% 
% [pol_lat, pol_lon] = get_pol_lat_lon;
% plotm(pol_lat, pol_lon, 'Color', 0.3*[1 1 1]);

if isempty(h_ax)
  plot_l_map_world_surface;
else
  plot_l_map_world_surface(h_ax);
end

%% Plot demeter track
idx = eph.datenum >= start_datenum & eph.datenum <= end_datenum;

if strcmp(color_type, 'track')
  plotm(eph.lat(idx), eph.lon(idx), 'r', 'linewidth', 2);
elseif strcmp(color_type, 'time')
  s = scatterm(eph.lat(idx), eph.lon(idx), [], eph.datenum(idx), 'filled');
  caxis([min(eph.datenum(idx)), max(eph.datenum(idx))]);
  c = colorbar;
  title(c, 'UTC');
  datetick(c, 'y', 'keeplimits');
end

title(sprintf('DEMETER %s to %s', datestr(start_datenum, 31), datestr(end_datenum, 31)));

if isempty(h_ax)
  figure_grow(gcf, 1.4, 1)
end

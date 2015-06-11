function plot_ephemeris(start_datenum, end_datenum, varargin)
% Plot THEMIS ephemeris data in the equatorial plane
% 
% plot_ephemeris(start_datenum, end_datenum, 'param', value, ...)
% 
% INPUTS
% start_datenum, end_datenum: date range to include
% 
% PARAMETERS
% probe: cell array of strings of THEMIS probes.  E.g., to plot only THEMIS
%  A, give {'A'}.  To plot all probes, give {'A', 'B', 'C', 'D', 'E'} or
%  all' (default)
% color_by: either color by 'track' (default) for a solid color for the
%  whole track, 'time' to color by UTC, or 'mag_field' to color by the
%  second (~300-900 Hz) channel of search coil magnetometer 1
% map_type: either 'L_MLT' (default) or 'world' to plot on a world map
% L_max: max L to plot if using the 'L_MLT' plot (default: 10)
% b_make_axes: if true (default) creates the figure in the normal manner;
%  otherwise, creates neither the figure nor the axes.  Useful if some other
%  function made a fancy map, and we just want to plot on top if it.

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'l_shell_mapping')); % For plot_l_map_world_surface

%% Parse Arguments
p = inputParser;
p.addParamValue('probe', 'all');
p.addParamValue('color_by', 'track');
p.addParamValue('map_type', 'L_MLT');
p.addParamValue('L_max', 10);
p.addParamValue('b_make_axes', true);
p.parse(varargin{:});

if ischar(p.Results.probe) && strcmp(p.Results.probe, 'all')
  probe = {'A', 'B', 'C', 'D', 'E'};
elseif ischar(p.Results.probe)
  probe = {p.Results.probe}; % User gave a string representing a single probe
else
  probe = p.Results.probe;
end

color_by = p.Results.color_by;
map_type = p.Results.map_type;
L_max = p.Results.L_max;
b_make_axes = p.Results.b_make_axes;

%% Make axes
if b_make_axes
  switch map_type
    case 'L_MLT'
      make_mlt_plot_grid('L_max', L_max);
      set(gca, 'xlimmode', 'manual', 'ylimmode', 'manual');
    case 'world'
      plot_l_map_world_surface; % From l_shell_mapping
    otherwise
      error('Invalid map_type: %s', map_type);
  end
end

%% Plot ephemeris
color_order = get(gca, 'ColorOrder');

h_line = nan(length(probe), 1);
for kk = 1:length(probe)
  eph = get_ephemeris(probe{kk}, start_datenum, end_datenum);
  
  switch map_type
    case 'L_MLT'
      switch color_by
        case 'track'
          h_line(kk) = plot_L_MLT_by_track(eph, color_order(kk,:));
        case 'time'
          plot_L_MLT_by_time(eph);
        case 'mag_field'
          plot_L_MLT_by_mag_field(eph, probe{kk});
      end
    case 'world'
      try
        switch color_by
          case 'track'
            h_line(kk) = plot_world_by_track(eph, color_order(kk,:));
          case 'time'
            plot_world_by_time(eph);
          case 'mag_field'
            plot_world_by_mag_field(eph, probe{kk});
        end
      catch er
        if strcmp(er.identifier, 'MapLatLon:NoValidPts')
          fprintf('Unable to plot probe %s: all points have L > 10\n', probe{kk});
        else
          rethrow(er);
        end
      end
  end
end

switch color_by
  case 'track'
    legend(h_line(ishandle(h_line)), probe{ishandle(h_line)});
end

switch map_type
  case 'world'
    figure_grow(gcf, 1.3, 1);
end

probe_str = [];
for kk = 1:(length(probe) - 1)
  probe_str = [probe_str, upper(probe{kk}), ', '];
end
probe_str = [probe_str, upper(probe{end})];

axis off;
set(gcf, 'color', 'w')
title(sprintf('THEMIS %s %s to %s', probe_str, datestr(start_datenum, 31), datestr(end_datenum, 31)));
increase_font;

function h_line = plot_L_MLT_by_track(eph, color)
%% Plot by L, MLT, colored by track
h_line = plot(eph.L.*cos((eph.MLT + 12)*2*pi/24), eph.L.*sin((eph.MLT + 12)*2*pi/24), 'color', color, 'linewidth', 2);

function plot_L_MLT_by_time(eph)
%% Plot by L, MLT, colored by time
cmap = jet(32);
[line_segments, colors, cax] = color_by_value_by_line(eph.epoch, ...
  eph.L.*cos((eph.MLT + 12)*2*pi/24), eph.L.*sin((eph.MLT + 12)*2*pi/24), cmap);

for kk = 1:length(line_segments)
  h = plot(line_segments{kk}(:,1), line_segments{kk}(:,2), 'color', colors{kk}, 'linewidth', 2);
  set(h, 'tag', 'eph_line');
end
% scatter(eph.L.*cos((eph.MLT + 12)*2*pi/24), eph.L.*sin((eph.MLT + 12)*2*pi/24), [], eph.epoch, 'filled');

caxis(cax);
colormap(cmap);
c = colorbar;
datetick(c, 'y', 'keeplimits');
title(c, 'UTC');

function plot_L_MLT_by_mag_field(eph, probe)
%% Plot by L, MLT, colored by magnetic field

channel = 2;

[time, data, f_center, f_bw, f_lim] = get_dfb_scm(eph.epoch(1), eph.epoch(end), 'probe', probe);

% Get rid of the impulsive high-frequency noisy crap
dec_factor = 100;
data_dec = decimate(data(:, channel), dec_factor);

data_int = log10(interp1(time(1:dec_factor:end), data_dec, eph.epoch));

scatter(eph.L.*cos((eph.MLT + 12)*2*pi/24), eph.L.*sin((eph.MLT + 12)*2*pi/24), [], data_int, 'filled');
caxis([min(data_int), max(data_int)]);
c = colorbar;
ylabel(c, sprintf('%0.0f-%0.0f Hz (log_{10} nT)', f_lim(1, channel), f_lim(2, channel)));


function h_line = plot_world_by_track(eph, color)
%% Plot on world map by track

% method = 'dipole';
method = 'cgm';

[lat_n, lon_n, lat_s, lon_s] = get_lat_lon_from_eph(eph, method);

h_line = plotm(lat_n, lon_n, 'color', color, 'linewidth', 2);
h_line = plotm(lat_s, lon_s, 'color', color, 'linewidth', 2);

function plot_world_by_time(eph)
%% Plot on world map by time

try
  [lat_n, lon_n, lat_s, lon_s, idx_valid] = get_lat_lon_from_eph(eph, 'cgm');
catch er
  if strcmp(er.identifier, 'MapLatLon:NoValidPts')
    return
  else
    rethrow(er);
  end
end

cmap = jet(32);
[line_segments_n, colors_n, cax] = color_by_value_by_line(eph.epoch(idx_valid), lat_n, lon_n, cmap);
[line_segments_s, colors_s, cax] = color_by_value_by_line(eph.epoch(idx_valid), lat_s, lon_s, cmap);

assert(length(line_segments_n) == length(line_segments_s));
for kk = 1:length(line_segments_n)
  plotm(line_segments_n{kk}(:,1), line_segments_n{kk}(:,2), 'color', colors_n{kk}, 'linewidth', 3);
  plotm(line_segments_s{kk}(:,1), line_segments_s{kk}(:,2), 'color', colors_s{kk}, 'linewidth', 3);
end
% scatter_size = 80;
% scatterm([lat_n; lat_s], [lon_n; lon_s], scatter_size, repmat(eph.epoch(idx_valid), 2, 1), 'filled');

caxis(cax);
colormap(cmap);
c = colorbar;
datetick(c, 'y');
title(c, 'UTC');

function plot_world_by_mag_field(eph, probe)
%% Plot on world map colored by magnetic field

channel = 2;

[time, data, f_center, f_bw, f_lim] = get_dfb_scm(eph.epoch(1), eph.epoch(end), 'probe', probe);

% Get rid of the impulsive high-frequency noisy crap
dec_factor = 100;
data_dec = decimate(data(:, channel), dec_factor);

data_int = log10(abs(interp1(time(1:dec_factor:end), data_dec, eph.epoch)));

try
  [lat_n, lon_n, lat_s, lon_s, idx_valid] = get_lat_lon_from_eph(eph, 'cgm');
catch er
  if strcmp(er.identifier, 'MapLatLon:NoValidPts')
    return
  else
    rethrow(er);
  end
end

data_int = data_int(idx_valid);

% markersize = 80;
% scatterm([lat_n; lat_s], [lon_n; lon_s], markersize, repmat(data_int, 2, 1), 'filled');
j = jet(64);
cax = [min(data_int), max(data_int)];
for kk = 1:(length(lat_n) - 1)
  if any(isnan(data_int(kk:kk+1)))
    continue;
  end
  
  plotm(lat_n(kk:kk+1), lon_n(kk:kk+1), 'linewidth', 7, 'color', ...
    interp1(linspace(0, 1, size(j, 1)), j, (mean(data_int(kk:kk+1)) - cax(1))/(cax(2) - cax(1))));
  plotm(lat_s(kk:kk+1), lon_s(kk:kk+1), 'linewidth', 7, 'color', ...
    interp1(linspace(0, 1, size(j, 1)), j, (mean(data_int(kk:kk+1)) - cax(1))/(cax(2) - cax(1))));
end

caxis(cax);
c = colorbar;
ylabel(c, sprintf('%0.0f-%0.0f Hz (log_{10} nT)', f_lim(1, channel), f_lim(2, channel)));

function [lat_n, lon_n, lat_s, lon_s, idx_valid] = get_lat_lon_from_eph(eph, method)
%% Determine field line footprints from satellite ephemeris

R_E = 6371; % Earth radius (km)
footprint_altitude = 100; % km

switch method
  case 'dipole'
    [lat_n, lon_n] = sm2gndlatlon_dipole(R_E + footprint_altitude, eph.L, eph.MLT, eph.epoch, 'north');
    [lat_s, lon_s] = sm2gndlatlon_dipole(R_E + footprint_altitude, eph.L, eph.MLT, eph.epoch, 'south');
  case 'cgm'
    idx_valid = eph.L < 10; % CGM is totally not valid for L > ~10
    if sum(idx_valid) == 0
      error('MapLatLon:NoValidPts', 'No points for L < 10');
    end
    eph.epoch = eph.epoch(idx_valid);
    eph.L = eph.L(idx_valid);
    eph.MLT = eph.MLT(idx_valid);
    
    lat_n = zeros(size(eph.epoch));
    lon_n = zeros(size(eph.epoch));
    lat_s = zeros(size(eph.epoch));
    lon_s = zeros(size(eph.epoch));
    for kk = 1:length(lat_n)
      [lat_n(kk), lon_n(kk), lat_s(kk), lon_s(kk)] = get_footprints(eph.epoch(kk), eph.L(kk), eph.MLT(kk), footprint_altitude); % From l_shell_mapping
    end
    
%     [lat_n, lon_n, lat_s, lon_s] = get_footprints(eph.epoch, eph.L, eph.MLT, footprint_altitude); % From l_shell_mapping
end

function [lat, lon] = sm2gndlatlon_dipole(r, L, MLT, date_datenum, str_hemisphere)
%% Convert from a position in space to a geographic position on the ground
% Uses the dipole model
R_E = 6371; % Earth radius (km)

if strcmp(str_hemisphere, 'north')
  hem_root = 1;
elseif strcmp(str_hemisphere, 'south')
  hem_root = -1;
end

gnd_pos_r = repmat(r, length(date_datenum), 1);
gnd_pos_lat = acos(hem_root*sqrt(r/R_E./L)); % Latitude of this field line's footprint at 100 km altitude (northern hemisphere, radians)
gnd_pos_lon = (MLT/24 - fpart(date_datenum))*2*pi; % Longitude of this field line's footprint, assuming MLT is constant along a field line (radians)
gnd_pos_sph_sm = [gnd_pos_r, gnd_pos_lat, gnd_pos_lon];
[gnd_pos_cart_sm(:,1), gnd_pos_cart_sm(:,2), gnd_pos_cart_sm(:,3)] = sph2cart(gnd_pos_lon, gnd_pos_lat, gnd_pos_r);

r_lat_lon = onera_desp_lib_coord_trans(gnd_pos_cart_sm, 'sm2rll', date_datenum);

lat = r_lat_lon(:,2);
lon = r_lat_lon(:,3);

function [line_segments, colors, cax] = color_by_value_by_line(t, x, y, cmap)
%% Plot tracks by value using lines instead of dots
% Returns line segments and the correct colors

cax = [min(t) max(t)];
cax_range = diff(cax);

cmap_len = size(cmap, 1);
line_segments = {};
colors = {};
idx_valid = true(cmap_len, 1);
for kk = 1:cmap_len
  idx = t >= cax_range/cmap_len*(kk - 1) + cax(1) & t <= cax_range/cmap_len*kk + cax(1);
  if kk ~= cmap_len
    idx(find(idx, 1, 'last') + 1) = true; % Get rid of gaps between the lines
  end
  
  if sum(idx) == 0
    idx_valid(kk) = false;
  end
  line_segments{end+1} = [x(idx), y(idx)];
  colors{end+1} = cmap(kk, :);
end

% Sometimes there are no indices for a certain color, if the satellite
% skips some times (i.e., if its L-shell is out of range); remove them
line_segments = line_segments(idx_valid);
colors = colors(idx_valid);

function data_filt = lowpass_filt(data, r)
%% Lowpass filter data with chebychev filter
% Filtering method stolen from decimate() function
% r = "decimation factor" (this function just performs the equivalent
% filtering, not decimation)

rip = .05;	% passband ripple in dB
nfilt = 8;

[b,a] = cheby1(nfilt, rip, .8/r);
data_filt = filter(b, a, data);

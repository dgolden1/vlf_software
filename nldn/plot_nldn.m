function plot_nldn(start_datenum, end_datenum, varargin)
% plot_nldn(start_datenum, end_datenum, 'param', value)
%
% Function to plot NLDN/GLD360 data
%
% INPUTS
% start_datenum, end_datenum: time range of values to plot
% 
% PARAMETERS
% 'nldn_filename': specify a specific NLDN filename to use; otherwise, it
% will be chosen automatically based on the date range
% 'flash_type': one of 'time' (default) or 'density'
% 'map_type': one of 'conus' (continental US, default) or 'world'
% 'h_ax': axis handle on which to plot
% 'b_show_palmer_conj': if true, annotates Palmer's conjugate point; if
% false (default), does not

% By Daniel Golden (dgolden1 at stanford dot edu) June 2009
% $Id$

%% Setup
persistent nldn last_nldn_filename % Don't load NLDN data if we already did

nldn_source_dir = fullfile(scottdataroot, 'ground', 'nldn');

addpath(fullfile(danmatlabroot, 'vlf', 'l_shell_mapping')); % For plot_l_map_world_surface


%% Arguments
p = inputParser;
p.addRequired('start_datenum');
p.addRequired('end_datenum');
p.addParamValue('nldn_filename', []);
p.addParamValue('flash_type', 'time');
p.addParamValue('map_type', 'conus');
p.addParamValue('h_ax', []);
p.addParamValue('b_show_palmer_conj', false);
p.parse(start_datenum, end_datenum, varargin{:});

start_datenum = datenum(p.Results.start_datenum); % Allows user to enter date vectors as input
end_datenum = datenum(p.Results.end_datenum);
nldn_filename = p.Results.nldn_filename;
flash_type = p.Results.flash_type;
map_type = p.Results.map_type;
h_ax = p.Results.h_ax;
b_show_palmer_conj = p.Results.b_show_palmer_conj;

switch map_type
  case 'conus'
    map_limits.lat_lim = [23 55];
    map_limits.lon_lim = [-127 -50];
  case 'world'
    map_limits.lat_lim = [-90 90];
    map_limits.lon_lim = [-180 180];
end

%% Lightning options
% ampl_thresh = 40; % Amplitude threshold in kA
ampl_thresh = 0; % Amplitude threshold in kA
if ampl_thresh > 0
  fprintf('Using amplitude threshold of %0.0f kA\n', ampl_thresh);
end

%% Load NLDN data
if isempty(nldn_filename)
  [start_year, ~] = datevec(start_datenum);
  nldn_start_filename = sprintf('nldn%s.mat', datestr(start_datenum, 'yyyymm'));
  nldn_end_filename = sprintf('nldn%s.mat', datestr(end_datenum - 1/86400, 'yyyymm'));
  assert(strcmp(nldn_start_filename, nldn_end_filename));
  
  nldn_filename = fullfile(nldn_source_dir, num2str(start_year), nldn_start_filename);
end

if isempty(nldn) || ~strcmp(nldn_filename, last_nldn_filename)
  nldn = load(nldn_filename);
  last_nldn_filename = nldn_filename;
end

idx = nldn.date >= start_datenum & nldn.date < end_datenum & abs(nldn.peakcur) >= ampl_thresh;

if strcmp(map_type, 'conus')
  idx = idx & angle_is_between(map_limits.lat_lim(1), map_limits.lat_lim(2), nldn.lat) & ...
    angle_is_between(map_limits.lon_lim(1), map_limits.lon_lim(2), nldn.lon);
end

idx = find(idx);

%% Create map
% Now works for GLD360 too!

if exist('h_ax', 'var') && ~isempty(h_ax)
  saxes(h_ax);
else
  figure('Color','white');
end

switch map_type
  case 'world'
    plot_l_map_world_surface(gca);
  case 'conus'
    % usamap('conus');
    % usamap([20 59], p_lon + 30*[-1 1]);
    axesm('MapProjection', 'lambert', 'MapLatLimit', map_limits.lat_lim, ...
      'MapLonLimit', map_limits.lon_lim, ...
      'frame', 'on', 'grid', 'on', 'meridianlabel', 'on', 'parallellabel', 'on');

    geoshow('usastatelo.shp', 'FaceColor',  'none');
    land = shaperead('landareas.shp', 'UseGeoCoords', true);
    geoshow([land.Lat], [land.Lon], 'Color', 0*[1 1 1]);
    tightmap on;
    axis off;
end

set(gca, 'tag', 'lightning_map');

%% Plot Palmer conjugate point (IGRF)
if b_show_palmer_conj
  plot_palmer_conjugate;
end

%% Plot NLDN data
if strcmp(flash_type, 'time')
  plot_by_time(nldn, idx, start_datenum, end_datenum, str_full);
elseif strcmp(flash_type, 'density')
  plot_by_density(nldn, idx, map_limits);
end

%% Fiddle with plot
titlestr = sprintf('%s to %s', datestr(start_datenum, 31), datestr(end_datenum, 31));
if ampl_thresh > 0
  titlestr = sprintf('%s (thresh = %d kA)', titlestr, ampl_thresh);
end
title(titlestr);

if isempty(h_ax)
  increase_font(gcf);
  figure_grow(gcf, 1.3, 1);
end

function plot_by_time(nldn, idx, start_datenum, end_datenum, str_full)
%% Function to plot NLDN flashes by time

% If there are a gazillion flashes, which there often are, subsample the
% plotting
switch str_full
  case 'partial'
    num_flashes_threshold = 2000;
    if length(idx) > num_flashes_threshold
      disp(sprintf('WARNING: Subsampling plot because num flashes (%d) is greater than threshold (%d)', ...
        length(idx), num_flashes_threshold));
      
      subsample_rate = ceil(length(idx)/num_flashes_threshold);
      idx = idx(1:subsample_rate:end);
      
      disp(sprintf('WARNING: Plotting one out of every %d flashes', subsample_rate));
    end
  case 'full'
  otherwise
    error('str_full should be either ''partial'' or ''full''');
end

size_min = 3;
size_max = 9;
% 	bigness = abs(nldn.peakcur(idx)).*nldn.nstrokes(idx);
bigness = abs(nldn.peakcur(idx));
if all(bigness == 0)
  % This happens with the GLD360 data when peak currents are screwed up
  marker_size = size_min*ones(size(idx));
else
  marker_size = ((bigness - min(bigness))/(max(bigness) - min(bigness))*(size_max - size_min) + size_min).^2;
end

% delete(s(ishandle(s)));
s = scatterm(nldn.lat(idx), nldn.lon(idx), marker_size, nldn.date(idx), 'filled');

c = colorbar;
% cax = caxis;
caxis([start_datenum, end_datenum]);
datetick(c, 'y', 'keeplimits');

function plot_by_density(nldn, idx, map_limits)
%% Function to plot NLDN flashed by flash density

persistent bin_lon bin_lat Bin_area last_map_limits

cax = [-4 0];

% Plot flash density
% Set up bins
bin_size = max(1, round(diff(map_limits.lon_lim)/50)); % Around 50 bins in longitude

if isempty(bin_lon) || ~all(map_limits.lat_lim == last_map_limits.lat_lim & map_limits.lon_lim == last_map_limits.lon_lim)
  [Bin_area, bin_lat, bin_lon] = get_nldn_flash_density_bin_areas(map_limits.lat_lim(1), ...
    map_limits.lat_lim(2), map_limits.lon_lim(1), map_limits.lon_lim(2), bin_size);
  
  last_map_limits = map_limits;
end

% Sum number of strokes in each bin
% 	N = hist3([nldn.lat(idx) nldn.lon(idx)], {bin_lat + 0.5, bin_lon + 0.5});
% 	N = hist3_weight([nldn.lat(idx) nldn.lon(idx)], nldn.nstrokes(idx), {bin_lat + 0.5, bin_lon + 0.5});

N = nldn_density_grid(nldn, idx, bin_lat, bin_lon);
N_norm = N./Bin_area; % Normalize by bin area

load jet_with_white;
log_N_norm = log10(N_norm);
log_N_norm(log_N_norm < cax(1)) = nan;
p = pcolorm(bin_lat + 0.5, bin_lon + 0.5, log_N_norm);
colormap(jet_with_white);

caxis(cax);
c = colorbar;
set(get(c, 'ylabel'), 'string', 'log_{10} num flashes/km^2');

function plot_palmer_conjugate
% Coords around which to center circle
% Palmer conjugate coords
p_lat = 40.06;
p_lon = -69.43;
p_name = 'palmer conj.';
% % Coords determined from hiss_nldn_superposed_epoch_hourly.m flash maps
% p_lat = 47;
% p_lon = -67;
% p_name = 'maine';

h_palm_conj = [];

% Plot Palmer conjugate
h_palm_conj(end+1) = plotm(p_lat, p_lon, 'kx', 'MarkerSize', 10);
h_palm_conj(end+1) = textm(p_lat, p_lon, p_name);

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
  
  h_palm_conj(end+1) = plotm(lats, lons, 'g');
  % 	hold on;
  h_palm_conj(end+1) = textm(lats(azimuths == 200), lons(azimuths == 200), sprintf('%d km', dist_vec(kk)), 'Color', 'k');
end

set(h_palm_conj, 'tag', 'palmer_conjugate');

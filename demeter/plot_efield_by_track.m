function plot_efield_by_track(start_datenum, end_datenum, h_ax)
% plot_efield_by_track(start_datenum, end_datenum, h_ax)
% Plot Demeter e-field data by track as an average amplitude in a given
% frequency band

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'l_shell_mapping'));

if ~exist('h_ax', 'var')
  h_ax = [];
end

%% Load data
[time, freq, P, lat, lon] = extract_survey_efield_1132_by_time(start_datenum, end_datenum);
% [time, freq, P, lat, lon, alt, MLT, L] = extract_survey_efield_1132_with_gaps(filename);

%% Get data of interest
f_low = 500; % Hz
f_high = 4000; % Hz

plot_geo_range(lat, lon, P, freq, f_low, f_high, time(1), time(end), h_ax);

function plot_geo_range(lat, lon, P, freq, f_low, f_high, start_datenum, end_datenum, h_ax)
%% Plot individual range

%% Extract power
df = mean(diff(freq));
power = log10(sum(10.^P(freq >= f_low & freq <= f_high, :))*df); % log10 mV^2/m^2

%% Plot
markersize = 100;

if isempty(h_ax)
  plot_l_map_world_surface;
else
  plot_l_map_world_surface(h_ax);
end

s = scatterm(lat, lon, markersize, power, 'filled');

caxis([1 7]);
c = colorbar;

%% Make labels
ylabel(c, sprintf('Power %0.1f to %0.1f kHz (log_{10} uV^2/m^2)', f_low/1e3, f_high/1e3));

if lat(1) > lat(end)
  up_or_down_str = 'descending';
else
  up_or_down_str = 'ascending';
end

title(sprintf('DEMETER E-field amplitude\n%s to %s (%s)', ...
  datestr(start_datenum, 31), datestr(end_datenum, 31), up_or_down_str));

if isempty(h_ax)
  figure_grow(gcf, 1.3, 1);
  increase_font;
end

function plot_latitude_dependence
% Plot latitude dependence of THEMIS

% By Daniel Golden (dgolden1 at stanford dot edu) March 2012
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'themis'));

input_dir = fullfile(vlfcasestudyroot, 'themis_chorus');
load(fullfile(input_dir, 'polar_themis_combined.mat'), 'them');

%% Bin data
[lat, MLT, ~, r] = xyz_to_lat_mlt_L(them.xyz_sm);
idx_day = MLT >= 9 & MLT < 15;
lat = lat(idx_day);
MLT = MLT(idx_day);
r = r(idx_day);
Bw = them.Bw(idx_day);

r_edges = 5:1:10;
r_centers = r_edges(1:end-1) + median(diff(r_edges))/2;
lat_edges = 0:1.5:90;


idx = Bw > 0;
[wave_ampl_sum, r_bin, theta_bin] = plot_r_lat(r(idx), abs(lat(idx)), r_edges, lat_edges, log10(Bw(idx)), ...
  'scaling_function', 'none', 'b_plot', false);
[num_meas, ~, ~] = plot_r_lat(r(idx), abs(lat(idx)), r_edges, lat_edges, 1, ...
  'scaling_function', 'none', 'b_plot', false);

%% Plot data
idx = wave_ampl_sum > 0;

lat_bin = theta_bin*180/pi;
avg_wave_ampl = wave_ampl_sum./num_meas;
plot_r_lat(r_bin(idx), lat_bin(idx), r_edges, lat_edges, avg_wave_ampl(idx), ...
  'scaling_function', 'none');
title('Day side (09 < MLT < 15)');
caxis([0 1]);
c = colorbar;
ylabel(c, 'avg log_{10} pT');
increase_font;

figure;
plot(lat_bin(1,:), avg_wave_ampl, 's-', 'linewidth', 2, 'markerfacecolor', 'w');
grid on;
xlim([0 25]);
xlabel('Latitude (deg)');
ylabel('Avg chorus amplitude (log_{10} pT)');
title('Day side (09 < MLT < 15)');
legend(cellfun(@(x) [num2str(x) ' R_E'], num2cell(r_centers), 'uniformoutput', false))
increase_font


1;

function plot_filterbank_channel_f
% Make a plot showing the filterbank channel frequencies

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Setup
close all;

%% Get filterbank info for some random day
[time, data, f_center, f_bw, f_lim] = get_dfb_scm(datenum([2010 01 01 0 0 0]), datenum([2010 01 02 0 0 0]));

%% Get gyrofrequency with dipole model
B0 = 3.12e-5; % mean equatorial magnetic field on Earth's surface, T
q = 1.6022e-19; % electron charge, c
me = 9.1094e-31; % electron mass, kg
r_min = 4; % Re
r_max = 12; % Re

r = linspace(r_min, r_max);
B = B0./r.^3;
fc = q*B/(2*pi*me); % equatorial gyrofrequency, Hz

%% Plot
figure;
hold on

colors = [1 0.3 0.3;
          0.2 0.5 0.2;
          0.3 0.3 1];
h = [];
for kk = 1:3
  h(end+1) = patch([r_min r_max r_max r_min], f_lim([1 1 2 2], kk), colors(kk,:));
end

h(end+1:end+2) = plot(r, 0.1*fc, r, 0.8*fc, 'color', 'k', 'linewidth', 2);
h(end) = [];
h(end+1) = plot(r([1 end]), 3e3*[1 1], 'k--', 'linewidth', 2);

grid on
set(gca, 'yscale', 'log');

xlabel('Radial distance (R_E)');
ylabel('Frequency (Hz)');
legend(h, 'Ch 1', 'Ch 2', 'Ch 3', '0.1-0.8 f_{ce}', '3 kHz');
increase_font;

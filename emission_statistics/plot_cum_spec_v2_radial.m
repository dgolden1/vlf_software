function plot_cum_spec_v2_radial(these_events, em_type)
% plot_cum_spec_v2_radial(these_events, em_type)
% Plot a "cumulative spectrogram" view of events, but in polar coordinates
% where R = frequency, and theta = time of day

% By Daniel Golden (dgolden1 at stanford dot edu) July 2008
% $Id$

%% Setup
error(nargchk(2, 2, nargin));

F_MAX = 7e3; % kHz

%% Generate cum_spec
[cum_spec_orig, freq_orig, time] = plot_cum_spec_v2(these_events, em_type);

f_i = find(freq_orig <= F_MAX);
frequency = freq_orig(f_i);
cum_spec = cum_spec_orig(f_i, :);

%% Transform
r_min = 0.2;
r_max = 1;
% theta = mod(-time*2*pi - pi/2, 2*pi);
theta = mod(time*2*pi + pi, 2*pi);
r = r_min + (frequency/F_MAX)*(r_max - r_min);

[Theta, R] = meshgrid(theta, r);

X = R.*cos(Theta);
Y = R.*sin(Theta);

%% Plot
figure;
hold on;

% Plot day/night terminator
patch_r = 1.2;
patch_t = linspace(-pi/2, pi/2);
patch_x = patch_r*cos(patch_t);
patch_y = patch_r*sin(patch_t);
patch(patch_x, patch_y, 'w');
patch(-patch_x, patch_y, 'k');


p = pcolor(X, Y, cum_spec);
set(p, 'linestyle', 'none');
axis square tight off;

title(sprintf('Cumulative spectrogram, %d %s emissions, %s to %s', length(these_events), ...
	em_type, datestr(min(floor([these_events.start_datenum])), 29), ...
	datestr(max(floor([these_events.start_datenum])), 29)));

increase_font;
disp('');

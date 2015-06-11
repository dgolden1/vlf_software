function plot_cum_spec_v2_radial_occur(these_events, em_type)
% plot_cum_spec_v2_radial_occur(these_events, em_type)
% Plot a "cumulative spectrogram"-style plot, but in a circular band
% centered around Palmer's L-shell

% By Daniel Golden (dgolden1 at stanford dot edu) July 2008
% $Id$

%% Setup
error(nargchk(2, 2, nargin));

L_MIN = 2.2; % These are about 300 km from palmer
L_MAX = 2.7;

%% Generate cum_spec
[cum_spec, frequency, time] = plot_cum_spec_v2(these_events, em_type, true);

% % Make the slice the average value between F_MAX and DC
% cum_spec_slice = mean(cum_spec(frequency < F_MAX, :));

% Make the slice the maximum value at this local time
cum_spec_slice = max(cum_spec);

%% Transform
theta = mod(time*2*pi - pi/2, 2*pi);
r = [L_MIN L_MAX];

[Theta, R] = meshgrid(theta, r);

X = R.*cos(Theta);
Y = R.*sin(Theta);

%% Plot
color_label = 'maximum field intensity (dB-fT/Hz^{1/2})';
values = repmat(cum_spec_slice, 2, 1);
plot_radial_local_time(theta, X, Y, values, color_label, L_MIN, L_MAX);

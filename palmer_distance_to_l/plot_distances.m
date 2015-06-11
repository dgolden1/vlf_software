% Script to plot pre-calculated distances from Palmer to different l-shells

% By Daniel Golden (dgolden1 at stanford dot edu) February 25
% $Id$

close all;
clear;

load palmer_distances.mat

figure;
plot(l_shells, palmer_distances, 'LineWidth', 2);
grid on;
xlabel('L-shell');
ylabel('Distance (km)');
title('Minimum distance from Palmer Station to ionospheric exit points');
increase_font(gca);

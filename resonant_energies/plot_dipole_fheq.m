% Plot dipole equatorial gyro frequencies

% Formulas from Park (1972), p 88

% By Daniel Golden (dgolden1 at stanford dot edu) March 2007
% $Id$

close all;
clear;

figure;
plot(L, fHeq/1e3, 'LineWidth', 2)
grid on;
set(gca, 'YTick', 0:10:120);
xlabel('L shell');
ylabel('Dipole f_{Heq}');

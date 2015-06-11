function plot_ion_prof
% Plot a given ionospheric profile

% ion_prof = 'ne_palmer_summer_day';
% ion_prof = 'ne_palmer_summer_night';
% ion_prof = 'ne_palmer_winter_day';
ion_prof = 'ne_palmer_winter_night';

load([ion_prof '.mat']);

figure;
semilogx(Ne, h, 'LineWidth', 2);
grid on;
xlabel('Electron density (e/m^3)');
ylabel('Height (km)');
title(strrep(ion_prof, '_', '\_'));
increase_font(gcf, 16);

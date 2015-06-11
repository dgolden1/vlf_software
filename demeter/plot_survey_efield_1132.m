function plot_survey_efield_1132(filename)
% plot_survey_efield_1132(filename)
% Plot a DEMETER survey e-field file

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

%% Load data file
[time, freq, P, lat, lon, alt, MLT, L] = extract_survey_efield_1132_with_gaps(filename);

%% Plot, making data gaps white
% Make Nans white
minmax_cax = [min(P(isfinite(P))) max(P(isfinite(P)))];
cax = [-3.2 2.4];
[P_plot, cmap, cax_plot] = colormap_white_bg(P, jet(64), minmax_cax);

figure;

h_spec = subplot(4, 1, 1:3);
imagesc(time, freq/1e3, P_plot);
axis xy;
caxis(cax_plot);
colormap(cmap);
c = colorbar;
ylabel(c, 'log (uV/m)^2/Hz');
ylabel('Frequency (kHz)');
title(sprintf('DEMETER E-field survey %s to %s', datestr(time(1), 31), datestr(time(end), 31)));
set(gca, 'xticklabel', '');
xl = xlim;

h_L = subplot(4, 1, 4);
plot(time, L, 'k', 'linewidth', 2);
ylim([1 6]);
ylabel('L');
grid on;
xlim(xl);

% figure_grow(gcf, 1.3, 1);

%% Mangle x-axis to include ephemeris
numlabels = length(get(gca, 'xtick'));
xtick = linspace(time(1), time(end), numlabels);

new_xticklabel = {sprintf('UTC\nLat\nLon\nMLT')};
for kk = 2:length(xtick)
  new_xticklabel{kk} = sprintf('%s\n%0.1f\n%0.1f\n%0.1f', ...
    datestr(xtick(kk), 'HH:MM'), ...
    interp1(time, lat, xtick(kk)), ...
    interp1(time, lon, xtick(kk)), ...
    interp1(time, MLT, xtick(kk)));
end
set(gca, 'xtick', xtick);
my_xticklabels(gca, xtick, new_xticklabel);

% Make sure the whole xlabel can be seen
% pos = get(gca, 'position');
% set(gca, 'position', [pos(1) .3 pos(3) .6]);

%% Pretty-up the figure
increase_font;

% Line up L and spec axes and squish them towards the top so ephemeris
% shows
smush_amt = 0.2; % Normalized figure units
pos_spec = get(h_spec, 'position');
pos_L = get(h_L, 'position');
set(h_L, 'position', [pos_spec(1), pos_L(2) + smush_amt, pos_spec(3), pos_L(4)]);
set(h_spec, 'position', [pos_spec(1) pos_spec(2) + smush_amt, pos_spec(3), pos_spec(4) - smush_amt]);

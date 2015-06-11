% plot_bhchorus

% close all;
clear;

load bhchorus.mat

x = linspace(0, 1, 1e3);
y = interp1(ffH, p, x, 'spline');
y(y < 0) = 0;

figure;
h_interp = plot(x, y, 'r', 'LineWidth', 2);
hold on;
h_data = plot(ffH, p, 'bo', 'MarkerFaceColor', [0.5 0.5 1], 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
grid on;
xlabel('f/f_H_{eq}');
ylabel('Percent Observed');
title('Expected chorus frequencies from Burtis and Helliwell (1976)');
legend([h_data, h_interp], 'Original Data', 'Interpolation');
increase_font(gcf, 16);

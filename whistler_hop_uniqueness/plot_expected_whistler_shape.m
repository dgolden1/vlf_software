function plot_expected_whistler_shape(Ne, B0, x_max)
% Plots the shape of the expected whistler trace for a given Ne and B0 and propagation
% distance
% 
% INPUTS
% x_max: propagation distance (in m)
% 
% By Daniel Golden (dgolden1 at stanford dot edu) May 27 2007

% $Id$

%% Get dispersion characteristics
[f, n_neg, n_pos, vp_neg, vp_pos, vg_neg, vg_pos] = get_plasma_speeds(Ne, B0);

%% Cut out non-whistler mode frequencies
last_whistler_i = find(real(vg_neg) == 0, 1, 'first') - 1;
f = f(1:last_whistler_i);
vg_neg = vg_neg(1:last_whistler_i);

% Calculate time of arrival for each frequency component to reach the end of the space
% Use only vg_neg (assume whistler mode)
t = x_max./real(vg_neg);

figure;
plot(t*1e3, f, 'b', 'LineWidth', 2);
hold on;
y_lims = ylim;
plot(zeros(2,1), y_lims, 'k', 'LineWidth', 2);
legend('Whistler', 'Originating Sferic', 'Location', 'SouthEast');
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
grid on;
% title(sprintf('Expected whistler shape\nNe = %0.0e, B_0 = %0.0e, d = %d km', Ne, B0, round(x_max/1e3)));
% x_lims = xlim;
% xlim([-min(t) min([min(t)*10 x_lims(2)])]);
xlim([-2 20]);
increase_font(gca, 20);

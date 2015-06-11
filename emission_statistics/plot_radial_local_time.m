function plot_radial_local_time(theta, X, Y, values, color_label, L_MIN, L_MAX)
% plot_radial_local_time(X, Y, values)

%% Setup
error(nargchk(7, 7, nargin));

L_FIG_MAX = 3.5;
R_MAX = 3;
LINE_WIDTH = 1.5;

%% Plot grid lines
hold on;
plot([0 0], R_MAX*[-1 1], 'k--', 'LineWidth', LINE_WIDTH);
plot(R_MAX*[-1 1], [0 0], 'k--', 'LineWidth', LINE_WIDTH);


%% Plot

p = pcolor(X, Y, values);
set(p, 'linestyle', 'none');
c = colorbar;

set(get(c, 'ylabel'), 'string', color_label);

xlim(L_FIG_MAX*[-1 1]);
ylim(L_FIG_MAX*[-1 1]);
axis equal;

%% Draw some L-shells
x = L_MIN*cos(theta); y = L_MIN*sin(theta);
plot(x, y, 'k--', 'LineWidth', LINE_WIDTH);

x = L_MAX*cos(theta); y = L_MAX*sin(theta);
plot(x, y, 'k--', 'LineWidth', LINE_WIDTH);

% x = 4*cos(theta); y = 4*sin(theta);
% plot(x, y, 'k--', 'LineWidth', LINE_WIDTH);


%% Draw earth sun/shade icon
% Dark
x = cos(theta);
y = sin(theta);
y(y > 0) = 0;
fill(x, y, 'k');

% Light
y = sin(theta);
y(y < 0) = 0;
fill(x, y, 'w');

% Draw a circle around
x = cos(theta);
plot(x, y, 'k', 'LineWidth', LINE_WIDTH);

%% Text
t_l = R_MAX;

sq2o2 = sqrt(2)/2;
text(-L_MIN*sq2o2, L_MIN*sq2o2, sprintf('L=%0.1f', L_MIN), 'verticalalignment', 'top');
text(-L_MAX*sq2o2, L_MAX*sq2o2, sprintf('L=%0.1f', L_MAX), 'horizontalalignment', 'right', 'verticalalignment', 'bottom');
% text(-t_l*sq2o2, t_l*sq2o2, sprintf('L=%0.1f', t_l), 'horizontalalignment', 'right', 'verticalalignment', 'bottom');

text(0.1, t_l, '12', 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(t_l + 0.1, 0, '06', 'horizontalalignment', 'left', 'verticalalignment', 'middle');
text(0.1, -t_l, '00', 'horizontalalignment', 'center', 'verticalalignment', 'top');
text(-(t_l + 0.1), 0, '18', 'horizontalalignment', 'right', 'verticalalignment', 'middle');

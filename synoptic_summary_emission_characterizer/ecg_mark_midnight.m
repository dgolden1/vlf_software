function text_handles = ecg_mark_midnight(ax)
% Mark the part of the plot that represents the times 0000
% and 2359 UTC

% By Daniel Golden (dgolden1 at stanford dot edu) Nov 2007
% $Id$

x_max = 828;
x_min = 64;
y_max = 463;
y_min = 265;

x = [x_min x_max; x_min x_max];
y = [y_min y_min; y_max y_max];

text_handles.pul = plot(x(1,1), y(1,1), 'r.', 'MarkerSize', 12); % Upper left
text_handles.tul = text(x(1,1), y(1,1), 'Upper Left', 'Color', 'r');

text_handles.pur = plot(x(1,2), y(1,2), 'r.', 'MarkerSize', 12); % Upper right
text_handles.tur = text(x(1,2), y(1,2), 'Upper Right', 'Color', 'r');

text_handles.pll = plot(x(2,1), y(2,1), 'r.', 'MarkerSize', 12); % Lower left
text_handles.tll = text(x(2,1), y(2,1), 'Lower Left', 'Color', 'r');

text_handles.plr = plot(x(2,2), y(2,2), 'r.', 'MarkerSize', 12); % Lower right
text_handles.tlr = text(x(2,2), y(2,2), 'Lower Right', 'Color', 'r');

f_low = 0.3;
f_high = 10;
t_low = 0;
t_high = (23 + 59/60)/24;


% Interpolate to find noon, 5 kHz
x_noon = 0.5*(x_max - x_min) + x_min;
y_5 = 5/(f_high - f_low)*(y_max - y_min) + y_min;
plot(x_noon, y_5, 'r.', 'MarkerSize', 12);
text(x_noon, y_5, 'Noon, 5 kHz', 'Color', 'r');

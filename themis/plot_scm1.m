function varargout = plot_scm1(start_datenum, end_datenum, varargin)
% h_ax = plot_scm1(start_datenum, end_datenum, 'param', value)
% 
% Plot search coil magnetometer data
% 
% PARAMETERS
% 'probe': one of 'A', 'B', 'C', 'D', 'E'
% 'plot_type': one of 'line' (default) or 'pcolor' (for a
% pseudo-spectrogram)

%% Parse input arguments
p = inputParser;
p.addParamValue('probe', 'A');
p.addParamValue('plot_type', 'line');
p.parse(varargin{:});
probe = p.Results.probe;
plot_type = p.Results.plot_type;

%% Get data and ephemeris
[time, data, f_center, f_bw, f_lim] = get_dfb_scm(start_datenum, end_datenum, 'probe', probe);
eph = get_ephemeris(probe, start_datenum, end_datenum);

%% Plot
% Interpolate ephemeris L over data samples
L_int = interp1(eph.epoch, eph.L, time);

switch plot_type
  case 'line'
    h_ax = plot_line(time, data, f_lim, L_int, probe);
end

if nargout >= 1
  varargout{1} = h_ax;
end

function h_data_ax = plot_line(time, data, f_lim, L, probe)
%% Plot
L_max = 10;
num_channels = 3;

figure;

% Super subplot parameters
nrows = 3;
ncols = 1;
hspace = 0;
vspace = 0.05;
hmargin = [0.15 0.1];
vmargin = [0.1 0.15];

%% Plot B-field values
h_data_ax = super_subplot(nrows, ncols, 1:2, hspace, vspace, hmargin, vmargin);
% h_ax = subplot(3, 1, 1:2);
semilogy(time, data(:, 1:num_channels));
grid on;
ylim(10.^[-4, 0]);
set(gca, 'xticklabel', []);

saxes(h_data_ax);
legend_text = {};
for kk = 1:num_channels
  legend_text{end+1} = sprintf('%0.0f to %0.0f Hz', f_lim(1, kk), f_lim(2, kk));
end

ylabel('nT');
title(sprintf('THEMIS %s DFB SCM1\n%s to %s', probe, datestr(time(1), 31), datestr(time(end), 31)));

xl = xlim;

%% Plot L
% subplot(3, 1, 3);
h_L_ax = super_subplot(nrows, ncols, 3, hspace, vspace, hmargin, vmargin);
idx_valid = L < L_max;
plot(time(idx_valid), L(idx_valid), 'LineWidth', 2);
grid on;
xlim(xl);
ylabel('L (dipole)');
datetick2('x', 'keeplimits');
% ylim([1 L_max]);

set(h_data_ax, 'xtick', get(h_L_ax, 'xtick'));
linkaxes([h_L_ax h_data_ax], 'x');

increase_font;

%% Add legend
% Must be done AFTER datetick2 command
saxes(h_data_ax);
legend(legend_text);

function plot_spectrum(filename)

% By Daniel Golden (dgolden1 at stanford dot edu) October 2008
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'vlftool_24_hour_fcn'));

% smooth_freq_bin = 100; % Hz
smooth_no = 5;

if ~exist('filename', 'var') || isempty(filename)
	filename = 'hiss_spec';
end

%% Plot
type = [];
load(filename);
type = strrep(type, '_', '\_'); % Make underscores safe in strings

if ~exist('smooth_no', 'var')
	smooth_no = smooth_freq_bin/mean(diff(freq));
end

[B_cal, unit_str] = cal_2003(sqrt(em_psd).', freq.', 512, 10e3);
B_cal = B_cal.';

figure;
plot(freq/1e3, smooth(B_cal, smooth_no), 'LineWidth', 2);
grid on;
xlabel('Frequency (kHz)');
ylabel(unit_str);
ylim([-20 30]);
title(type);

increase_font(gcf, 16);

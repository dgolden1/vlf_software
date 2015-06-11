function nldn_hiss_correlation_plots
% Load up hourly vectors with hiss, dst and nldn data and look for
% correlation!

% By Daniel Golden (dgolden1 at stanford dot edu) 
% $Id$

%% Setup
% close all;

input_dir = '/home/dgolden/vlf/case_studies/nldn/statistics';

dst_stats = load(fullfile(input_dir, 'dst_statistics.mat'));
hiss_stats = load(fullfile(input_dir, 'hiss_statistics.mat'));
nldn_stats = load(fullfile(input_dir, 'nldn_statistics.mat'));

date_start = min(dst_stats.hour);
date_end = max(dst_stats.hour);

lightning_amp_mod = log10(nldn_stats.lightning_amp);
lightning_amp_mod(isinf(lightning_amp_mod)) = min(lightning_amp_mod(~isinf(lightning_amp_mod)));

%% Create Dst* (min Dst in X hours preceding given hour)
dst_star_history = 1; % Hours
dst_star = zeros(size(dst_stats.dst));
for kk = 1:length(dst_stats.dst)
	idx = (kk - dst_star_history + 1):kk;
	idx(idx < 1) = [];
	dst_star(kk) = min(dst_stats.dst(idx));
end

%% Time Plot that the user has to scroll through
% scrolling_time_plot(nldn_stats.hours, dst_star, hiss_stats.hiss_amp, nldn_stats.lightning_amp, date_start, date_end, nldn_stats.unit_str);

%% Scatter plot
% scatter_plot(hiss_stats.hiss_amp, lightning_amp_mod, dst_stats.dst);

%% Histograms
norm_hiss_ecle_hist(dst_star, hiss_stats.hiss_amp, lightning_amp_mod, nldn_stats.unit_str, nldn_stats.hours);

%% Lightning statistics plot
% lightning_statistics_plot(nldn_stats.hours, nldn_stats.lightning_amp, nldn_stats.unit_str);

%% function lightning_statistics_plot(hour, lightning_amp)
function lightning_statistics_plot(hours, lightning_amp, nldn_unit_str)
bins = zeros(24, 1);
for kk = 1:length(bins)
	idx = abs(fpart(hours) - (kk-1)/24) < 1e-2;
	bins(kk) = sum(lightning_amp(idx))/sum(idx);
end

figure;
bar(fpart((0:23)/24 - 4/24), bins, 'hist');
grid on;
xlim([0 1]);
datetick('x', 'keeplimits');
xlabel('Palmer MLT');
ylabel(sprintf('Avg ECLE (%s)', nldn_unit_str));

increase_font(gcf);

function scrolling_time_plot(hours, dst_star, hiss_amp, lightning_amp, date_start, date_end, nldn_unit_str)
% DST
figure;
s(1) = subplot(3, 1, 1);
plot(hours, dst_star, 'Color', [0.2 0.8 0.2], 'LineWidth', 2);
grid on;
xlim([date_start date_end]);
ylim([-100 50]);
xlabel('Date');
ylabel('nT');
title('Dst* (12-hr)')

% Hiss
s(2) = subplot(3, 1, 2);
plot(hours, hiss_amp, 'b', 'LineWidth', 2);
grid on;
xlim([date_start date_end]);
xlabel('Date');
ylabel('dB-fT/Hz^{-1/2}');
title('Hiss amplitude');

% NLDN
s(3) = subplot(3, 1, 3);
plot(hours, log10(lightning_amp), 'r', 'LineWidth', 2);
grid on;
xlim([date_start date_end]);
xlabel('Date');
ylabel(['log_{10} ' nldn_unit_str]);
title('Effective Conjugate Lightning Energy');

set(s, 'Tag', 'corr_ax');
linkaxes(s, 'x');

datetick2('x', 'keeplimits');

increase_font(gcf, 12);

%% function scatter_plot(hiss_amp, lightning_amp_mod, dst)
function scatter_plot(hiss_amp, lightning_amp_mod, dst)
figure;
scatter3(hiss_amp, lightning_amp_mod, dst, 'filled');
grid on;
xlabel('Hiss amplitude dB-fT/Hz^{-1/2}');
ylabel('Effective conjugate lightning energy (log_{10} kA)');
zlabel('Dst (nT)');

%% function norm_hiss_ecle_hist(dst, hiss_amp, lightning_amp_mod)
function norm_hiss_ecle_hist(dst_star, hiss_amp, lightning_amp_mod, nldn_unit_str, hours)
b_use_only_hiss_interval = true;
% b_use_only_hiss_interval = false;

hiss_interval = [16 04]/24; % Start and end of hiss interval (UT)

if b_use_only_hiss_interval
	disp('Restricting statistics to hiss interval (1400-2300 LT)');
	idx = fpart(hours) <= hiss_interval(2) | fpart(hours) >= hiss_interval(1);
	dst_star = dst_star(idx);
	hiss_amp = hiss_amp(idx);
	lightning_amp_mod = lightning_amp_mod(idx);
end

% dst_q = quantile(dst_star, [0.33 0.67]);
dst_q = [-50 -20];

% Histogram of ECLE values
figure;
subplot(3, 1, 1);
idx = dst_star > dst_q(2);
[n, x_bins] = hist(lightning_amp_mod(idx));
h = bar(x_bins, n, 'barwidth', 1);
set(gca, 'yscale', 'log'); set(get(h, 'baseline'), 'basevalue', 1);
grid on;
title(sprintf('ECLE Statistics\nDst* > %0.0f (low)', dst_q(2)));
ylabel('Num hours');

subplot(3, 1, 2);
idx = dst_star > dst_q(1) & dst_star <= dst_q(2);
n = hist(lightning_amp_mod(idx), x_bins);
h = bar(x_bins, n, 'barwidth', 1);
set(gca, 'yscale', 'log'); set(get(h, 'baseline'), 'basevalue', 1);
grid on;
title(sprintf('Dst > %0.0f, Dst* <= %0.0f (medium)', dst_q(1), dst_q(2)));
ylabel('Num hours');

subplot(3, 1, 3);
idx = dst_star <= dst_q(1);
n = hist(lightning_amp_mod(idx), x_bins);
h = bar(x_bins, n, 'barwidth', 1);
set(gca, 'yscale', 'log'); set(get(h, 'baseline'), 'basevalue', 1);
grid on;
title(sprintf('Dst* <= %0.0f (high)', dst_q(1)));
ylabel('Num hours');

xlabel(sprintf('ECLE (Log_{10} %s)', nldn_unit_str));

increase_font(gcf, 12);


% Histogram of normalized hiss ocurrence for given values of ECLE
figure;
subplot(3, 1, 1);
idx = dst_star > dst_q(2);
n_all = hist(lightning_amp_mod(idx), x_bins);
idx = idx & hiss_amp > -20;
n_hiss = hist(lightning_amp_mod(idx), x_bins);
bar(x_bins, n_hiss./n_all, 'hist');
grid on;
title(sprintf('Hiss norm occur vs. ECLE\nDst > %0.0f (low)', dst_q(2)));
ylabel('Norm occur.');

subplot(3, 1, 2);
idx = dst_star > dst_q(1) & dst_star <= dst_q(2);
n_all = hist(lightning_amp_mod(idx), x_bins);
idx = idx & hiss_amp > -20;
n_hiss = hist(lightning_amp_mod(idx), x_bins);
bar(x_bins, n_hiss./n_all, 'hist');
grid on;
title(sprintf('Dst > %0.0f, Dst <= %0.0f (medium)', dst_q(1), dst_q(2)));
ylabel('Norm occur.');

subplot(3, 1, 3);
idx = dst_star <= dst_q(1);
n_all = hist(lightning_amp_mod(idx), x_bins);
idx = idx & hiss_amp > -20;
n_hiss = hist(lightning_amp_mod(idx), x_bins);
bar(x_bins, n_hiss./n_all, 'hist');
grid on;
title(sprintf('Dst <= %0.0f (high)', dst_q(1)));
ylabel('Norm occur.');
xlabel(sprintf('ECLE (Log_{10} %s)', nldn_unit_str));

increase_font(gcf, 12);

% Normalize y-limits
y_lim_max = [0 0];
for kk = 1:3
	subplot(3, 1, kk);
	y_lim = ylim;
	y_lim_max(1) = min(y_lim_max(1), y_lim(1));
	y_lim_max(2) = max(y_lim_max(2), y_lim(2));
end
for kk = 1:3
	subplot(3, 1, kk);
	ylim(y_lim_max);
end

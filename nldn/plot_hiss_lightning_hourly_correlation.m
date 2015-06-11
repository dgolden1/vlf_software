function plot_hiss_lightning_hourly_correlation
% Little ditty to determine how the correlation between lightning and hiss
% changes throughout the day

% By Daniel Golden (dgolden1 at stanford dot edu) September 2009
% $Id$

load ~/temp/hiss_hist.mat;
load ~/temp/nldn_epoch_output.mat;

figure;
%% Hiss data (already computed)
subplot(3, 1, 1);
b = bar(time_pts, num_events./days_of_data, 'hist');
set(b, 'facecolor', [0.2 0.2 1]);
grid on;
title('Hiss norm occur.');
datetick('x', 'keeplimits');

%% Lightning data
subplot(3, 1, 2);
lightning_counts_hourly = zeros(size(time_pts));
for kk = 1:length(time_pts)
	idx_this_hour = abs(fpart(dst.hour - 4/24) - (kk-1)/24) < 1/1440;
	lightning_counts_hourly(kk) = sum(us_flashes(idx_this_hour));
end
b = bar(time_pts, lightning_counts_hourly, 'hist');
set(b, 'facecolor', [1 0.2 0.2]);
grid on
datetick('x', 'keeplimits');
title('Num flashes')

%% Correlation data
subplot(3, 1, 3)
lightning_ratio_hourly = zeros(size(time_pts));
hiss_flashes_hourly = zeros(size(time_pts));
nohiss_flashes_hourly = zeros(size(time_pts));
hiss_hours_hourly = zeros(size(time_pts));
nohiss_hours_hourly = zeros(size(time_pts));
cumulative_lightning_ratio_hourly = zeros(size(time_pts));
for kk = 1:length(time_pts)
	idx_this_hour = abs(fpart(dst.hour - 4/24) - (kk-1)/24) < 1/1440;
	lightning_ratio_hourly(kk) = mean(us_flashes(idx_hiss & idx_this_hour))/mean(us_flashes(~idx_hiss & idx_this_hour));
	hiss_flashes_hourly(kk) = sum(us_flashes(idx_hiss & idx_this_hour));
	nohiss_flashes_hourly(kk) = sum(us_flashes(~idx_hiss & idx_this_hour));
	hiss_hours_hourly(kk) = sum(idx_hiss & idx_this_hour);
	nohiss_hours_hourly(kk) = sum(~idx_hiss & idx_this_hour);
	cumulative_lightning_ratio_hourly(kk) = (sum(hiss_flashes_hourly(1:kk))/sum(hiss_hours_hourly(1:kk)))/(sum(nohiss_flashes_hourly(1:kk))/sum(nohiss_hours_hourly(1:kk)));
end
% b = bar(time_pts, lightning_ratio_hourly, 'hist');
% set(b, 'facecolor', [0.4 0.8 0.4]);
area(time_pts, log10(lightning_ratio_hourly), 'facecolor', [0.4 0.8 0.4]);
ylim(0.5*[-1 1]);
grid on
datetick('x', 'keeplimits');
title('(hiss-fl/nohiss-fl)/(hiss-hr/nohiss-hr)')
increase_font(gcf, 14)
xlabel('Palmer LT');

%% Plot hiss and nohiss flashes and hoursfigure
figure;
subplot(2, 2, 1)
plot(time_pts - 0.5/24, hiss_flashes_hourly, time_pts - 0.5/24, nohiss_flashes_hourly, 'linewidth', 2);
grid on;
datetick('x', 'keeplimits');
ylabel('Num flashes');
% legend('hiss', 'no hiss', 'location', 'best');

subplot(2, 2, 3)
plot(time_pts - 0.5/24, hiss_hours_hourly, time_pts - 0.5/24, nohiss_hours_hourly, 'linewidth', 2);
grid on;
datetick('x', 'keeplimits');
ylabel('Num hours');
xlabel('Time (Palmer LT)');

subplot(2, 2, [2 4]);
plot(time_pts - 0.5/24, log10(hiss_flashes_hourly./nohiss_flashes_hourly), 'color', [1 0.1 0.1], 'linewidth', 2);
hold on;
plot(time_pts - 0.5/24, log10(hiss_hours_hourly./nohiss_hours_hourly), 'color', [0.5 0.2 1], 'linewidth', 2);
legend('flash ratio', 'hour ratio', 'location', 'best');
grid on;
datetick('x', 'keeplimits');
ylabel('log_{10} flash, hour ratio');
xlabel('Time (Palmer LT)');

increase_font(gcf, 14);

disp('');

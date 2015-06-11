function plot_flashes_per_hour_hist_with_error_bars
% Function to plot a histogram of "fraction of hours with hiss" vs flashes
% per hour, with error bars
% The error bars are complicated

% By Daniel Golden (dgolden1 at stanford dot edu) September 2009
% $Id$

%% Setup
% close all;
% clear;
load ~/temp/nldn_epoch_output.mat

%% Plot for two hour ranges
% The whole range
idx_hour = true(size(idx_hiss));
hour_str = 'all hours';
plot_for_hour_range(idx_hour, hour_str)

% Only 2100-2300 UT
idx_hour = abs(fpart(hiss.hour) - 22/24) < (1/24 + 1/1440);
hour_str = '2100-2300 UT';
plot_for_hour_range(idx_hour, hour_str)

function plot_for_hour_range(idx_hour, hour_str)
%%
confidence = 0.95;
z = norminv(1 - (1 - confidence)/2);

load ~/temp/nldn_epoch_output.mat


h1 = hist(us_flashes(idx_hiss & idx_hour), 1e4*(0:1:8));
h = hist(us_flashes(idx_hour), 1e4*(0:1:8));

% figure; bar(1e4*(0:1:8), h1, 'barwidth', 1); title('Unnormalized num hiss hours');
% figure; bar(1e4*(0:1:8), h1./h, 'barwidth', 1); title('Normalized num hiss hours');


n = h; % Num samples
x_bar = h1./h; % Mean

% % The complicated method
% s = sqrt((1./(n-1)).*(h1.*(1 - x_bar).^2 + (h - h1).*(0 - x_bar).^2));
% error_plus_minus = tinv(confidence + (1 - confidence)/2, h - 1).*s./sqrt(n);
% error_mid = x_bar;

% The simpler method, from Navidi - "Statistics for Engineers and
% Scientists" (2006) p316
n_tilde = n + 4;
p_tilde = (h1 + 2)./n_tilde;
error_mid = p_tilde;
error_plus_minus = z*sqrt(p_tilde.*(1 - p_tilde)./n_tilde);

figure;
b = bar(1e4*(0:1:8), h1./h, 'barwidth', 1, 'facecolor', [0.8 0.8 0.8]);
hold on;
grid on;
e = errorbar(1e4*(0:1:8), error_mid, error_plus_minus, 'k*');
xlabel('Num flashes per hour');
ylabel('Normalized hiss occurrance');
title(sprintf('Flashes per hour during hiss, normalized histogram: %s', hour_str));
increase_font;
xlim(1e4*[-1 9]);

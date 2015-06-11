function plot_lightning_hiss_monthly_histogram
% Function to plot monthly occurrence of hiss (hours per month) and
% lightning (flashes per month), with errorbars

% Error bar method from from Navidi - "Statistics for Engineers and
% Scientists" (2006) p316

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Setup
load ~/temp/nldn_epoch_output.mat

months = 1:10;
gray = [0.8 0.8 0.8];

%% Hiss and lightning
figure;
% Hiss
subplot(2, 1, 1);

[~, m_hiss] = datevec(hiss.hour(idx_hiss));
[~, m_all] = datevec(hiss.hour);
assert(all(m_all >= 1 & m_all <= 10));
h_hiss = hist(m_hiss, months);
h_all = hist(m_all, months);

bar(months, h_hiss./h_all, 'barwidth', 1, 'facecolor', gray);
grid on;
hold on;

n_tilde = h_all + 4;
p_tilde = (h_hiss + 2)./n_tilde;
error_mid = p_tilde;
error_plus_minus = 1.96*sqrt(p_tilde.*(1 - p_tilde)./n_tilde); % 95% confidence interval
e = errorbar(months, error_mid, error_plus_minus, 'k*');
ylabel('Hiss norm. occur. (hourly)');

% Lightning
subplot(2, 1, 2);
[~, m_flash] = datevec(hiss.hour(us_flashes > 2e4));
h_flash = hist(m_flash, months);

bar(months, h_flash./h_all, 'barwidth', 1, 'facecolor', gray);
grid on;
hold on;

n_tilde = h_all + 4;
p_tilde = (h_flash + 2)./n_tilde;
error_mid = p_tilde;
error_plus_minus = 1.96*sqrt(p_tilde.*(1 - p_tilde)./n_tilde); % 95% confidence interval
error_plus = min(error_plus_minus, 1 - error_mid);
error_minus = min(error_plus_minus, error_mid);
e = errorbar(months, error_mid, error_plus, error_minus, 'k*');
ylabel(sprintf('Flash dens. > 2x10^4\nnorm. occur. (hourly)'));
yl = ylim; yl(1) = 0; ylim(yl);

xlabel('Month');
increase_font(gcf, 14);

%% Dst
dst_dist = zeros(3, 10);
dst_dist(1, :) = hist(m_dst(dst.dst >= -20), 1:10);
dst_dist(2, :) = hist(m_dst(dst.dst < -20 & dst.dst >= -50), 1:10);
dst_dist(3, :) = hist(m_dst(dst.dst < -50), 1:10);

figure; bar(1:10, dst_dist.'./[h_all; h_all; h_all;].', 'stack');
grid on;
xlabel('Month');
ylabel('Fraction of hours');
legend('Dst > -20', '-50 < Dst < -20', 'Dst < -50', 'Location', 'southwest');
increase_font(gcf, 14);
xlim([0 11]);

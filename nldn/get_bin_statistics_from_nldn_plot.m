function get_bin_statistics_from_nldn_plot(h_ax, bin_lat, bin_lon, N_norm_total_matrix, dst_amp, hiss_amp, hour_vec)
% Function to get statistics for a single lat/lon bin on the NLDN maps I
% make
% 
% Sample run:
% 1. Click on the figure axis
% 2. Make sure all the variables from the run are loaded: load ~/temp/nldn_epoch_output.mat
% 3. Run: get_bin_statistics_from_nldn_plot(gca, bin_lat, bin_lon, N_norm_total_matrix, dst.dst, hiss_amp, dst.hour)

% By Daniel Golden (dgolden1 at stanford dot edu) July 2009
% $Id$

%% Get bin
[Bin_lon, Bin_lat] = meshgrid(bin_lon, bin_lat);
axes(h_ax);
[lat, lon] = inputm(1);
disp(sprintf('clicked %0.2f, %0.2f', lat, lon));

bin_idx = find(Bin_lat < lat & Bin_lon < lon, 1 , 'last');
[idx(1) idx(2)] = ind2sub(size(Bin_lat), bin_idx);
disp(sprintf('Using bin at %0.2f, %0.2f (idx [%d %d])', Bin_lat(bin_idx), Bin_lon(bin_idx), idx(1), idx(2)));

%% New plot
date_start = hour_vec(1);
date_end = hour_vec(end);
lightning_amp = squeeze(N_norm_total_matrix(idx(1), idx(2), :));
nldn_unit_str = 'log_{10} num strokes/km^2';

figure;

% DST
s(1) = subplot(4, 1, 1);
plot(hour_vec, dst_amp, 'Color', [0.2 0.8 0.2], 'LineWidth', 2);
grid on;
xlim([date_start date_end]);
ylim([-100 50]);
ylabel('nT');
title('Dst')

% Hiss
s(2) = subplot(4, 1, 2);
plot(hour_vec, hiss_amp, 'b', 'LineWidth', 2);
grid on;
xlim([date_start date_end]);
ylabel('dB-fT/Hz^{-1/2}');
title('Hiss amplitude');

% NLDN
s(3) = subplot(4, 1, 3);
plot(hour_vec, log10(lightning_amp), 'r.', 'MarkerSize', 12);
grid on;
xlim([date_start date_end]);
ylabel(['log_{10} ' nldn_unit_str]);
title('Effective Conjugate Lightning Energy');

% If there's lightning, is there hiss or not?
s(4) = subplot(4, 1, 4);
corr_vec = zeros(size(hour_vec));
corr_vec(lightning_amp > 0 & hiss_amp > -20) = 1;
corr_vec(lightning_amp > 0 & hiss_amp == -20) = -1;
stairs(hour_vec, corr_vec);
grid on;
ylim([-1.1 1.1]);
ylabel('Hiss/Lightning Correlation');
xlabel('Date');

set(s, 'Tag', 'corr_ax');
linkaxes(s, 'x');

datetick2('x', 'keeplimits');

increase_font(gcf, 12);

%% Print some information about the correlation
disp(sprintf('Num hours with lightning AND hiss: %d', sum(corr_vec == 1)));
disp(sprintf('Num hours with lightning and NO hiss: %d', sum(corr_vec == -1)));
disp(sprintf('Fraction of hours with lightning that also had hiss: %0.2f', sum(corr_vec == 1)/sum(corr_vec ~= 0)));
disp(sprintf('Num flashes/km^2 during lightning AND hiss: %f', sum(lightning_amp(corr_vec == 1))));
disp(sprintf('Num flashes/km^2 during lightning and NO hiss: %f', sum(lightning_amp(corr_vec == -1))));
disp(sprintf('Fraction of flashes/km^2 that had hiss: %0.2f', sum(lightning_amp(corr_vec == 1))/sum(lightning_amp(corr_vec ~= 0))));

disp('');

%% Old plot
% figure;
% plot(hour_vec, log10(squeeze(N_norm_total_matrix(idx(1), idx(2), :))), '.', 'MarkerSize', 12);
% xlim(hour_vec([1 end]));
% datetick2('x', 'keeplimits');
% ylabel('log_{10} num strokes/km^2');
% increase_font(gcf);
% grid on;

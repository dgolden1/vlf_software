function pp_kp_correlation_plot

%% Setup
load('/home/dgolden/vlf/vlf_software/dgolden/image_euv/palmer_pp_db.mat');
[kp_date, kp] = kp_read_datenum('/home/dgolden/vlf/case_studies/kp/kp_2001.txt');

palmer_pp_db = palmer_pp_db(isfinite([palmer_pp_db.pp_L]));

kpi = interp1(kp_date, kp, [palmer_pp_db.img_datenum]);

%% Plot
figure;
h = plot(kpi, [palmer_pp_db.pp_L], 'o', 'MarkerFaceColor', 'b');
grid on;
xlabel('kp');
ylabel('Plasmapause distance (Earth Radii)');

%% Best fit
x = kpi;
y = [palmer_pp_db.pp_L];
n = length(x);

p = polyfit(x.', y.', 1);
hold on;
plot(x, polyval(p, x), 'r--', 'LineWidth', 2);

legend('Data', 'Best Fit');

% Correlation coefficient
rho = corr(x.', y.');

title(sprintf('Plasmapause distance at Palmer''s longitude correlated with Kp (%s = %0.2f)', '\rho', rho));
increase_font(gcf, 14);

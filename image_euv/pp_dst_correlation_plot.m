% function pp_kp_correlation_plot

%% Setup
load('/home/dgolden/vlf/vlf_software/dgolden/image_euv/palmer_pp_db.mat');
[dst_date, dst] = dst_read_datenum('/home/dgolden/vlf/case_studies/chorus_2001/dst/dst_2001.txt');

palmer_pp_db = palmer_pp_db(isfinite([palmer_pp_db.pp_L]));

dsti = interp1(dst_date, dst, [palmer_pp_db.img_datenum]);

%% Plot
h = plot(dsti, [palmer_pp_db.pp_L], 'o', 'MarkerFaceColor', 'b');
grid on;
xlabel('DST (nT)');
ylabel('Plasmapause distance (Earth Radii)');
title('Plasmapause distance at Palmer''s longitude correlated with DST');


%% Best fit
x = dsti;
y = [palmer_pp_db.pp_L];
n = length(x);

p = polyfit(x.', y.', 1);
hold on;
plot(x, polyval(p, x), 'r--', 'LineWidth', 2);

legend('Data', 'Best Fit');

% Correlation coefficient

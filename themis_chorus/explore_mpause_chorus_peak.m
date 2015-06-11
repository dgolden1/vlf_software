function explore_mpause_chorus_peak
% Explore the relationship between the chorus L peak and the magnetopause
% at noon

% By Daniel Golden (dgolden1 at stanford dot edu) June 2012
% $Id$

%% Setup
close all;

start_datenum = datenum([2008 09 01 0 0 0]);
end_datenum = datenum([2008 10 01 0 0 0]);
dt = 1/24;

%% Load model features
epoch_vec = start_datenum:dt:end_datenum;

t_feat_start = now;
[X_all, X_names_all] = set_up_predictor_matrix_v2(epoch_vec);
fprintf('Loaded model features in %s\n', time_elapsed(t_feat_start, now));

%% Load model parameters
% Load everything except for Y, which is big and useless
model = load(fullfile(vlfcasestudyroot, 'themis_chorus', 'themis_chorus_regression.mat'), '-regexp', '^(?!Y).*');

%% Get chorus amplitudes
chorus_ampl_filename = '~/temp/mpause_chorus_ampl.mat';
t_chorus_ampl_start = now;
if exist(chorus_ampl_filename, 'file')
  load(chorus_ampl_filename, 'chorus_ampl');
  fprintf('Loaded precomputed chorus amplitudes in %s\n', time_elapsed(t_chorus_ampl_start, now));
else
  chorus_ampl = nan([size(model.beta, 1), size(model.beta, 2), size(model.beta, 3), length(epoch_vec)]);

  for kk = 1:length(epoch_vec)
    for jj = 1:length(model.lat_centers)
      chorus_ampl(:,:,jj,kk) = run_chorus_model(X_all(kk,:), X_names_all, model, model.lat_centers(jj));
    end
  end
  
  save(chorus_ampl_filename, 'chorus_ampl');
  fprintf('Computed chorus amplitudes in %s\n', time_elapsed(t_chorus_ampl_start, now));
end

% Get chorus amplitude vs. L at noon and drop lat dependence
chorus_ampl_noon = squeeze(interp1(model.MLT_centers, permute(chorus_ampl, [2 1 4 3]), 12));

% Spline interpolate chorus amplitude across L to get a better estimate of
% L of max chorus
L_centers_interp = linspace(model.L_centers(1), model.L_centers(end), 50);
chorus_ampl_noon_interp = nan(length(L_centers_interp), length(epoch_vec));
idx_chorus_valid = all(isfinite(chorus_ampl_noon));
chorus_ampl_noon_interp(:, idx_chorus_valid) = interp1(model.L_centers, chorus_ampl_noon(:, idx_chorus_valid), L_centers_interp, 'spline');

% Find L of maximum chorus for each epoch
[chorus_ampl_noon_L_max_val, chorus_ampl_noon_L_max_idx] = max(chorus_ampl_noon_interp);
chorus_ampl_noon_L_max = L_centers_interp(chorus_ampl_noon_L_max_idx);
chorus_ampl_noon_L_max(~isfinite(chorus_ampl_noon_L_max_val)) = nan;

%% Get magnetopause
% Values needed for magnetopause calculation
qd = load(fullfile(vlfcasestudyroot, 'indices', 'QinDenton_01min_pol_them.mat'), 'epoch', 'Pdyn', 'BzIMF');
BzIMF = interp1(qd.epoch, qd.BzIMF, epoch_vec);
Pdyn = interp1(qd.epoch, qd.Pdyn, epoch_vec);
R_mpause = nan(size(epoch_vec));
for kk = 1:length(R_mpause)
  R_mpause(kk) = shue_magnetopause(BzIMF(kk), Pdyn(kk), 0);
end

clear qd

%% Plot
figure;
plot(epoch_vec, [R_mpause(:), chorus_ampl_noon_L_max(:)]);
datetick2;
grid on
ylabel('L');
legend('Magnetopause', 'Max chorus ampl');
title('Noon (MLT = 12)');
increase_font;
print_trim_png('~/temp/mp_chorus_max_L');

figure;
plot(epoch_vec, R_mpause(:) - chorus_ampl_noon_L_max(:));
datetick2;
grid on
ylabel('L_{mpause} - L_{max chorus}');
title('Noon (MLT = 12)');
increase_font;
print_trim_png('~/temp/mp_chorus_L_difference');

figure;
plot(R_mpause, chorus_ampl_noon_L_max, 'o');
xlabel('Noon Magnetopause L');
ylabel('Noon max chorus ampl L');
grid on;
title(sprintf('r = %0.2f', nancorr(R_mpause(:), chorus_ampl_noon_L_max(:))));
increase_font;
print_trim_png('~/temp/mp_chorus_max_L_scatter');


function model_flythrough_chorus_only(start_datenum, end_datenum, b_ae_kp_only)
% Fly through chorus model output along with THEMIS spacecraft and compare
% amplitudes

% By Daniel Golden (dgolden1 at stanford dot edu) June 2012
% $Id$

%% Setup
% close all;

if ~exist('end_datenum', 'var') || isempty(end_datenum)
  start_datenum = datenum([2008 09 04 10 30 0]);
  end_datenum = datenum([2008 09 05 04 0 0]);
end
if ~exist('b_ae_kp_only', 'var') || isempty(b_ae_kp_only)
  b_ae_kp_only = false;
end

addpath(fullfile(danmatlabroot, 'vlf', 'themis'));

% start_datenum = datenum([2008 09 03 0 0 0]);
dt = 1/144;
epoch_vec = start_datenum:dt:end_datenum;

%% Load model data
model_output_filename = fullfile(vlfcasestudyroot, 'themis_chorus', sprintf('chorus_model_output_%s.mat', datestr(start_datenum, 'yyyy_mm_dd')));
if exist(model_output_filename, 'file') && false
  load(model_output_filename);
  fprintf('Loaded %s\n', model_output_filename);
else
  t_data_start = now;
  [X_all, X_names_all] = set_up_predictor_matrix_v2(epoch_vec, 'b_ae_kp_only', b_ae_kp_only);
  if b_ae_kp_only
    model_filename = fullfile(vlfcasestudyroot, 'themis_chorus', 'themis_chorus_regression_ae_kp.mat');
  else
    model_filename = fullfile(vlfcasestudyroot, 'themis_chorus', 'themis_chorus_regression.mat');
  end
  model_chorus = load(model_filename, '-regexp', '^(?!Y).*');

  % Get model output
  chorus_wave_ampl_cube = squeeze(run_chorus_model(X_all, X_names_all, model_chorus, 0));
  
  % save(model_output_filename, 'X_all', 'X_names_all', 'model_chorus', 'chorus_wave_ampl_cube', 'epoch_vec', 'b_ae_kp_only');
  % fprintf('Saved %s in %s\n', model_output_filename, time_elapsed(t_data_start, now));
end

%% Get THEMIS amplitude
[chorus.epoch, chorus.field_power, chorus_eph] = get_dfb_by_em_type('A', 'chorus');
idx = chorus.epoch >= min(epoch_vec) & chorus.epoch <= max(epoch_vec);
[~, chorus_eph] = subsample_them(chorus.epoch, chorus_eph, idx);
[~, chorus] = subsample_them(chorus.epoch, chorus, idx);

%% Get model amplitude along THEMIS track
chorus_model_ampl = get_model_ampl_at_pos(model_chorus, chorus_wave_ampl_cube, epoch_vec, chorus.epoch, chorus_eph.L, chorus_eph.MLT, 'chorus');

%% Massage measured data so line plots don't stretch across gaps
% chorus_ampl_meas = massage_measured_data(chorus.epoch, sqrt(chorus.field_power)*1e3); % Convert to pT
% hiss_ampl_meas = massage_measured_data(hiss.epoch, sqrt(hiss.field_power)*1e3); % Convert to pT

chorus_ampl_meas = sqrt(chorus.field_power)*1e3; % Convert to pT

%% Replace data gaps with NaNs
% Make chorus epoch continuous, without data gaps (put NaNs where there's
% no data)
epoch_cont = min(chorus.epoch):min(diff(chorus.epoch)):max(chorus.epoch);
chorus_meas_cont = nan(size(epoch_cont));
[dist_nearest, idx_nearest] = distance_from_a_to_b(chorus.epoch, epoch_cont);
idx_valid = abs(dist_nearest) < 5/86400;
chorus_ampl_meas_nonzero = chorus_ampl_meas;
chorus_ampl_meas_nonzero(chorus_ampl_meas_nonzero == 0) = nan;
chorus_meas_cont(idx_nearest(idx_valid)) = chorus_ampl_meas_nonzero(idx_valid);

chorus_model_cont = nan(size(epoch_cont));
chorus_model_cont(idx_nearest) = chorus_model_ampl;

%% Get the running average of the measurements to compare to the model
idx_valid = chorus_ampl_meas > 0;
chorus_meas_cont_nonan = interp1(chorus.epoch(idx_valid), chorus_ampl_meas(idx_valid), epoch_cont, 'nearest');
[dist_nearest_cont, idx_nearest_cont] = distance_from_a_to_b(epoch_cont, chorus.epoch);

n_hours_filter = 2; % Number of hours to average
n_hours_fwd = 0; % Include this many hours AFTER a given time point
n_filter_taps = round(n_hours_filter/(min(diff(chorus.epoch))*24));
%chorus_meas_running_avg = exp(filter(ones(1, n_filter_taps)/n_filter_taps, 1, log(chorus_meas_cont_nonan)));
chorus_meas_running_avg = filter(ones(1, n_filter_taps)/n_filter_taps, 1, chorus_meas_cont_nonan);
chorus_meas_running_avg_epoch = epoch_cont - n_hours_fwd/24;

% Find data gaps and set running average to 0 in them
chorus_epoch_nonzero = chorus.epoch(chorus_ampl_meas > 0);
data_gap_start_idx = find(diff(chorus_epoch_nonzero) > 10/1440);
data_gap_end_idx = data_gap_start_idx + 1;
data_gap_start_epoch = chorus_epoch_nonzero(data_gap_start_idx);
data_gap_end_epoch = chorus_epoch_nonzero(data_gap_end_idx);
idx_valid = true(size(chorus_meas_running_avg));
for kk = 1:length(data_gap_start_idx)
  idx_valid(chorus_meas_running_avg_epoch > data_gap_start_epoch(kk) & chorus_meas_running_avg_epoch < data_gap_end_epoch(kk)) = false;
end
chorus_meas_running_avg(~idx_valid) = nan;

% Only plot running average where modeled amplitude is plotted
% idx_valid = ~isnan(chorus_model_ampl(idx_nearest_cont)) & abs(dist_nearest_cont) < 5/1440;
% chorus_meas_running_avg(~idx_valid) = nan;

%% Plot
figure;
h = gca;
% semilogy(chorus.epoch, [chorus_ampl_meas, chorus_model_ampl], '.', 'markersize', 8);
semilogy(epoch_cont, chorus_meas_cont, 'b-');
hold on;
semilogy(chorus_meas_running_avg_epoch, chorus_meas_running_avg, '-', 'color', [0 0.8 0], 'linewidth', 2);
semilogy(epoch_cont, chorus_model_cont, 'r-', 'LineWidth', 2);
ylim([1 100]);
ylabel('Chorus Amplitude (pT)')
grid on;
%datetick2('x', 'keeplimits');
xlim([start_datenum end_datenum]);
legend('Measured', sprintf('%d-hr avg', n_hours_filter), 'Modeled', 'Location', 'North');
figure_grow(gcf, 2, 1);


%% Get THEMIS ephemeris
eph = get_ephemeris('A', min(epoch_vec), max(epoch_vec));

%% Make ephemeris axes
tick_datenums = roundto(start_datenum, 0.125, @ceil):0.125:roundto(end_datenum, 0.125, @floor);
tick_labels = [num2cell(datestr(tick_datenums, 'HH:MM'), 2).'; ...
               num2cell(num2str(interp1(eph.epoch, eph.MLT, tick_datenums.', 'nearest'), '%0.1f'), 2).'; ...
               num2cell(num2str(interp1(eph.epoch, eph.L, tick_datenums.', 'nearest'), '%0.1f'), 2).'];
tick_labels(:, end) = {'UTC (HH:MM)', 'MLT', 'L'};
subax = add_x_axes(h, tick_datenums, tick_labels);

increase_font;

%% Smooth measured chorus and plot again
% % Lowpass smoothing filter
% smooth_time = 3/1440; % Smoothing filter window length, in days
% num_taps = round(smooth_time/min(diff(chorus.epoch)));
% chorus_cont_lowpass = filter(ones(num_taps, 1)/num_taps, 1, chorus_meas_cont);
% 
% figure
% semilogy(epoch_cont, chorus_cont_lowpass, '.', chorus.epoch, chorus_model_ampl, '.', 'markersize', 8);
% ylim([1 100]);
% ylabel('Chorus Ampl (pT)')
% title(sprintf('Measured chorus filtered with %0.0f min smoothing filter', smooth_time*1440))
% grid on;
% datetick2('x', 'keeplimits');
% legend('Measured Chorus', 'Modeled Chorus');
% figure_grow(gcf, 2, 1);
% increase_font;

1;

function wave_ampl = get_model_ampl_at_pos(model, wave_ampl_cube, model_epoch, epoch, L, MLT, em_type)
%% Function: get model wave amplitude at point and time

[L_mat, MLT_mat, model_epoch_mat] = ndgrid(model.L_centers, model.MLT_centers, model_epoch);

F = TriScatteredInterp(L_mat(:), MLT_mat(:), model_epoch_mat(:), wave_ampl_cube(:));
wave_ampl = F(L(:), MLT(:), epoch(:));

% Don't allow interpolating outside the bounds of the model
switch em_type
  case 'hiss'
    L_lim = [2.5 4.5];
  case 'chorus'
    L_lim = [5.5 10.5];
end
wave_ampl(L < L_lim(1) | L > L_lim(2)) = nan;

wave_ampl = 10.^wave_ampl; % Convert from log10 pT to pT

function data_new = massage_measured_data(epoch, data)
%% Function: stuff nans at data gaps so plots look better

idx = find(diff(epoch) > 5/1440);
data_new = data;
data_new(idx) = nan;

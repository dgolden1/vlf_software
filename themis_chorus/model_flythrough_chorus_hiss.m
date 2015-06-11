function model_flythrough_chorus_hiss
% Fly through model output along with THEMIS spacecraft and compare
% amplitudes
% 
% This uses output from an OLD chorus model from March 14, 2012

% By Daniel Golden (dgolden1 at stanford dot edu) March 2012
% $Id$

%% Setup
close all;

addpath(fullfile(danmatlabroot, 'vlf', 'themis'));

%% Get model output
% Computed in make_chorus_hiss_wave_map_movie
model_filename = fullfile(vlfcasestudyroot, 'themis_chorus', 'chorus_hiss_model_output_2008_09_03.mat');
load(model_filename, 'chorus_wave_ampl_cube', 'hiss_wave_ampl_cube', 'model_hiss', 'model_chorus', 'epoch_vec');

%% Get THEMIS amplitude
[chorus.epoch, chorus.field_power, chorus_eph] = get_dfb_by_em_type('A', 'chorus');
idx = chorus.epoch >= min(epoch_vec) & chorus.epoch <= max(epoch_vec);
[~, chorus_eph] = subsample_them(chorus.epoch, chorus_eph, idx);
[~, chorus] = subsample_them(chorus.epoch, chorus, idx);

[hiss.epoch, hiss.field_power, hiss_eph] = get_dfb_by_em_type('A', 'hiss');
idx = hiss.epoch >= min(epoch_vec) & hiss.epoch <= max(epoch_vec);
[~, hiss_eph] = subsample_them(hiss.epoch, hiss_eph, idx);
[~, hiss] = subsample_them(hiss.epoch, hiss, idx);

%% Get model amplitude along THEMIS track
model_chorus_ampl = get_model_ampl_at_pos(model_chorus, chorus_wave_ampl_cube, epoch_vec, chorus.epoch, chorus_eph.L, chorus_eph.MLT, 'chorus');
model_hiss_ampl = get_model_ampl_at_pos(model_hiss, hiss_wave_ampl_cube, epoch_vec, hiss.epoch, hiss_eph.L, hiss_eph.MLT, 'hiss');

%% Massage measured data so line plots don't stretch across gaps
% chorus_ampl_meas = massage_measured_data(chorus.epoch, sqrt(chorus.field_power)*1e3); % Convert to pT
% hiss_ampl_meas = massage_measured_data(hiss.epoch, sqrt(hiss.field_power)*1e3); % Convert to pT

chorus_ampl_meas = sqrt(chorus.field_power)*1e3; % Convert to pT
hiss_ampl_meas = sqrt(hiss.field_power)*1e3; % Convert to pT

%% Get THEMIS ephemeris
eph = get_ephemeris('A', min(epoch_vec), max(epoch_vec));

%% Plot
figure
h(1) = subplot(2, 1, 1);
semilogy(chorus.epoch, [chorus_ampl_meas, 10.^model_chorus_ampl], '.');
ylim([1 100]);
ylabel('Chorus Ampl (pT)')
grid on;
legend('Measured Chorus', 'Modeled Chorus');
set(gca, 'xticklabel', '');

h(2) = subplot(2, 1, 2);
semilogy(hiss.epoch, [hiss_ampl_meas, 10.^model_hiss_ampl], '.');
ylim([1 100]);
ylabel('Hiss Ampl (pT)');
grid on;
legend('Measured Hiss', 'Modeled Hiss');

%% Make ephemeris axes
% tick_datenums = roundto(min([chorus.epoch; hiss.epoch]), 0.25):0.25:roundto(max([chorus.epoch; hiss.epoch]), 0.25, @floor);
% tick_labels = [num2cell(datestr(tick_datenums, 'HH:MM'), 2).'; ...
%                num2cell(num2str(interp1(eph.datenum, eph.MLT, tick_datenums.', 'nearest'), '%0.1f'), 2).'; ...
%                num2cell(num2str(interp1(eph.datenum, eph.L, tick_datenums.', 'nearest'), '%0.1f'), 2).'];
% tick_labels(:, end) = {'UTC (H:M)', 'MLT', 'L'};
% subax = add_x_axes(h(2), tick_datenums, tick_labels);
               

xtick = get(h(2), 'xtick');
set(h(1), 'xtick', xtick);

increase_font;

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
    L_lim = [5.5 9.5];
end
wave_ampl(L < L_lim(1) | L > L_lim(2)) = nan;

function data_new = massage_measured_data(epoch, data)
%% Function: stuff nans at data gaps so plots look better

idx = find(diff(epoch) > 5/1440);
data_new = data;
data_new(idx) = nan;

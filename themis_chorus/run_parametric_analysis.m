function varargout = run_parametric_analysis(parameter_names, b_make_movie)
% Run a parametric analysis by varying a bunch of different parameters, one
% at a time, to see how the output changes
% [chorus_ampl_map, epoch_vec, fake_data, model] = run_parametric_analysis(parameter_names, b_make_movie)

% By Daniel Golden (dgolden1 at stanford dot edu) May 2012
% $Id$

%% Setup
if ~exist('parameter_names', 'var') || isempty(parameter_names)
  parameter_names = {'ae_pulse_bz_step', ...
                     'ae_pulse_bz_pulse', ...
                     'pdyn_step', ...
                     'pdyn_pulse', ...
                     'bz_step', ...
                     'ae_pulse', ...
                     'symh_pulse'};
elseif ischar(parameter_names)
  parameter_names = {parameter_names};
end

if ~exist('b_make_movie', 'var') || isempty(b_make_movie)
  if nargout == 0
    b_make_movie = true;
  else
    b_make_movie = false;
  end
end

%% Data ranges for "quiet" and "peak disturbed" cases
lim.AE = [60 500];
lim.ByIMF = [0 0];
lim.BzIMF = [2 -5];
lim.symh = [-5 -40];
lim.Pdyn = [1.5 3];
lim.V_SW = [375 550];

% Index axes limits
idx_ax_limits.AE = [0 600];
idx_ax_limits.symh = [-50 0];
idx_ax_limits.Pdyn = [0 4];
idx_ax_limits.dphi_mp_dt = [0 1e4];
idx_ax_limits.Bz = [-7 7];

%% Data defaults ("quiet" values)
fake_data_orig.epoch = 0:1/1440:2; % Epochs over which features are defined
fake_data_orig.epoch_plot = (min(fake_data_orig.epoch) + 1):(1/144):max(fake_data_orig.epoch); % Epochs over which to evaluate model
data_size = size(fake_data_orig.epoch);

fn = fieldnames(lim);
for kk = 1:length(fn)
  fake_data_orig.(fn{kk}) = lim.(fn{kk})(1)*ones(data_size);
end

fake_data_orig.name = '';

%% Plot the data (for debugging)
% for kk = 1:length(fn), subplot(length(fn), 1, kk); plot(fake_data_orig.epoch, fake_data_orig.(fn{kk})); ylabel(fn{kk}); end

for kk = 1:length(parameter_names)
  fake_data{kk} = fake_data_orig;
  
  switch lower(parameter_names{kk})
    case 'ae_pulse_bz_step'
      fake_data{kk} = get_bz_ae_data(lim, fake_data{kk}, 'step');
    case 'ae_pulse_bz_pulse'
      fake_data{kk} = get_bz_ae_data(lim, fake_data{kk}, 'pulse');
    case 'pdyn_step'
      fake_data{kk}.Pdyn(fake_data{kk}.epoch >= 1 + 4/24) = lim.Pdyn(2);
    case 'pdyn_pulse'
      fake_data{kk}.Pdyn(fake_data{kk}.epoch >= 1 + 4/24 & fake_data{kk}.epoch < (1 + 4/24 + 30/1440)) = lim.Pdyn(2);
    case 'bz_step'
      fake_data{kk}.BzIMF(fake_data{kk}.epoch >= 1 + 4/24) = lim.BzIMF(2);
    case 'ae_pulse'
      fake_data{kk}.AE = make_triangle_pulse(fake_data{kk}.epoch, 1 + 4/24, 1.5/24, 0, 1.5/24, lim.AE(1), lim.AE(2));
    case 'symh_pulse'
      fake_data{kk} = get_symh_pulse_fake_data(lim);
      
    otherwise
      error('Unknown run_name: %s', parameter_names{kk});
  end
  
  fake_data{kk}.name = parameter_names{kk};
  
  if nargout > 0
    [chorus_ampl_map{kk}, model] = run_one_analysis(fake_data{kk}, idx_ax_limits, b_make_movie);
    epoch_plot{kk} = fake_data{kk}.epoch_plot;
  else
    run_one_analysis(fake_data{kk}, idx_ax_limits, b_make_movie);
  end
end

%% Assign output arguments
if nargout > 0
  varargout{1} = chorus_ampl_map;
  varargout{2} = epoch_plot;
  varargout{3} = fake_data;
  varargout{4} = model;
end


function [chorus_ampl_map, model] = run_one_analysis(fake_data, idx_ax_limits, b_make_movie)
%% Function: do one run

[fake_data.X_all, fake_data.X_names_all] = set_up_predictor_matrix_v2(fake_data.epoch_plot, 'fake_data', fake_data);

if b_make_movie
  make_chorus_wave_map_movie('fake_data', fake_data, 'idx_ax_limits', idx_ax_limits, 'chorus_cax', log10([1 10]));
end

if nargout > 0
  model_filename = fullfile(vlfcasestudyroot, 'themis_chorus', 'themis_chorus_regression.mat');
  model = load(model_filename);
  chorus_ampl_map = run_chorus_model(fake_data.X_all, fake_data.X_names_all, model, 0);
end

function fake_data_symh_pulse = get_symh_pulse_fake_data(lim)
%% Function: get fake data for SYM-H pulse

% Asymmetric triangle pulse, starting at t = 1, reaching peak 12 hours later, and
% returning to baseline 36 hours later (full width 48 hours)

% Longer data because the symh pulse is super long
fake_data.epoch = 0:1/1440:4; % Epochs over which features are defined
fake_data.epoch_plot = (min(fake_data.epoch) + 1):(1/144):max(fake_data.epoch); % Epochs over which to evaluate model
data_size = size(fake_data.epoch);

fn = fieldnames(lim);
for kk = 1:length(fn)
  fake_data.(fn{kk}) = lim.(fn{kk})(1)*ones(data_size);
end

% Calculate the pulse
fake_data_symh_pulse = fake_data;
fake_data_symh_pulse.name = 'symh_pulse';

fake_data_symh_pulse.symh = make_triangle_pulse(fake_data.epoch, 1 + 4/24, 12/24, 0, 36/24, lim.symh(1), lim.symh(2));

function fake_data = get_bz_ae_data(lim, fake_data, str_bz_format)
%% Function: get fake data from AE pulse and Bz pulse/step

fake_data.AE = make_triangle_pulse(fake_data.epoch, 1 + 4/24, 1.5/24, 0, 1.5/24, lim.AE(1), lim.AE(2));

switch str_bz_format
  case 'step'
    fake_data.BzIMF = make_triangle_pulse(fake_data.epoch, 1 + 4/24, 0.5/24, 0, Inf, lim.BzIMF(1), lim.BzIMF(2));
  case 'pulse'
    fake_data.BzIMF = make_triangle_pulse(fake_data.epoch, 1 + 4/24, 0.5/24, 1/24, 0.5/24, lim.BzIMF(1), lim.BzIMF(2));
  otherwise
    error('Invalid str_bz_format: %s', str_bz_format);
end


function data = make_triangle_pulse(epoch, start_time, time_to_high, time_plateau, time_to_low, low_val, high_val)
%% Function: make a triangular pulse with potentially uneven slopes

% y = mx + b
% (y2 - y1) = m*(x2 - x1)

data = low_val*ones(size(epoch));

m_rise = (high_val - low_val)/time_to_high;
b_rise = low_val - m_rise*start_time;
idx_rise = epoch >= start_time & epoch < start_time + time_to_high;
data(idx_rise) = m_rise*epoch(idx_rise) + b_rise;

idx_plateau = epoch >= start_time + time_to_high & epoch < start_time + time_to_high + time_plateau;
data(idx_plateau) = high_val;

m_fall = (low_val - high_val)/time_to_low;
b_fall = high_val - m_fall*(start_time + time_to_high + time_plateau);
idx_fall = epoch >= start_time + time_to_high + time_plateau & epoch < start_time + time_to_high + time_plateau + time_to_low;
data(idx_fall) = m_fall*epoch(idx_fall) + b_fall;

1;

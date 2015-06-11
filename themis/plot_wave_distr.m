function plot_wave_distr(probe, varargin)
% Plot L-MLT distribution of waves
% 
% plot_wave_distr(probe, 'param', value, ...)
% 
% INPUTS
% probe: 'A' (default), 'B', 'C', 'D', 'E', a cell array of some
%  combination of probes or 'all'
% 
% PARAMETERS:
% start_datenum: don't plot data before this date
% end_datenum: don't plot data after this date
% em_type: 'chorus', 'hiss' or 'both' (default).  If 'chorus' or 'hiss' are
%  selected, the emissions are differentiated based on the satellite's
%  location with respect to the plasmapause (a parameter that has some
%  gaps) and in the case of chorus, channels are selected that have some
%  component within 0.1--0.5 fce
% ae_level: either 1 (AE < 100 nT), 2 (100 nT < AE 300 nT), 3 (AE > 300 nT)
%  or 'all' (default)
% b_plot_samples: true to also plot an L-MLT map of sample density
%  (default: false)
% avg_method: how to average over the amplitudes; one of 'amplitude' (same
%  as Meredith's studies), 'power' (same as Li's 2009 study) or 'dB' (same
%  as my cumulative spectrograms, default).  This will determine the extent
%  to which big emissions swamp the statistics
% dL: L bin size (Re, default: 0.25)
% dMLT: MLT bin size (hr, default: 1)

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Parse arguments
p = inputParser;
p.addParamValue('start_datenum', 0);
p.addParamValue('end_datenum', Inf);
p.addParamValue('em_type', 'all');
p.addParamValue('ae_level', 'all');
p.addParamValue('b_plot_samples', false);
p.addParamValue('avg_method', 'dB');
p.addParamValue('dL', 0.25);
p.addParamValue('dMLT', 1);
p.addParamValue('L_max', 10);
p.parse(varargin{:});
start_datenum = p.Results.start_datenum;
end_datenum = p.Results.end_datenum;
em_type = p.Results.em_type;
ae_level = p.Results.ae_level;
b_plot_samples = p.Results.b_plot_samples;
dL = p.Results.dL;
dMLT = p.Results.dMLT;
L_max = p.Results.L_max;
avg_method = p.Results.avg_method;

% By setting L_min lower for chorus, the plots look basically the same, but
% this fixes a bug when plotting gridlines via make_mlt_plot_grid.m; when
% shading is flat and L_min is 2, the dashed grid becomes very coarse. When
% L_min is 5, the dashed grid is finer. The grid is screwed up regardless
% with interpolated shading.
if strcmp(em_type, 'hiss')
  L_min = 2;
else
  L_min = 5; 
end

%% Setup
if ischar(probe)
  if strcmp(probe, 'all')
    probe = {'A', 'B', 'C', 'D', 'E'};
  else
    probe = {probe};
  end
end

probe_str = '';
for kk = 1:(length(probe) - 1)
  probe_str = [probe_str, upper(probe{kk}), ', '];
end
probe_str = [probe_str, upper(probe{end})];

%% Choose averaging method functions
switch lower(avg_method)
  case 'amplitude'
    fwd_avg_fcn = @(x) sqrt(x);
    rvs_avg_fcn = @(x) 2*log10(x);
    cax = [0 20]; % dB-pT
  case 'power'
    fwd_avg_fcn = @(x) x;
    rvs_avg_fcn = @log10;
    cax = [10 30]; % dB-pT
  case 'db'
    fwd_avg_fcn = @log10;
    rvs_avg_fcn = @(x) x;
    cax = [-5 22]; % dB-pT
  otherwise
    error('Weird value for avg_method: %s', avg_method);
end

%% Load AE
ae = load(fullfile(vlfcasestudyroot, 'indices', 'ae_1min.mat'), 'ae', 'epoch');

%% Load B-field data
for kk = 1:length(probe)
  [field_epoch_list{kk,1}, field_power_list{kk,1}, eph] = get_dfb_by_em_type(probe{kk}, em_type);
  L_list{kk,1} = eph.L;
  MLT_list{kk,1} = eph.MLT;
end
field_epoch = cell2mat(field_epoch_list);
field_power = cell2mat(field_power_list);
L = cell2mat(L_list);
MLT = cell2mat(MLT_list);

if ~all(isfinite(field_power))
  error('All field_power values must be finite');
end

idx_valid = field_epoch >= start_datenum & field_epoch < end_datenum & field_power > 0;

if ischar(ae_level)
  assert(strcmp(ae_level, 'all'));
  ae_str = 'all';
else
  ae_int = interp1(ae.epoch, ae.ae, field_epoch);
  assert(all(isfinite(ae_int)));
  switch ae_level
    case 1
      idx_valid = idx_valid & ae_int < 100;
      ae_str = 'AE < 100 nT';
    case 2
      idx_valid = idx_valid & ae_int >= 100 & ae_int <= 300;
      ae_str = '100 <= AE <= 300 nT';
    case 3
      idx_valid = idx_valid & ae_int > 300;
      ae_str = 'AE > 300 nT';
    otherwise
      error('Invalid value for ae_level: %d', ae_level);
  end
end

field_epoch = field_epoch(idx_valid);
field_power = field_power(idx_valid);
L = L(idx_valid);
MLT = MLT(idx_valid);

%% Generate histograms
durations = median(diff(field_epoch))*86400; % Inter-sample period, seconds

L_edges = L_min:dL:L_max;
MLT_edges = 0:dMLT:24;

[N_duration, r, theta] = plot_l_mlt(L, MLT, L_edges, MLT_edges, durations, 'b_plot', false);
[N_total, r, theta] = plot_l_mlt(L, MLT, L_edges, MLT_edges, 1, 'b_plot', false);
[N, r, theta] = plot_l_mlt(L, MLT, L_edges, MLT_edges, fwd_avg_fcn(field_power), 'b_plot', false);

% Vectors of r and theta, for debuggin via imagesc
MLT_vec = (dMLT/2):dMLT:(24 + dMLT/2);
r_vec = r(:,1);

%% Exclude areas of low measurement
min_seconds = 120; % Exclude bins with fewer than this many seconds
N(N_duration < min_seconds) = nan;

%% Plot wave map
b_shading_interp = true;
% b_shading_interp = false;
if dMLT >= 2 && fpart(dMLT) == 0
  MLT_gridlines = 0:dMLT:23;
else
  MLT_gridlines = 0:23;
end
wave_map_r = r(:,1:end-1);
wave_map_MLT = (theta(:,1:end-1) + pi)*24/(2*pi);
% wave_map_durations = (rvs_avg_fcn(N(:,1:end-1)./N_total(:,1:end-1)) + 6)*10; % avg dB-pT
wave_map_durations = (rvs_avg_fcn(N(:,1:end-1)./N_total(:,1:end-1)) + 6)/2; % avg log10 pT
idx_wave_map = isfinite(wave_map_durations);

plot_l_mlt(wave_map_r(idx_wave_map), wave_map_MLT(idx_wave_map), L_edges, MLT_edges, ...
  wave_map_durations(idx_wave_map), 'scaling_function', 'none', 'b_shading_interp', b_shading_interp, ...
  'b_oversample_mlt', true, 'MLT_gridlines', MLT_gridlines);

axis off
c = colorbar;
% old_cax = caxis;
% new_cax = [floor(old_cax(1)) ceil(old_cax(2))];
% caxis(new_cax);
% log_colorbar(new_cax, 'h_cbar', c, 'ax_label', 'avg pT')
ylabel(c, 'avg log_{10} pT');
% caxis(cax);

title(sprintf('THEMIS %s %s emissions avg B-field (%s)\n%s to %s', probe_str, em_type, ae_str, ...
  datestr(floor(min(field_epoch)), 29), datestr(ceil(max(field_epoch)), 29)));

increase_font;

%% Plot sample density
if b_plot_samples
  plot_l_mlt(L, MLT, L_edges, MLT_edges, 1, ...
    'b_shading_interp', false, 'b_oversample_mlt', true, 'MLT_gridlines', MLT_gridlines);
  title(sprintf('THEMIS %s %s emission samples (%s)\n%s to %s', probe_str, em_type, ae_str, ...
    datestr(floor(min(field_epoch)), 29), datestr(ceil(max(field_epoch)), 29)));

  axis off
  c = colorbar;
  ylabel(c, sprintf('log_{10} # %d-sec samples', round(durations)));
  % caxis([0.5 4] + log10(4*dL*dMLT)); % Calibrated for hiss, dL = 0.25, dMLT = 1
  
  increase_font;
end

1;

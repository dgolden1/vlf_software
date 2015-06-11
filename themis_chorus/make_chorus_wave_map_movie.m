function make_chorus_wave_map_movie(varargin)
% Show evolution of a wave map over an actual time period
% 
% PARAMETERS
% start_datenum: default: 2008-09-03 00:00
% end_datenum: default: 2008-09-05 06:00
% dt: time step in days (default: 1/144 = 10 min)
% fake_data: some fake data on which to run the model; a struct with the
%  fields 'epoch_plot', 'X_all', 'X_names_all', 'name'
% idx_ax_limits: struct with fields AE, symh, Pdyn, dphi_mp_dt, defining
%  the y-axis limits for these indices if they're plotted
% chorus_cax: color axis limits for chorus plots (log10 pT)
% b_equatorial: true (default) to plot in equatorial plane; false to plot
%  in meridional plane
% b_ae_kp_only: use the model which only has current AE* and Kp as inputs

% By Daniel Golden (dgolden1 at stanford dot edu) January 2012
% $Id$

%% Parse input parameters
p = inputParser;
p.addParamValue('start_datenum', datenum([2008 09 03 0 0 0]));
p.addParamValue('end_datenum', datenum([2008 09 05 06 0 0]));
p.addParamValue('dt', 10/1440);
p.addParamValue('framerate', 15);
p.addParamValue('fake_data', [])
p.addParamValue('idx_ax_limits', []);
p.addParamValue('chorus_cax', [0 2]);
p.addParamValue('b_equatorial', true);
p.addParamValue('b_ae_kp_only', false);
p.parse(varargin{:});
start_datenum = p.Results.start_datenum;
end_datenum = p.Results.end_datenum;
dt = p.Results.dt;
framerate = p.Results.framerate;
fake_data = p.Results.fake_data;
idx_ax_limits = p.Results.idx_ax_limits;
chorus_cax = p.Results.chorus_cax;
b_equatorial = p.Results.b_equatorial;
b_ae_kp_only = p.Results.b_ae_kp_only;

%% Setup
t_net_start = now;

input_dir = fullfile(vlfcasestudyroot, 'themis_chorus');
output_dir = '~/temp';

%% Load model features
if isempty(fake_data)
  epoch_vec = start_datenum:dt:end_datenum;

  t_feat_start = now;
  [X_all, X_names_all] = set_up_predictor_matrix_v2(epoch_vec, 'b_ae_kp_only', b_ae_kp_only);
  fprintf('Loaded model features in %s\n', time_elapsed(t_feat_start, now));
else
  epoch_vec = fake_data.epoch_plot;
  X_all = fake_data.X_all;
  X_names_all = fake_data.X_names_all;
end

%% Load model parameters
% Load everything except for Y, which is big and useless
if b_ae_kp_only
  model_filename = fullfile(input_dir, 'themis_chorus_regression_ae_kp.mat');
else
  model_filename = fullfile(input_dir, 'themis_chorus_regression.mat');
end
  

model = load(model_filename, '-regexp', '^(?!Y).*');

%% Make figure with plots of indices
if b_equatorial
  num_eff_rows_map = 6;
  num_rows_map = 1;
  num_cols_map = length(model.lat_centers);
  num_extra_rows = length(model.lat_centers);
else
  num_eff_rows_map = 6;
  num_rows_map = 2;
  num_cols_map = 2;
  num_extra_rows = 0;
end

% Gather values of various geomagnetic indices and solar wind parameters
% for line plots in the movie
if isempty(fake_data) || b_ae_kp_only
  qd = load(fullfile(vlfcasestudyroot, 'indices', 'QinDenton_01min_pol_them.mat'), '-regexp', '^(?!Dst).*');
  symh = load(fullfile(vlfcasestudyroot, 'indices', 'asy_sym.mat'), 'epoch', 'symh');
  
  indices.AE = interp1(qd.epoch, qd.AE, epoch_vec);
  indices.symh = interp1(symh.epoch, symh.symh, epoch_vec);
  indices.Pdyn = interp1(qd.epoch, qd.Pdyn, epoch_vec);
  indices.dphi_mp_dt = interp1(qd.epoch, get_dphi_mp_dt(qd.V_SW, qd.ByIMF, qd.BzIMF, qd.Pdyn), epoch_vec);
  indices.Bz = interp1(qd.epoch, qd.BzIMF, epoch_vec);
  clear qd symh;
else
  indices.AE = interp1(fake_data.epoch, fake_data.AE, epoch_vec, 'nearest');
  indices.symh = interp1(fake_data.epoch, fake_data.symh, epoch_vec, 'nearest');
  indices.Pdyn = interp1(fake_data.epoch, fake_data.Pdyn, epoch_vec, 'nearest');
  indices.dphi_mp_dt = interp1(fake_data.epoch, ...
    get_dphi_mp_dt(fake_data.V_SW, fake_data.ByIMF, fake_data.BzIMF, fake_data.Pdyn), epoch_vec, 'nearest');
  indices.Bz = interp1(fake_data.epoch, fake_data.BzIMF, epoch_vec, 'nearest');
end

[h_map, h_extra, h_indices, x_lim, x_ticks, label_start_time] = movie_make_figure(...
  num_eff_rows_map, num_rows_map, num_cols_map, num_extra_rows, epoch_vec, indices, [], idx_ax_limits);
h_fig = gcf;

%% Make colorbar
map_pos = get(h_map(end), 'position');
h_cbar = axes('position', [0.42, map_pos(2) - 0.02, 0.2, 0.015]);
[h_cbar(1), h_cbar(2)] = log_colorbar(10.^chorus_cax, 'ax_label', 'Chorus Amplitude (pT)', ...
  'orientation', 'horizontal', 'h_cbar', h_cbar);

%% Get chorus amplitudes
chorus_ampl = nan([size(model.beta, 1), size(model.beta, 2), size(model.beta, 3), length(epoch_vec)]);

t_chorus_ampl_start = now;
for kk = 1:length(epoch_vec)
  for jj = 1:length(model.lat_centers)
    chorus_ampl(:,:,jj,kk) = run_chorus_model(X_all(kk,:), X_names_all, model, model.lat_centers(jj));
  end
end
fprintf('Computed chorus amplitudes in %s\n', time_elapsed(t_chorus_ampl_start, now));

%% Make MLT-epoch chorus amplitude axes (keogram)
if b_equatorial
  if isempty(fake_data)
    epoch_vec_plot = epoch_vec;
  else
    epoch_vec_plot = (epoch_vec - min(epoch_vec))*24;
  end
  [epoch_keyogram, MLT_keyogram, keogram] = make_chorus_keogram(chorus_ampl, epoch_vec_plot, model.L_centers, model.MLT_centers, model.lat_centers);

  h_idx = [];

  for kk = 1:length(model.lat_centers)
    this_ax_num = length(h_idx) + 1;

    saxes(h_extra(kk));
    imagesc(epoch_keyogram, MLT_keyogram, keogram{kk});
    axis xy
    yl = [0 24];
    ylim(yl);
    ylabel('MLT');
    if length(model.lat_centers) > 1
      lat_str = sprintf('\\lambda=%0.0f^\\circ', model.lat_centers(kk));
    else
      lat_str = '';
    end
    text(label_start_time, yl(1) + diff(yl)*0.7, sprintf('Chorus Amplitude %s', lat_str), ...
      'fontweight', 'bold', 'color', 'k');
    set(gca, 'ytick', 0:6:18, 'xticklabel', [], 'xtick', x_ticks, 'xlim', x_lim);
    caxis(chorus_cax);
  end
end

%% Make movie
if b_equatorial
  plane_str = 'L_MLT';
else
  plane_str = 'meridional';
end

if isempty(fake_data)
  date_suffix = sprintf('%s--%s', datestr(start_datenum, 'yyyy-mm-dd'), datestr(end_datenum, 'yyyy-mm-dd'));
else
  date_suffix = sprintf('fake_data_%s', fake_data.name);
end
if b_ae_kp_only
  type_suffix = '_ae_kp';
else
  type_suffix = '';
end
output_filename = sprintf('chorus_model_%s%s_%s.avi', plane_str, type_suffix, date_suffix);

movie_filename = fullfile(output_dir, output_filename);

movie_fofo(@(frameno) update_movie_frame(frameno, epoch_vec_plot, chorus_ampl, model, fake_data, h_map, [h_indices h_extra], chorus_cax, b_equatorial), ...
  length(epoch_vec), 'output_filename', movie_filename, 'framerate', framerate, 'h_fig', h_fig);

fprintf('Processing complete in %s\n', time_elapsed(t_net_start, now));

1;

function plot_chorus_ampl_equatorial(chorus_ampl, model, fake_data, epoch, h_ax, chorus_cax)
%% Function: plot an L-MLT map of a given chorus amplitude

% Values needed for magnetopause calculation
if isempty(fake_data)
  persistent qd
  if isempty(qd)
    qd = load(fullfile(vlfcasestudyroot, 'indices', 'QinDenton_01min_pol_them.mat'), 'epoch', 'Pdyn', 'BzIMF');
  end
  BzIMF = interp1(qd.epoch, qd.BzIMF, epoch);
  Pdyn = interp1(qd.epoch, qd.Pdyn, epoch);
else
  BzIMF = interp1(fake_data.epoch, fake_data.BzIMF, epoch, 'nearest');
  Pdyn = interp1(fake_data.epoch, fake_data.Pdyn, epoch, 'nearest');
end

[L_mat, MLT_mat] = ndgrid(model.L_centers, model.MLT_centers);

L_edges = model.L_edges;
L_max = max(L_edges);
% L_edges = 5:L_max;

for kk = 1:length(model.lat_centers)
  this_chorus_ampl = chorus_ampl(:,:,kk);
  idx_plot = isfinite(this_chorus_ampl);
  % plot_l_mlt(L_mat(idx_plot), MLT_mat(idx_plot), model.L_edges, model.MLT_edges,  chorus_ampl(idx_plot), ...
  %           'scaling_function', 'none', 'b_shading_interp', false, 'b_oversample_mlt', true, ...
  %           'MLT_gridlines', 0:2:22, 'h_ax', h_ax);
  cla(h_ax(kk));
  plot_l_mlt(L_mat(idx_plot), MLT_mat(idx_plot), L_edges, model.MLT_edges,  this_chorus_ampl(idx_plot), ...
            'scaling_function', 'none', 'MLT_gridlines', 0:2:22, 'b_oversample_mlt', true, 'h_ax', h_ax(kk));

  caxis(chorus_cax);
  axis off
  
  % theta_mpause = linspace(0, 2*pi, 100);
  % R_mpause = shue_magnetopause(BzIMF, Pdyn, theta_mpause);
  
  set(gca, 'xlimmode', 'manual', 'ylimmode', 'manual');
  % plot(R_mpause.*cos(theta_mpause), R_mpause.*sin(theta_mpause), 'color', [1 0 1], 'linewidth', 2);

  text(L_max*1.02*cos(pi/4), L_max*1.02*sin(pi/4), sprintf('%d R_E', L_max));
  
  if kk == ceil(length(model.lat_centers)/2)
    if epoch > datenum([1900 0 0 0 0 0])
      title_prefix = sprintf('Chorus model\n%s', datestr(epoch, 31)); % Epoch is a datenum
    else
      title_prefix = sprintf('Chorus model\n%0.2f hrs', epoch); % Epoch is in hours
    end
  else
    title_prefix = '';
  end
  if length(model.lat_centers) > 1
    title_suffix = sprintf('\n%s\\lambda=%0.0f^\\circ', title_prefix, model.lat_centers(kk));
  else
    title_suffix = '';
  end
  title([title_prefix title_suffix]);
end

function plot_chorus_ampl_meridional(chorus_ampl, model, epoch, h_ax, chorus_cax)
%% Function: plot an L-MLT map of a given chorus amplitude

b_interp = true;

% Assume we did the modeling with dMLT == 3 hours
assert(length(model.MLT_centers) == 4);

mlt_plot_order = [0 12 6 18];
mlt_plot_dir = {'left', 'right', 'left', 'right'};
earth_color = {'k', 'w', [1 1 1]*0.5, [1 1 1]*0.5};

for kk = 1:4
  % Average over two adjacent MLT sectors, starting with midnight
  % this_mlt_idx = mod((kk-2)*2 + [1 2], length(model.MLT_centers)) + 1;
  % this_MLT_center = mod(model.MLT_centers(this_mlt_idx(1)) + ...
  %   angledist(model.MLT_centers(this_mlt_idx(1))*pi/12, model.MLT_centers(this_mlt_idx(2))*pi/12, 'rad')*12/pi/2, 24);
  this_mlt_idx = kk;
  this_MLT_center = model.MLT_centers(kk);

  
  ax_idx = find(mlt_plot_order == this_MLT_center);
  cla(h_ax(ax_idx));
  
  this_chorus_ampl = squeeze(nanmean(chorus_ampl(:,this_mlt_idx,:), 2));
  plot_meridional(model.L_edges, model.L_centers, model.lat_edges, model.lat_centers, this_chorus_ampl, ...
    'cax', chorus_cax, 'b_interp', b_interp, 'outer_direc', mlt_plot_dir{ax_idx}, 'earth_color', earth_color{ax_idx}, 'h_ax', h_ax(ax_idx));
  
  axis off

  text(mean(xlim), 4.5, sprintf('MLT=%0.0f', this_MLT_center), 'horizontalalignment', 'center');
end

axes(h_ax(1));
text(max(xlim), 4.5, datestr(epoch, 31), 'horizontalalignment', 'center');

1;

function update_index_cursor(epoch, h_idx)
%% Function: update the cursor in the line plots to show what time it is
delete(findobj(h_idx, 'tag', 'epoch_cursor'));

for kk = 1:length(h_idx)
  saxes(h_idx(kk));
  hold on;
  
  yl = ylim;
  
  h_epoch_cursor = plot(epoch*[1 1], yl, 'r-');
  set(h_epoch_cursor, 'tag', 'epoch_cursor');
end

function update_movie_frame(frameno, epoch_vec, chorus_ampl, model, fake_data, h_map, h_indices, chorus_cax, b_equatorial)
%% Function: make a new frame for the movie

if b_equatorial
  plot_chorus_ampl_equatorial(chorus_ampl(:,:,:,frameno), model, fake_data, epoch_vec(frameno), h_map, chorus_cax);
else
  plot_chorus_ampl_meridional(chorus_ampl(:,:,:,frameno), model, epoch_vec(frameno), h_map, chorus_cax);
end
update_index_cursor(epoch_vec(frameno), h_indices);

increase_font(gcf, 14);

1;

function [h_map, h_extra, h_indices, x_lim, x_ticks, label_start_time] = movie_make_figure(num_eff_rows_map, num_rows_map, num_cols_map, num_extra_rows, epoch_vec, indices, indices_to_plot, ax_limits)
% Make figure for the wave map movie with time plots of indices along the
% bottom
% 
% INPUTS
% num_eff_rows_map: number of rows that the wave map will take up
% num_extra_rows: number of extra rows to leave blank for, for example,
%  keyograms which will be created separately


% By Daniel Golden (dgolden1 at stanford dot edu) May 2012
% $Id$

%% Setup
if ~exist('ax_limits', 'var') || isempty(ax_limits)
  ax_limits.AE = [0 1600];
  ax_limits.symh = [-65 30];
  ax_limits.Pdyn = [0 10];
  ax_limits.dphi_mp_dt = [0 2e4];
  ax_limits.Bz = [-15 15];
end

if min(epoch_vec) < 5 % If this is fake data (i.e., dates start around 0), plot by hour
  b_fake_data = true;
else
  b_fake_data = false;
end

%% Choose which indices to plot
if ~exist('indices_to_plot', 'var') || isempty(indices_to_plot)
  indices_to_plot = {'AE', ...
                     'SYM-H', ...
                     'Pdyn', ...
                     ...'dphi_mp_dt', ...
                     'Bz', ...
                    };
end
num_rows_idx = length(indices_to_plot);

%% Set up axes
% super_subplot parameters
nrows = num_eff_rows_map + num_extra_rows + num_rows_idx + 1; % An extra row for the map colorbar
ncols = 1;
hspace = 0;
vspace = 0.005;
hmargin = [0.06 0.02];
if b_fake_data
  vmargin = [0.1 0.05];
else
  vmargin = [0.05 0.05];
end

h_fig = figure;
% figure_grow(gcf, 1, 2);
if num_cols_map > 2
  figure_grow(gcf, 2);
else
  figure_grow(gcf, 1.7, 2);
end

if min(epoch_vec) < 5 % If this is fake data (i.e., dates start around 0), plot by hour
  epoch_vec = (epoch_vec - min(epoch_vec))*24;
end
start_datenum = min(epoch_vec);
end_datenum = max(epoch_vec);
x_lim = [start_datenum end_datenum];
label_start_time = start_datenum + (end_datenum - start_datenum)*0.02;
x_vals = epoch_vec;

if b_fake_data
  d_tick = floor((end_datenum - start_datenum)/10);
  x_ticks = ceil(start_datenum):d_tick:end_datenum;
elseif end_datenum - start_datenum < 5
  x_ticks = floor(start_datenum):0.5:end_datenum;
else
  tick_cadence = floor((end_datenum - start_datenum)/4);
  x_ticks = floor(start_datenum):tick_cadence:end_datenum;
end


%% Make map axes
h_map = [];
true_num_rows_map = num_eff_rows_map/num_rows_map;
for jj = 1:num_rows_map
  for kk = 1:num_cols_map
    this_idx = (0:(true_num_rows_map - 1))*num_cols_map + kk + (jj-1)*(true_num_rows_map*num_cols_map);
    h_map(end+1) = super_subplot(nrows, num_cols_map, this_idx, hspace, vspace, hmargin, vmargin);
  end
end

%% Make extra axes
h_extra = [];
for kk = 1:num_extra_rows
  h_extra(kk) = super_subplot(nrows, ncols, num_eff_rows_map + 1 + kk, hspace, vspace, hmargin, vmargin);
end

%% Make index axes
h_indices = [];

if ismember('AE', indices_to_plot)
  this_ax_num = length(h_indices) + 1;
  h_indices(end+1) = super_subplot(nrows, ncols, num_eff_rows_map + 1 + num_extra_rows + this_ax_num, hspace, vspace, hmargin, vmargin);
  plot(x_vals, indices.AE, 'k');
  set(gca, 'xticklabel', [], 'xtick', x_ticks, 'xlim', x_lim);
  ylim(ax_limits.AE);
  text(label_start_time, ax_limits.AE(1) + diff(ax_limits.AE)*0.7, 'AE (nT)', 'fontweight', 'bold');
end

if ismember('SYM-H', indices_to_plot)
  this_ax_num = length(h_indices) + 1;
  h_indices(end+1) = super_subplot(nrows, ncols, num_eff_rows_map + 1 + num_extra_rows + this_ax_num, hspace, vspace, hmargin, vmargin);
  plot(x_vals, indices.symh, 'k');
  set(gca, 'xticklabel', [], 'xtick', x_ticks, 'xlim', x_lim);
  % set(gca, 'ytick', [-40 0]);
  ylim(ax_limits.symh);
  text(label_start_time, ax_limits.symh(1) + diff(ax_limits.symh)*0.2, 'SYM-H (nT)', 'fontweight', 'bold');
end

if ismember('Pdyn', indices_to_plot)
  this_ax_num = length(h_indices) + 1;
  h_indices(end+1) = super_subplot(nrows, ncols, num_eff_rows_map + 1 + num_extra_rows + this_ax_num, hspace, vspace, hmargin, vmargin);
  plot(x_vals, indices.Pdyn, 'k');
  set(gca, 'xticklabel', [], 'xtick', x_ticks, 'xlim', x_lim);
  ylim(ax_limits.Pdyn);
  text(label_start_time, ax_limits.Pdyn(1) + diff(ax_limits.Pdyn)*0.7, 'P_{dyn} (nPa)', 'fontweight', 'bold');
end

if ismember('dphi_mp_dt', indices_to_plot)
  this_ax_num = length(h_indices) + 1;
  h_indices(end+1) = super_subplot(nrows, ncols, num_eff_rows_map + 1 + num_extra_rows + this_ax_num, hspace, vspace, hmargin, vmargin);
  plot(x_vals, indices.dphi_mp_dt, 'k');
  set(gca, 'xticklabel', [], 'xtick', x_ticks, 'xlim', x_lim);
  % set(gca, 'ytick', 0:5e3:1.5e4, 'yticklabel', num2str((0:5e3:1.5e4).'));
  ylim(ax_limits.dphi_mp_dt);
  text(label_start_time, ax_limits.dphi_mp_dt(1) + diff(ax_limits.dphi_mp_dt)*0.7, 'd\Phi_{MP}/dt', 'fontweight', 'bold');
end

if ismember('Bz', indices_to_plot)
  this_ax_num = length(h_indices) + 1;
  h_indices(end+1) = super_subplot(nrows, ncols, num_eff_rows_map + 1 + num_extra_rows + this_ax_num, hspace, vspace, hmargin, vmargin);
  plot(x_vals, indices.Bz, 'k');
  hold on;
  plot(x_vals, zeros(size(x_vals)), 'k--');
  set(gca, 'xticklabel', [], 'xtick', x_ticks, 'xlim', x_lim);
  % set(gca, 'ytick', 0:5e3:1.5e4, 'yticklabel', num2str((0:5e3:1.5e4).'));
  ylim(ax_limits.Bz);
  text(label_start_time, ax_limits.Bz(1) + diff(ax_limits.Bz)*0.7, 'B_z (nT)', 'fontweight', 'bold');
end

if b_fake_data
  set(gca, 'xticklabelmode', 'auto');
  xlabel('Hours');
else
  datetick('x', 'mmm dd', 'keeplimits', 'keepticks');
  % datetick('x', 'dd mmm', 'keeplimits', 'keepticks');
  % xticklabel = get(gca, 'xticklabel');
  % xticklabel(2:2:end, :) = ' ';
  % set(gca, 'xticklabel', xticklabel);
end

1;

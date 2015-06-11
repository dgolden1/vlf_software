function make_chorus_hiss_wave_map_movie(start_datenum, end_datenum, dt)
% Show evolution of a wave map with both chorus and hiss over an actual
% time period

% By Daniel Golden (dgolden1 at stanford dot edu) January 2012
% $Id$

%% Setup
t_net_start = now;

addpath(fullfile(danmatlabroot, 'vlf', 'plasmapause')); % For moldwinObrien2003 plasmapause model

input_dir_chorus = fullfile(vlfcasestudyroot, 'themis_chorus');
input_dir_hiss = fullfile(vlfcasestudyroot, 'themis_emissions');
output_dir = '~/temp';

if ~exist('start_datenum', 'var') || isempty(start_datenum) || ~exist('end_datenum', 'var') || isempty(end_datenum)
  start_datenum = datenum([2008 09 03 0 0 0]);
  end_datenum = datenum([2008 09 05 06 0 0]);
end
if ~exist('dt', 'var') || isempty(dt)
  dt = 1/144; % One frame every 10 min
end

epoch_vec = start_datenum:dt:end_datenum;

%% Load model parameters
% Don't load X
model_chorus = load(fullfile(input_dir_chorus, 'themis_polar_chorus_regression_old.mat'), '-regexp', '^(?!X$).*');
warning('Using old chorus regression file');
model_hiss = load(fullfile(input_dir_hiss, 'themis_hiss_solarwind_regression.mat'), '-regexp', '^(?!X$).*');

%% Load model features
t_chorus_feat_start = now;
[X_all_chorus, X_names_all_chorus] = set_up_predictor_matrix_v2(epoch_vec);
fprintf('Loaded chorus model features in %s\n', time_elapsed(t_chorus_feat_start, now));

t_hiss_feat_start = now;
[X_all_hiss, X_names_all_hiss] = set_up_predictor_matrix_v1(epoch_vec);
fprintf('Loaded hiss model features in %s\n', time_elapsed(t_hiss_feat_start, now));


%% Set up axes
% super_subplot parameters
nrows_l_mlt = 7;

nrows = nrows_l_mlt + 5;
ncols = 1;
hspace = 0;
vspace = 0.005;
hmargin = [0.06 0.02];
vmargin = [0.05 0.05];

h_fig = figure;
% figure_grow(gcf, 1, 2);
figure_grow(gcf, 1.5, 1.5);

x_ticks = floor(start_datenum):0.5:end_datenum;
x_lim = [start_datenum end_datenum];
label_start_time = start_datenum + (end_datenum - start_datenum)*0.02;

%% Make map axes
h_map = super_subplot(nrows, ncols, 1:nrows_l_mlt, hspace, vspace, hmargin, vmargin);
wave_cax = [0 2]; % log10 pT

h_idx = [];

%% Make MLT-epoch chorus amplitude axes
[h_idx, chorus_wave_ampl_cube] = make_wave_panel(model_chorus, X_all_chorus, X_names_all_chorus, 'Chorus', epoch_vec, wave_cax, nrows, ncols, nrows_l_mlt, hspace, vspace, hmargin, vmargin, h_idx, label_start_time, x_ticks, x_lim);

% wave_ampl = nan([size(model_chorus.beta), length(epoch_vec)]);
% 
% t_chorus_ampl_start = now;
% for kk = 1:length(epoch_vec)
%   wave_ampl(:,:,kk) = get_l_mlt_map(X_all_chorus(kk,:), X_names_all_chorus, model_chorus, 'chorus');
% end
% fprintf('Computed chorus amplitudes in %s\n', time_elapsed(t_chorus_ampl_start, now));
% 
% this_ax_num = length(h_idx) + 1;
% h_idx(end+1) = super_subplot(nrows, ncols, nrows_l_mlt + this_ax_num, hspace, vspace, hmargin, vmargin);
% map = squeeze(nanmean(wave_ampl(model_chorus.L_centers >= 5 & model_chorus.L_centers <= 10, :, :)));
% MLT_centers_interp = linspace(0, 25, 49); % Interpolate so that image isn't antialiased in inkscape
% imagesc(epoch_vec, MLT_centers_interp, interp1(model_chorus.MLT_centers, map, MLT_centers_interp, 'nearest', 'extrap'));
% axis xy
% yl = [0 24];
% ylim(yl);
% ylabel('MLT');
% text(label_start_time, yl(1) + diff(yl)*0.7, 'Chorus Amplitude', 'fontweight', 'bold', 'color', 'w');
% set(gca, 'ytick', 0:6:18, 'xticklabel', [], 'xtick', x_ticks, 'xlim', x_lim);
% caxis(wave_cax);

%% Make MLT-epoch hiss amplitude axes
[h_idx, hiss_wave_ampl_cube] = make_wave_panel(model_hiss, X_all_hiss, X_names_all_hiss, 'Hiss', epoch_vec, wave_cax, nrows, ncols, nrows_l_mlt, hspace, vspace, hmargin, vmargin, h_idx, label_start_time, x_ticks, x_lim);

% wave_ampl = nan([size(model_hiss.beta), length(epoch_vec)]);
% 
% t_chorus_ampl_start = now;
% for kk = 1:length(epoch_vec)
%   wave_ampl(:,:,kk) = get_l_mlt_map(X_all_hiss(kk,:), X_names_all_hiss, model_hiss, 'hiss');
% end
% fprintf('Computed hiss amplitudes in %s\n', time_elapsed(t_chorus_ampl_start, now));
% 
% this_ax_num = length(h_idx) + 1;
% h_idx(end+1) = super_subplot(nrows, ncols, nrows_l_mlt + this_ax_num, hspace, vspace, hmargin, vmargin);
% map = squeeze(nanmean(wave_ampl(model_hiss.L_centers >= 2 & model_hiss.L_centers <= 5, :, :)));
% MLT_centers_interp = linspace(0, 25, 49); % Interpolate so that image isn't antialiased in inkscape
% imagesc(epoch_vec, MLT_centers_interp, interp1(model_hiss.MLT_centers, map, MLT_centers_interp, 'nearest', 'extrap'));
% axis xy
% yl = [0 24];
% ylim(yl);
% ylabel('MLT');
% text(label_start_time, yl(1) + diff(yl)*0.7, 'Hiss Amplitude', 'fontweight', 'bold', 'color', 'w');
% set(gca, 'ytick', 0:6:18, 'xticklabel', [], 'xtick', x_ticks, 'xlim', x_lim);
% caxis(wave_cax);

%% Make index axes
sfigure(h_fig);

this_ax_num = length(h_idx) + 1;
h_idx(end+1) = super_subplot(nrows, ncols, nrows_l_mlt + this_ax_num, hspace, vspace, hmargin, vmargin);
plot(epoch_vec, 10.^(X_all_chorus(:, strcmp(X_names_all_chorus, 'log10(AE) (t-[00.0 00.0]hrs)'))), 'k');
set(gca, 'xticklabel', [], 'xtick', x_ticks, 'xlim', x_lim);
yl = [0 1600];
ylim(yl);
text(label_start_time, yl(1) + diff(yl)*0.7, 'AE (nT)', 'fontweight', 'bold');

this_ax_num = length(h_idx) + 1;
h_idx(end+1) = super_subplot(nrows, ncols, nrows_l_mlt + this_ax_num, hspace, vspace, hmargin, vmargin);
plot(epoch_vec, X_all_chorus(:, strcmp(X_names_all_chorus, 'SYM-H (t-[00.0 00.0]hrs)')), 'k');
set(gca, 'xticklabel', [], 'xtick', x_ticks, 'xlim', x_lim, 'ytick', [-40 0]);
yl = [-65 30];
ylim(yl);
text(label_start_time, yl(1) + diff(yl)*0.2, 'SYM-H (nT)', 'fontweight', 'bold');

% this_ax_num = length(h_idx) + 1;
% h_idx(end+1) = super_subplot(nrows, ncols, nrows_l_mlt + this_ax_num, hspace, vspace, hmargin, vmargin);
% plot(epoch_vec, 10.^(X_all_chorus(:, strcmp(X_names_all_chorus, 'log10(Pdyn) (t-[00.0 00.0]hrs)'))), 'k');
% set(gca, 'xticklabel', [], 'xtick', x_ticks, 'xlim', x_lim);
% yl = [0 10];
% ylim(yl);
% text(label_start_time, yl(1) + diff(yl)*0.7, 'P_{dyn} (nPa)', 'fontweight', 'bold');

this_ax_num = length(h_idx) + 1;
h_idx(end+1) = super_subplot(nrows, ncols, nrows_l_mlt + this_ax_num, hspace, vspace, hmargin, vmargin);
plot(epoch_vec, X_all_chorus(:, strcmp(X_names_all_chorus, 'dphi_mp_dt (t-[00.0 00.0]hrs)')), 'k');
set(gca, 'xticklabel', [], 'xtick', x_ticks, 'xlim', x_lim, 'ytick', 0:5e3:1.5e4, 'yticklabel', num2str((0:5e3:1.5e4).'));
yl = [0 2e4];
ylim(yl);
text(label_start_time, yl(1) + diff(yl)*0.7, 'd\Phi_{MP}/dt', 'fontweight', 'bold');
datetick('x', 'dd mmm', 'keeplimits', 'keepticks');
xticklabel = get(gca, 'xticklabel');
xticklabel(2:2:end, :) = ' ';
set(gca, 'xticklabel', xticklabel);

%% Make colorbar
map_pos = get(h_map, 'position');
h_cbar = axes('position', [0.75, map_pos(2) + 0.05, 0.025, map_pos(4) - 0.1]);
[h_cbar(1), h_cbar(2)] = log_colorbar(10.^wave_cax, 'ax_label', 'Wave Amplitude (pT)', 'h_cbar', h_cbar);

%% Make movie
output_filename = sprintf('them_chorus_hiss_model_%s--%s.avi', datestr(start_datenum, 'yyyy-mm-dd'), ...
  datestr(end_datenum, 'yyyy-mm-dd'));

movie_filename = fullfile(output_dir, output_filename);

movie_fofo(@(frameno) update_movie_frame(frameno, epoch_vec, model_chorus, ...
  chorus_wave_ampl_cube, model_hiss, hiss_wave_ampl_cube, h_map, h_idx, wave_cax), ...
  length(epoch_vec), 'output_filename', movie_filename, 'framerate', 15, 'b_antialias', false, 'h_fig', h_fig);

fprintf('Processing complete in %s\n', time_elapsed(t_net_start, now));

1;

function [h_idx, wave_ampl_cube] = make_wave_panel(model, X_all, X_names_all, em_type, epoch_vec, wave_cax, nrows, ncols, nrows_l_mlt, hspace, vspace, hmargin, vmargin, h_idx, label_start_time, x_ticks, x_lim)
%% Make a panel of the figure that shows wave amplitude vs MLT

switch lower(em_type)
  case 'hiss'
    L_lim = [2 5];
  case 'chorus'
    L_lim = [5 10];
end

wave_ampl_cube = nan([size(model.beta), length(epoch_vec)]);

t_ampl_start = now;
for kk = 1:length(epoch_vec)
  wave_ampl_cube(:,:,kk) = get_l_mlt_map(X_all(kk,:), X_names_all, model, lower(em_type));
end
fprintf('Computed %s amplitudes in %s\n', lower(em_type), time_elapsed(t_ampl_start, now));

this_ax_num = length(h_idx) + 1;
h_idx(end+1) = super_subplot(nrows, ncols, nrows_l_mlt + this_ax_num, hspace, vspace, hmargin, vmargin);
map = squeeze(nanmean(wave_ampl_cube(model.L_centers >= L_lim(1) & model.L_centers <= L_lim(2), :, :)));
map(map < wave_cax(1)) = wave_cax(1); % Clip to allow for colorbar with white background
MLT_centers_interp = linspace(0, 25, 49); % Interpolate so that image isn't antialiased in inkscape
imagesc(epoch_vec, MLT_centers_interp, interp1(model.MLT_centers, map, MLT_centers_interp, 'nearest', 'extrap'));
axis xy
yl = [0 24];
ylim(yl);
ylabel('MLT');
text(label_start_time, yl(1) + diff(yl)*0.7, sprintf('%s Amplitude', em_type), 'fontweight', 'bold', 'color', 'w');
set(gca, 'ytick', 0:6:18, 'xticklabel', [], 'xtick', x_ticks, 'xlim', x_lim);
caxis(wave_cax);
freezeColors;

function wave_ampl = get_l_mlt_map(X_all, X_names_all, model, em_type)
%% Function: make an L-MLT map for a given time point
% X_in should be for a single time point (i.e., a 1xM row vector)

wave_ampl = nan(size(model.beta));

for kk = 1:numel(wave_ampl)
  % Skip bins with empty beta; these are ones with too few measurements for
  % a model
  if isempty(model.beta{kk})
    continue;
  end
  
  if strcmp(em_type, 'hiss')
    % Hiss model has the same features for all bins
    this_feature_names = model.X_names;
    this_beta = model.beta{kk};
  else
    % Chorus model has different features for different bins
    this_feature_names = model.feature_names{kk};
    this_beta = model.beta{kk};
  end

  % Parse out features for this bin
  % This only works if X_names_all and this_feature_names are sorted in the
  % same way... which they should be
  X_in = X_all(:, ismember(X_names_all, this_feature_names));

  if strcmp(em_type, 'hiss')
    % Set cos(latitude) coefficient to 1, since we're assuming latitude is 0
    X_in(end+1) = 1;
  end

  wave_ampl(kk) = [1 X_in]*this_beta; % log10(pT)
end

if strcmp(em_type, 'hiss')
  wave_ampl = wave_ampl/2 + 3; % Convert from log10(nT^2) to log10(pT)
end

1;

function plot_wave_ampl(ampl_chorus, model_chorus, ampl_hiss, model_hiss, epoch, h_ax, wave_cax)
%% Function: plot an L-MLT map of a given chorus amplitude

persistent kp kp_date
if isempty(kp)
  load kp;
end

b_use_jet = true;

cla(h_ax);

MLT_edges = 0:2:24;

L_max = 10;
L_edges = 2:L_max;

% Chorus
[ampl_chorus_binned, r_chorus, theta_chorus] = get_one_wave_map(model_chorus.L_centers, model_chorus.MLT_centers, ampl_chorus, L_edges, MLT_edges);
[x, y, grid_ampl_chorus] = interp_wave_ampl_onto_grid(ampl_chorus_binned, r_chorus, theta_chorus);
[X, Y] = meshgrid(x, y);
R = sqrt(X.^2 + Y.^2);

% Hiss
[ampl_hiss_binned, r_hiss, theta_hiss] = get_one_wave_map(model_hiss.L_centers, model_hiss.MLT_centers, ampl_hiss, L_edges, MLT_edges);
[~, ~, grid_ampl_hiss] = interp_wave_ampl_onto_grid(ampl_hiss_binned, r_hiss, theta_hiss);

% Set some unaesthetic grid points to nan
grid_ampl_chorus(R < 5.5 | R > 10) = nan;
grid_ampl_hiss(R < 2 | R > 4.5) = nan;


saxes(h_ax);

% Combine into one image and plot
if b_use_jet
  grid_ampl_combined = nan([length(x), length(y)]);

  idx = isfinite(grid_ampl_chorus);
  grid_ampl_combined(idx) = grid_ampl_chorus(idx);
  
  idx = isfinite(grid_ampl_hiss);
  grid_ampl_combined(idx) = grid_ampl_hiss(idx);
  
  grid_ampl_combined(grid_ampl_combined < wave_cax(1)) = wave_cax(1);
  [new_image_data, new_color_map, new_cax] = colormap_white_bg(grid_ampl_combined, jet, wave_cax);
  imagesc(x, y, new_image_data);
  colormap(new_color_map);
  caxis(new_cax);
else
  grid_ampl_combined = zeros([length(x), length(y), 3]);

  % Set chorus and hiss to red and green channels, scalled by wave_cax
  grid_ampl_combined(:,:,1) = (grid_ampl_chorus - wave_cax(1))/diff(wave_cax);
  grid_ampl_combined(:,:,2) = (grid_ampl_hiss - wave_cax(1))/diff(wave_cax);

  % Set the chorus or hiss channel to 0 where that emission is unknown
  grid_ampl_combined(isnan(grid_ampl_combined)) = 0;

  % Set the color to white where no emission amplitude is known
  grid_ampl_combined(repmat(all(grid_ampl_combined == 0, 3), [1 1 3])) = 1;

  % Clip to between 0 and 1
  grid_ampl_combined(grid_ampl_combined > 1) = 1;
  grid_ampl_combined(grid_ampl_combined < 0) = 0;
  
  image(x, y, grid_ampl_combined);
end

make_mlt_plot_grid('h_ax', h_ax, 'L_max', L_max, 'MLT_gridlines', 0:2:24, 'solid_lines_L', 5);

% Plot Moldwin Obrien 2003 plasmapause
% MLT_pp = linspace(0, 24, 50);
% this_kp = interp1(kp_date, kp, epoch);
% L_pp = moldwinObrien2003(MLT_pp, this_kp);
% theta_pp = mod(MLT_pp*pi/12 + pi, 2*pi);
% plot(L_pp.*cos(theta_pp), L_pp.*sin(theta_pp), 'color', [0 0.8 0], 'linewidth', 3);

axis off xy equal

t(1) = text(L_max*1.02*cos(pi/4), L_max*1.02*sin(pi/4), sprintf('%d R_E', L_max));
t(2) = text(0, 7, 'Chorus', 'horizontalalignment', 'center', 'color', 'w');
t(3) = text(0, 3.5, 'Hiss', 'horizontalalignment', 'center', 'color', 'w');


title(datestr(epoch, 31));

1;

function [ampl, r, theta] = get_one_wave_map(L_centers, MLT_centers, wave_ampl, L_edges, MLT_edges)
%% Function: get a wave map for one wave type

[L_mat, MLT_mat] = ndgrid(L_centers, MLT_centers);
idx_plot = isfinite(wave_ampl);
[~, r, theta, ampl] = plot_l_mlt(L_mat(idx_plot), MLT_mat(idx_plot), L_edges, MLT_edges, ...
  wave_ampl(idx_plot), 'scaling_function', 'none', 'b_oversample_mlt', true, 'b_plot', false);

1;

function [x, y, grid_ampl] = interp_wave_ampl_onto_grid(ampl, r, theta)
%% Function: grid wave map

L_max = 10;
npts = 250;
x = linspace(-L_max, L_max, npts);
y = linspace(-L_max, L_max, npts);
[x_mat, y_mat] = meshgrid(x, y);

% Put a NaN in the middle to disallow interpolation across center of earth
r_vec = [r(:); 0];
theta_vec = [theta(:); 0];
ampl_vec = [ampl(:); nan];

F = TriScatteredInterp(r_vec.*cos(theta_vec), r_vec.*sin(theta_vec), ampl_vec, 'linear');
grid_ampl = F(x_mat, y_mat);


function update_index_cursor(epoch, h_idx)
%% Function: update the curser in the line plots to show what time it is
delete(findobj(h_idx, 'tag', 'epoch_cursor'));

for kk = 1:length(h_idx)
  saxes(h_idx(kk));
  hold on;
  
  yl = ylim;
  
  h_epoch_cursor = plot(epoch*[1 1], yl, 'r-');
  set(h_epoch_cursor, 'tag', 'epoch_cursor');
end

function update_movie_frame(frameno, epoch_vec, model_chorus, chorus_wave_ampl_cube, model_hiss, hiss_wave_ampl_cube, h_map, h_idx, wave_cax)
%% Function: make a new frame for the movie

plot_wave_ampl(chorus_wave_ampl_cube(:,:,frameno), model_chorus, hiss_wave_ampl_cube(:,:,frameno), model_hiss, epoch_vec(frameno), h_map, wave_cax);
update_index_cursor(epoch_vec(frameno), h_idx);

increase_font(gcf, 14);

1;

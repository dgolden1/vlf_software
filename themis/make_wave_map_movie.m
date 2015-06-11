function make_wave_map_movie(start_datenum, end_datenum, dt)
% Show evolution of a wave map over an actual time period

% By Daniel Golden (dgolden1 at stanford dot edu) January 2012
% $Id$

%% Setup
t_net_start = now;

input_dir = fullfile(vlfcasestudyroot, 'themis_emissions');
output_dir = '~/temp';

if ~exist('start_datenum', 'var') || isempty(start_datenum) || ~exist('end_datenum', 'var') || isempty(end_datenum)
  start_datenum = datenum([2008 09 03 0 0 0]);
  end_datenum = datenum([2008 09 05 06 0 0]);
end
if ~exist('dt', 'var') || isempty(dt)
  dt = 1/144; % One frame every 10 min
end

epoch_vec = start_datenum:dt:end_datenum;

b_nnet = false;

%% Load model parameters
if b_nnet
  model = load(fullfile(input_dir, 'themis_hiss_solarwind_regression_nnet.mat'), '-regexp', '^(?!X).*');
else
  % Load everything but X which is a monster
  model = load(fullfile(input_dir, 'themis_hiss_solarwind_regression.mat'), '-regexp', '^(?!X).*');
end


%% Load model features
t_feat_start = now;

% Load selected feature names
feature_filename = fullfile(vlfcasestudyroot, 'themis_emissions', 'themis_hiss_solarwind_features.mat');
load(feature_filename, 'X_names');

% Get rid of the L and MLT features; they're not needed anymore since
% we're binning by L and MLT
X_names(ismember(X_names, {'abs(log(them_combined.L - 1) - log(4 - 1))', 'cos(them_combined.MLT/24*2*pi)'})) = [];
% X_names(~cellfun(@isempty, strfind(X_names, 'them_combined'))) = [];

[X, X_names_full] = set_up_predictor_matrix_v1(epoch_vec);
X_in = X(:, ismember(X_names_full, X_names));

% The last item in X_in is supposed to be cos(latitude) , but it's not
% present in X_in, since we didn't include ephemeris parameters when we ran
% set_up_predictor_matrix_v1(). Just set cos(latitude) to be 1 for all time.
X_in(:,end+1) = 1;

assert(length(X_names) == size(X_in, 2));

fprintf('Loaded model features in %s\n', time_elapsed(t_feat_start, now));

%% Set up axes
% super_subplot parameters
nrows_l_mlt = 6;

nrows = nrows_l_mlt + 4;
ncols = 1;
hspace = 0;
vspace = 0.005;
hmargin = [0.06 0.02];
vmargin = [0.05 0.05];

h_fig = figure;
% figure_grow(gcf, 1, 2);
figure_grow(gcf, 1.5, 1.5);

xticks = floor(start_datenum):0.5:end_datenum;
x_lim = [start_datenum end_datenum];
label_start_time = start_datenum + (end_datenum - start_datenum)*0.02;

%% Make map axes
h_map = super_subplot(nrows, ncols, 1:nrows_l_mlt, hspace, vspace, hmargin, vmargin);
hiss_cax = [0 2.5]; % log10 pT

%% Make MLT-epoch hiss amplitude axes
% my_L_vec = 2.5:4.5;
% hiss_ampl = nan(9, 13, length(epoch_vec));
% 
% for kk = 1:length(epoch_vec)
%   hiss_ampl(:,:,kk) = get_l_mlt_map(X_in(kk,:), model);
% end
% 
% hiss_cax = [0 2.5]; % dB-pT
% 
% h_idx(1) = super_subplot(nrows, ncols, 1, hspace, vspace, hmargin, vmargin);
% map = squeeze(mean(hiss_ampl(ismember(model.L_centers, my_L_vec), :, :)));
% MLT_centers_interp = linspace(0, 25, 49); % Interpolate so that image isn't antialiased in inkscape
% imagesc(epoch_vec, MLT_centers_interp, interp1(model.MLT_centers, map, MLT_centers_interp, 'nearest', 'extrap'));
% % imagesc(epoch_vec, model.MLT_centers, map);
% axis xy
% yl = [0 24];
% ylim(yl);
% ylabel('MLT');
% text(label_start_time, yl(1) + diff(yl)*0.7, 'Hiss Amplitude', 'fontweight', 'bold', 'color', 'w');
% set(gca, 'ytick', 0:6:18, 'xticklabel', [], 'xtick', xticks, 'xlim', x_lim);
% caxis(hiss_cax);

%% Make index axes
h_idx(1) = super_subplot(nrows, ncols, nrows_l_mlt + 1, hspace, vspace, hmargin, vmargin);
plot(epoch_vec, 10.^(X(:, strcmp(X_names_full, 'log10(AE) (t-0hrs)'))), 'k');
set(gca, 'xticklabel', [], 'xtick', xticks, 'xlim', x_lim);
yl = [0 1600];
ylim(yl);
text(label_start_time, yl(1) + diff(yl)*0.7, 'AE (nT)', 'fontweight', 'bold');

h_idx(2) = super_subplot(nrows, ncols, nrows_l_mlt + 2, hspace, vspace, hmargin, vmargin);
plot(epoch_vec, X(:, strcmp(X_names_full, 'SYM-H (t-0hrs)')), 'k');
set(gca, 'xticklabel', [], 'xtick', xticks, 'xlim', x_lim, 'ytick', [-40 0]);
yl = [-65 30];
ylim(yl);
text(label_start_time, yl(1) + diff(yl)*0.2, 'SYM-H (nT)', 'fontweight', 'bold');

h_idx(3) = super_subplot(nrows, ncols, nrows_l_mlt + 3, hspace, vspace, hmargin, vmargin);
plot(epoch_vec, 10.^(X(:, strcmp(X_names_full, 'log10(Pdyn) (t-0hrs)'))), 'k');
set(gca, 'xticklabel', [], 'xtick', xticks, 'xlim', x_lim);
yl = [0 10];
ylim(yl);
text(label_start_time, yl(1) + diff(yl)*0.7, 'P_{dyn} (nPa)', 'fontweight', 'bold');

h_idx(4) = super_subplot(nrows, ncols, nrows_l_mlt + 4, hspace, vspace, hmargin, vmargin);
plot(epoch_vec, X(:, strcmp(X_names_full, 'dphi_mp_dt (t-0hrs)')), 'k');
set(gca, 'xticklabel', [], 'xtick', xticks, 'xlim', x_lim, 'ytick', 0:5e3:1.5e4, 'yticklabel', num2str((0:5e3:1.5e4).'));
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
[h_cbar(1), h_cbar(2)] = log_colorbar(10.^hiss_cax, 'ax_label', 'Hiss Amplitude (pT)', 'h_cbar', h_cbar);

%% Get hiss amplitudes
% hiss_ampl = nan([size(model.beta) length(epoch_vec)]);
% for kk = 1:length(epoch_vec)
%   hiss_ampl(:,:,kk) = get_l_mlt_map(X_in(kk, :), model);
% end

%% Make movie
output_filename = sprintf('them_hiss_model_%s--%s.avi', datestr(start_datenum, 'yyyy-mm-dd'), ...
  datestr(end_datenum, 'yyyy-mm-dd'));

movie_filename = fullfile(output_dir, output_filename);

movie_fofo(@(frameno) update_movie_frame(frameno, epoch_vec, X_in, model, h_map, h_idx, hiss_cax, b_nnet), ...
  length(epoch_vec), 'output_filename', movie_filename, 'framerate', 15, 'h_fig', h_fig);

fprintf('Processing complete in %s\n', time_elapsed(t_net_start, now));

1;

function hiss_ampl = get_l_mlt_map(X_in, model)
%% Function: make an L-MLT map for a given time point
% X_in should be for a single time point (i.e., a 1xM row vector)

hiss_ampl = nan(size(model.beta));

for kk = 1:numel(hiss_ampl)
  % Skip bins with empty beta; these are ones with too few measurements for
  % a model
  if isempty(model.beta{kk})
    continue;
  end
  
  hiss_ampl(kk) = [1 X_in]*model.beta{kk}/2 + 3; % Convert from log10(nT^2) to log10(pT)
end

1;

function hiss_ampl = get_l_mlt_map_nnet(X_in, model)
%% Function: make an L-MLT map for a given time point
% X_in should be for a single time point (i.e., a 1xM row vector)

hiss_ampl = nan(size(model.r));

for kk = 1:numel(hiss_ampl)
  % Skip bins with empty network; these are ones with too few measurements
  % for a model
  if isempty(model.net{kk})
    continue;
  end
  
  hiss_ampl(kk) = sim(model.net{kk}, X_in.')/2 + 3; % Convert from log10(nT^2) to log10(pT)
end

function plot_hiss_ampl(hiss_ampl, model, epoch, h_ax, hiss_cax)
%% Function: plot an L-MLT map of a given hiss amplitude

cla(h_ax);

[L_mat, MLT_mat] = ndgrid(model.L_centers, model.MLT_centers);
idx_plot = isfinite(hiss_ampl);

% L_edges = model.L_edges;
L_max = 5;
L_edges = 2:L_max;

% plot_l_mlt(L_mat(idx_plot), MLT_mat(idx_plot), model.L_edges, model.MLT_edges,  hiss_ampl(idx_plot), ...
%           'scaling_function', 'none', 'b_shading_interp', false, 'b_oversample_mlt', true, ...
%           'MLT_gridlines', 0:2:22, 'h_ax', h_ax);
plot_l_mlt(L_mat(idx_plot), MLT_mat(idx_plot), L_edges, model.MLT_edges,  hiss_ampl(idx_plot), ...
          'scaling_function', 'none', 'MLT_gridlines', 0:2:22, 'b_oversample_mlt', true, 'h_ax', h_ax);
        
caxis(hiss_cax);
axis off

text(L_max*1.02*cos(pi/4), L_max*1.02*sin(pi/4), sprintf('%d R_E', L_max));

title(datestr(epoch, 31));

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

function update_movie_frame(frameno, epoch_vec, X_in, model, h_map, h_idx, hiss_cax, b_nnet)
%% Function: make a new frame for the movie

if b_nnet
  hiss_ampl = get_l_mlt_map_nnet(X_in(frameno, :), model);
else
  hiss_ampl = get_l_mlt_map(X_in(frameno, :), model);
end

plot_hiss_ampl(hiss_ampl, model, epoch_vec(frameno), h_map, hiss_cax);
update_index_cursor(epoch_vec(frameno), h_idx);

increase_font(gcf, 14);

function plot_palmer_themis_correlation(em_type)
% Plot some coincident wave measurements between Palmer and THEMIS

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Setup
close all;

if ~exist('em_type', 'var') || isempty(em_type)
  em_type = 'hiss';
end

load(sprintf('palmer_themis_common_epoch_%s.mat', em_type), 'epoch', 'palmer_em_pow', 'them');

%% Each probe individually
% mlt_radius = 3;
% for kk = 1:length(them)
%   [this_palmer_pow, this_them_pow, colors, cax_label, cax] = get_scatter_values(palmer_epoch, palmer_em_pow, them(kk), mlt_radius, em_type);
%   plot_single_correlation(this_palmer_pow, this_palmer_pow, colors, cax_label, cax);
%   title(sprintf('THEMIS %s', them(kk).probe));
% end

%% All probes combined
% mlt_radius = 3;
% [total_palmer_pow, total_them_pow, total_colors, cax_label, cax] = combine_scatter_values(epoch, palmer_em_pow, them, mlt_radius, [], em_type);
% plot_single_correlation(total_palmer_pow, total_them_pow, total_colors, cax_label, cax);
% title('THEMIS All Probes');

%% The fishing expedition for all probes combined
% find_optimal_correlation(epoch, palmer_em_pow, them, em_type);

%% Multiple regression model
get_glm(epoch, palmer_em_pow, them, em_type);

function [this_palmer_pow, this_them_pow, this_epoch, colors, cax_label, cax] = get_scatter_values(palmer_epoch, palmer_em_pow, them, em_type, mlt_radius, L_range)
%% Function: get a single set of THEMIS and Palmer values
if (~exist('L_range', 'var') || isempty(L_range)) && (~exist('mlt_radius', 'var') || isempty(mlt_radius))
  b_all_values = true;
else
  b_all_values = false;

  if isempty(L_range)
    L_range = [1 Inf];
  end
  if isscalar(mlt_radius)
    mlt_radius = [-mlt_radius, mlt_radius]; % hours before and after Palmer's MLT
  end
end

palmer_mlt_offset = -4; % MLT at UTC midnight, hours

idx_has_th_data = find(~isnan(them.field_power));

if b_all_values
  idx_valid = idx_has_th_data;
else
  palmer_mlt = fpart(palmer_epoch + palmer_mlt_offset/24)*24; % hours
  dark = load('palmer_darkness', 'epoch', 'idx_darkness');
  idx_valid = idx_has_th_data(angle_is_between((palmer_mlt(idx_has_th_data) + mlt_radius(1))/24*2*pi, ...
                                               (palmer_mlt(idx_has_th_data) + mlt_radius(2))/24*2*pi, ...
                                               them.MLT(idx_has_th_data)/24*2*pi, 'rad') & ... % THEMIS is within the MLT range of Palmer
                              them.L(idx_has_th_data) >= L_range(1) & them.L(idx_has_th_data) < L_range(2) & ... % THEMIS is within the specified L range
                              palmer_mlt(idx_has_th_data) > 15 & palmer_mlt(idx_has_th_data) < 21 & ... % MLT is in a range of maximal hiss occurrence at Palmer
                              interp1(dark.epoch, dark.idx_darkness, palmer_epoch(idx_has_th_data)) > 0.5); % Palmer is in darkness
end

this_palmer_pow = palmer_em_pow(idx_valid);
this_them_pow = them.field_power(idx_valid);
this_epoch = palmer_epoch(idx_valid);

% color = them.L(idx_valid);
% cax_label = 'THEMIS L';
% switch em_type
%   case 'chorus'
%     cax = [3 10];
%   case 'hiss'
%     cax = [1.5 5];
% end
colors = abs(diff([palmer_mlt(idx_valid), them.MLT(idx_valid)], 1, 2));
cax_label = 'MLT difference (hours)';
cax = [0 max(abs(mlt_radius))];

function [total_palmer_pow, total_them_pow, total_epoch, total_colors, cax_label, cax] = combine_scatter_values(palmer_epoch, palmer_em_pow, them, em_type, mlt_radius, L_range)
%% Function: run get_scatter_values on all THEMIS probes and combine output

total_palmer_pow = [];
total_them_pow = [];
total_epoch = [];
total_colors = [];
for kk = 1:length(them)
  [this_palmer_pow, this_them_pow, this_epoch, this_colors, cax_label, cax] = get_scatter_values(palmer_epoch, palmer_em_pow, them(kk), em_type, mlt_radius, L_range);
  total_palmer_pow = [total_palmer_pow; this_palmer_pow];
  total_them_pow = [total_them_pow; this_them_pow];
  total_epoch = [total_epoch; this_epoch];
  total_colors = [total_colors; this_colors];
end

function [palmer_power_combined, them_combined, epoch_combined] = combine_them_simple(palmer_power, epoch, them)

for name = fieldnames(them).'
  if length(name{1}) >= 3 && strcmp(name{1}(1:3), 'gap')
    continue;
  end
  
  for kk = 1:length(them)
    idx_valid = ~isnan(them(kk).field_power);
    if ~strcmp(name{1}, 'probe')
      field_combined{kk} = them(kk).(name{1})(idx_valid);
    else
      field_combined{kk} = repmat(them(kk).probe, sum(idx_valid), 1);
    end
  end
  them_combined.(name{1}) = cell2mat(field_combined.');
end

% To get indices for probe A, for example, do:
% idx_a = strcmpi(num2cell(them_combined.probe), 'A');

epoch_combined = them_combined.epoch;
palmer_power_combined = interp1(epoch, palmer_power, epoch_combined);

function plot_single_correlation(palmer_pow, them_pow, colors, cax_label, cax, h_fig)
%% Function: plot a single amplitude correlation

if exist('h_fig', 'var') && ~isempty(h_fig)
  sfigure(h_fig);
  clf;
else
  figure;
end

scatter(10*log10(max(min(palmer_pow(palmer_pow > 0)), palmer_pow)), 10*log10(max(min(them_pow(them_pow > 0)), them_pow)) + 120, [], colors, 'filled');
%   set(gca, 'xscale', 'log', 'yscale', 'log');
grid on;
xlabel('Palmer power (dB-fT)');
ylabel('Themis power (dB-fT)');

if ~isempty(cax_label) || ~isempty(cax)
  c = colorbar;
  ylabel(c, cax_label);
  caxis(cax);
end

increase_font;

function [rho, p_val, L_min, L_max, MLT_before, MLT_after] = find_optimal_correlation(palmer_epoch, palmer_em_pow, them, em_type)
%% Function: do some fishing to find L and MLT parameters with good correlations

output_dir = '~/temp/palmer_them_corr';
if ~exist(output_dir, 'dir')
  mkdir(output_dir);
end

%% Get input grid
L_centers_vec = 2:8; % Range of possible L shell centers
L_rads_vec = 1:4; % Range of possible L-shell radii
[L_centers_mat, L_rads_mat] = ndgrid(L_centers_vec, L_rads_vec);
L_min_mat = max(L_centers_mat - L_rads_mat, 1.5);
L_max_mat = min(L_centers_mat + L_rads_mat, 10);

% figure;
% subplot(1, 2, 1);
% imagesc(L_min_mat); colorbar;
% subplot(1, 2, 2);
% imagesc(L_max_mat); colorbar;

MLT_centers_vec = -3:0.5:3;
MLT_rads_vec = 1:6;
[MLT_centers_mat, MLT_rads_mat] = ndgrid(MLT_centers_vec, MLT_rads_vec);
MLT_before_mat = MLT_centers_mat - MLT_rads_mat;
MLT_after_mat = MLT_centers_mat + MLT_rads_mat;

% figure;
% subplot(1, 2, 1);
% imagesc(MLT_before_mat); colorbar
% subplot(1, 2, 2);
% imagesc(MLT_after_mat); colorbar

[L_centers_nd, L_rads_nd, MLT_centers_nd, MLT_rads_nd] = ndgrid(L_centers_vec, L_rads_vec, MLT_centers_vec, MLT_rads_vec);
L_min_nd = max(L_centers_nd - L_rads_nd, 1.5);
L_max_nd = min(L_centers_nd + L_rads_nd, 10);
MLT_before_nd = MLT_centers_nd - MLT_rads_nd;
MLT_after_nd = MLT_centers_nd + MLT_rads_nd;

%% Determine correlations
rho = zeros(size(L_centers_nd));
p_val = ones(size(L_centers_nd));
for kk = 1:numel(L_centers_nd)
  t_start = now;
  
  [total_palmer_pow{kk}, total_them_pow{kk}] = combine_scatter_values(palmer_epoch, palmer_em_pow, them, em_type, [MLT_before_nd(kk), MLT_after_nd(kk)], [L_min_nd(kk), L_max_nd(kk)]);
  idx = total_palmer_pow{kk} > 0 & total_them_pow{kk} > 0;
  if sum(idx) > 5
    [rho(kk), p_val(kk)] = corr(flatten(total_palmer_pow{kk}(idx)), flatten(total_them_pow{kk}(idx)));
  else
    1;
  end
  
  fprintf('Calculated correlation %d of %d in %s\n', kk, numel(L_centers_nd), time_elapsed(t_start, now));
end

%% Plot results with good correlations
idx_significant = find(p_val < 0.05);
for kk = 1:length(idx_significant)
  this_idx = idx_significant(kk);
  plot_single_correlation(total_palmer_pow{this_idx}, total_them_pow{this_idx}, 'k', [], [], 1);
  title(sprintf('L = [%0.0f %0.0f], MLT = [%0.1f %0.1f], \\rho = %0.2f, p = %0.3f', ...
    L_min_nd(this_idx), L_max_nd(this_idx), MLT_before_nd(this_idx), MLT_after_nd(this_idx), ...
    rho(this_idx), p_val(this_idx)));
  this_filename = fullfile(output_dir, sprintf('palmer_themis_corr_L%0.0f%0.0f_MLT%0.0f%0.0f_idx%04d', ...
    L_min_nd(this_idx), L_max_nd(this_idx), MLT_before_nd(this_idx)*10, MLT_after_nd(this_idx)*10, this_idx));
  
  print('-dpng', '-r90', this_filename);
  fprintf('Saved %s (%d of %d)\n', this_filename, kk, length(idx_significant));
end

function get_glm(epoch, palmer_em_pow_orig, them, em_type)
%% Function: fit a GLM model of various parameters to predict THEMIS emissions

%% Setup
palmer_mlt_offset = -4; % local MLT at midnight UTC

darkness = load('palmer_darkness.mat', 'epoch', 'idx_darkness', 'time_to_term');
ae = load('ae.mat', 'ae', 'epoch');
TS05 = load('TS05.mat', 'epoch', 'Pdyn', 'BzIMF', 'ByIMF');

[palmer_power_combined, them_combined, epoch_combined] = combine_them_simple(palmer_em_pow_orig, epoch, them);

[~, month] = datevec(epoch_combined);

%% Initialize predictor matrix
% We intentionally interpolate across vectors containing NaNs (particularly
% the TS05 vectors) since we want the output values to be NaN where the
% interpolation isn't valid.  glmfit() deals with this automatically.
warning('off', 'MATLAB:interp1:NaNinY');

% Set up index predictors
TS05_epoch_diff = median(diff(TS05.epoch));
num_TS05_mes_per_hour = round((1/24)/TS05_epoch_diff);
this_ae = interp1(ae.epoch, ae.ae, epoch_combined);
% Average AE in the last 3 and 6 hours.
this_ae_3hr = interp1(ae.epoch, filter(1/3*ones(1, 3), 1, ae.ae), epoch_combined);
this_ae_6hr = interp1(ae.epoch, filter(1/6*ones(1, 6), 1, ae.ae), epoch_combined);
this_Pdyn = interp1(TS05.epoch, TS05.Pdyn, epoch_combined);
this_Pdyn_3hr = interp1(TS05.epoch, filter(1/(num_TS05_mes_per_hour*3)*ones(1, num_TS05_mes_per_hour*3), 1, TS05.Pdyn), epoch_combined);
this_Pdyn_6hr = interp1(TS05.epoch, filter(1/(num_TS05_mes_per_hour*6)*ones(1, num_TS05_mes_per_hour*6), 1, TS05.Pdyn), epoch_combined);
this_Bz = interp1(TS05.epoch, TS05.BzIMF, epoch_combined);
this_Bz_3hr = interp1(TS05.epoch, filter(1/(num_TS05_mes_per_hour*3)*ones(1, num_TS05_mes_per_hour*3), 1, TS05.BzIMF), epoch_combined);
this_Bz_6hr = interp1(TS05.epoch, filter(1/(num_TS05_mes_per_hour*6)*ones(1, num_TS05_mes_per_hour*6), 1, TS05.BzIMF), epoch_combined);
this_palmer_darkness = darkness.idx_darkness(interp1(darkness.epoch, 1:length(darkness.epoch), epoch_combined, 'nearest'));
this_palmer_time_to_term = darkness.time_to_term(interp1(darkness.epoch, 1:length(darkness.epoch), epoch_combined, 'nearest'));

warning('on', 'MATLAB:interp1:NaNinY');

%% Set up Palmer predictors
palmer_mlt = fpart(epoch_combined + palmer_mlt_offset/24)*24;
this_time_to_term = interp1(darkness.epoch, darkness.time_to_term, epoch_combined);
mlt_offset = angledist(palmer_mlt/24*2*pi, them_combined.MLT/24*2*pi, 'rad', true)*24/(2*pi);

mlt_lower_lim = 14;
mlt_upper_lim = 22;
month_lower_lim = 3;
month_upper_lim = 10;
mlt_offset_lower_lim = -1;
mlt_offset_upper_lim = 1;
idx_palmer_range = palmer_mlt >= mlt_lower_lim & palmer_mlt <= mlt_upper_lim & ...
                   month >= month_lower_lim & month <= month_upper_lim & ...
                   ...this_palmer_time_to_term > -1/24 & ...
                   mlt_offset > mlt_offset_lower_lim & mlt_offset < mlt_offset_upper_lim;
b_palmer_emission = palmer_power_combined > 0 & idx_palmer_range;
b_palmer_no_emission = palmer_power_combined == 0 & idx_palmer_range;

%% Plot normalized occurrence for Palmer emissions
edges = -50:5:-20;
centers = edges + diff(edges(1:2))/2;
n_em = histc(10*log10(them_combined.field_power(them_combined.field_power > 0 & b_palmer_emission)), edges);
n_no_em = histc(10*log10(them_combined.field_power(them_combined.field_power > 0 & b_palmer_no_emission)), edges);
n_total = histc(10*log10(them_combined.field_power(them_combined.field_power > 0 & idx_palmer_range)), edges);
figure;
bar(centers(1:end-1), n_em(1:end-1)./n_total(1:end-1), 1, 'facecolor', [1 1 1]*0.8);
[m, pm] = agresti_coull(n_total(1:end-1), n_em(1:end-1), 0.05);
hold on;
h = errorbar(centers(1:end-1), m, pm);
set(h, 'linestyle', 'none', 'color', 'k');
ylim([0 1]);
grid on;
xlabel('THEMIS Hiss Power (dB-nT)');
ylabel('Normalized occurrence');
title(sprintf('%0.0f <= MLT <= %0.0f, %d <= month <= %d, %0.0f <= MLT offset <= %0.0f, total: %d/%d', ...
  mlt_lower_lim, mlt_upper_lim, month_lower_lim, month_upper_lim, mlt_offset_lower_lim, mlt_offset_upper_lim, sum(n_em), sum(n_total)));

%% Set up predictor matrix
X = [log10(this_ae), ...
     log10(this_ae_3hr), ...
     log10(this_Pdyn), ...
     log10(this_Pdyn_3hr), ...
     log10(this_Pdyn_6hr), ...
     this_Bz_6hr, ...
     abs(log(them_combined.L - 1) - log(4 - 1)), ... % Peak L dependence is L ~ 4
     ...log(them_combined.L - 1), ...
     sin(them_combined.MLT/24*2*pi), ...
     cos(them_combined.MLT/24*2*pi), ...
     b_palmer_emission.*log10(this_ae), ...
     b_palmer_emission.*log10(this_ae_3hr), ...
     b_palmer_emission.*log10(this_Pdyn), ...
     b_palmer_emission.*log10(this_Pdyn_3hr), ...
     b_palmer_emission.*log10(this_Pdyn_6hr), ...
     b_palmer_emission.*this_Bz_6hr, ...
     b_palmer_emission.*abs(log(them_combined.L - 1) - log(4 - 1)), ...
     b_palmer_emission.*sin(them_combined.MLT/24*2*pi), ...
     b_palmer_emission.*cos(them_combined.MLT/24*2*pi), ...
     b_palmer_emission, ...
    ];

Y = 10*log10(them_combined.field_power);

%% Calculate the fit using valid values
idx_in = them_combined.field_power > 0 & all(isfinite(X), 2) & idx_palmer_range;% & palmer_power_combined > 0;
Y_in = Y(idx_in);
X_in = X(idx_in,:);
[b, dev, stats] = glmfit(X_in, Y_in);
Y_out = glmval(b, X_in, 'identity');

fprintf('p-value for parameter %0.0f: %0.3f\n', flatten([(0:size(X, 2)).', stats.p].'));
% stats.p

% Test for colinearity (see Chatterjee and Hadi (2006) page 243)
% I think I'm doing this right, but it's kind of confusing
assert(size(X, 2) < 40); % Big number of columns will cause corr function to use up all the OS's memory
corr_mtx = corr(X(all(isfinite(X), 2), :));
corr_eig = eig(corr_mtx);
fprintf('Condition number (test of coliniearity; <15 good, >30 bad): %0.1f\n', ...
  sqrt(max(corr_eig)/min(corr_eig)));

% Goodness of fit metric
r_squared = corr(Y_in, Y_out)^2;
fprintf('Goodness of fit (R^2): %0.3f\n', r_squared);

%% Plot results
lims = [-50 -20];
bin_size = 2;

figure;
subplot(4, 4, [2 3 4 6 7 8 10 11 12]);
scatter(Y_in, Y_out);
title(sprintf('R^2 = %0.3f', r_squared));
axis([lims lims]);
grid on;

subplot(4, 4, [1 5 9]);
edges = lims(1):bin_size:lims(2);
centers = edges + diff(edges(1:2))/2;
n = histc(Y_out, edges);
barh(centers, n, 1);
ylim(lims);
set(gca, 'xscale', 'log');
grid on;
ylabel('Y_{out} (dB-nT)');

subplot(4, 4, [14 15 16]);
n = histc(Y_in, edges);
bar(centers, n, 1);
xlim(lims);
set(gca, 'yscale', 'log');
grid on;
xlabel('Y_{in} (dB-nT)');

increase_font;

1;

function norm_occur_l_ae_biv_hist(events, outliers, em_type, palmer_pp_db, DG, mlt_sector, ax, biv_mod_idx, biv_mod_sub_idx)
% norm_occur_l_ae_biv_hist(events, outliers, em_type, palmer_pp_db, DG, mlt_sector, ax, biv_mod_idx, biv_mod_sub_idx)
% 
% bivariate histogram of normalized emission occurrence (dependent variable) vs. PP and AE
% 
% Run as plot_pp_emission_correlation('norm_occur_l_ae_biv_hist', em_type, mlt_sector)
% 
% INPUTS
% ax is a 3-element vector of axes handles on which to plot the three
% figures.  If any element is -1, that figure will be plotted in a new
% figure window
% 
% biv_mod_idx is the model index to use for the bivariate GLM regression.
% If biv_mod_idx is not given, the model index will be selected based on
% the lowest BIC
% 
% biv_mod_sub_idx is a vector of indices of parameters for the chosen
% biv_mod_idx.  If biv_mod_sub_idx is not given, all indices of the chosen
% biv_mod_idx will be used
% 
% E.g., if biv_mod_idx = 39 and biv_mod_sub_idx = [1 3 4 5 7 8 9 10 11],
% then the line X = XX{modelnum} will become
% X = XX{39}(:, [1 3 4 5 7 8 9 10 11])
% 
% These parameters should only be supplied after doing a proper BIC
% analysis to find optimal parameters

% By Daniel Golden (dgolden1 at stanford dot edu) January 2010
% $Id$

%% Setup
global PALMER_MLT MIN_L MAX_L
[CHORUS_B_MIN CHORUS_B_MAX HISS_B_MIN HISS_B_MAX] = chorus_hiss_globals;

event_datenums = [events.start_datenum].';

start_datenum = floor(min(event_datenums));
end_datenum = ceil(max(event_datenums));

b_make_histograms = false;

if ~exist('ax', 'var') || isempty(ax)
	ax = [-1 -1 -1];
end

%% Choose a subset of images based on MLT
[idx_valid, sector_name] = choose_mlt_sector([palmer_pp_db.img_datenum].', mlt_sector);
palmer_pp_db = palmer_pp_db(idx_valid);
img_datenums = [palmer_pp_db.img_datenum].';


%% Generate a list of synoptic intervals that are within N minutes of an EUV image
syn_datenums = flatten(DG.synoptic_epochs(DG.synoptic_epochs >= start_datenum & DG.synoptic_epochs < end_datenum & DG.b_data));
b_outlier = false(size(syn_datenums));
for kk = 1:length(outliers)
	b_outlier(abs(syn_datenums - outliers(kk).start_datenum) < 5/86400) = true;
end
syn_datenums = syn_datenums(~b_outlier);

[mapped_pp, idx_valid, idx_finite] = get_pp_values_on_em_datenums(palmer_pp_db, syn_datenums);

% % Keep "indeterminate" values
% syn_datenums = syn_datenums(idx_valid);
% max_pp = min(mapped_pp(idx_valid), MAX_L);

% Throw away "indeterminate" values
syn_datenums = syn_datenums(idx_finite);
max_pp = min(mapped_pp(idx_finite), MAX_L);


%% Get AE on these same intervals
[start_year, ~] = datevec(start_datenum);
[end_year, ~] = datevec(end_datenum);
if start_year ~= end_year
	error('Events must span a single year; these events span %04d to %04d', start_year, end_year);
end

[ae_date, ae_all] = ae_read_datenum(start_year);
% [ae_date, ae_all] = kp_read_datenum(start_year);

% Average AE in last N hours
% n_hours_history = 6;
n_hours_history = 0;
ae = interp1(ae_date + n_hours_history/2/24, smooth(ae_all, n_hours_history + 1), syn_datenums);


%% Make a list of dates with and without emissions
b_emission = false(size(syn_datenums));
for kk = 1:length(events)
	% For each event, set the corresponding b_emission value to be true.
	% Machine rounding errors sometimes result in slight differences in
	% synoptic datenums, so we look for a synoptic datenum within 10
	% seconds of the emission start_datenum
	b_emission(abs(events(kk).start_datenum - syn_datenums) < 10/86400) = true;
end

%% Max frequency for each synoptic epoch with an emission
f_max = zeros(size(b_emission));
f_min = zeros(size(b_emission));
for kk = 1:length(syn_datenums)
	this_epoch_events = events([events.start_datenum] == syn_datenums(kk));
	if ~isempty(this_epoch_events)
		f_max(kk) = max([this_epoch_events.f_uc]);
		f_min(kk) = min([this_epoch_events.f_lc]);
	end
end

%% Make two lists of plasmapause and AE values
pp_with_em = max_pp(b_emission);
pp_without_em = max_pp(~b_emission);

ae_with_em = ae(b_emission);
ae_without_em = ae(~b_emission);


%% Choose number of bins for pp and ae
nbins = 5*[1 1];

% Sometimes, if there are a lot of MAX_L values, MAX_L comes out of the
% quantile command multiple times

% We want each bin to have nearly the same number of epochs
q_pp = quantile(max_pp, linspace(0, 1, nbins(1) + 1));
q_pp_unique = unique(q_pp);
while length(q_pp) ~= length(q_pp_unique)
	if nbins(1) == 3
		error('Unable to find enough unique pp bins');
	end
	nbins(1) = nbins(1) - 1;
	q_pp = quantile(max_pp, linspace(0, 1, nbins(1) + 1));
	q_pp_unique = unique(q_pp);
end

q_ae = quantile(ae, linspace(0, 1, nbins(2) + 1));
q_ae_unique = unique(q_ae);
while length(q_ae) ~= length(q_ae_unique)
	if nbins(2) == 3
		error('Unable to find enough unique ae bins');
	end
	nbins(2) = nbins(2) - 1;
	q_ae = quantile(ae, linspace(0, 1, nbins(2) + 1));
	q_ae_unique = unique(q_ae);
end


%% Make two histograms: one for pp with emissions, one for pp without
bin_edges_pp = [q_pp_unique(1:end-1) q_pp_unique(end)*1.01]; % Add a bit to the last bin edge to include the largest value in the bin
bin_edges_ae = [q_ae_unique(1:end-1) q_ae_unique(end)*1.01];
[Bin_edges_ae, Bin_edges_pp] = meshgrid(bin_edges_ae, bin_edges_pp);

bin_centers_pp = bin_edges_pp(1:(end-1)) + diff(bin_edges_pp)/2;
bin_centers_ae = bin_edges_ae(1:(end-1)) + diff(bin_edges_ae)/2;
[Bin_centers_ae, Bin_centers_pp] = meshgrid(bin_centers_ae, bin_centers_pp);

% pp varies down a given column, ae varies down a row
N_with_em = hist3([pp_with_em, ae_with_em], 'Edges', {bin_edges_pp, bin_edges_ae});
N_without_em = hist3([pp_without_em, ae_without_em], 'Edges', {bin_edges_pp, bin_edges_ae});

% Remove superfluous bins
N_with_em = N_with_em(1:end-1, 1:end-1);
N_without_em = N_without_em(1:end-1, 1:end-1);

N_total = N_with_em + N_without_em;
N_norm_occur = N_with_em./N_total;

MIN_BIN_SIZE = 20;
N_norm_occur_valid = N_norm_occur;
N_norm_occur_valid(N_total < MIN_BIN_SIZE) = nan;


%% Scatter plot
if ax(1) == -1
	figure;
else
	axes(ax(1));
end

% Norm occur histogram
if b_make_histograms
	subplot(4, 4, [5 6 7 9 10 11 13 14 15]);
end

% N_norm_occur_padded = [N_norm_occur_valid, zeros(size(N_norm_occur_valid, 1), 1); zeros(1, size(N_norm_occur_valid, 2)+1)];
% p = pcolor(Bin_edges_ae, Bin_edges_pp, N_norm_occur_padded);
% c = colorbar;
% ylabel(c, 'Norm occur');
% colormap(flipud(gray));
% hold on;
% 
% % Draw X's through cells have fewer entries than MIN_BIN_SIZE
% nodata = find(isnan(N_norm_occur_padded));
% for kk = 1:length(nodata)
% 	y_bot = bin_edges_pp(bin_edges_pp == Bin_edges_pp(nodata(kk)));
% 	y_top = bin_edges_pp(find(bin_edges_pp == Bin_edges_pp(nodata(kk))) + 1);
% 	x_left = bin_edges_ae(bin_edges_ae == Bin_edges_ae(nodata(kk)));
% 	x_right = bin_edges_ae(find(bin_edges_ae == Bin_edges_ae(nodata(kk))) + 1);
% 	
% 	plot([x_left x_right], [y_bot y_top], 'k');
% 	plot([x_right x_left], [y_bot y_top], 'k');
% 	
% 	disp('');
% end

pos_biv = get(gca, 'position');

% Overlay scatter plots
plot(ae_without_em, pp_without_em, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 4);
hold on;
plot(ae_with_em, pp_with_em, 'bs', 'Color', [0.3 0.3 1], 'MarkerFaceColor', [0.3 0.3 1], 'MarkerSize', 6);
grid on;

% Set AE to log scale
set(gca, 'xscale', 'log', 'xminortick', 'off', 'tag', 'chorus_scatterplot');
xlim(bin_edges_ae([1 end]));
ylim(bin_edges_pp([1 end]));

xlabel(sprintf('Avg. AE in prev. %d hours (nT)', n_hours_history));
ylabel('Plasmapause extent (R_E)');


%% AE 1D histogram
if b_make_histograms
	bar_color = [0.5 0.5 0.5];

	N_with_em_ae = sum(N_with_em, 1);
	N_total_ae = sum(N_total, 1);

	% s_ae = subplot(3, 3, [1 2]);
	s_ae = subplot(4, 4, [1 2 3]);
	b_ae = bar_by_edges(bin_edges_ae, N_with_em_ae./N_total_ae, 'color', bar_color);
	ylabel('Norm occur (vs AE)');
	hold on;
	box on;

	% Error bars
	% http://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval#Agresti-Coull_Interval
	% (95% confidence)
	n_twiddle = N_total_ae + 4;
	p_twiddle = (N_with_em_ae + 2)./n_twiddle;
	error_ae = 1.96*sqrt(p_twiddle.*(1 - p_twiddle)./n_twiddle);
	e = errorbar(bin_centers_ae, p_twiddle, error_ae, 'k', 'linestyle', 'none');
	yl = ylim;
	ylim([max(0, yl(1)), 0.5]);

	% Line up axes
	xlim(bin_edges_ae([1 end]));
	pos_ae = get(gca, 'position');
	grid on;
	set(gca, 'position', [pos_biv(1) pos_ae(2) pos_biv(3) pos_ae(4)]);

	title(sprintf('%s, %s MLT, %d events from %s to %s', ...
		em_type, sector_name, sum(b_emission), datestr(start_datenum), datestr(end_datenum)));
	pos_t = get(get(gca, 'title'), 'position');
	set(get(gca, 'title'), 'position', [bin_edges_ae(end) pos_t(2:3)]);
	% set(get(gca, 'title'), 'horizontalalignment', 'left');
	% h = annotation('textbox', [0.5 0.5 .5 .5], 'string', 'etc etc', 'linestyle', 'off')

	% Set AE to log scale
	% set(gca, 'xscale', 'log', 'xticklabel', [], 'xtick', bin_edges_ae, 'xminortick', 'off', 'xminorgrid', 'off');
	set(gca, 'xscale', 'log', 'xticklabel', [], 'ytick', [0 0.25 0.5]);
end


%% PP 1D histogram
if b_make_histograms
	N_with_em_pp = sum(N_with_em, 2);
	N_total_pp = sum(N_total, 2);

	% s_pp = subplot(3, 3, [6 9]);
	s_pp = subplot(4, 4, [8 12 16]);
	b_pp = bar_by_edges(bin_edges_pp, N_with_em_pp./N_total_pp, 'orientation', 'horizontal', 'color', bar_color);
	grid on;
	xlabel('Norm occur (vs PP)');
	hold on;
	box on;

	% Error bars (95% confidence)
	n_twiddle = N_total_pp + 4;
	p_twiddle = (N_with_em_pp + 2)./n_twiddle;
	error_pp = 1.96*sqrt(p_twiddle.*(1 - p_twiddle)./n_twiddle);
	e = herrorbar(p_twiddle, bin_centers_pp, error_pp, error_pp);
	set(e(2), 'visible', 'off');
	set(e(1), 'color', 'k');
	xl = xlim;
	xlim([max(xl(1), 0), 0.5]);

	% Line up axes
	ylim(bin_edges_pp([1 end]));
	pos_pp = get(gca, 'position');
	set(gca, 'position', [pos_pp(1) pos_biv(2) pos_pp(3) pos_biv(4)]);

	% set(gca, 'yticklabel', [], 'ytick', bin_edges_pp);
	set(gca, 'yticklabel', [], 'xtick', [0 0.25 0.5]);

	figure_grow(gcf, 1.5);
end
increase_font(gcf);

%% Single regression on plasmapause
max_single_order = 4;
% [max_pp, max_pp.^2, max_pp.^3, ...]
XX_single = repmat(max_pp, 1, max_single_order).^repmat(1:max_single_order, length(max_pp), 1);

% Determine Akaike Information Criteron and Bayesian Information Criterion
% to choose final order of model (best model has lowest value of favorite
% information criterion)
AIC = zeros(max_single_order, 1);
BIC = zeros(max_single_order, 1);
for kk = 1:max_single_order
	[b, dev, stats] = glmfit(XX_single(:, 1:kk), b_emission, 'binomial', 'logit');
	mu_fitted = glmval(b, XX_single(:, 1:kk), 'logit');
	log_likelihood = sum(log(binopdf(b_emission, ones(size(b_emission)), mu_fitted)));
	BIC(kk) = -2*log_likelihood + length(b)*log(length(b_emission));
	AIC(kk) = -2*log_likelihood + 2*length(b);
end

% figure;
% plot(BIC, 'linewidth', 2);
% grid on;
% xlabel('PP model order');
% ylabel('BIC');
% increase_font;

modelno = find(BIC == min(BIC), 1);
X_single = XX_single(:, 1:modelno);
fprintf('Final single model order: %d\n', modelno);

[b, dev, stats] = glmfit(X_single, b_emission, 'binomial', 'logit');
b
p = stats.p

% Plot the fit
x_lim = bin_edges_pp([1 end]);
pp_fit_vec = linspace(x_lim(1), x_lim(2), 100).';
XX_single_fit = repmat(pp_fit_vec, 1, max_single_order).^repmat(1:max_single_order, length(pp_fit_vec), 1);

X_single_fit = XX_single_fit(:, 1:modelno);
[yhat, dylo, dyhi] = glmval(b, X_single_fit, 'logit', stats, 'confidence', 0.95);

if ax(2) == -1
	figure;
else
	axes(ax(2));
end
conf_int_color = 0.7*[1 1 1];
fill([yhat - dylo; flipud(yhat + dyhi)], [pp_fit_vec; flipud(pp_fit_vec)], ...
	conf_int_color, 'edgecolor', conf_int_color);
hold on;
plot(yhat, pp_fit_vec, 'k', 'LineWidth', 2);
grid on;
% hold on;
% plot(yhat - dylo, pp_fit_vec, 'r', 'LineWidth', 2);
% plot(yhat + dyhi, pp_fit_vec, 'r', 'LineWidth', 2);
xlim([0 0.6]);
ylim([2.3 6]);
xlabel('Mean norm occur. prob.');
ylabel('Plasmapause extent (R_E)');
increase_font;

set(gca, 'tag', 'univariate_regression_plot');


%% Multiple regression
% Try lots of different possibilities for X; the one we choose is the one
% that minimizes the Bayesian information criterion (BIC).  That can be
% determined using this method:
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/237941
model_order = 4;
XX = all_permut_of_X(model_order, log10(ae), max_pp);
XX_sym = all_permut_of_X(model_order, sym('ae'), sym('pp'));
AIC = zeros(size(XX));
BIC = zeros(size(XX));
for kk = 1:length(XX)
	[b, dev, stats] = glmfit(XX{kk}, b_emission, 'binomial', 'logit');
	mu_fitted = glmval(b, XX{kk}, 'logit');
	log_likelihood = sum(log(binopdf(b_emission, ones(size(b_emission)), mu_fitted)));
	BIC(kk) = -2*log_likelihood + length(b)*log(length(b_emission));
	AIC(kk) = -2*log_likelihood + 2*length(b);
end

% for kk = 1:length(XX_sym), fprintf('%02d %s\n', kk, char(XX_sym{kk})); end
% figure;
% % plot(1:length(AIC), AIC, 1:length(BIC), BIC, 'LineWidth', 2);
% plot(BIC, 'LineWidth', 2);
% % legend('AIC', 'BIC');
% xlabel('Bivariate model no');
% ylabel('BIC');
% grid on;
% increase_font;

% If a specific model index and/or sub indices were supplied, use them
if ~exist('biv_mod_idx', 'var') || isempty(biv_mod_idx)
	modelno = find(BIC == min(BIC), 1);
else
	modelno = biv_mod_idx;
end
if ~exist('biv_mod_sub_idx', 'var') || isempty(biv_mod_sub_idx)
	biv_mod_sub_idx = 1:size(XX{modelno}, 2);
end
X = XX{modelno}(:, biv_mod_sub_idx);
fprintf('Model: %s\n', char(XX_sym{modelno}(:, biv_mod_sub_idx)));


[b, dev, stats] = glmfit(X, b_emission, 'binomial', 'logit');
b
p = stats.p

b_emission_hat = glmval(b, X, 'logit');
SSE = dev;
SSR = sum((b_emission_hat - mean(b_emission)).^2);
SST = sum((b_emission - mean(b_emission)).^2);

% Make a grid for plotting the fit
% x_lim = bin_edges_ae([1 end]);
% y_lim = bin_edges_pp([1 end]);
x_lim = 10.^[1.7 3];
y_lim = [2.3 6];
logae_fit_vec = log10(logspace(log10(x_lim(1)), log10(x_lim(2)), 100)).';
pp_fit_vec = linspace(y_lim(1), y_lim(2), 100).';
[logae_fit, pp_fit] = meshgrid(logae_fit_vec, pp_fit_vec);

XXfit = all_permut_of_X(model_order, logae_fit(:), pp_fit(:));
Xfit = XXfit{modelno}(:, biv_mod_sub_idx);
[yhat, dylo, dyhi] = glmval(b, Xfit, 'logit', stats);

% % Threshold yhat so that we plot white where the 95% confidence interval is
% % greater than 0.5
% yhat_thresh = yhat;
% yhat_thresh(dyhi + dylo > 0.5) = -1;
% [yhat_thresh, cmap, cax] = colormap_white_bg(yhat_thresh, jet, [0 1]);

cax = [0 1];

if ax(3) == -1
	figure;
else
	axes(ax(3));
end
subplot(2, 3, [1 2 4 5]);
% Set areas with high variance to zero
imagesc(logae_fit_vec, pp_fit_vec, reshape(yhat.*(1 - (dyhi + dylo).^2), size(logae_fit)));
% c = colorbar;
% ylabel(c, 'Norm occur');
title('Mean normalized occurrence probability');
axis xy;
% grid on;
% colormap(cmap);
caxis(cax);
ylabel('Plasmapause extent (R_E)');
xlabel(sprintf('Log_{10} avg. AE in prev. %d hours (nT)', n_hours_history));
set(gca, 'tickdir', 'out');
increase_font;
set(gca, 'tag', 'bivariate_regression_plot');

subplot(2, 3, 3);
imagesc(logae_fit_vec, pp_fit_vec, reshape(yhat + dyhi, size(logae_fit)));
% c = colorbar;
% ylabel(c, 'Norm occur upper');
title('Norm occur upper 95%');
axis xy;
% grid on;
caxis(cax);
ylabel('Plasmapause (L)');
xlabel(sprintf('Log_{10} avg. AE in prev. %d hours (nT)', n_hours_history));
set(gca, 'tickdir', 'out');

subplot(2, 3, 6);
imagesc(logae_fit_vec, pp_fit_vec, reshape(yhat - dylo, size(logae_fit)));
% c = colorbar;
% ylabel(c, 'Norm occur lower');
title('Norm occur lower 95%');
axis xy;
% grid on;
caxis(cax);
ylabel('Plasmapause (L)');
set(gca, 'tickdir', 'out');

figure_grow(gcf, 1.5, 1);
increase_font;


% for kk = 1:1
% % 	subplot(3, 1, kk);
% 	axis xy;
% 	grid on;
% 	caxis([0 1]);
% 	ylabel('Plasmapause (L)');
% 	
% 	set(gca, 'xtick', roundn(log10(bin_edges_ae), -2), 'ytick', roundn(bin_edges_pp, -1), 'tickdir', 'out');
% end

% figure_grow(gcf, 0.5, 1);

%% Plot number of epochs in each bin (> ~10-30 = statistically significant)
% figure;
% 
% % Num epochs
% N_total_padded = [N_total, zeros(size(N_total, 1), 1); zeros(1, size(N_total, 2)+1)];
% pcolor(Bin_edges_ae, Bin_edges_pp, N_total_padded);
% set(gca, 'xscale', 'log');
% c = colorbar;
% ylabel(c, 'Num epochs');
% xlabel(sprintf('Avg. AE in prev. %d hours (nT)', n_hours_history));
% ylabel('Plasmapause (L)');
% 
% title(sprintf('%s, %s MLT\n%d events from %s to %s\n%dx%d bins, %d-%d intervals per bin', ...
% 	em_type, sector_name, sum(b_emission), datestr(start_datenum), datestr(end_datenum), ...
% 	nbins(1), nbins(2), max(MIN_BIN_SIZE, min(N_total(:))), max(N_total(:))));
% 
% increase_font(gcf);

disp('');

function X_cell = all_permut_of_X(order, term1, term2)
% Get all permutations of X (e.g., by removing and adding elements of equal
% order) that include all lower order terms

[X, maxorder, comborder] = buildx(order, term1, term2);

X_cell = {};
X_cell_idx = 1;
% Loop over orders
for kk = 1:order
	order_idx = find(comborder == kk);
	lower_order_idx = find(comborder < kk);
	% All combinations of this order for all values of n things taken
	for jj = 1:length(order_idx)
		sub_idx = nchoosek(order_idx, jj);
		% All combinations of this order for this value of n things taken
		for ii = 1:size(sub_idx, 1)
			X_cell{X_cell_idx} = [X(:, lower_order_idx) X(:, sub_idx(ii, :))];
% 			disp(X_cell{X_cell_idx})

			X_cell_idx = X_cell_idx + 1;
		end
	end
end

function X_cell = even_more_permute_of_X(order, term1, term2)
% Really get ALL permutations of X
% I.e., there are n terms in X.  Get the n-choose-k subsets for every value
% of k up to order
% 
% It turns out that there can be quite a bit of permutations, which makes
% this function infeasible
%  order   size(X_cell, 1)
%    1            7
%    2          255
%    3        32767
%    4     16777215 ( 16 million)
% 
% So this really isn't feasible past order 2, which makes it useless.  Oh,
% well!

[X, maxorder, comborder] = buildx(order, term1, term2);

X_cell = {};
for kk = 1:length(X)
	subs_idx = nchoosek(1:length(X), kk);
	for jj = 1:size(subs_idx, 1)
		X_cell{end+1} = X(:, subs_idx(jj, :));
	end
end


function [X, maxorder, comborder] = buildx(order, term1, term2)
% [X, maxorder, comborder] = buildx(order, term1, term2)
% Build up X parameter with given terms
% 
% E.g., if order is 2 and two terms are given, X is a cell array with
% [term1, term2, term1.*term2, term1.^2, term2.^2]
% and all subsets thereof
% 
% comborder is number of multiplied original terms
% E.g., comborder(a) = 1, comborder(a*b) = 2, comborder(a^2*b) = 3,
% comborder(b^4) = 4
% maxorder is the maximum order of either of the two components, a or b

assert(order >= 1);

a = [];
b = [];
for kk = 1:order
	a = [a term1.^kk];
	b = [b term2.^kk];
end

X = [a b];

comborder = [(1:order) (1:order)];
maxorder = [(1:order) (1:order)];

%  Loop over a's
for kk = 1:order
	% Loop over b's
	for jj = 1:order
		X(:, end+1) = a(:, kk).*b(:, jj);
		comborder(end+1) = kk + jj;
		maxorder(end+1) = max(kk, jj);
	end
end

% Sort by maxorder, then comborder
[~, idx1] = sort(maxorder);
[~, idx2] = sort(comborder(idx1));

maxorder = maxorder(idx1(idx2));
comborder = comborder(idx1(idx2));
X = X(:, idx1(idx2));

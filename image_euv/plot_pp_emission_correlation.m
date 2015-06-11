function plot_pp_emission_correlation(plot_type, em_type, mlt_sector)
% plot_pp_emission_correlation(plot_type, em_type, mlt_sector)
% 
% Plots correlation between emissions and plasmapause location
% 
% em_type can be one of 'hiss' or 'chorus'
% plot_type can be one of
%  ampl_l_scatter -- scatter plot of emission amplitude vs. PP L
%  freq_l_scatter -- scatter plot of emission mean frequency vs. PP L
%  burstiness_l_scatter -- scatter plot of emission burstiness vs. PP L
%  norm_occur_l_hist -- histogram of normalized emission occurrence vs. PP
%   L
%  norm_occur_l_ae_biv_hist -- bivariate histogram of normalized emission
%   occurrence (dependent variable) vs. PP and AE
% mlt_sector should be 0 (all MLT sectors), 1 (00-06), 2 (06-12), 3
% (12-18), 4 (18-24), 5 (04-10) or 6 (16-22)

% By Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id$

%% Setup
if ~exist('mlt_sector', 'var') || isempty(mlt_sector)
	mlt_sector = 0;
end

addpath(fullfile(danmatlabroot, 'vlf', 'emission_statistics')); % chorus_hiss_globals

% Min and max burstiness for an emission to be considered chorus or hiss
global PALMER_MLT MIN_L MAX_L
[CHORUS_B_MIN CHORUS_B_MAX HISS_B_MIN HISS_B_MAX] = chorus_hiss_globals;

PALMER_MLT = -(4+1/60)/24;

MIN_L = 2;
MAX_L = 7; % PP values of Inf get rounded to this value

%% Load database files
[~, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
	case 'quadcoredan.stanford.edu'
		palmer_pp_db = '/home/dgolden/vlf/case_studies/image_euv_2001/palmer_pp_db.mat';
		emission_db = '/home/dgolden/vlf/case_studies/chorus_hiss_detection/auto_chorus_hiss_db_2001.mat';
		outliers_db = '/home/dgolden/vlf/case_studies/chorus_hiss_detection/auto_chorus_hiss_outliers_2001.mat';
    case 'dantop'
		palmer_pp_db = 'C:\Users\Daniel\temp\palmer_pp_db.mat';
		emission_db = 'C:\Users\Daniel\temp\auto_chorus_hiss_db_2001.mat';
	otherwise
		error('Unknown hostname: %s', hostname(1:end-1));
end
load(palmer_pp_db, 'palmer_pp_db');
load(emission_db, 'events');
load(outliers_db, 'outliers');

%% Load data gap info
DG = load(fullfile(danmatlabroot, 'vlf', 'emission_statistics', 'data_gaps.mat'));

%% Parse out valid data
% Parse out valid plasmapause data - keep Inf, discard NaN
palmer_pp_db = palmer_pp_db(~isnan([palmer_pp_db.pp_L]));

% Parse out valid emissions
burstiness = [events.burstiness];
switch em_type
	case 'all'
		idx = true(size(burstiness));
	case 'chorus'
		idx = burstiness >= CHORUS_B_MIN & burstiness < CHORUS_B_MAX;
	case 'hiss'
		idx = burstiness >= HISS_B_MIN & burstiness < HISS_B_MAX;
	otherwise
		error('Unknown emission type ''%s''', em_type);
end

events = events(idx);

%% Run subfunction
switch plot_type
	case 'ampl_l_scatter'
		if mlt_sector ~= 0, warning('Ignoring extraneous argument ''mlt_sector''');	end
		ampl_l_scatter(events, em_type, palmer_pp_db);
	case 'freq_l_scatter'
		freq_l_scatter(events, outliers, em_type, palmer_pp_db);
	case 'burstiness_l_scatter'
		burstiness_l_scatter(events, em_type, palmer_pp_db, mlt_sector);
	case 'norm_occur_l_hist'
		norm_occur_l_hist(events, em_type, palmer_pp_db, DG, mlt_sector);
	case 'norm_occur_l_ae_biv_hist'
		norm_occur_l_ae_biv_hist(events, outliers, em_type, palmer_pp_db, DG, mlt_sector);
	otherwise
		error('Unknown plot type ''%s''', plot_type);
end

%% Function ampl_l_scatter
function ampl_l_scatter(events, em_type, palmer_pp_db)

global PALMER_MLT MIN_L MAX_L

%% Find plasmapause points within 1 hour of emission
[mapped_pp, idx_valid, idx_finite] = get_pp_values_on_em_datenums(palmer_pp_db, [events.start_datenum].');

em_amplitude = [events.amplitude].';

%% Separate values into different MLT sectors
sector_names = {'post-midnight 00-06', 'pre-noon 06-12', 'post-noon 12-18', 'pre-midnight 18-24'};
rho = zeros(4, 1);
idx_mlt_sec = zeros(length(em_datenums), 4);
for kk = 1:4
	idx_mlt_sec(:, kk) = fpart(em_datenums + PALMER_MLT) >= (kk - 1)*0.25 & ...
	                     fpart(em_datenums + PALMER_MLT) < kk*0.25;
	
	rho(kk) = corr(mapped_pp(idx_finite & idx_mlt_sec( :, kk)), ...
		em_amplitude(idx_finite & idx_mlt_sec( :, kk)));
end

%% Correlation plot!
figure;

for kk = 1:4
	this_plot_idx = idx_valid & idx_mlt_sec( :, kk);
	subplot(2, 2, kk);
	scatter(min(mapped_pp(this_plot_idx), MAX_L), em_amplitude(this_plot_idx), '.', 'sizedata', 72);
	grid on;
	
	if mod(kk, 2)
		ylabel(sprintf('%s ampl. (uncal dB)', em_type));
	end
	if kk > 2
		xlabel('PP (L)');
	end
	
	title(sprintf('%s MLT\n%s (%d events, \\rho = %0.2f)', sector_names{kk}, em_type, sum(this_plot_idx), rho(kk)));

	xlim([MIN_L MAX_L]);
	ylim([-10 10]);
	
	% hold on;
	% p = polyfit([events.intensity], -log(mapped_pp.') + rand(size(mapped_pp.'))*0.001, 1);
	% p_fun = polyval(p, [events.intensity]);
	% plot([events.intensity], exp(-p_fun), 'r--', 'LineWidth', 2);
end

increase_font(gcf, 14);

%% Function freq_l_scatter
function freq_l_scatter(events, outliers, em_type, palmer_pp_db_orig)

global PALMER_MLT MIN_L MAX_L

if ~strcmp(em_type, 'chorus')
	error('There''s no point in making this plot for an emission other than chorus');
end

%% Delete outliers
event_datenums = [events.start_datenum];
b_outlier = false(size(event_datenums));
for kk = 1:length(outliers)
	b_outlier(abs(event_datenums - outliers(kk).start_datenum) < 5/86400) = true;
end
event_datenums = event_datenums(~b_outlier);
events = events(~b_outlier);

%% Find plasmapause points within 1 hour of emission
[mlt_idx, sector_name] = choose_mlt_sector([palmer_pp_db_orig.img_datenum], 05);
palmer_pp_db = palmer_pp_db_orig(mlt_idx);
[mapped_pp, idx_valid, idx_finite] = get_pp_values_on_em_datenums(palmer_pp_db, [events.start_datenum].');

em_freq = mean([[events.f_lc]; [events.f_uc]]).';
em_freq_max = [events.f_uc];
em_freq_min = [events.f_lc];

idx_finite_idx = find(idx_finite);

%% Scatter plot
figure;
hold on;

% Lines connecting min and max frequencies
for kk = 1:length(idx_finite_idx)
	plot(mapped_pp(idx_finite_idx(kk))*ones(1, 2), ...
		[em_freq_min(idx_finite_idx(kk)) em_freq_max(idx_finite_idx(kk))]/1e3, 'k-');
% 	text(mapped_pp(idx_finite_idx(kk)), em_freq_max(idx_finite_idx(kk))/1e3, sprintf(' %s', datestr(event_datenums(idx_finite_idx(kk)), 31)));
end

% plot(em_freq(idx_finite), mapped_pp(idx_finite), '.', 'MarkerSize', 16);
plot(mapped_pp(idx_finite), em_freq_min(idx_finite)/1e3, 'b.', 'MarkerSize', 16);
plot(mapped_pp(idx_finite), em_freq_max(idx_finite)/1e3, 'r.', 'MarkerSize', 16);
xlabel('Plasmapause L');
ylabel('Emission frequency (kHz)');
title(sprintf('Correlation of chorus frequency with plasmapause (\\rho = %0.2f)', corr(em_freq(idx_finite), mapped_pp(idx_finite))));
grid on;
increase_font;


%% Function burstiness_l_scatter
function burstiness_l_scatter(events, em_type, palmer_pp_db, mlt_sector)

%% Choose a subset of images based on MLT
[mlt_idx, sector_name] = choose_mlt_sector(palmer_pp_db, mlt_sector);
palmer_pp_db = palmer_pp_db(mlt_idx);

%% Find plasmapause points within 1 hour of emission
[mapped_pp, idx_valid, idx_finite] = get_pp_values_on_em_datenums(palmer_pp_db, [events.start_datenum].');

%% Scatter plot
em_burstiness = [events.burstiness].';
[rho, pval] = corr(em_burstiness(idx_finite), mapped_pp(idx_finite));

figure;
plot(em_burstiness(idx_finite), mapped_pp(idx_finite), '.', 'MarkerSize', 16);
xlabel('Emission burstiness');
ylabel('Plasmapause L');
title(sprintf('Correlation of %s %s emission burstiness with plasmapause (\\rho = %0.2f)', sector_name, em_type, rho));
grid on;
increase_font;


%% Function ampl_l_scatter
function norm_occur_l_hist(events, em_type, palmer_pp_db, DG, mlt_sector)

global PALMER_MLT MIN_L MAX_L

event_datenums = [events.start_datenum].';

start_datenum = floor(min(event_datenums));
end_datenum = ceil(max(event_datenums));

img_datenums = [palmer_pp_db.img_datenum].';

%% Choose a subset of images based on MLT
[mlt_idx, sector_name] = choose_mlt_sector(palmer_pp_db, mlt_sector);
palmer_pp_db = palmer_pp_db(mlt_idx);

img_datenums = [palmer_pp_db.img_datenum].';

%% Generate a list of synoptic intervals with/without emissions
syn_datenums = flatten(DG.dates(DG.dates >= start_datenum & DG.dates < end_datenum & DG.b_data));
nearest_img_to_syn_idx = nearest(syn_datenums, img_datenums);
syn_dist = abs(syn_datenums - img_datenums(nearest_img_to_syn_idx));

% Remove synoptic intervals that are not within 15 minutes of a plasmapause
% value
idx_valid = syn_dist <= 15/1440;
syn_datenums = syn_datenums(idx_valid);
palmer_pp_db_nearest = palmer_pp_db(nearest_img_to_syn_idx);
palmer_pp_db_nearest = palmer_pp_db_nearest(idx_valid);
max_pp = min(max([[palmer_pp_db_nearest.pp_L]; [palmer_pp_db_nearest.pp_L2]]), MAX_L);

b_emission = false(size(syn_datenums));
for kk = 1:length(events)
	% For each event, set the corresponding b_emission value to be true
	% Machine rounding errors sometimes result in slight differences in
	% synoptic datenums, so we look for a synoptic datenum within 10
	% seconds of the emission start_datenum
	b_emission(abs(events(kk).start_datenum - syn_datenums) < 10/86400) = true;
end

% Make the list
pp_with_em = max_pp(b_emission);
pp_without_em = max_pp(~b_emission);

%% Make two histograms: one for pp with emissions, one for pp without
NBINS = 7;

q = unique(quantile(max_pp, linspace(0, 1, NBINS + 1)));

% Sometimes, if there are a lot of MAX_L values, MAX_L comes out of the
% quantile command multiple times
NBINS = length(q) - 1;

bin_edges = [q(1:end-1) q(end)+0.01]; % Add a bit to the last bin edge to include the largest value in the bin
bin_centers = bin_edges(1:end-1) + diff(bin_edges)/2;

n_with_em = histc(pp_with_em, bin_edges);
n_without_em = histc(pp_without_em, bin_edges);

% Delete the empty last bin
n_with_em = n_with_em(1:end-1);
n_without_em = n_without_em(1:end-1);

n_total = n_with_em + n_without_em;
n_norm_occur = n_with_em./n_total;

% Exclude the Inf bin for the correlation
rho = corr(bin_centers(1:end-1).', n_norm_occur(1:end-1).');


%% Plot histogram
figure;

% Norm occur histogram
face_color = [0 0.8 0]; % Green
% b = bar(c, [n_norm_occur 0], 'hist');
% set(b, 'FaceColor', face_color);
b = bar_by_edges(bin_edges, n_norm_occur, 'color', face_color);
grid on;
ylabel('Norm occur');
xlabel('Plasmapause (L)');
title(sprintf('%s, %s MLT, (%d events from %s to %s\n%d bins, %d intervals per bin, \\rho = %0.2f', ...
	em_type, sector_name, sum(b_emission), datestr(start_datenum), datestr(end_datenum), ...
	NBINS, round(length(max_pp)/NBINS), rho));
xlim(bin_edges([1 end]));
ylim([0 0.4]);

increase_font(gcf, 14);

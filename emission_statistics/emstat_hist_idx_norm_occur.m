function varargout = emstat_hist_idx_norm_occur(em_type, these_events, idx_type, n_hours_history, mlt_sector)
% [bin_edges, bin_centers, n_norm_occur, n_total, rho] = 
%  emstat_hist_idx_norm_occur(em_type, these_events, idx_type, n_hours_history, mlt_sector)
% 
% idx_type should be one of: 'dst', 'kp', or 'ae'
% mlt_sector should be 0 (all MLT sectors), 1 (00-06), 2 (06-12), 3 (12-18) or 4 (18-24)
% The these_events' times are in UT, but the MLT sector is MLT, so the
% times are converted within this file

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Setup
PALMER_MLT = -(4+1/60)/24;

if ~exist('n_hours_history', 'var') || isempty(n_hours_history)
	n_hours_history = 0;
end
if ~exist('mlt_sector', 'var') || isempty(mlt_sector)
	mlt_sector = 0;
end

event_datenums = [these_events.start_datenum];

start_datenum = floor(min(event_datenums));
end_datenum = ceil(max(event_datenums));
[year, ~] = datevec(start_datenum);

%% Get index and choose bin_edges

% % Make the retrieved idx persistent, since retrieving it is the most time-intensive
% % portion of this script
% persistent idx_date idx idx_type_last
% if ~isempty(idx_type_last) && strcmp(idx_type_last, idx_type)
% 	b_fetch_idx = false;
% else
% 	b_fetch_idx = true;
% 	idx_type_last = idx_type;
% end
b_fetch_idx = true;

switch idx_type
	case 'dst'
		if b_fetch_idx, [idx_date, idx] = dst_read_datenum(year); end
% 		lowest_bin = -60;
% 		highest_bin = -10;
% 		bin_interval = 10;
		if ~exist('n_hours_history', 'var') || isempty(n_hours_history), n_hours_history = 1; end
	case 'kp'
		if b_fetch_idx, [idx_date, idx] = kp_read_datenum(year); end
% 		lowest_bin = 3;
% 		highest_bin = 5.5;
% 		bin_interval = 0.5;
		if ~exist('n_hours_history', 'var') || isempty(n_hours_history), n_hours_history = 24; end
	case 'ae'
		if b_fetch_idx, [idx_date, idx] = ae_read_datenum(year); end
% 		lowest_bin = 200;
% 		highest_bin = 800;
% 		bin_interval = 150;
		if ~exist('n_hours_history', 'var') || isempty(n_hours_history), n_hours_history = 6; end
	otherwise
		error('Invalid index type');
end

%% Only select emissions from a given MLT mlt_sector
addpath(fullfile(danmatlabroot, 'vlf', 'image_euv'));

[idx_valid, sector_name] = choose_mlt_sector(event_datenums, mlt_sector);
event_datenums = event_datenums(idx_valid);

DG = load(sprintf('data_gaps_%04d.mat', year));
[idx_valid, sector_name] = choose_mlt_sector(DG.dates, mlt_sector);
synoptic_datenums = DG.dates(idx_valid & DG.b_data & DG.dates >= start_datenum & DG.dates < end_datenum);

% sector_names = {'All', 'post-midnight 00-06', 'pre-noon 06-12', 'post-noon 12-18', 'pre-midnight 18-24'};
% 
% sector_name = sector_names{mlt_sector + 1};
% event_mlts = fpart(event_datenums + PALMER_MLT);
% 
% DG = load(sprintf('data_gaps_%04d.mat', year));
% if mlt_sector ~= 0
% 	event_datenums = event_datenums(event_mlts >= (mlt_sector-1)*0.25 & event_mlts < mlt_sector*0.25);
% 
% 	synoptic_datenums = DG.dates(DG.b_data & DG.dates >= start_datenum & DG.dates < end_datenum & ...
% 		fpart(DG.dates + PALMER_MLT) >= (mlt_sector-1)*0.25 & fpart(DG.dates + PALMER_MLT) < mlt_sector*0.25);
% else
% 	synoptic_datenums = DG.dates(DG.b_data & DG.dates >= start_datenum & DG.dates < end_datenum);
% end

%% Get days that don't have data gaps
% days = datenum(start_datenum:(end_datenum-1));
% 
% % Eliminate days that have more than two hours of data gap within the
% % emission interval
% day_mask = find_data_gap_days(em_int_start_ut, em_int_end_ut, 2, days);
% days = days(day_mask);

%% Find the maximum of this index in the last N hours
% % Get idx_star over a reduced resolution grid of dates, because it takes a
% % while
% idx_reduced_datenums = start_datenum:n_hours_history/2/24:(end_datenum + n_hours_history/24);
% 
% if strcmp(idx_type, 'dst')
% 	maxomin = 'min';
% else
% 	maxomin = 'max';
% end
% idxi = get_idx_star(idx, idx_date, idx_reduced_datenums, n_hours_history, maxomin);
% 
% % Interpolate idxi over synoptic times
% idxi_int = interp1(idx_reduced_datenums, idxi, synoptic_datenums);
% 
% history_type = 'max';

%% Find the average or max of this index in the last N hours
history_type = 'max';

% idxi_int = interp1(idx_date + n_hours_history/2/24, smooth(idx, n_hours_history + 1), synoptic_datenums);

switch history_type
	case 'avg'
		% Average idx in last N hours
		idxi_int = interp1(idx_date + n_hours_history/2/24, smooth(idx, n_hours_history + 1), synoptic_datenums);
	case 'max'
		% Max idx in last N hours
		idxi_datenum = synoptic_datenums(1):(max(n_hours_history, 1)/2/24):(synoptic_datenums(end) + max(1, n_hours_history/24));
		idxi_raw = get_idx_star(idx, idx_date, idxi_datenum, n_hours_history, 'max');
		idxi_int = interp1(idxi_datenum, idxi_raw, synoptic_datenums);
end

%% Generate boolean list of when we saw the emissions
b_emission = false(size(synoptic_datenums));
event_datenums_unique = unique(event_datenums);
for kk = 1:length(event_datenums_unique)
	% For each event, set the corresponding b_emission value to be true
	% Machine rounding errors sometimes result in slight differences in
	% synoptic datenums, so we look for a synoptic datenum within 10
	% seconds of the emission start_datenum
	b_emission(abs(synoptic_datenums - event_datenums_unique(kk)) < 10/86400) = true;
end

%% Lists of indexes with/without emission
% Now we have the idx for each synoptic interval, and a binary 'true' or
% 'false' for emissions ocurring in synoptic interval. Make two lists:
% a list of IDXs for when we had emissions, and a list of IDXs
% for when we didn't

idx_with_em = idxi_int(b_emission);
idx_without_em = idxi_int(~b_emission);

%% Determine bin_edges based on idx properties
switch idx_type
	case 'dst'
		min_step = 10;
	case 'kp'
		min_step = 0.5;
	case 'ae'
		min_step = 100;
end
bin_center = round(mean(idxi_int)/min_step)*min_step;

NBINS = 7;

q = quantile(idxi_int, linspace(0, 1, NBINS + 1));
bin_edges = [q(1:end-1) q(end)+1]; % Add 1 to the last bin edge to include the largest value in the bin

%% Make two histograms: one for index with emissions, one for index without
bin_centers = bin_edges(1:end-1) + diff(bin_edges)/2;

% % A complicated procedure to get non-uniform bin edges to work correctly
% c(1) = mean(bin_edges(1:2));
% for kk = 2:length(bin_edges)
% 	c(kk) = 2*bin_edges(kk) - c(kk-1);
% end

n_with_em = histc(idx_with_em, bin_edges);
n_without_em = histc(idx_without_em, bin_edges);

% Remove the Inf bin (which has nothing in it)
n_with_em = n_with_em(1:end-1);
n_without_em = n_without_em(1:end-1);

n_total = n_with_em + n_without_em;

n_norm_occur = n_with_em./n_total;

mask = ~isnan(n_norm_occur) & (n_norm_occur > 0);
rho = corr(bin_centers(mask).', n_norm_occur(mask).');

%% Assign output arguments
if nargout > 0
	error(nargoutchk(4, 5, nargout));
end
if nargout > 3
	varargout{1} = bin_edges;
	varargout{2} = bin_centers;
	varargout{3} = n_norm_occur;
	varargout{4} = n_total;
end
if nargout > 4
	varargout{5} = rho;
	
	return;
end

%% Remove values for which we have insufficient statistics
MIN_EVENTS = 10;
n_norm_occur_valid = n_norm_occur;
n_norm_occur_valid(n_total <= MIN_EVENTS) = NaN;

%% Plot histogram
figure;
face_color = [1 0.3 0.3]; % Red
% b = bar(c, [n_norm_occur_valid 0], 'hist');
% set(b, 'FaceColor', face_color);
b = bar_by_edges(bin_edges, n_norm_occur_valid,	'color', face_color);
grid on;
% ylim([0 0.25]);
ylim([0 0.4]);
xlim(bin_edges([1 end]));

ylabel('Norm occur');
title(sprintf('%s, %s MLT, %d events from %s to %s\n%d bins, %d intervals per bin, \\rho = %0.2f', em_type, sector_name, ...
	length(event_datenums), datestr(start_datenum), datestr(end_datenum), NBINS, round(length(idxi_int)/NBINS), rho));

%% Plot day stats
% ax_occur = subplot(4, 1, 4);
% b = bar(c, [n_total 0], 'hist');
% set(gca, 'yscale', 'log');
% ylim([1e1 10^max(ceil(log10(n_total)))]);
% set(get(b, 'baseline'), 'basevalue', 1);
% grid on;
% xlim([bin_edges(1) bin_edges(end)]);

% set(gca, 'XTick', bin_edges);
% XTickLabel = get(gca, 'XTickLabel');
% XTickLabel = mat2cell(XTickLabel, ones(1, size(XTickLabel, 1)), size(XTickLabel, 2));
% switch idx_type
% 	case 'dst'
% 		XTickLabel{1} = '-Inf';
% 	otherwise
% 		XTickLabel{end} = 'Inf';
% end
% set(gca, 'XTickLabel', XTickLabel);

switch idx_type
	case 'dst'
		xlabel(sprintf('%s Dst in prev %d hrs (nT)', history_type, n_hours_history));
	case 'kp'
		xlabel(sprintf('%s Kp in prev %d hrs', history_type, n_hours_history));
	case 'ae'
		xlabel(sprintf('%s AE in prev %d hrs (nT)', history_type, n_hours_history));
end

% ylabel('# intervals');

% axes(ax_hist);

increase_font(gcf, 14);

%% Plot error bars
% sigma_with_em = sqrt(n_with_em);
% sigma_total = sqrt(n_total);
% 
% sigma = sqrt((sigma_with_em./n_total).^2 + (n_with_em.*sigma_total./n_total.^2).^2);
% 
% hold on;
% errorbar(bin_centers, n_norm_occur(1:end-1), sigma(1:end-1), 'Color', [0.8 0.0 0.0], 'LineStyle', 'none');

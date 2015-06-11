function hiss_nldn_superposed_epoch_hourly
% Function that does a superposed epoch analysis on hiss for every hour to
% determine where NLDN lightning tends to be when and before we see hiss.
% Output is NLDN flash density maps.

% By Daniel Golden (dgolden1 at stanford dot edu) July 2009
% $Id$

%% Setup
% Map properties
lat_min = 23;
lat_max = 55;
lon_min = -127;
lon_max = -50;
lat_lon_binsize = 4;

[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
        case 'polarbear'
			nldn_source_dir = '/home/dgolden1/input/nldn/daily';
			statistics_dir = '/home/dgolden1/input/nldn/statistics';
			output_dir = '~/output';
        case 'quadcoredan.stanford.edu'
			nldn_source_dir = '/home/dgolden/vlf/case_studies/nldn/daily';
			statistics_dir = '/home/dgolden/vlf/case_studies/nldn/statistics';
			output_dir = '~/temp';
        otherwise
               error('Unknown host (%s)', hostname(1:end-1));
end

date_start = datenum([2003 01 01 0 0 0]);
date_end = datenum([2003 11 01 0 0 0]);
days = date_start:date_end;

%% Parallel
PARALLEL = false;

if ~PARALLEL
	warning('Parallel mode disabled!');
end

poolsize = matlabpool('size');
if PARALLEL && poolsize == 0
	matlabpool('open');
end
if ~PARALLEL && poolsize ~= 0
	matlabpool('close');
end

%% Epoch and thresholding settings
fix_on = 'each_hour'; % Epoch is each hour that contains hiss
% fix_on = 'start_only'; % Epoch is only the start of the hiss

b_only_hiss_interval = false; % Look over all local times
% b_only_hiss_interval = true; % Only look in the usual hiss interval of 1200-0000 MLT (1600-0400 UT) 
hiss_interval = [04 16]/24;

nldn_thresh = 00; % Peak current absolute value threshold (kA)

epoch_start = 0; % Hour wrt epoch to start accumulating lightning data
epoch_end = 1; % Hour wrt epoch to end accumulating lightning data

% Dst delimiters; Dst > -20 is "low", -20 < Dst < -50 is "medium" and Dst <
% -50 is "high"
dst_lim = [-50 -20];


%% Find data gaps
data_gaps = load(fullfile(danmatlabroot, 'vlf', 'emission_statistics', 'data_gaps.mat'));
data_gap_hours = floor(data_gaps.dates*24)/24;
[data_gap_hours_unique, ~, n] = unique(data_gap_hours);
data_per_hour = accumarray(n.', data_gaps.b_data);
idx_data_gap_mask = data_per_hour >= 2;

% The hours from data_gaps.mat only go through Oct 31, 2300. Add one to the
% vector to go through Nov 1 (which, as it happens, is the start of a two-day data gap)
assert(data_gap_hours_unique(end) == datenum([2003 10 31 23 0 0]));
idx_data_gap_mask(end+1) = false;

%% Load hiss, Dst files, define epoch
hiss = load(fullfile(statistics_dir, 'hiss_statistics.mat'));
dst = load(fullfile(statistics_dir, 'dst_statistics.mat'));
assert(all(dst.hour == hiss.hour));

% If we're only doing analysis during the hiss interval, remove other parts
% of our arrays
if b_only_hiss_interval
	idx_hiss_interval = idx_data_gap_mask & (fpart(hiss.hour) < hiss_interval(1) | fpart(hiss.hour) > hiss_interval(2));
else
	idx_hiss_interval = idx_data_gap_mask;
end
dst.hour = dst.hour(idx_hiss_interval);
dst.dst = dst.dst(idx_hiss_interval);
hiss.hiss_amp = hiss.hiss_amp(idx_hiss_interval);
hiss.hour = hiss.hour(idx_hiss_interval);
hiss_amp = hiss.hiss_amp;

switch fix_on
	case 'each_hour'
		epoch = hiss_amp > min(hiss_amp); % Any time there's hiss
	case 'start_only'
		epoch = hiss_amp(2:end) > min(hiss_amp) & hiss_amp(1:end-1) == min(hiss_amp); % Just the start of hiss
		epoch = [0; epoch];
end

[Bin_area, bin_lat, bin_lon] = get_nldn_flash_density_bin_areas(lat_min, lat_max, lon_min, lon_max, lat_lon_binsize);

N_norm_total_matrix = zeros([size(Bin_area) length(hiss.hour)]);
N_raw_total_matrix = zeros([size(Bin_area) length(hiss.hour)]);

t_net_start = now;

% Loop over nldn days
hours_processed = false(size(hiss.hour));
for kk = 1:(length(days) - 1)
	t_start = now;

	nldn_filename = fullfile(nldn_source_dir, sprintf('nldn%s.mat', datestr(days(kk), 'yyyymmdd')));
	nldn = load(nldn_filename);
% 	disp(sprintf('Loaded %s', just_filename(nldn_filename)));

	% Loop over hours in this day
	this_day_hours = find(hiss.hour >= days(kk) & hiss.hour < days(kk+1));
	for jj = 1:length(this_day_hours)
		hour_idx = this_day_hours(jj);
		this_hour = hiss.hour(hour_idx);
		
		% Indices into nldn struct for lightning preceding this epoch
		nldn_idx = (nldn.date >= this_hour + epoch_start/24) & (nldn.date < this_hour + epoch_end/24 & abs(nldn.peakcur) > nldn_thresh);

		N = nldn_density_grid(nldn, nldn_idx, bin_lat, bin_lon); % Num flashes
% 		N = nldn_density_grid_expand(nldn, nldn_idx, bin_lat, bin_lon);
		N_norm = N./Bin_area; % Num flashes/km^2

		N_norm_total_matrix(:, :, hour_idx) = N_norm_total_matrix(:, :, hour_idx) + N_norm;
		N_raw_total_matrix(:, :, hour_idx) = N_raw_total_matrix(:, :, hour_idx) + N;
		hours_processed(hour_idx) = true;
	end
	
	disp(sprintf('Processed %s in %0.1f seconds', just_filename(nldn_filename), (now - t_start)*86400));
end
assert(all(hours_processed(1:end-1)));
clear nldn;

% Totals regardless of DST
idx_hiss = hiss_amp > -20;
N_norm_total_total = sum(N_norm_total_matrix, 3)/length(hiss.hour); % Num flashes/km^2/hour
N_norm_total_hiss = sum(N_norm_total_matrix(:, :, idx_hiss), 3)/sum(idx_hiss);
N_norm_total_nohiss = sum(N_norm_total_matrix(:, :, ~idx_hiss), 3)/sum(~idx_hiss);
num_hours_total = sum(N_norm_total_matrix ~= 0, 3);
num_hours_hiss = sum(N_norm_total_matrix(:, :, idx_hiss) ~= 0, 3);
num_hours_nohiss = sum(N_norm_total_matrix(:, :, ~idx_hiss) ~= 0, 3);


% Totals for different DST values
% low Dst = highly disturbed!
dst_low_idx = (dst.dst < dst_lim(1));
N_norm_total_total_dst_low = sum(N_norm_total_matrix(:, :, dst_low_idx), 3)/sum(dst_low_idx);
N_norm_total_hiss_dst_low = sum(N_norm_total_matrix(:, :, idx_hiss & dst_low_idx), 3)/sum(idx_hiss & dst_low_idx);
N_norm_total_nohiss_dst_low = sum(N_norm_total_matrix(:, :, ~idx_hiss & dst_low_idx), 3)/sum(~idx_hiss & dst_low_idx);
num_hours_total_dst_low = sum(N_norm_total_matrix(:, :, dst_low_idx) ~= 0, 3);
num_hours_hiss_dst_low = sum(N_norm_total_matrix(:, :, idx_hiss & dst_low_idx) ~= 0, 3);
num_hours_nohiss_dst_low = sum(N_norm_total_matrix(:, :, ~idx_hiss & dst_low_idx) ~= 0, 3);

% med
dst_med_idx = (dst.dst >= dst_lim(1) & dst.dst < dst_lim(2));
N_norm_total_total_dst_med = sum(N_norm_total_matrix(:, :, dst_med_idx), 3)/sum(dst_med_idx);
N_norm_total_hiss_dst_med = sum(N_norm_total_matrix(:, :, idx_hiss & dst_med_idx), 3)/sum(idx_hiss & dst_med_idx);
N_norm_total_nohiss_dst_med = sum(N_norm_total_matrix(:, :, ~idx_hiss & dst_med_idx), 3)/sum(~idx_hiss & dst_med_idx);
num_hours_total_dst_med = sum(N_norm_total_matrix(:, :, dst_med_idx) ~= 0, 3);
num_hours_hiss_dst_med = sum(N_norm_total_matrix(:, :, idx_hiss & dst_med_idx) ~= 0, 3);
num_hours_nohiss_dst_med = sum(N_norm_total_matrix(:, :, ~idx_hiss & dst_med_idx) ~= 0, 3);

% high Dst = undisturbed!
dst_high_idx = (dst.dst >= dst_lim(2));
N_norm_total_total_dst_high = sum(N_norm_total_matrix(:, :, dst_high_idx), 3)/sum(dst_high_idx);
N_norm_total_hiss_dst_high = sum(N_norm_total_matrix(:, :, idx_hiss & dst_high_idx), 3)/sum(idx_hiss & dst_high_idx);
N_norm_total_nohiss_dst_high = sum(N_norm_total_matrix(:, :, ~idx_hiss & dst_high_idx), 3)/sum(~idx_hiss & dst_high_idx);
num_hours_total_dst_high = sum(N_norm_total_matrix(:, :, dst_high_idx) ~= 0, 3);
num_hours_hiss_dst_high = sum(N_norm_total_matrix(:, :, idx_hiss & dst_high_idx) ~= 0, 3);
num_hours_nohiss_dst_high = sum(N_norm_total_matrix(:, :, ~idx_hiss & dst_high_idx) ~= 0, 3);


t_net_end = now;
t_net_minutes = (t_net_end - t_net_start)*1440;
disp(sprintf('Finished processing in %d minutes, %0.0f seconds', ...
	floor(t_net_minutes), fpart(t_net_minutes)*60));

%% Plot output

addl_plot_title = sprintf(' (%d-kA thresh, %d^\\circ bin, [%d %d](%d) hiss int)', nldn_thresh, lat_lon_binsize, hiss_interval*24, b_only_hiss_interval);

% plot_pcolor_map(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, ['Total (non-epoch)' addl_plot_title], log10(N_norm_total_total), [-6 -2], 'log_{10} avg num flashes/km^2/hour', 'jet_with_white');
% hiss_nldn_sp_epoch_plotter(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, sprintf('Total (non-epoch)'), N_norm_total_total);
% hiss_nldn_sp_epoch_plotter(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, sprintf('Total - hiss'), N_norm_total_hiss);
% hiss_nldn_sp_epoch_plotter(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, sprintf('Total - no hiss'), N_norm_total_nohiss);

%% Difference plots (hiss minus no-hiss)

% % Hourly thresholding
% num_hours_thresh = 20; % Threshold (bins fewer than this many hours total of lightning are set to nan)
% hiss_nohiss_all = hourly_thresh(log10(N_norm_total_hiss) - log10(N_norm_total_nohiss), num_hours_total, num_hours_thresh);
% hiss_nohiss_high = hourly_thresh(log10(N_norm_total_hiss_dst_high) - log10(N_norm_total_nohiss_dst_high), num_hours_total_dst_high, num_hours_thresh);
% hiss_nohiss_med = hourly_thresh(log10(N_norm_total_hiss_dst_med) - log10(N_norm_total_nohiss_dst_med), num_hours_total_dst_med, num_hours_thresh);
% hiss_nohiss_low = hourly_thresh(log10(N_norm_total_hiss_dst_low) - log10(N_norm_total_nohiss_dst_low), num_hours_total_dst_low, num_hours_thresh);

% Daily thresholding
num_days_thresh = 10;
hiss_nohiss_all = sup_ep_daily_thresh(log10(N_norm_total_hiss./N_norm_total_nohiss), N_norm_total_matrix, true(size(dst.dst)), dst.hour, num_days_thresh);
hiss_nohiss_high = sup_ep_daily_thresh(log10(N_norm_total_hiss_dst_high./N_norm_total_nohiss_dst_high), N_norm_total_matrix, dst_high_idx, dst.hour, num_days_thresh);
hiss_nohiss_med = sup_ep_daily_thresh(log10(N_norm_total_hiss_dst_med./N_norm_total_nohiss_dst_med), N_norm_total_matrix, dst_med_idx, dst.hour, num_days_thresh);
hiss_nohiss_low = sup_ep_daily_thresh(log10(N_norm_total_hiss_dst_low./N_norm_total_nohiss_dst_low), N_norm_total_matrix, dst_low_idx, dst.hour, num_days_thresh);

%% Create US lightning index
us_flashes = squeeze(sum(sum(N_raw_total_matrix, 1), 2));
idx_hiss_22 = idx_hiss & abs(fpart(hiss.hour) - 22/24) < 1/1440;
idx_nohiss_22 = ~idx_hiss & abs(fpart(hiss.hour) - 22/24) < 1/1440;

%% Save results
save(fullfile(output_dir, 'nldn_epoch_output.mat'));
disp(sprintf('Saved %s', fullfile(output_dir, 'nldn_epoch_output.mat')));

%% Plot thresholded maps
plot_pcolor_map(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, ['Total hiss-no\_hiss - all DST' addl_plot_title], hiss_nohiss_all, [], 'log_{10} (hiss-fl/nohiss-fl)/(hiss-hr/nohiss-hr)', 'hotcold');
plot_pcolor_map(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, ['Total hiss-no\_hiss - high DST (undisturbed)' addl_plot_title], hiss_nohiss_high, [], 'log_{10} (hiss-fl/nohiss-fl)/(hiss-hr/nohiss-hr)', 'hotcold');
plot_pcolor_map(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, ['Total hiss-no\_hiss - medium DST' addl_plot_title], hiss_nohiss_med, [], 'log_{10} (hiss-fl/nohiss-fl)/(hiss-hr/nohiss-hr)', 'hotcold');
plot_pcolor_map(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, ['Total hiss-no\_hiss - low DST (highly disturbed)' addl_plot_title], hiss_nohiss_low, [], 'log_{10} (hiss-fl/nohiss-fl)/(hiss-hr/nohiss-hr)', 'hotcold');

% plot_pcolor_map(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, 'Num hours with flashes - all DST', log10(num_hours_total), [], 'log_{10} hours with lightning', jet_with_white);
% plot_pcolor_map(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, 'Num hours with flashes - high DST', log10(num_hours_total_dst_high), [], 'log_{10} hours with lightning', jet_with_white);
% plot_pcolor_map(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, 'Num hours with flashes - med DST', log10(num_hours_total_dst_med), [], 'log_{10} hours with lightning', jet_with_white);
% plot_pcolor_map(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, 'Num hours with flashes - low DST', log10(num_hours_total_dst_low), [], 'log_{10} hours with lightning', jet_with_white);


% hiss_nldn_sp_epoch_plotter_diff(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, 'Total hiss-no\_hiss - all DST', N_norm_total_hiss, N_norm_total_nohiss);
% hiss_nldn_sp_epoch_plotter_diff(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, 'Total hiss-no\_hiss - high DST', N_norm_total_hiss_dst_high, N_norm_total_nohiss_dst_high);
% hiss_nldn_sp_epoch_plotter_diff(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, 'Total hiss-no\_hiss - medium DST', N_norm_total_hiss_dst_med, N_norm_total_nohiss_dst_med);
% hiss_nldn_sp_epoch_plotter_diff(lat_min, lat_max, lon_min, lon_max,
% bin_lat, bin_lon, 'Total hiss-no\_hiss - low DST', N_norm_total_hiss_dst_low, N_norm_total_nohiss_dst_low);

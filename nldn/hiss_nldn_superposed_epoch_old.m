function hiss_nldn_superposed_epoch_old
% Function that does a superposed epoch analysis on hiss to determine where
% NLDN lightning tends to be when and before we see hiss. Output is NLDN
% flash density maps.

% By Daniel Golden (dgolden1 at stanford dot edu) July 2009
% $Id$

%% Setup
fix_on = 'each_hour'; % Epoch is each hour that contains hiss
% fix_on = 'start_only'; % Epoch is only the start of the hiss

% b_only_hiss_interval = false; % Look over all local times
b_only_hiss_interval = true; % Only look in the usual hiss interval of 1200-0000 MLT (1600-0400 UT) 
warning('b_only_hiss_interval = true');

epoch_start = -0.5; % Hour wrt epoch to start accumulating lightning data
epoch_end = 0.5; % Hour wrt epoch to end accumulating lightning data

% % Dst delimiters; Dst > -20 is "low", -20 < Dst < -50 is "medium" and Dst <
% % -50 is "high"
% dst_lim = [-50 -20];

% Map properties
lat_min = 23;
lat_max = 55;
lon_min = -127;
lon_max = -50;

[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
        case 'polarbear'
			nldn_source_dir = '/home/dgolden1/input/nldn/';
			statistics_dir = '/home/dgolden1/input/nldn/statistics';
			output_dir = '~/output';
        case 'quadcoredan.stanford.edu'
			nldn_source_dir = '/home/dgolden/vlf/case_studies/nldn/';
			statistics_dir = '/home/dgolden/vlf/case_studies/nldn/statistics';
			output_dir = '~/temp';
        otherwise
               error('Unknown host (%s)', hostname(1:end-1));
end

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

%% Load hiss, Dst files, define epoch
hiss = load(fullfile(statistics_dir, 'hiss_statistics.mat'));
hiss_amp = hiss.hiss_amp;

switch fix_on
	case 'each_hour'
		epoch = hiss_amp > min(hiss_amp);
	case 'start_only'
		epoch = hiss_amp(2:end) > min(hiss_amp) & hiss_amp(1:end-1) == min(hiss_amp);
		epoch = [0; epoch];
end

dst = load(fullfile(statistics_dir, 'dst_statistics.mat'));
assert(all(dst.hour == hiss.hour));

[Bin_area, bin_lat, bin_lon] = get_nldn_flash_density_bin_areas(lat_min, lat_max, lon_min, lon_max);

N_norm_total_net = zeros(size(Bin_area));
N_norm_total = zeros([size(Bin_area) 0]);
epoch_dst = [];

t_net_start = now;

% Loop over months
for kk = 1:10
	t_start = now;
	this_start_datenum = datenum([2003 kk 01 0 0 0]); % Hardcoded dates in 2003!
	this_end_datenum = datenum([2003 kk+1 01 0 0 0]); % Hardcoded dates in 2003!
	
	nldn_filename = fullfile(nldn_source_dir, sprintf('nldn%s.mat', datestr(this_start_datenum, 'yyyymm')));
	nldn = load(nldn_filename);
	disp(sprintf('Loaded %s', just_filename(nldn_filename)));

	% Indices into hiss struct for epochs in this month
	epoch_idx = find((hiss.hour >= this_start_datenum) & (hiss.hour < this_end_datenum) & epoch);
	disp(sprintf('Processing %d epochs', length(epoch_idx)));
	
	% Build up lightning maps for epochs and various Dst levels
	for jj = 1:length(epoch_idx)
		% Indices into nldn struct for lightning preceding this epoch
		nldn_idx = (nldn.date >= hiss.hour(epoch_idx(jj)) + epoch_start/24) & (nldn.date < hiss.hour(epoch_idx(jj)) + epoch_end/24);
		
		% Sum number of strokes in each lat/lon bin; this approach IGNORES MULTIPLCITY
% 		N = hist3([nldn.lat(nldn_idx) nldn.lon(nldn_idx)], {bin_lat + 0.5, bin_lon + 0.5});
% 		N = nldn_density_grid(nldn.lat(nldn_idx), nldn.lon(nldn_idx), nldn.nstrokes(nldn_idx), bin_lat, bin_lon);
		N = nldn_density_grid_expand(nldn, nldn_idx, bin_lat, bin_lon);
		N_norm = N./Bin_area;
		
		% Add this map to the appropriate DST category
		epoch_dst(end+1) = min(dst.dst(dst.hour >= hiss.hour(epoch_idx(jj)) + epoch_start & ...
			dst.hour < hiss.hour(epoch_idx(jj)) + epoch_end));
% 		disp(sprintf('DEBUG dst = %d @ epoch = %s', round(epoch_dst(end)), datestr(hiss.hour(epoch_idx(jj)), 0)));
		
		N_norm_total(:,:,end+1) = N_norm;

% 		if mean_dst > dst_lim(2)
% 			N_norm_total_low = N_norm_total_low + N_norm;
% 		elseif mean_dst <= dst_lim(2) && mean_dst > dst_lim(1)
% 			N_norm_total_med = N_norm_total_med + N_norm;
% 		else
% 			N_norm_total_high = N_norm_total_high + N_norm;
% 		end
	end
	
	% Build up net lightning map
	N = hist3([nldn.lat nldn.lon], {bin_lat, bin_lon});
	N_norm = N./Bin_area;
	N_norm_total_net = N_norm_total_net + N_norm; % Total total - unrelated to epochs
	
	disp(sprintf('Processed in %0.0f seconds', (now - t_start)*86400));
end

% Separate lightning maps into "low", "medium" and "high" dst levels
dst_lim = quantile(epoch_dst, [1/3 2/3]);
N_norm_total_low = sum(N_norm_total(:, :, epoch_dst > dst_lim(2)), 3);
N_norm_total_med = sum(N_norm_total(:, :, epoch_dst <= dst_lim(2) & epoch_dst > dst_lim(1)), 3);
N_norm_total_high = sum(N_norm_total(:, :, epoch_dst <= dst_lim(1)), 3);
N_norm_total_all_dst = sum(N_norm_total, 3); % Total for all epochs regardless of Dst


t_net_end = now;
t_net_minutes = (t_net_end - t_net_start)*1440;
disp(sprintf('Finished processing in %d minutes, %0.0f seconds', ...
	floor(t_net_minutes), fpart(t_net_minutes)*60));

%% Plot output

hiss_nldn_sp_epoch_plotter(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, sprintf('Total (non-epoch)', dst_lim(2)), N_norm_total_net);
hiss_nldn_sp_epoch_plotter(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, sprintf('Total (epoch)', dst_lim(2)), N_norm_total_all_dst);
hiss_nldn_sp_epoch_plotter(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, sprintf('Superposed epoch Dst > %d', round(dst_lim(2))), N_norm_total_low);
hiss_nldn_sp_epoch_plotter(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, sprintf('Superposed epoch %d < Dst <= %d', round(dst_lim(1)), round(dst_lim(2))), N_norm_total_med);
hiss_nldn_sp_epoch_plotter(lat_min, lat_max, lon_min, lon_max, bin_lat, bin_lon, sprintf('Superposed epoch Dst <= %d', round(dst_lim(1))), N_norm_total_high);

save(fullfile(output_dir, 'nldn_epoch_output.mat'));
disp(sprintf('Saved %s', fullfile(output_dir, 'nldn_epoch_output.mat')));

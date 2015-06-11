function emstat_hist_idx_corr(dates, these_events, idx_type)
% idx_type should be one of: 'dst', 'kp', or 'ae'

% $Id$

switch idx_type
	case 'dst'
		[idx_date, idx] = dst_read_datenum('/home/dgolden/vlf/case_studies/dst/dst_2003.txt');
	case 'kp'
		[idx_date, idx] = kp_read_datenum('/home/dgolden/vlf/case_studies/kp/kp_2003.txt');
	case 'ae'
		[idx_date, idx] = ae_read_datenum('/home/dgolden/vlf/case_studies/ae/ae_2003.txt');
	otherwise
		error('Invalid index type');
end

% For each emission, find maximum intensity of this index the last N hours from
% the middle of the emission
NUM_HOURS_IDX = 24;
for kk = 1:length(dates)
	t_start = dates(kk) - NUM_HOURS_IDX/24;
	t_end = dates(kk);
	this_idx = idx(idx_date >= t_start & idx_date <= t_end);
	switch idx_type
		case 'dst'
			idx_value(kk) = min(this_idx);
		otherwise
			idx_value(kk) = max(this_idx);
	end
end

intensity = [these_events.intensity];
duration = [these_events.end_datenum] - [these_events.start_datenum];
% scatter(idx_value, duration.*intensity);
scatter(idx_value, intensity);

% rho = corr(idx_value.', (duration.*intensity).');
rho = corr(idx_value.', (intensity).');
disp(sprintf('rho = %0.2f', rho(1)));

switch idx_type
	case 'dst'
		xlabel('DST (nT)');
	case 'kp'
		xlabel('Kp');
	case 'ae'
		xlabel('AE (nT)');
end

% ylabel('Intensity-duration product (uncal dB-days)');
ylabel('Intensity (uncal dB)');

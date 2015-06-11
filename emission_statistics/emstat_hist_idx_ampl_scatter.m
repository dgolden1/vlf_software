function varargout = emstat_hist_idx_ampl_scatter(em_type, these_events, idx_type, num_hours_idx)
% rho = emstat_hist_idx_ampl_scatter(em_type, these_events, idx_type, num_hours_idx)
% idx_type should be one of: 'dst', 'kp', or 'ae'

% $Id$

%% Misc
dates = mean([[these_events.start_datenum]; [these_events.end_datenum]]); % Middle of emission

%% Get index and choose bins

% Make the retrieved idx persistent, since retrieving it is the most time-intensive
% portion of this script
persistent idx_date idx idx_type_last
if ~isempty(idx_type_last) && strcmp(idx_type_last, idx_type)
	b_fetch_idx = false;
else
	b_fetch_idx = true;
	idx_type_last = idx_type;
end

switch idx_type
	case 'dst'
		if b_fetch_idx, [idx_date, idx] = dst_read_datenum('/home/dgolden/vlf/case_studies/dst/dst_2003.txt'); end
		lowest_bin = -60;
		highest_bin = -10;
		bin_interval = 10;
		if ~exist('num_hours_idx') || isempty(num_hours_idx), num_hours_idx = 24; end
	case 'kp'
		if b_fetch_idx, [idx_date, idx] = kp_read_datenum('/home/dgolden/vlf/case_studies/kp/kp_2003.txt'); end
		lowest_bin = 3;
		highest_bin = 5.5;
		bin_interval = 0.5;
		if ~exist('num_hours_idx') || isempty(num_hours_idx), num_hours_idx = 24; end
	case 'ae'
		if b_fetch_idx, [idx_date, idx] = ae_read_datenum('/home/dgolden/vlf/case_studies/ae/ae_2003.txt'); end
		lowest_bin = 200;
		highest_bin = 800;
		bin_interval = 150;
		if ~exist('num_hours_idx') || isempty(num_hours_idx), num_hours_idx = 6; end
	otherwise
		error('Invalid index type');
end

%% Find the maximum of this index in the last N hours
if strcmp(idx_type, 'dst')
	maxomin = 'min';
else
	maxomin = 'max';
end
idxi = get_idx_star(idx, idx_date, dates, num_hours_idx, maxomin);

%% Plot
rho = corr(idxi.', [these_events.intensity].');

scatter(idxi, [these_events.intensity], 'filled');
grid on;

switch idx_type
	case 'dst'
		xlabel('DST* (nT)');
	case 'kp'
		xlabel('kp*');
	case 'ae'
		xlabel('AE* (nT)');
end

ylabel('Intensity (uncal dB)');

%% Output args
if nargout > 0
	varargout{1} = rho;
end

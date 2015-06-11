function idx_star = get_idx_star(idx, idx_date, epoch_datenum, n_hours_history, str_maxomin)
% idx_star = get_idx_star(idx, idx_date, epoch_datenum, n_hours_history, str_maxomin)
% 
% In the vein of Meredith's AE* (Meredith [2004]), find the maximum (or
% minimum) of a given magnetic index in the past 'n_hours_history' hours from
% each epoch

% By Daniel Golden (dgolden1 at stanford dot edu) October 2008
% $Id$

idx_star = zeros(size(epoch_datenum));
for kk = 1:length(epoch_datenum)
	t_start = epoch_datenum(kk) - n_hours_history/24;
	t_end = epoch_datenum(kk);
	this_idx = idx(idx_date >= t_start & idx_date <= t_end);
	
	% If the time range [t_start t_end] is smaller than the index interval,
	% this_idx may be empty; interpolate one value between t_start and
	% t_end
	if isempty(this_idx)
		this_idx = interp1(idx_date, idx, mean([t_start t_end]));
	end
	
% 	% DEBUG - mean of the value at epoch_datenum - n_hours_history with the
% 	% values 2 before and 2 after
% 	date_distances = abs(epoch_datenum(kk) - n_hours_history/24 - idx_date);
% 	i_smooth = find(date_distances == min(date_distances), 1) + [-2 -1 0 1 2];
% 	this_idx = mean(idx(i_smooth(i_smooth > 0)));
	
	switch str_maxomin
		case 'min'
			idx_star(kk) = min(this_idx);
		case 'max'
			idx_star(kk) = max(this_idx);
		otherwise
			error('Invalid string for ''str_maxomin'' (''%s'')', str_maxomin);
	end
end

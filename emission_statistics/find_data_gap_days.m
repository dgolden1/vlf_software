function day_mask = find_data_gap_days(em_int_start_ut, em_int_end_ut, n_hours_thresh, days)
% day_mask is false on days with data gaps longer than n_hours_thresh
% during the emission interval specified by em_int_start_ut and
% em_int_end_ut (both of which are in fractions of a day, UT).
% 
% In the case that the emission interval crosses midnight (as with hiss),
% then it is the day where the interval starts that will get day_mask set
% to false

% By Daniel Golden (dgolden1 at stanford dot edu) August 2009
% $Id$

assert(em_int_start_ut < 1);
assert(em_int_end_ut < 2);

[start_year, ~] = datevec(min(days));
[end_year, ~] = datevec(max(days));
assert(start_year == end_year);

data_gaps = load(sprintf('data_gaps_%04d.mat', start_year), 'b_data', 'dates');

if em_int_end_ut < em_int_start_ut
	em_int_end_ut = em_int_end_ut + 1;
end

day_mask = true(size(days));
for kk = 1:length(days)
	idx = data_gaps.dates >= days(kk) + em_int_start_ut & data_gaps.dates <= days(kk) + em_int_end_ut; % Gaps in this day
	if sum(data_gaps.b_data(idx)) <= n_hours_thresh*4
		day_mask(kk) = false;
	end
end

if ~any(day_mask)
	error('No days found from %s to %s without significant data gaps', datestr(min(days)), datestr(max(days)));
end

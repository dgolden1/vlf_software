function hiss_nohiss_out = sup_ep_daily_thresh(hiss_nohiss_in, N_norm_total_matrix, idx, hours, num_days_thresh)
% Helper function for hiss_nldn_superposed_epoch_hourly()
% 
% Function to set bins in hiss_nohiss_in as nan if they have fewer days of
% lightning than specified in num_days_thresh.
% idx should be the index of the hours that we're considering

% By Daniel Golden (dgolden1 at stanford dot edu) August 2009
% $Id$

[days, m, n] = unique(floor(hours));

days_with_flashes = zeros(size(N_norm_total_matrix, 1), size(N_norm_total_matrix, 2));
for kk = 1:length(days)
	this_idx = idx & (floor(hours) == days(kk)); % this_idx is indices with 'idx' (dst level) and this calendar day
	days_with_flashes = days_with_flashes + (sum(N_norm_total_matrix(:, :, this_idx), 3) ~= 0); % Add one to each bin that has at least one flash on this day
end

hiss_nohiss_out = hiss_nohiss_in;
hiss_nohiss_out(days_with_flashes < num_days_thresh) = nan;


function hiss_nohiss_out = hourly_thresh(hiss_nohiss_in, num_hours_total, num_hours_thresh)
% Function to set bins in hiss_nohiss_in as nan if they have fewer hours of
% lightning than specified in num_days_thresh

hiss_nohiss_out = hiss_nohiss_in;
hiss_nohiss_out(num_hours_total < num_hours_thresh) = nan;

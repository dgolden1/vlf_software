function mask = cum_spec_emission_mask(these_events, indices, frequency, time)
% mask = cum_spec_emission_mask(these_events, indices, frequency, time)
% Create emission mask for cum_spec_v2 for normalization purposes

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$


mask = zeros(length(frequency), length(time));

for kk = find(indices)
	temp_mask = zeros(length(frequency), length(time));
	temp_mask((frequency >= these_events(kk).f_lc) & (frequency <= these_events(kk).f_uc), ...
		(time >= fpart(these_events(kk).start_datenum)) & ((time <= fpart(these_events(kk).end_datenum)) | ...
		(fpart(these_events(kk).end_datenum) == 0))) = 1;
	mask = mask + temp_mask;
end

mask(mask == 0) = 1;

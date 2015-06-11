function [mapped_pp, idx_valid, idx_finite] = get_pp_values_on_em_datenums(palmer_pp_db, em_datenums)
% [mapped_pp, idx_valid, idx_finite] = get_pp_values_on_em_datenums(palmer_pp_db, events)
% 
% Take in palmer pp and emission databases, and return mapped_pp, a parsed
% version of palmer_pp_db that assigns PP L values on the date epochs from
% events.  If there is no palmer_pp_db value within 30 minutes of a given
% event, the value of mapped_pp for that epoch will be NaN.
% 
% idx_valid is true for non-NaN values of mapped_pp
% idx_finite is true for finite and non-NaN values of mapped_pp

% By Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id$

max_pp = max([[palmer_pp_db.pp_L]; [palmer_pp_db.pp_L2]]);

mapped_pp = nan(size(em_datenums));
img_datenums = [palmer_pp_db.img_datenum].';

% Emission epoch must be within this many minutes of a PP value to be
% considered valid
pp_minutes_thresh = 30;

% Loop over emissions; for each, if it's within pp_minutes_thresh minutes
% of a PP value, assign it the nearest PP value; otherwise, assign it a PP
% value of NaN
for kk = 1:length(em_datenums)
	date_dist = abs(img_datenums - em_datenums(kk));
	[min_date_dist, i] = min(date_dist);
	if min_date_dist > pp_minutes_thresh/3600;
		continue;
	end
	
	mapped_pp(kk) = max_pp(i);
end

idx_valid = ~isnan(mapped_pp);
idx_finite = isfinite(mapped_pp);

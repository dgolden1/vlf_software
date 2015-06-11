function [idx_valid, sector_name] = choose_mlt_sector(datenums, mlt_sector)
% [sector_name, new_palmer_pp_db] = choose_mlt_sector(palmer_pp_db, mlt_sector)
% Choose a subset of images from palmer_pp_db based on MLT

% By Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id$

PALMER_MLT = -(4+1/60)/24;

sector_names = {'all', 'post-midnight 00-06', 'pre-noon 06-12', ...
	'post-noon 12-18', 'pre-midnight 18-24', 'pre-noon 04-10', 'pre-midnight 16-22'};
sector_name = sector_names{mlt_sector + 1};

if mlt_sector > 0 && mlt_sector <= 4
	idx_valid = fpart(datenums + PALMER_MLT) >= (mlt_sector-1)*0.25 & fpart(datenums + PALMER_MLT) < mlt_sector*0.25;
elseif mlt_sector == 5
	idx_valid = fpart(datenums + PALMER_MLT) >= 4/24 & fpart(datenums + PALMER_MLT) < 10/24;
elseif mlt_sector == 6
	idx_valid = fpart(datenums + PALMER_MLT) >= 16/24 & fpart(datenums + PALMER_MLT) < 22/24;
elseif mlt_sector == 0
	idx_valid = true(size(datenums));
end

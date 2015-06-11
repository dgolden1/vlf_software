function L = get_from_palmer_pp_db(palmer_pp_db, img_datenum)
% L = get_from_palmer_pp_db(palmer_pp_db, img_datenum)
% Function to retrieve a stored L value from the Palmer plasmapause db

% By Daniel Golden (dgolden1 at stanford dot edu) May 2008
% $Id$

% Does this time value exist in the database?
db_i = find([palmer_pp_db.img_datenum] == img_datenum);

if ~isempty(db_i)
	assert(length(db_i) == 1);
	
	L = palmer_pp_db(db_i).pp_L;
else
	error('get_from_palmer_pp_db:NotFound', 'No entry for %s in database', datestr(img_datenum, 31));
end

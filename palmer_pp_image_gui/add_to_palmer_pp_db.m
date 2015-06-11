function palmer_pp_db = add_to_palmer_pp_db(palmer_pp_db, pp_L, pp_L2, img_datenum, test_db_warning_handle)
% palmer_pp_db = add_to_palmer_pp_db(palmer_pp_db, pp_L, img_datenum, test_db_warning_handle)
% Function to write to the Palmer plasmapause db
% 
% str_pp_L can be 'pp_L' or 'pp_L2' to add to pp_L or pp_L2 field
% test_db_warning_handle is the handle to the test_db_warning_handle object
% in the palmer_pp_image_gui, which this function will edit to note that
% there are unsaved changes to the database

% By Daniel Golden (dgolden1 at stanford dot edu) May 2008
% $Id$

%% Setup
if ~exist('pp_L', 'var')
	pp_L = [];
end
if ~exist('pp_L2', 'var')
	pp_L2 = [];
end

%% Add
% Does this time value already exist in the database?
db_i = find([palmer_pp_db.img_datenum] == img_datenum);

if ~isempty(db_i) % value already exists; replace it
	assert(length(db_i) == 1);

	if ~isempty(pp_L)
		disp(sprintf('Overwriting pp_L value at %s with L=%0.1f', datestr(img_datenum, 31), pp_L));
		palmer_pp_db(db_i).pp_L = pp_L;
	end
	if ~isempty(pp_L2)
		disp(sprintf('Overwriting pp_L2 value at %s with L=%0.1f', datestr(img_datenum, 31), pp_L2));
		palmer_pp_db(db_i).pp_L2 = pp_L2;
	else
		palmer_pp_db(db_i).pp_L2 = pp_L;
	end
	
else % Value doesn't exist yet; create it
	if isempty(pp_L)
		error('When creating a new database value, the pp_L field must be set before the pp_L2 field');
	end
	
	disp(sprintf('Creating new pp_L value at %s with L=%0.1f', datestr(img_datenum, 31), pp_L));
	db_entry.pp_L = pp_L;

	if ~isempty(pp_L2)
		disp(sprintf('Creating new pp_L2 value at %s with L=%0.1f', datestr(img_datenum, 31), pp_L2));
		db_entry.pp_L2 = pp_L2;
	else
		db_entry.pp_L2 = pp_L;
	end

	db_entry.img_datenum = img_datenum;
	palmer_pp_db(end+1) = db_entry;
end

%% Unsaved changes warning
if exist('test_db_warning_handle', 'var')
	set(test_db_warning_handle, 'String', 'Warning: there are unsaved changes');
end

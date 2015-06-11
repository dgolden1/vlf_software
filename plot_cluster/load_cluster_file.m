function pos_struct = load_cluster_file(filename)
% pos_struct = load_cluster_file(filename)
% Little script to either load a cluster position .mat file, or create it
% if it doesn't exist. Filename should EXCLUDE the path and extension.

% By Daniel Golden (dgolden1 at stanford dot edu) May 2009
% $Id$

cluster_pos_dir = '/home/dgolden/vlf/case_studies/cluster_palmer_2001_2002/cluster_position';
full_txt_filename = fullfile(cluster_pos_dir, [filename '.txt']);
full_mat_filename = fullfile(cluster_pos_dir, [filename '.mat']);

% Create the mat file if it doesn't exist
if ~exist(full_mat_filename, 'file')
	pos_struct = parse_cluster_pos_file(full_txt_filename);
	save(full_mat_filename, 'pos_struct');
else
	load(full_mat_filename);
end

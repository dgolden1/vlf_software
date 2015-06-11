function collect_palmer_pp_1d_db_files
% Function to collect all of the palmer_pp_1d_db files and turn them into a
% single file

% By Daniel Golden (dgolden1 at stanford dot edu) November 2009
% $Id$

%% Setup
% db_dir = '/home/dgolden/vlf/case_studies/image_euv_2001/palmer_plasmapause_db';

year = 2001;
max_L = 6;

%% Set paths
[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
% 	case 'vlf-alexandria'
	case 'quadcoredan.stanford.edu'
		db_dir = '/home/dgolden/vlf/case_studies/image_euv_2001/palmer_plasmapause_db';
		output_filename = '/home/dgolden/vlf/case_studies/image_euv_2001/palmer_plasmapause_db/palmer_plasmapause_db.mat';
	case 'scott.stanford.edu'
		db_dir = '/data/user_data/dgolden/palmer_plasmapause_db';
		output_filename = '/data/user_data/dgolden/palmer_plasmapause_db/palmer_plasmapause_db.mat';
end

%% Collect filenames
[~, filenames_str] = unix(sprintf('find %s -name "e*_xform.mat" | sort', db_dir));
filelist = textscan(filenames_str, '%s');
filelist = filelist{1};

t_start = now;

%% Look at the first file to get variable dimensions

s = load(filelist{1});

L = s.L(s.L < max_L);
dens = nan(length(s.plasma_density), length(filelist));
img_datenum = nan(length(filelist), 1);

dens(:, 1) = s.plasma_density;
img_datenum(1) = get_img_datenum(filelist{1});

%% Process the rest of the files
for kk = 2:length(filelist)
	img_datenum(kk) = get_img_datenum(filelist{kk});

	s = load(filelist{kk});
	
	% Make sure the L values from this file are the same as all the other
	% files
	assert(all(abs(L - s.L(s.L < max_L)) < 0.01));
	
	dens(:, kk) = s.plasma_density(s.L < max_L);
	
	disp(sprintf('Processed %s (%d of %d)', just_filename(filelist{kk}), kk, length(filelist)));
end

save(output_filename, 'L', 'dens', 'img_datenum');
disp(sprintf('Saved %s', output_filename));

disp(sprintf('Processed %d files in %s', length(filelist), time_elapsed(t_start, now)));

function make_fits_annotated_images_library
% Run make_fits_annotated_images on fits files from select directories

% By Daniel Golden (dgolden1 at stanford dot edu) November 2009
% $Id$

%% Setup
fits_dir = '/home/dgolden/vlf/case_studies/image_euv_2001/fits';
output_dir = '/home/dgolden/temp/image';

%% Load list of subdirectories
fid = fopen('make_fits_annotated_images_library_subdirs.txt', 'r');
subdirs = textscan(fid, '%s');
subdirs = subdirs{1};

%% Process
t_start = now;
for kk = 1:length(subdirs)
% 	this_output_dir = fullfile(output_dir, subdirs{kk});
	this_output_dir = output_dir;
	if ~exist(this_output_dir, 'dir'), mkdir(this_output_dir); end
	
	this_fits_dir = fullfile(fits_dir, subdirs{kk}, 'eqmapped');
	d_fits = dir(fullfile(this_fits_dir, '*_xform.fits'));
	
	disp(sprintf('Running on %s', subdirs{kk}));
	make_fits_annotated_images(this_output_dir, {d_fits.name}, this_fits_dir);
end

disp(sprintf('Processed %d directories in %s', length(subdirs), time_elapsed(t_start, now)));

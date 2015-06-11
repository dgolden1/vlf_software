function make_palmer_pp_1d_db_files
% Script to create database of Palmer plasmapause plots

% By Daniel Golden (dgolden1 at stanford dot edu) May 2008
% $Id$

%% Setup
close all;

% PALMER_LONGITUDE = -64.05;
PALMER_MLT = -(4 + 1/60)/24; % In units of days from UT

%% Parallel
PARALLEL = true;

if ~PARALLEL
	warning('Parallel mode disabled!');
end

poolsize = matlabpool('size');
if PARALLEL && poolsize == 0
	matlabpool('open');
end
if ~PARALLEL && poolsize ~= 0
	matlabpool('close');
end


%% Set paths
[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
% 	case 'vlf-alexandria'
	case 'quadcoredan.stanford.edu'
		destin_dir = '/home/dgolden/vlf/case_studies/image_euv_2001/palmer_plasmapause_db';
		fits_dir = '/home/dgolden/vlf/case_studies/image_euv_2001/fits';
	case 'scott.stanford.edu'
		destin_dir = '/home/dgolden/output/palmer_plasmapause_db';
		fits_dir = '/data/spacecraft/image/image_euv/fits';
	otherwise
		if ~isempty(regexp(hostname, 'corn[0-9][0-9].stanford.edu'))
			error('Corn machines not supported yet');
		else
			error('Unknown hostname ''%s''', hostname(1:end-1));
		end
end

%% Load list of subdirectories
fid = fopen('make_palmer_pp_1d_db_files_subdirs.txt', 'r');
subdirs = textscan(fid, '%s');
subdirs = subdirs{1};

%% Process and create output files
t_net_start = now;
for kk = 1:length(subdirs)
	pathname = fullfile(fits_dir, subdirs{kk}, 'eqmapped');
	files = dir(fullfile(pathname, '*_xform.fits'));
	disp(sprintf('Processing dir %s (%d of %d)...', pathname, kk, length(subdirs)));
	parfor jj = 1:length(files)
		t_start = now;
		
		[junk, fname] = fileparts(files(jj).name);
		destin_filename = fullfile(destin_dir, subdirs{kk}, [fname '.mat']);
		fits_filename = fullfile(pathname, files(jj).name);
		
		process_single_file(destin_dir, subdirs{kk}, fits_filename, destin_filename, PALMER_MLT);
		
		disp(sprintf('Processed %s (%d of %d) in %s', files(jj).name, jj, length(files), time_elapsed(t_start, now)));
	end
end
disp(sprintf('Finished processing in %s', time_elapsed(t_net_start, now)));

function process_single_file(destin_dir, subdir, fits_filename, destin_filename, PALMER_MLT)

% If the output directory doesn't exist, create it
if ~(exist(fullfile(destin_dir, subdir), 'dir'))
	mkdir(fullfile(destin_dir, subdir));
% If the output file already exists, don't recreate it
elseif exist(destin_filename, 'file')
	return;
end

img_datenum = get_img_datenum(fits_filename);
angle_offset = (fpart(img_datenum) + PALMER_MLT + 0.5)*2*pi;
[L, plasma_density] = get_plasma_density(fits_filename, angle_offset);

save(destin_filename, 'L', 'plasma_density');

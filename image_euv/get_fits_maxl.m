% Print out some info from all the FITS files

% By Daniel Golden (dgolden1 at stanford dot edu) November 2009
% $Id$

%% Setup
fits_dir = '/home/dgolden/vlf/case_studies/image_euv_2001/fits/';
output_file = '~/temp/max_l.txt';

%% Collect filenames
[~, filenames_str] = unix(sprintf('find %s -name "e*_xform.fits" | sort', fits_dir));
filelist = textscan(filenames_str, '%s');
filelist = filelist{1};

%% Open file
fid = fopen(output_file, 'w');

%% Loop over files
for kk = 1:length(filelist)
	fitsfilename = filelist{kk};
	
	info = fitsinfo(fitsfilename);
	max_L = get_fits_keyword(info, 'MAX_L');

	img_datenum = get_img_datenum(fitsfilename);
	
	str_line = sprintf('%s %s: MAX_L = %0.1f', datestr(img_datenum, 'yyyy-mm-dd HH:MM'), ...
		just_filename(fitsfilename), max_L);
	
	disp(str_line);
	fprintf(fid, '%s\n', str_line);
end

function fits_datasorter(source_dir, dest_dir)
% fits_datasorter(source_dir, dest_dir)
% Function to sort FITS files
% 
% source_dir: directory in which there are a bunch of fits, png and mtx
% files (not in subdirectories)
% dest_dir: directory of the yyyy-mm-dd folders

% By Daniel Golden (dgolden1 at stanford dot edu) May 2008
% $Id$

fits_files = [dir(fullfile(source_dir, '*.fits')); dir(fullfile(source_dir, '*.mtx')); dir(fullfile(source_dir, '*.png'))];

t_start = now;
for kk = 1:length(fits_files)
	fits_datenum = get_img_datenum(fits_files(kk).name);
	dest_day_dir = fullfile(dest_dir, datestr(fits_datenum, 'yyyy-mm-dd'));
	if ~exist(dest_day_dir, 'dir')
		mkdir(dest_day_dir);
	end
	if ~exist(fullfile(dest_day_dir, 'original'))
		mkdir(fullfile(dest_day_dir, 'original'));
	end
	if ~exist(fullfile(dest_day_dir, 'eqmapped'))
		mkdir(fullfile(dest_day_dir, 'eqmapped'));
	end

	% If this is an unmodified fits file, move to 'original' folder	
	if ~isempty(regexpi(fits_files(kk).name, 'e[0-9]{11}\.fits'))
		movefile(fullfile(source_dir, fits_files(kk).name), fullfile(dest_day_dir, 'original'));
	% If this is one of the myriad prodcuts for xform(), move to the 'eqmapped' folder
	elseif ~isempty(regexpi(fits_files(kk).name, 'e[0-9]{11}\.mtx|e[0-9]{11}_mask\.png|e[0-9]{11}_shadowmask\.fits|e[0-9]{11}_xform\.fits'))
		movefile(fullfile(source_dir, fits_files(kk).name), fullfile(dest_day_dir, 'eqmapped'));
	else
		disp(sprintf('Unrecognized filename format ''%s''; skipping', fits_files(kk).name));
		continue;
	end
	
	disp(sprintf('Sorted %s (%d of %d)', fits_files(kk).name, kk, length(fits_files)));
end

disp(sprintf('Finished sorting in %s', time_elapsed(t_start, now)));

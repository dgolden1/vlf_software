function make_fits_images(filenames, output_dir, bCenterPlot)
% Make a JPEGs out of fits files
% 
% If bCenterPlot is true, the plot will be a zoom-in of the center region,
% for the purposes of centering the projection

% By Daniel Golden (dgolden1 at stanford dot edu) May, 2008
% $Id$

%% Setup
if ~exist('filenames', 'var') || isempty(filenames)
	[filenames, pathname] = uigetfile('*.fits', 'Select FITS files', 'MultiSelect', 'On');
	if iscell(filenames)
		for kk = 1:length(filenames)
			filenames{kk} = fullfile(pathname, filenames{kk});
		end
	else
		filenames = fullfile(pathname, filenames);
	end
end
if ~iscell(filenames), filenames = {filenames}; end

if ~exist('output_dir', 'var') || isempty(output_dir)
	output_dir = uigetdir('', 'Select JPEG output directory');
end

%% Make images
figure;
for kk = 1:length(filenames)
	data = fitsread(filenames{kk});
	info = fitsinfo(filenames{kk});

	clf;
	imagesc(data);
	axis xy square;
	cmap = flipud(gray);
	colormap(cmap);
	colorbar;
	grid on;
	date = jdaytodatenum(get_fits_keyword(info, 'JUL_DAY'));
	title([datestr(date) ' UTC']);
	
	if bCenterPlot
		xlim([45 95]);
		ylim([55 95]);
	end
	
	increase_font(gca);

	[pathstr, fname] = fileparts(filenames{kk});
	
	if bCenterPlot
		outfilename = fullfile(output_dir, [fname '_center.jpg']);
	else
		outfilename = fullfile(output_dir, [fname '.jpg']);
	end
	print('-dpng', outfilename);
end
close;

function make_fits_annotated_images(output_dir, filenames, pathname)
% make_fits_annotated_images(output_dir, filenames, pathname)
% Make a JPEGs out of fits files, including various annotations

% By Daniel Golden (dgolden1 at stanford dot edu) May, 2008
% $Id$

%% Setup
if ~exist('filenames', 'var') || isempty(filenames)
	[filenames, pathname] = uigetfile('*_xform.fits', 'Select FITS files', 'MultiSelect', 'On');
	if isnumeric(filenames), return; end
end
if ~iscell(filenames), filenames = {filenames}; end

if ~exist('output_dir', 'var') || isempty(output_dir)
	output_dir = uigetdir(fullfile(pathname, '..', 'png'), 'Select PNG output directory');
	if isnumeric(output_dir), return; end
end

%% Make images
max_plot_L = 6;
figure_handle = 1;
t_net_start = now;
for kk = 1:length(filenames)
	t_start = now;
	plot_fits(fullfile(pathname, filenames{kk}), max_plot_L, figure_handle, [], [], false, false, false);
	
	[pathstr, fname] = fileparts(filenames{kk});
	outfilename = fullfile(output_dir, [fname '.png']);
	print('-dpng', '-r90', outfilename);
	
	disp(sprintf('Wrote %s (%d of %d) in %s', [fname '.png'], kk, length(filenames), time_elapsed(t_start, now)));
end
disp(sprintf('Finished in %s', time_elapsed(t_net_start, now)));

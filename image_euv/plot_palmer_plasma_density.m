function plot_palmer_plasma_density(fitsfilename, max_plot_L, figure_handle, axes_handle, palmer_pp_db_filename)
% plot_palmer_plasma_density(fitsfilename, max_plot_L, figure_handle, axes_handle, palmer_pp_db_filename)
% Get density for a given IMAGE EUV FITS file at Palmer's longitude
% 
% If figure_handle or axes_handle is not specified, a new window will be
% opened for plotting

% By Daniel Golden (dgolden1 at stanford dot edu) April 2008
% $Id$

%% Setup
% PALMER_LONGITUDE = -64.05;
PALMER_MLT = -4; % Palmer MLT offset from UT, in hours
PALMER_MLT

if ~exist('max_plot_L', 'var') || isempty(max_plot_L), max_plot_L = inf; end
if ~exist('figure_handle', 'var'), figure_handle = []; end
if ~exist('axes_handle', 'var'), axes_handle = []; end
if ~exist('palmer_pp_db_filename', 'var'), palmer_pp_db_filename = '/home/dgolden/vlf/case_studies/image_euv_2001/palmer_pp_db.mat'; end

db_path = '/home/dgolden/vlf/case_studies/image_euv_2001/palmer_plasmapause_db';

if ~isempty(axes_handle)
	bNOANNOT = true;
else
	bNOANNOT = false;
end

% Get image UT
img_datenum = get_img_datenum(fitsfilename);

angle_offset = (img_datenum - floor(img_datenum))*2*pi;

%% Get plasma density
% Determine whether this file already exists in the database
[y m d] = datevec(img_datenum);
[junk, fname] = fileparts(fitsfilename);
db_filename = fullfile(db_path, datestr(img_datenum, 'yyyy-mm-dd'), [fname '.mat']);
if exist(db_filename, 'file')
	load(db_filename);
else
	error('Missing db file %s', db_filename);
% 	[L, plasma_density] = get_plasma_density(fitsfilename, PALMER_MLT*2*pi/24+ angle_offset + pi);
end


% get rid of invalid values
L(isnan(plasma_density)) = [];
plasma_density(isnan(plasma_density)) = [];

%% Plot it
if isempty(figure_handle) && isempty(axes_handle)
	sfigure;
elseif ~isempty(axes_handle)
	axes(axes_handle);
	cla;
else
	sfigure(figure_handle);
	clf;
end

if length(plasma_density) < 2
% 	error('plot_palmer_plasma_density:NotEnoughVals', 'Not enough valid plasma density values');
	cla(gca, 'reset');
	t = text(0.2, 0.5, 'Not enough valid plasma density values', 'color', 'r');
	return;
end

semilogy(L, plasma_density, 'LineWidth', 2);
grid on;
xlabel('L shell (R_E)');
ylabel('He^+ Column Density (cm^{-2})');
title(sprintf('Plasma density at Palmer latitude for %s', datestr(img_datenum, 31)));
xl = xlim;
if ~isinf(max_plot_L)
	xlim([1 max_plot_L]);
else
	xlim([1 xl(2)]);
end

if ~bNOANNOT
	increase_font(gca);
end

%% Add a dot on the plasmapause location from the palmer plasmapause database file
if ~isempty(palmer_pp_db_filename) && exist(palmer_pp_db_filename, 'file')
	load(palmer_pp_db_filename, 'palmer_pp_db');
	db_i = find([palmer_pp_db.img_datenum] == img_datenum);
	assert(length(db_i) <= 1)
	
	if ~isempty(db_i) && isfinite(palmer_pp_db(db_i).pp_L)
		yval = interp1(L, plasma_density, palmer_pp_db(db_i).pp_L);
		hold on;
		green = [0.4 0.8 0.4];
		h_pp_loc = semilogy(palmer_pp_db(db_i).pp_L, yval, 'o', 'Color', 'k', ...
			'MarkerFaceColor', green, 'MarkerSize', 8);
	end
end
if exist('h_pp_loc', 'var') && ~bNOANNOT
	legend(h_pp_loc, 'Plasmapause');
end

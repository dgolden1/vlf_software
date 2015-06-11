function [L, plasma_density] = get_plasma_density(fitsfilename, angle, db_path)
% [L, plasma_density] = get_plasma_density(fitsfilename, angle)
% Get 1-D plasma density plot from an IMAGE EUV FITS file for a given angle
% (in radians) CCW from noon

% By Daniel Golden (dgolden1 at stanford dot edu) April 2008
% $Id$

%% Setup
DEBUG = false;

if ~exist('db_path', 'var') || isempty(db_path)
	db_path = '/home/dgolden/vlf/case_studies/image_euv_2001/palmer_plasmapause_db';
end

%% Debug: plot density
if DEBUG,
	close all;
	sfigure(1);
	plot_fits(fitsfilename);
	h_img = gca;
	axes(h_img);
	hold on;
end

%% Read FITS file
info = fitsinfo(fitsfilename);
imdata = fitsread(fitsfilename);

% load shadowmask
smfilename = strrep(fitsfilename, '_xform', '_shadowmask');
smdata = fitsread(smfilename);

%% Error checking - is this a non-equatorially mapped file?
if size(imdata, 1) ~= 600 || size(imdata, 2) ~= 600 || ndims(imdata) ~= 2
	error('Data must be a 600x600 array - is this file not equatorially mapped?');
end

%% Rotate image 180 degrees so the sun is to the right
imdata = rot90(rot90(imdata));

%% Calibrate
img_datenum = get_img_datenum(fitsfilename);
imdata = calibrate_euv_image(imdata, img_datenum);

%% Goofy procedure to get density over L and azimuth slices
azim_width = 30/1440*2*pi; % Azimuthal resolution of slices (30 minutes)
L_res = 0.1; % Radial resolution of slices

% Get coordinates in SM coordinate system of image
max_L = get_fits_keyword(info, 'MAX_L'); % The maximum L of the file
% max_calc_L = 6; % The maximum L out to which we're going to calculate stuff
% if max_L_file < max_calc_L
% 	error('File max_L < 6 (max_L = %0.1f)', max_L);
% end

x_sm = linspace(-max_L, max_L, size(imdata, 2));
y_sm = linspace(-max_L, max_L, size(imdata, 1));

L = (1+L_res):L_res:(max_L-L_res);
densities = zeros(1, length(L));

% Sum all the pixels in each slice and divide by the number of pixels
[X_sm, Y_sm] = meshgrid(x_sm, y_sm);
R = sqrt(X_sm.^2 + Y_sm.^2);
Theta = atan2(Y_sm, X_sm);
for kk = 1:length(densities)
	mask = R >= (L(kk) - L_res/2) & R < (L(kk) + L_res/2) & angle_is_between((angle - azim_width/2)*180/pi, (angle + azim_width/2)*180/pi, Theta*180/pi);
	
% 	mask(smdata ~= 1) = false; % Discard data outside the area of the cameras, on the seam, or in the Earth's shadow
	
	valid_pixels = imdata(mask);

% 	% Discard invalid values (values of zero)
% 	valid_pixels(valid_pixels == 0) = [];
	
	% If there are not enough valid pixels here, set the density to NaN
	if length(valid_pixels) < 10
		warning('Not enough valid pixels for image at %s', datestr(img_datenum, 31));
		densities(kk) = NaN;
		continue;
	end
	

	densities(kk) = 10.^mean(log10(valid_pixels));
	
	if DEBUG
		sfigure(2);
		if exist('h_mask', 'var'), delete(h_mask); end
		hold on;
		h_mask = imagesc(x_sm, y_sm, mask);
% 		h_mask = imagesc(x_sm, y_sm, zeros(size(mask)));
% 		alphamask = double(~mask); alphamask(alphamask == 1) = 0.5;
% 		set(h_mask, 'AlphaData', alphamask);
		drawnow;
	
		disp(sprintf('L = %0.1f, D = %01.1e, npts = %d', L(kk) - L_res/2, densities(kk), length(valid_pixels)));
	end
	
	
% 	imagesc(double(mask)); axis xy square; colormap gray;
end

if DEBUG
	if exist('h_mask', 'var'), delete(h_mask); end
end


plasma_density = densities;

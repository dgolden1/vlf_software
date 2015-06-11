function [intensities, MSEs] = ecg_get_intensities_from_pix(pixels, h_img)
% intensity = ecg_get_intensities_from_pix(pixels, h_img)
% Get intensities for given pixels on the image
% 
% INPUTS
% pixels: nx2 array of pixels (x, then y)
% h_img: handle to image, or matrix of RGB values
% 
% OUTPUTS
% intensities: pixel intensities

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

%% Setup
error(nargchk(2, 3, nargin));
pixels = round(pixels);

% Values representing the limits of the colorbar on the spectrogram (set in
% emission_char_gui_OpeningFcn)
global spec_db_low spec_db_high

if matlabpool('size') == 0
	disp('ecg_get_intensities_from_pix warning: parallel mode disabled');
end

%% Get intensities
num_pix = size(pixels, 1);
intensities = zeros(num_pix, 1);
MSEs = zeros(num_pix, 1);

% h_img can be the image handle, or the image values
if numel(h_img) == 1 && ishandle(h_img)
	img_cdata = get(h_img, 'CData');
else
	img_cdata = h_img;
end

px = pixels(:, 1);
py = pixels(:, 2);
parfor kk = 1:num_pix
	r = img_cdata(py(kk), px(kk), 1); % 'pixels' has x as the first column, but img_cdata has y as the first dimension
	g = img_cdata(py(kk), px(kk), 2);
	b = img_cdata(py(kk), px(kk), 3);
	[intensities(kk), MSEs(kk)] = ecg_get_intensity_from_rgb(r, g, b, spec_db_low, spec_db_high);
end

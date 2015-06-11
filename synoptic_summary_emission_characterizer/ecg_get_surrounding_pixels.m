function pixels = ecg_get_surrounding_pixels(pixel, radius)
% pixels = ecg_get_surrounding_pixels(pixel, radius)
% Get all pixels within a given radius of pixel
% 
% Does NOT do checking to determine whether the pixels are inside the
% spectrogram box
% 
% INPUTS
% pixel: center pixel
% radius: radius within which to gather additional pixels
% 
% OUTPUTS
% pixels: nx2 array of n x-y pixel pairs

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

error(nargchk(2, 2, nargin));

pixel = round(pixel);

% Assemble all pixels within a square with given radius
x_vals = (pixel(1)-radius : pixel(1)+radius);
y_vals = (pixel(2)-radius : pixel(2)+radius);

% Ditch values in the square that are not within a circle with the given
% radius
[yy_vals, xx_vals] = meshgrid(y_vals, x_vals);
i_valid = sqrt((xx_vals - pixel(1)).^2 + (yy_vals - pixel(2)).^2) <= radius;
xx_vec = xx_vals(i_valid);
yy_vec = yy_vals(i_valid);

pixels = [xx_vec yy_vec];

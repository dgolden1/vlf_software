function ecg_blink_pixels(pixels, h_img)
% ecg_blink_pixels(pixels, h_img)
% Function to highlight given pixels on an image
% 
% INPUTS:
% pixels: nx2 array of n x-y pixel pairs
% h_img: handle to image

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

error(nargchk(2, 2, nargin));

x = pixels(:,1);
y = pixels(:,2);

h_ax = get(h_img, 'Parent');
hold on;

plot(x, y, 'r.');

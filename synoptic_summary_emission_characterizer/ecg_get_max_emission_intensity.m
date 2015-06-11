function [intensity, x_center, y_center, radius] = ecg_get_max_emission_intensity(x_min, x_max, y_min, y_max, h_img)
% [intensity, x_center, y_center, radius] = ecg_get_max_emission_intensity(x_min, x_max, y_min, y_max, h_img)
% Get maximum intensity in a small-area averages sense for a given emission

% By Daniel Golden (dgolden1 at stanford dot edu) December 2007
% $Id$

%% Setup
error(nargchk(5, 5, nargin));

x_min = round(x_min);
x_max = round(x_max);
y_min = round(y_min);
y_max = round(y_max);

x_vec = x_min:x_max;
y_vec = y_min:y_max;

[Y, X] = meshgrid(y_vec, x_vec);
x = X(:);
y = Y(:);

MAX_RADIUS = 10;
radius = min([MAX_RADIUS, x_max-x_min, y_max-y_min]);
if radius < 0
	error('Region contains no pixels');
end


%% Find intensities, averaged over a circle with given radius
% Life is easier if we use a square intsead of a circle for averaging

intensities_full = ecg_get_intensities_from_pix([x y], h_img);
i_max = size(X, 1);
j_max = size(X, 2);

% Turn intensities_full into an image, with x values down the rows
intensities_full = reshape(intensities_full, i_max, j_max);
[jj, ii] = meshgrid(1:j_max, 1:i_max);

% The matrix of average intensities
intensities_avg = zeros(size(intensities_full));

for i = 1:i_max
	for j = 1:j_max
		indices = sqrt((jj - j).^2 + (ii - i).^2) <= radius;
		intensities = intensities_full(indices);
		intensities_avg(i, j) = ecg_intensity_avg_fcn(intensities);

% 		% DEBUG
% 		if intensities_avg(i, j) == max(intensities_avg(:))
% 			figure(2);
% 			img = imagesc(intensities_full.');
% 			colorbar;
% 			title('intensities full');
% 			CData = get(img, 'CData');
% 			CData(~indices.') = min(min(CData));
% 			set(img, 'CData', CData);
% 			caxis([35 55]);
% 			figure(3);
% 			img = imagesc(intensities_avg.');
% 			colorbar;
% 			title('intensities avg');
% 			pause;
% 		end
	end
end


%% Find the maximum intensity
[r, c] = find(intensities_avg == max(max(intensities_avg)), 1);
intensity = max(max(intensities_avg));
x_center = x_vec(r);
y_center = y_vec(c);

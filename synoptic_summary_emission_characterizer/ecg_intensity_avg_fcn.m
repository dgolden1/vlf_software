function intensity = ecg_intensity_avg_fcn(intensities)
% intensity = ecg_intensity_avg_fcn(intensities)
% Get weighted average of pixel intensities

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

% NaN values represent invalid pixels that could not be reliably mapped to
% the Jet color map
intensities(isnan(intensities)) = [];

if isempty(intensities)
	error('ecg_intensity_avg_fcn:NoValidColoredPixels', 'No validly-colored pixels selected');
end

avg_type = 'true_avg';

switch avg_type
	case 'true_avg', intensity = mean(intensities);
	case 'rms_avg', intensity = sqrt(mean(intensities.^2));
end

function [intensity, mse] = ecg_get_intensity_from_rgb(r, g, b, db_low, db_high)
% intensity = ecg_get_intensity_from_rgb(r, g, b);
% Return intensity, in uncalibrated dB, from a given pixel's RGB values
% 
% INPUTS
% r: red level
% g: green level
% b: blue level
% db_low: low end of the colorbar (default 35 dB)
% db_high: high end of the colorbar (default 80 dB)
% 
% OUTPUTS
% intensity: best fit to Jet colormap for intensity in uncalibrated dB
% mse: mean square error for fit to colormap (large errors may indicate
% invalid pixels)

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

%% Default arguments
% Values representing the limits of the colorbar on the spectrogram
global spec_db_low spec_db_high

if ~exist('db_low', 'var') || isempty(db_low), db_low = spec_db_low; end
if ~exist('db_high', 'var') || isempty(db_high), db_high = spec_db_high; end

r = double(r);
g = double(g);
b = double(b);

%% Get Jet colormap
persistent J
if isempty(J)
	J = ecg_get_jet;
	J = J*255; % Scale J to be from 0 to 255
end
m = max(size(J));

%% Find the closest fit to the jet color scale
% NEW WAY (minimum mean square error)
MSE = sqrt((J(:,1) - r).^2 + (J(:,2) - g).^2 + (J(:,3) - b).^2);

db_index = find(MSE == min(MSE));
if length(db_index) ~= 1
	error('ecg_get_intensity_from_rgb:MultipleValidDBLevels', 'More than one valid dB value found for pixel');
end
% OLD WAY (least squares approach... which doesn't work because it's not
% constrained to be only one dB value)
% db_index_vec = (J.')\double([r g b].');
% db_index = db_index_vec(db_index_vec == max(db_index_vec));
% assert(length(db_index) == 1);

%% Throw out bad MSE values (maybe a white or black pixel)
if MSE(db_index) > 75
	intensity = nan;
	mse = MSE(db_index);
	return;
end

%% Convert to dB
intensity = (db_index - 1)/(m-1)*(db_high - db_low) + db_low;
mse = MSE(db_index);

function intensity = ecg_get_intensity_from_pix(pixels, h_img, radius)
% intensity = ecg_get_intensity_from_pix(pixels, h_img, radius)
% Get weighted average of intensities from given pixels on the image
% 
% INPUTS
% pixels: nx2 array of pixels
% h_img: handle to image
% radius: radius of circle over which to average pixels
% 
% OUTPUTS
% intensity: mean intensity

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

%% Argument wrangling
error(nargchk(2, 3, nargin));
pixels = round(pixels);

if ~exist('radius', 'var'), radius = 5; end

%% Get spectrogram limits
% Edges of spectrogram (set in emission_char_gui_OpeningFcn)
global spec_x_min spec_x_max spec_y_min spec_y_max
assert(~isempty(spec_x_min))

% Discard pixels that are out of range of the spectrogram
pixels(pixels(:,1) <= spec_x_min | pixels(:,1) >= spec_x_max | ...
	pixels(:,2) <= spec_y_min | pixels(:,2) >= spec_y_max, :) = [];

if isempty(pixels)
	error('ecg_get_intensity_from_pix:NoValidPixelsInSelection', 'No valid pixels in selection');
end

%% Get mean intensity
[intensities, MSEs] = ecg_get_intensities_from_pix(pixels, h_img);

% Discard errored pixels
intensities(isnan(intensities)) = [];
MSEs(isnan(MSEs)) = [];

if isempty(intensities)
	error('ecg_get_intensity_from_pix:NoValidPixelsInSelection', 'No valid pixels in selection');
end

intensity = ecg_intensity_avg_fcn(intensities);

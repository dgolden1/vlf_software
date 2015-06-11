function [hour, minute, freq] = ecg_pix_to_param(varargin)
% [hour, minute, freq] = ecg_pix_to_param(x, y)
%   or
% [hour, minute, freq] = ecg_pix_to_param([x y])
% Take in a pair of pixels from a 24-hour synoptic spectrogram and return
% the time and frequency

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

%% Argument check
if nargin == 1 && length(varargin{1}) == 2
	x = varargin{1}(1);
	y = varargin{1}(2);
elseif nargin == 2
	x = varargin{1};
	y = varargin{2};
else
	error('Wrong number of input arguments')
end


%% Edges of spectrogram (set in emission_char_gui_OpeningFcn)
global spec_x_min spec_x_max spec_y_min spec_y_max
assert(~isempty(spec_x_min))


%% Map pixel values to frequency and time values

% If x or y is out of range, map it to the edge of the axis
x = max([min([x spec_x_max]) spec_x_min]);
y = max([min([y spec_y_max]) spec_y_min]);

% Low and high frequency and time values for the spectrogram
f_low = 300;
f_high = 10e3;
t_low = 5/60/24;
t_high = (23 + 59/60)/24;

time = (x - spec_x_min)/(spec_x_max - spec_x_min)*(t_high - t_low) + t_low; % Lower times are lower x-values
freq = f_high - (y - spec_y_min)/(spec_y_max - spec_y_min)*(f_high - f_low); % Lower frequencies are HIGHER y-values (y starts at the top)

hour = floor(time*24);
minute = floor((time*24-hour)*60);

minround = 5;
minute = floor(minute/minround)*minround;

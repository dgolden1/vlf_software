function [x, y] = ecg_param_to_pix(varargin)
% [x, y] = ecg_param_to_pix(hour, minute, freq, end_time_str)
%  or
% [x, y] = ecg_param_to_pix(decimal_hour, freq, end_time_str)
% Take in time and frequency and convert to pixels on the spectrogram
% 
% If end_time_str exists and is 'end', then if hour is 0, it will be
% interpreted as 24

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

%% Argument checking
bIsEndTime = false;
if nargin == 2 || (nargin == 3 && ischar(varargin{3}))
	hour = varargin{1};
	freq = varargin{2};
	
	time = hour/24;

	if nargin == 3 && strcmp(varargin{3}, 'end') && time == 0
		time = 1;
	end
	
elseif nargin == 3 || (nargin == 4 && ischar(varargin{4}))
	hour = varargin{1};
	minute = varargin{2};
	freq = varargin{3};

	time = (hour + minute/60)/24;
	
	if nargin == 4 && strcmp(varargin{4}, 'end') && time == 0
		time = 1;
	end
else
	error('Wrong number of input arguments');
end


%% Edges of spectrogram (set in emission_char_gui_OpeningFcn)
global spec_x_min spec_x_max spec_y_min spec_y_max
assert(~isempty(spec_x_min))

% Low and high frequency and time values for the spectrogram
f_low = 0.3;
f_high = 10;
t_low = 0;
t_high = 1;

x = (time - t_low)/(t_high - t_low)*(spec_x_max - spec_x_min) + spec_x_min;
y = spec_y_max - (freq - f_low)/(f_high - f_low)*(spec_y_max - spec_y_min);

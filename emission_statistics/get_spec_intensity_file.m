function [spec_intensity, time, freq] = get_spec_intensity_file(spec_filename)
% spec_intensity = get_spec_intensity_file(spec_filename)
% Returns an intensity matrix for a given 24-hour spectrogram PNG
% 
% Returned time is UTC, frequency in kHz

% By Daniel Golden (dgolden1 at stanford dot edu) May 2008
% $Id$

%% Setup
error(nargchk(1, 1, nargin));

SPEC_PATH = fileparts(spec_filename);

% Use functions from the synoptic summary emission characterizer to convert
% from RGB pixel values to intensities
addpath('../synoptic_summary_emission_characterizer');

% Set global variables for the edges of the spectrogram
global spec_x_min spec_x_max spec_y_min spec_y_max
ecg_set_spec_globals;

spec_x_length = spec_x_max - spec_x_min + 1;
spec_y_length = spec_y_max - spec_y_min + 1;

%% DEBUG
time = linspace(0, 1, spec_x_length);
freq = fliplr(linspace(0.3, 10, spec_y_length));

%% Convert spectrogram RGB values to numerical values
num_pix = spec_x_length*spec_y_length;
pixels = zeros(num_pix, 2);

% If we already have an intensity file for this spectrogram, read the
% intensities off of that
intensity_filename = fullfile(SPEC_PATH, 'spec_amps', sprintf('palmer_%s.mat', datestr(event.start_datenum, 'yyyymmdd')));
if exist(intensity_filename, 'file')
	load(intensity_filename, 'spec_amp');
	spec_intensity = spec_amp;
% Otherwise, we need to get the intensities manually
else

	% Create the array of pixels that we want to sample for this emission
	emission_mask = false(size(cum_spec));
	count = 1;
	for xx = spec_em_x_min:spec_em_x_max
		for yy = spec_em_y_min:spec_em_y_max
			pixels(count, :) = [yy, xx];
			emission_mask(yy - spec_y_min + 1, xx - spec_x_min + 1) = true;
			count = count + 1;
		end
	end

	% Load this emission's spectrogram
	img_filename = sprintf('palmer_%s.png', datestr(event.start_datenum, 'yyyymmdd'));
	img = imread(fullfile(SPEC_PATH, img_filename));

	% Get the intensities
	x = spec_x_min:spec_x_max;
	y = spex_y_min:spec_y_max;
	[X, Y] = meshgrid(x, y);
	x = X(:);
	y = Y(:);
	pixels = [x y];

	intensities = ecg_get_intensities_from_pix(pixels, img);
	intensities(isnan(intensities)) = 0; % Where we couldn't match a value, just call it 0
end

%% Plot spectrogram

time = linspace(0, 1, spec_x_length);
frequency = fliplr(linspace(0.3, 10, spec_y_length));

% Normalize
cum_spec = cum_spec/max(max(cum_spec));

% Remove horizontal separator bars, which occur in the png specgrograms at
s_bar_png = [69:8:85 92:8:284 291:8:499 506:8:714 721:8:825];
% And in the cumulative spectrogam at
s_bar = s_bar_png - 68;

for kk = 1:length(s_bar)
	X = mod([s_bar(kk)-1, s_bar(kk)+1] - 1, spec_x_length) + 1;
	Y = 1:spec_y_length;
	Z = cum_spec(Y, X);
	XI = s_bar(kk);
	YI = Y;
% 	ZI = interp2(X, Y, Z, XI, YI);
	ZI = interp2([1 3], Y, Z, 2, YI);
	cum_spec(1:spec_y_length, s_bar(kk)) = ZI;
end


% Shift to get spectrogram in terms of Palmer LT
time_pivot_i = find(time >= mod(-PALMER_T_OFFSET, 1), 1, 'first');
cum_spec = [cum_spec(:, time_pivot_i:end) cum_spec(:, 1:time_pivot_i-1)];

figure(gcf);
imagesc(time, frequency, cum_spec);
axis xy;
datetick('x', 'keeplimits');

xlabel('Hour (Palmer LT)');
ylabel('Frequency (kHz)');
% title(sprintf('VLF emission events (%s) 2003', strrep(em_type, '_', '\_')));

%% Add L shell 1/2 fHeq lines
add_fh_lines_to_spec(gca);

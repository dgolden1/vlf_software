function [time, frequency, em_intensity] = grab_emission_intensity(event)

%% Setup
SPEC_DB_MIN = -20; % Assumes calibrated spectrograms
SPEC_PATH = '/home/dgolden/vlf/case_studies/chorus_2003/synoptic_summary_plots/calibrated';

%% Spectrogram sizes (including decoration)
global spec_x_min spec_x_max spec_y_min spec_y_max
ecg_set_spec_globals;

spec_x_length = spec_x_max - spec_x_min + 1;
spec_y_length = spec_y_max - spec_y_min + 1;

cum_spec = zeros(spec_y_length, spec_x_length);

%% Get information about event
start_hour = (event.start_datenum - floor(event.start_datenum))*24;
end_hour = (event.end_datenum - floor(event.end_datenum))*24;
if end_hour == 0, end_hour = 24; end

[spec_em_x_min, spec_em_y_min] = ecg_param_to_pix(start_hour, event.f_uc);
[spec_em_x_max, spec_em_y_max] = ecg_param_to_pix(end_hour, event.f_lc);
spec_em_x_min = max(round(spec_em_x_min), spec_x_min);
spec_em_x_max = min(round(spec_em_x_max), spec_x_max);
spec_em_y_min = max(round(spec_em_y_min), spec_y_min);
spec_em_y_max = min(round(spec_em_y_max), spec_y_max);

em_x_length = spec_em_x_max - spec_em_x_min + 1;
em_y_length = spec_em_y_max - spec_em_y_min + 1;

num_pix = em_x_length*em_y_length;
pixels = zeros(num_pix, 2);

%% Event coordinates in units of intensity file
% The spec_amp file doesn't have window decorations
amp_em_x_min = spec_em_x_min - spec_x_min + 1;
amp_em_x_max = spec_em_x_max - spec_x_min + 1;
amp_em_y_min = spec_em_y_min - spec_y_min + 1;
amp_em_y_max = spec_em_y_max - spec_y_min + 1;

%% Load intensity file
% Save some time if we load the same spec_amp more than once in a row
persistent intensity_filename_last spec_amp_last

intensity_filename = fullfile(SPEC_PATH, 'spec_amps', sprintf('palmer_%s.mat', datestr(event.start_datenum, 'yyyymmdd')));
if ~strcmp(intensity_filename, intensity_filename_last)
	if ~exist(intensity_filename, 'file')
		error('Missing intensity file: %s', intensity_filename);
	end

	load(intensity_filename, 'spec_amp');

	% Remove vertical separator bars, which occur in the png spectrograms at
	s_bar_png = [69:8:85 92:8:292 299:8:507 514:8:714 721:8:825];
	% And in the cumulative spectrogam at
	s_bar = s_bar_png - 68;

	s_bar = s_bar(2:end) - 1;

	for kk = 1:length(s_bar)
		X = mod([s_bar(kk)-1, s_bar(kk)+1] - 1, spec_x_length) + 1;
		Y = 1:spec_y_length;
		Z = spec_amp(Y, X);
		XI = s_bar(kk);
		YI = Y;
		ZI = interp2([1 3], Y, Z, 2, YI);
		spec_amp(1:spec_y_length, s_bar(kk)) = ZI;
	end
	
	intensity_filename_last = intensity_filename;
	spec_amp_last = spec_amp;
else
	spec_amp = spec_amp_last;
end

%% Create the array of pixels that we want to sample for this emission
emission_mask = false(size(cum_spec));
count = 1;
for xx = amp_em_x_min:amp_em_x_max
	for yy = amp_em_y_min:amp_em_y_max
		pixels(count, :) = [yy, xx];
		emission_mask(yy, xx) = true;
		count = count + 1;
	end
end

em_intensity = spec_amp(emission_mask);
em_intensity = reshape(em_intensity, em_y_length, em_x_length);

%% Outputs
time = (0:spec_x_length-1)/spec_x_length;
frequency = fliplr(linspace(0.3, 10, spec_y_length));

time = time(amp_em_x_min:amp_em_x_max);
frequency = frequency(amp_em_y_min:amp_em_y_max);

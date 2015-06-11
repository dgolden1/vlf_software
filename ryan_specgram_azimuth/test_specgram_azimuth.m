function [F, T, angles_plot] = test_specgram_azimuth(file_datenum)
% test_specgram_azimuth(file_datenum)
% 
% Function to test out Ryan's plot_specgram_azimuth_2ch function
% 
% e.g., test_specgram_azimuth(datenum([2003 01 17 00 20 00]));

% By Daniel Golden (dgolden1 at stanford dot edu) October 2009
% $Id$

%% Setup
warning('off','MATLAB:colorbar:DeprecatedV6Argument');

b_only_ns = false; % Use only 1-channel cleaned data

%% Load raw data from Alexandria and decimate
if b_only_ns
	data_file = fullfile(scottdataroot, 'user_data', 'dgolden', 'palmer_bb_cleaned', '2003', ...
		datestr(file_datenum, 'mm_dd'), ...
		[datestr(file_datenum, 'PA_yyyy_mm_ddTHHMM_05_002') '_cleaned.mat']);

	disp(sprintf('Running on %s', data_file));

	BB = load(data_file);
	fs_dec = BB.Fs;
	assert(fs_dec == 20e3);
	sitename = strrep(char(BB.station_name(:).'), '_', '');
	sitename = sitename(isstrprop(sitename, 'alphanum')); % Get rid of weird characters

	data_ns = BB.data;
	data_ew = zeros(size(data_ns));

	start_offset = 0; % sec
else
	start_offset = 5; % sec
	segment_length = 10; % sec

	% data_file = '/media/vlf-alexandria-array/raw_data/broadband/palmer/2003/01_27/BB035000.mat';
	data_file = fullfile(scottdataroot, 'awesome', 'broadband', 'palmer', ...
		datestr(file_datenum, 'yyyy'), datestr(file_datenum, 'mm_dd'), ...
		[datestr(file_datenum, 'BBHHMMSS') '.mat']);

	disp(sprintf('Running on %s', data_file));

	BB = matLoadExcept(data_file, 'data');
	if ~isfield(BB, 'channel_sampling_freq')
		error('Error: interleaved data only!');
	end
	fs = BB.channel_sampling_freq(1);
	sitename = BB.siteName;

	data = matGetVariable(data_file, 'data', segment_length*2*fs, start_offset*2*fs);

	assert(fs == 100e3);
	fs_dec = 20e3;
	data_ns = decimate(data(1:2:end), 5);
	data_ns = data_ns - mean(data_ns); % Remove DC
	data_ew = decimate(data(2:2:end), 5);
	data_ew = data_ew - mean(data_ew);
end

%% Compile data struct
bb_datenum = get_bb_fname_datenum(data_file, 'false') + start_offset/86400;
bb_datevec = datevec(bb_datenum);

data_struct = struct('data', [data_ns(:) data_ew(:)].', 'Fs', fs_dec, ...
	'startTime', bb_datevec, 'station_name', sitename, 'units', 'raw');

data_title = sprintf('Palmer %s', datestr(bb_datenum, 31));

%% Plot regular spectrogram
nfft = 256;
window = hamming(nfft);
noverlap = length(window)/2;

figure;
subplot(2, 1, 1);
spectrogram_dan(data_ns, window, noverlap, nfft, fs_dec);
caxis([30 80]);
c = colorbar;
ylabel('Hz');
title([data_title ' N/S']);
ylabel(colorbar, 'uncal dB');

subplot(2, 1, 2);
spectrogram_dan(data_ew, window, noverlap, nfft, fs_dec);
caxis([35 80]);
colorbar;
ylabel('Hz');
title([data_title ' E/W']);
ylabel(colorbar, 'uncal dB');

xlabel('Sec');
increase_font(gcf, 14);

%% Plot azimuth spectrogram
% dB offset = -45
db_thresh = 45;

z = data_ns + j*data_ew;

[mags,ecc,angles,diff_delays,diff_delays_1c,F,T] = specgram_azimuth(z, nfft, fs_dec, window, noverlap);

figure;

s(1) = subplot(1, 2, 1);

db_min = -20;
db_max = 25;
% plot_specgram_azimuth_2ch(data_struct, 1024, db_min, db_max, db_thresh,
% gcf, 2);

angles_plot = mod180(angles*180/pi);
angles_plot(db(mags) < db_thresh) = -91;

imagesc(T, F, angles_plot); axis xy;

grid on;
colormap([1,1,1;hsv(180)]);
caxis([-90 90]);
freezeColors;
c = colorbar('v6');
ylabel(c, '\theta (deg)');
freezeColors(c);
xlabel('Sec');
ylabel('Freq');

title([data_title ' azimuth']);

%% Plot azimuth distribution
freq_delta = 500; % Hz
freq_centers = unique(round(F/freq_delta)*freq_delta);
% freq_centers = freq_centers + max(0, freq_delta/2 - min(freq_centers)); % Make sure the bottom bin is full width

az_bin_size = 5; % Degrees

azimuths = (-90 + az_bin_size/2):az_bin_size:(90 - az_bin_size/2);
az_distr = zeros(length(freq_centers), length(azimuths));
for kk = 1:length(freq_centers)
	distr_angles = flatten(angles_plot(F > freq_centers(kk) - freq_delta/2 & F <= freq_centers(kk) + freq_delta/2, :));
	distr_mags = flatten(mags(F > freq_centers(kk) - freq_delta/2 & F <= freq_centers(kk) + freq_delta/2, :));
	distr_angles(db(distr_mags) < db_thresh) = [];
	distr_mags(db(distr_mags) < db_thresh) = [];
	
% 	az_distr(kk, :) = hist(distr_angles, azimuths);
	distr_angles = nearest(distr_angles, azimuths, 'val');
	az_distr(kk, :) = accumarray(1 + (distr_angles - min(azimuths))/az_bin_size, db(distr_mags), [length(azimuths) 1]);
end

s(2) = subplot(1, 2, 2);
imagesc(azimuths, freq_centers, az_distr); axis xy;
colormap(jet);
freezeColors;
xlabel('\theta (deg)');
ylabel('Freq (Hz)');
c = colorbar('v6');
ylabel(c, 'Num pixels * pixel mag (uncal dB)');
freezeColors(c);
title([data_title ' weighted azimuth distribution']);

increase_font(gcf, 14);

linkaxes(s(1:2), 'y');

figure_squish(gcf, 0.5, 1);
pos = get(gcf, 'position');
set(gcf, 'position', [0 pos(2)-100 pos(3:4)]);

%% Plot d-delay-o-gram
figure;
s(3) = subplot(1, 2, 1);

% diff_delays = diff_delays*1e3; % Convert from sec to msec
% max_delay_ampl = 1/(fs_dec/nfft)^2/2 * 1e3;
% delays_plot = diff_delays;
% delays_plot(db(mags) < db_thresh) = -max_delay_ampl*51/50;
% 
% imagesc(T, F, delays_plot); axis xy;

diff_delays_1c = diff_delays_1c*1e3; % Convert from sec to msec
max_delay_ampl = 1/(fs_dec/nfft)^2/2 * 1e3;
delays_plot_1c = diff_delays_1c;
delays_plot_1c(db(mags) < db_thresh) = -max_delay_ampl*51/50;

imagesc(T, F, delays_plot_1c); axis xy;

caxis([-max_delay_ampl*51/50 max_delay_ampl]);
colormap([.8 .8 .8; hotcold(100)]);
c = colorbar('v6');
freezeColors(c);
ylabel(c, 'diff delay (msec/Hz)'); 
freezeColors;

xlabel('Sec');
ylabel('Hz');

if b_only_ns
	addl_title = ' - N/S channel only';
else
	addl_title = '';
end
title([data_title ' d-delay-o-gram' addl_title]);

increase_font(gcf, 14);

linkaxes(s([1 3]));

%% Plot delay-o-gram distribution
freq_delta = 500; % Hz
freq_centers = unique(round(F/freq_delta)*freq_delta);
% freq_centers = freq_centers + max(0, freq_delta/2 - min(freq_centers)); % Make sure the bottom bin is full width

nbins = 50;
dd_bin_size = max_delay_ampl/nbins;

dd_vals = (dd_bin_size/2):dd_bin_size:(max_delay_ampl - dd_bin_size/2);
dd_distr = zeros(length(freq_centers), length(dd_vals));
for kk = 1:length(freq_centers)
	distr_dds = abs(flatten(diff_delays_1c(F > freq_centers(kk) - freq_delta/2 & F <= freq_centers(kk) + freq_delta/2, :)));
	distr_mags = flatten(mags(F > freq_centers(kk) - freq_delta/2 & F <= freq_centers(kk) + freq_delta/2, :));
	distr_dds(db(distr_mags) < db_thresh) = [];
	distr_mags(db(distr_mags) < db_thresh) = [];
	
	distr_dds = nearest(distr_dds, dd_vals, 'val');
	dd_distr(kk, :) = accumarray(round(1 + (distr_dds - min(dd_vals))/dd_bin_size), db(distr_mags), [length(dd_vals) 1]);
end

s(4) = subplot(1, 2, 2);
imagesc(dd_vals, freq_centers, dd_distr); axis xy;
colormap(jet);
q = quantile(dd_distr(:), [0.1 0.99]);
caxis(q);
freezeColors;
c = colorbar('v6');
ylabel(c, 'Num pixels * pixel mag (uncal dB)');
freezeColors(c);
xlabel('diff delay (msec/Hz)');
% plot(centroid(dd_vals.', dd_distr.'), freq_centers, 'linewidth', 2);
% grid on;
% xlabel('Mean weighted diff delay (msec/Hz)');
ylabel('Freq (Hz)');
title([data_title ' weighted differential delay distribution']);

increase_font(gcf, 14);

linkaxes(s(3:4), 'y');

figure_squish(gcf, 0.5, 1);
pos = get(gcf, 'position');
set(gcf, 'position', [0 pos(2)-200 pos(3:4)]);

disp('');

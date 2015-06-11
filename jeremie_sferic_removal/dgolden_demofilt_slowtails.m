% Test sferic removal using real data on slowtails

% By Daniel Golden (dgolden1 at stanford dot edu) May 2009
% $Id$

%% Setup
close all;
clear;

% data_filename = '/media/vlf-alexandria-array/data_products/palmer_bb_2003_cleaned/01_13/PA_2003_01_13T0350_05_002_cleaned.mat';
data_filename = '/media/vlf-alexandria-array/data_products/palmer_bb_2003_cleaned/02_02/PA_2003_02_02T2135_05_002_cleaned.mat';
output_dir = '~/temp/';

%% Parallel
PARALLEL = true;

if ~PARALLEL
        warning('Parallel mode disabled!');
end

poolsize = matlabpool('size');
if PARALLEL && poolsize == 0
        matlabpool('open');
end
if ~PARALLEL && poolsize ~= 0
        matlabpool('close');
end

%% Load data
df = load(data_filename);
fs = 2e3;
data_1k = decimate(df.data, df.Fs/fs);
data_1k = data_1k(:);

t = (0:length(data_1k)-1)/fs;

bb_datenum = get_bb_fname_datenum(data_filename, false);

%% Spectrogram of original data
nfft = 128;
window = 128;
noverlap = 64;

figure;
spectrogram_cal(data_1k, window, noverlap, nfft, fs, 'palmer', 2003);
title(sprintf('Original: Palmer %s', datestr(bb_datenum, 31)));

%% Eliminate impulses
pulse_width = 40;
thresh = 20;

t_start = now;
b_slowtail_filter = false;
imp_locs = find_impulse_locs(data_1k, pulse_width, thresh, fs, b_slowtail_filter);
data_fixed = remove_impulses(data_1k, imp_locs, 100, 100, pulse_width);
disp(sprintf('Pass 1: cleaned %d impulses (threshold=%d) in %s', length(imp_locs), ...
  thresh, time_elapsed(t_start, now)));

t_start = now;
thresh = thresh/2;
imp_locs = find_impulse_locs(data_fixed, pulse_width, thresh, fs, b_slowtail_filter);
data_fixed = remove_impulses(data_fixed, imp_locs, 100, 100, pulse_width);
t_total = (now - t_start)*1440; % Minutes
disp(sprintf('Pass 2: cleaned %d impulses (threshold=%d) in %s', length(imp_locs), ...
  thresh, time_elapsed(t_start, now)));

%% Spectrogram of corrected data
figure
spectrogram_cal(data_fixed, window, noverlap, nfft, fs, 'palmer', 2003);
title(sprintf('Cleaned: Palmer %s', datestr(bb_datenum, 31)));

%% Time domain plot of data before and after
figure
plot(t, data_1k, t, data_fixed, 'LineWidth', 2);
% plot(1:length(data), data, 1:length(data), data_fixed, 'LineWidth', 2);
grid on;
xlabel('Time (sec)');
ylabel('Amplitude (uncal)');
legend('Original', 'Fixed', 'Location', 'Best');

%% Write output data
% if exist('output_dir', 'var') && ~isempty(output_dir) && exist(output_dir, 'dir')
%   [pathstr, name, ext] = fileparts(data_filename);
%   output_filename = fullfile(output_dir, [name '_cleaned' ext]);
% 
%   write_twochannel_data(output_filename, df, data_fixed);
%   disp(sprintf('Wrote %s', output_filename));
% elseif exist('output_dir', 'var') && ~isempty(output_dir) 
%   error('%s does not exist!', output_dir);
% end

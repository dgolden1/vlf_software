% Test sferic removal using real data

% By Daniel Golden (dgolden1 at stanford dot edu) May 2009
% $Id$

%% Setup
close all;
clear;

data_filename = '/home/dgolden/vlf/vlf_software/dgolden/sferic_removal/PA010415110505_002.mat';
output_dir = '/home/dgolden/temp';
% data_filename = '/home/dgolden1/input/uncleaned/hiss_PA030126043505_002_ss.mat';
% output_dir = '';

b_plot = true;
s = []; % Axes handles for linkaxes

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
data = decimate(df.data, 5);
data = data - mean(data);
fs = df.Fs/5;

% reduce data length
% data = data(1:1*fs);

t = (0:length(data)-1)/fs;

%% Spectrogram of original data
if b_plot
  % window = 32;
  % noverlap = 16;
  % nfft = 128;
  window = 256;
  noverlap = 128;
  nfft = 256;

  h_spec = figure;
  s(end+1) = subplot(2, 1, 1);
  spectrogram_dan(data, window, noverlap, nfft, fs);
  caxis([15 70]);
  title('Original');
end

%% Eliminate impulses
pulse_width = 40;
thresh = 20;

t_start = now;
b_slowtail_filter = true;
imp_locs = find_impulse_locs(data, pulse_width, thresh, fs, b_slowtail_filter);
data_fixed = remove_impulses(data, imp_locs, 100, 100, pulse_width);
t_total = (now - t_start)*1440; % Minutes
disp(sprintf('Pass 1: cleaned %d impulses (threshold=%d) in %d min, %0.0f sec', length(imp_locs), ...
  thresh, floor(t_total), fpart(t_total)*60));

% t_start = now;
% thresh = thresh/2;
% imp_locs = find_impulse_locs(data_fixed, pulse_width, thresh, fs, b_slowtail_filter);
% data_fixed = remove_impulses(data_fixed, imp_locs, 100, 100, pulse_width);
% t_total = (now - t_start)*1440; % Minutes
% disp(sprintf('Pass 2: cleaned %d impulses (threshold=%d) in %d min, %0.0f sec', length(imp_locs), ...
%   thresh, floor(t_total), fpart(t_total)*60));

% t_start = now;
% thresh = thresh/2;
% imp_locs = find_impulse_locs(data_fixed, pulse_width, thresh);
% data_fixed = remove_impulses(data_fixed, imp_locs, 100, 100, pulse_width);
% t_total = (now - t_start)*1440; % Minutes
% disp(sprintf('Pass 3: cleaned %d impulses (threshold=%d) in %d min, %0.0f sec', length(imp_locs), ...
%   thresh, floor(t_total), fpart(t_total)*60));

%% Spectrogram of corrected data
if b_plot
  figure(h_spec)
  s(end+1) = subplot(2, 1, 2);
  spectrogram_dan(data_fixed, window, noverlap, nfft, fs);
  caxis([15 70]);
  title('Fixed');
end

%% Time domain plot of data before and after
if b_plot
  figure
  plot(t, data, t, data_fixed);
  % plot(1:length(data), data, 1:length(data), data_fixed, 'LineWidth', 2);
  s(end+1) = gca;
  grid on;
  xlabel('Time (sec)');
  ylabel('Amplitude (uncal)');
  legend('Original', 'Fixed', 'Location', 'Best');
end

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

%% Link axes
if b_plot
  linkaxes(s, 'x');
end

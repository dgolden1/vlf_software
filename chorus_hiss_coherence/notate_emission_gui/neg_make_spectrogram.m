function [h_ax, file_datenum] = neg_make_spectrogram(filename)
% file_datenum = neg_make_spectrogram(filename)
% Make the spectrogram in figure 1

% By Daniel Golden (dgolden1 at stanford dot edu) June 2009
% $Id$

%% Setup
data = matGetVariable(filename, 'data');
fs = matGetVariable(filename, 'Fs');
file_datenum = get_bb_fname_datenum(filename, false);

% nfft = 1024;
% window = 512;
% noverlap = 256;
nfft = 512;
window = 512;
noverlap = 0;

%% Make spectrogram
[S, F, T] = spectrogram_dan(data, hann(window), noverlap, nfft, fs);

% % Subsample the spectrogram to save memory
% S = S(1:2:end, 1:2:end);
% F = F(1:2:end);
% T = T(1:2:end);

[B_cal, unit_str] = palmer_cal_2003(S, F, window, fs/2);

sfigure(1);
clf;
% figure_squish(1);
imagesc(T, F/1e3, B_cal);
axis xy;
title(sprintf('Palmer Station  %s', datestr(file_datenum, 'yyyy mmm dd')));
xlabel(sprintf('Time (seconds after %s UTC)', datestr(file_datenum, 'HH:MM:SS')));
ylabel('Frequency (kHz)');
caxis([-1 1.25]);
c = colorbar;
set(get(c, 'ylabel'), 'String', unit_str);

increase_font(gcf);

h_ax = gca;

%% Change image dimensions
set(1, 'units', 'inches');
pos = get(1, 'Position');
set(1, 'position', [pos(1) pos(2) 12 4], 'paperpositionmode', 'auto');
posa = get(h_ax, 'Position');
set(h_ax, 'position', [0.07 posa(2) 0.8 posa(4)]);
set(h_ax, 'units', 'inches');
posa_in = get(h_ax, 'outerposition');
set(1, 'paperposition', [0 0 posa_in(3) posa_in(4)+.5]);
set(h_ax, 'units', 'normalized');

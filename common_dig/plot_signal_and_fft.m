function plot_signal_and_fft(x, fs, name_str)
% plot_signal_and_fft(x, fs, name_str)
% Function to plot a time domain signal, its fft, and its modified
% periodogram

% By Daniel Golden (dgolden1 at stanford dot edu) June 2009
% $Id$

t = (0:length(x)-1).'/fs;

if ~exist('name_str', 'var')
	name_str = '';
end

% Remove DC
x = x(:) - mean(x);

nfft = 2^nextpow2(length(x));
X = fft(x.*hamming(length(x)), nfft)/nfft;
f = linspace(-fs/2, fs/2, nfft);

% Set window length to be the next power of two less than 1/8 the length of
% the signal
window = min(2^floor(log2(length(x)/8)), 1024); % 1/8 the signal length, but no more than 1024
[Pxx, w] = pwelch(x, window, window/2, window, fs, 'twosided');

% Why does Welch plot frequencies up to the Nyquist but not negative
% frequencies? I don't know! Reshape the result so that the negative
% frequency part actually has negative frequencies
idx = w > fs/2;
w(idx) = w(idx) - fs;
w = [w(idx); w(~idx)];
Pxx = [Pxx(idx); Pxx(~idx)];

figure;
subplot(3, 1, 1);
plot(t, abs(x));
grid on;
xlabel('Time (sec)');
ylabel('Amplitude');
title(name_str);

s(1) = subplot(3, 1, 2);
plot(f, fftshift(2*log10(abs(X))));
grid on;
ylabel('Log(amplitude squared)');
if all(isreal(x))
	xlim([0 fs/2]);
else
	xlim([-fs/2 fs/2]);
end

s(2) = subplot(3, 1, 3);
plot(w, 10*log10(Pxx), 'LineWidth', 2);
grid on;
xlabel('Frequency (Hz)');
ylabel('dB/Hz');
if all(isreal(x))
	xlim([0 fs/2]);
else
	xlim([-fs/2 fs/2]);
end

linkaxes(s, 'x');
increase_font;

disp('');

function [t, f, spec, s_periodogram, s_mediogram, s_medio_diff, data_cal] = get_data_specs(data_uncal, fs, start_datenum, sitename)
% [t, f, spec, s_periodogram, s_mediogram, s_medio_diff] = get_data_specs(data_uncal, fs, start_datenum, sitename)
% Get various spectral parameter from some data that are used to analyze
% the data
% 
% INPUTS
% data_uncal: UNCALIBRATED data.  This function does the calibration.
% fs: sampling frequency
% start_datenum: start datenum of the data
% sitename: station name from the .mat file (used for calibration)

% By Daniel Golden (dgolden1 at stanford dot edu) April 2011
% $Id$

%% Get calibrated time-domain data
[data_cal, units, cax] = cal_t(data_uncal, fs, sitename, start_datenum);

%% Get the spectral data
% These parameters seem to work pretty well
% m_window = 128;
% m_nfft = 256;
% m_noverlap = 64;

% These are the same as above for 20 kHz data, but extend to arbitrary fs
m_window = 2^nextpow2(fs*0.0064); % Window is at least 6.4 ms long
m_nfft = m_window*2;
m_noverlap = m_window/2;

% The spectrogram, mediogram and periodogram are all created with the same
% parameters
[~, f, t, spec] = spectrogram_dan(data_cal - mean(data_cal), m_window, m_noverlap, m_nfft, fs);
s_mediogram = 10*log10(median(spec, 2));
s_periodogram = 10*log10(mean(spec, 2));

df = diff(f(1:2));

% rate of change of the mediogram per unit frequency (dB/Hz)
s_medio_diff = diff(s_mediogram)/df;

function [B_cal, unit_str, caxis_recommendation] = palmer_cal_2003(B, F, window, maxFreq)
% [B_cal, unit_str, caxis_recommendation] = palmer_cal_2003(B, F, window, maxFreq)
% Calibrate B-field date from 2003
% Input: B (field data, as S output from spectrogram() function)
% Output: B (calibrated; unit_str specifies units, caxis_recommendation is a recommended value for caxis)

% Originally by Maria Spasojevic
% Modified by Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id$

%% Setup
error(nargchk(4, 4, nargin));

warning('This function is obsolete.  Use palmer_cal_2003_t, followed by the \n[~, F, T, P] = spectrogram() function instead. --DIG 2010-02-18');

%%
% LOAD PROPER CALIBRATION
persistent cal
if isempty(cal)
	load('palmerCal_01Nov2003.mat');
end
DF.cal = cal;

% Assumes N/S channel!
interpCal = interp1( cal.f, cal.ns, F );

B_cal = abs(B.*repmat(interpCal, 1, size(B, 2)));

B_cal = sqrt(2)*2*B_cal.^2./sum(hann(window)); % Specgram uses a hann window, spectrogram uses a hamming window (7% difference)!
B_cal = B_cal./(maxFreq*2);
B_cal = 10*log10( B_cal ./ ( 1/100e3 ) );
% unit_str = 'dB wrt 10^{-29} T^2 Hz^{-1}';

% Convert to dB fT/Hz^{1/2}
B_cal = B_cal + 10;
unit_str = 'dB-fT/Hz^{1/2}';
caxis_recommendation = [-20 25];

% % Convert to log fT^2/Hz
% B_cal = (B_cal + 10)/10;
% unit_str = 'log_{10} fT^2/Hz';
% caxis_recommendation = [-2 2.5];

% % Convert to log fT/Hz^{1/2}
% B_cal = (B_cal + 10)/20;
% unit_str = 'log_{10} fT/Hz^{1/2}';
% caxis_recommendation = [-1 1.25];

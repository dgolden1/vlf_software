function [t_imp_start, t_imp_end, det_sig, det_fs, det_thresh] = find_sferics(data_bb, fs_bb, thresh)
% [t_imp_start, t_imp_end, det_sig, det_fs, det_thresh] = find_sferics(data_bb, fs_bb, thresh)
% Find impulse locations in a broadband data file.
% 
% INPUTS
% data_bb: broadband data
% fs_bb: sampling frequency (must be ~35 kHz or higher)
% thresh: det_thresh for what amplitude descrepancy represents an impulse.
%  This can be progressively lowered over the course of multiple runs.  0.01 is
%  a reasonable first try; lower values will find more sferics and higher
%  values will find fewer.  Values that are too low will label legitimate
%  pieces of data as sferics and may not do what you expect.
% 
% OUTPUTS
% t_imp_start: vector of start times for sferics (the first data sample is
%  at t=0)
% t_imp_end: vector of end times for sferics.  Sferic n begins at
%  t_imp_start(n) and ends at t_imp_end(n).
% det_sig_full: detection signal (for debugging)
% det_fs: sampling frequency of detection signal (for debugging)
% det_thresh: calculated det_thresh for detection signal (for debugging)
% 
% This technique is tuned to find sferics, which have maximum energy in the
% range 5-15 kHz due to the convolution of (a) sferic energy distribution
% and (b) the attenuation profile of the Earth-ionosphere waveguide.
% 
% Sferics which overlap the start and end sections of the data are
% intentionally ignored.

% Useful instructions: Audio Restoration: An Investigation of Digital
% Methods for Click Removal and Hiss Reduction
% (http://www.umiacs.umd.edu/~jnuzman/audio/audio.pdf)
% 
% Useful Matlab tutorial: Linear Prediction and Autoregressive Modeling
% http://www.mathworks.com/products/signal/demos.html?file=/products/demos/
% shipping/signal/lpcardemo.html

% By Daniel Golden (dgolden1 at stanford dot edu) August 2010
% $Id$

%% Setup
error(nargchk(3, 3, nargin));

if fs_bb < 33e3
  error('fs (%0.0f kHz) must be greater than 33 kHz', fs_bb/1e3);
end

b_debug = false; % Display some debugging info

t_imp_start = [];
t_imp_end = [];

% Number of seconds before and after each bad data section over which to
% get the LPC coefficients. These values should match those in
% remove_sferics.m.
% These values are only used here to ensure that we don't place sferics too
% close to the start or end of the data sample, where we won't be able to
% get data to interpolate over them.
t_interp_before = 0.02;
t_interp_after = 0.005;

% Minimum distance (in seconds) allowed between what we label as sferics;
% if they're closer together than this, combine them and replace both as
% one.
% If this value is too low, a single sferic may be erroneously labeled as
% two separate ones, and the LPC parameter estimation can get screwed up.
% If this value is too high, the data over which we interpolate gets big,
% and vertical gaps may appear in the data where the background signal
% cannot be estimated.
t_min_inter_sf = 0.0015;


%% Find sferic energy between 5 and 15 kHz
% bandpass filter between 5 and 15 kHz, square signal, decimate to 6 kHz bandwidth
% See Ryan's thesis, page 110 at
% http://vlf.stanford.edu/pubs/accurate-and-efficient-long-range-lightning-geo-location-using-vlf-radio-atmospheric-waveform-b

data_bb = data_bb - mean(data_bb);

% Decimate the original data to fs ~ 33 kHz so that the bandpass is less expensive
fs_dec_optimal = 33e3;
dec_factor = floor(fs_bb/fs_dec_optimal);
fs_dec = fs_bb/dec_factor;
data_dec = decimate(data_bb, dec_factor);

% FIR method with downsampling
% Squaring the signal after filtering is actually not something that Ryan
% does; he takes the absolute value (or, the square root of the sum of
% squares of two channels).  However, it seems to nicely increase contrast
% and improve the sferic removal.
load('Hbp_33000_fir.mat', 'Hbp'); % Bandpass, fs = 33.3 kHz, passband 5 < f < 15 kHz, < 30 dB at stopband
det_fs_optimal = 6e3;
det_dec_factor = floor(fs_dec/det_fs_optimal);
det_fs = fs_dec/det_dec_factor;
det_sig_full = decimate(filtfilt(Hbp.Numerator, 1, data_dec).^2, det_dec_factor);
% det_sig_full = decimate(abs(filtfilt(Hbp.Numerator, 1, data_dec)), det_dec_factor);

% IIR BP filter, no downsampling
% load('Hbp.mat', 'Hbp'); % Bandpass, fs = 100 kHz, passband 5 < f < 15 kHz, < 30 dB at stopband
% det_fs_optimal = 5e3;
% det_dec_factor = floor(fs_bb/det_fs_optimal);
% det_fs = fs_bb/det_dec_factor;
% det_sig_full = decimate(filtfilthd(Hbp, data_bb).^2, det_dec_factor);

det_sig = abs(det_sig_full); % Absolute value of signal for thresholding
t_det = (0:length(det_sig_full)-1).'/det_fs;

% det_thresh = 1000*median(det_sig);
det_thresh = median(det_sig) + thresh*std(det_sig);

%% Peak detection
% Binary "good" or "bad" values for each time period in the subsampled data
b_sf_ok = true(size(det_sig));
b_sf_ok(det_sig > det_thresh) = false;

% In the unlikely event that we find no sferics, skip all this nonsense
if all(b_sf_ok)
  if b_debug
    fprintf('No sferics found\n');
  end
  return;
end

% Note start times of each "bad" (sferic-contaminated) period, and each
% "good" (uncontaminated period)
bad_times_idx = find(b_sf_ok(1:end-1) & ~b_sf_ok(2:end)) + 1;
good_times_idx = find(~b_sf_ok(1:end-1) & b_sf_ok(2:end)) + 1;

if isempty(good_times_idx) || isempty(bad_times_idx)
  if b_debug
    fprintf('No sferics found\n');
  end
  return;
end

% Ignore bad periods at the beginning or end of the data. Under this
% scheme, good periods always follow bad period; the start index of
% sferic n is bad_times_idx(n) and the start index of the good data
% following sferic n is good_times_idx(n)
if good_times_idx(1) < bad_times_idx(1)
  good_times_idx(1) = [];
end
if bad_times_idx(end) > good_times_idx(end)
  bad_times_idx(end) = [];
end
assert(length(bad_times_idx) == length(good_times_idx));
assert(all(good_times_idx > bad_times_idx));


% The peak in detection generally precedes the main component of the
% sferic.  Mandate that all bad times must last for at least 1 ms after
% their peak.
% Under this scheme, it is possible to push the end of one sferic out past
% the beginning of the next.  This is fixed in the following section.
for kk = 1:length(bad_times_idx)
  % Get the peak of the detector signal for this sferic
  [~, peak_idx] = max(det_sig(bad_times_idx(kk):good_times_idx(kk)));
  peak_idx = peak_idx + bad_times_idx(kk) - 1;

  if t_det(good_times_idx(kk)) - t_det(peak_idx) < 1e-3
    % Make this good_times value either the first value that's 1 ms away
    % from the peak, or the last value in the file, whichever comes first
    good_times_idx(kk) = min([length(t_det) find(t_det > t_det(peak_idx) + 1e-3, 1, 'first')]);
  end
end

% Combine sferics that are closer together than t_min_inter_sf
idx = (bad_times_idx(2:end) - good_times_idx(1:end-1))/det_fs >= t_min_inter_sf;
bad_times_idx = bad_times_idx([true; idx]);
good_times_idx = good_times_idx([idx; true]);

% Don't allow sferics within time t_interp_before / t_interp-after of the
% start or end of the data set; we need that data to exist for
% interpolation
idx = true(size(bad_times_idx));
if ~isempty(good_times_idx) % End of the data
  idx = idx & (t_det(end) - t_det(good_times_idx) > t_interp_after);
end
if ~isempty(bad_times_idx) % Beginning of the data
  idx = idx & (t_det(bad_times_idx) - t_det(1) > t_interp_before);
end
bad_times_idx = bad_times_idx(idx);
good_times_idx = good_times_idx(idx);

t_imp_start = t_det(bad_times_idx);
t_imp_end = t_det(good_times_idx);

if b_debug
  fprintf('Found %d sferics\n', length(t_imp_start));
end

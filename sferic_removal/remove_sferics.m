function [data_cleaned, data_orig_slowtail] = remove_sferics(data_bb, fs_bb, t_imp_start, t_imp_end, b_slowtail_filter)
% [data_cleaned, data_orig_slowtail] = remove_sferics(data_bb, fs_bb, t_imp_start, t_imp_end, b_slowtail_filter)
% Remove previously found impulses from broadband data_bb
% 
% INPUTS
% data_bb: broadband data
% fs_bb: sampling frequency.  This need not be the same as entered into
%  find_sferics(), e.g., if the user prefers to downsample the data
%  for this step to increase speed
% t_imp_start: vector of start times for sferics (the first data sample is
%  at t=0).
% t_imp_end: vector of end times for sferics.  These vectors may be
%  determined via the find_sferics() function.  Sferic n begins
%  at t_imp_start(n) and ends at t_imp_end(n).
% b_slowtail_filter: true to filter out data below ~400 Hz, to eliminate
% interference from sferic slowtails
% 
% OUTPUTS
% data_cleaned: the cleaned data_bb
% data_orig_slowtail: the uncleaned data after the slowtail filter is
%  applied (for direct comparison between uncleaned and cleaned data)

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
error(nargchk(4, 5, nargin));

if ~exist('b_slowtail_filter', 'var') || isempty(b_slowtail_filter)
  b_slowtail_filter = true;
end

% Number of seconds before and after each bad data section over which to
% get the LPC coefficients.  Beware that data after the sferic may be
% contaminated by following sferics.  These values should match those in
% find_sferics.m.
t_interp_before = 0.02;
t_interp_after = 0.005;

%% Highpass filter to remove slowtails
if b_slowtail_filter
  % load('Hhp_16600_fir.mat', 'Hhp'); % Passband > 500 Hz, Stopband < 300 Hz, Fs = 1e5/6 Hz, FIR = EXPENSIVE
  % data_dec = filtfilt(Hhp.Numerator, 1, data_dec);

  % Passband > 400 Hz, Stopband < 300 Hz, IIR = NONLINEAR PHASE
  if fs_bb == 1e5/6
    load('Hhp_16600.mat', 'Hhp');
  elseif fs_bb == 1e5/5
    load('Hhp_20000.mat', 'Hhp');
  else
    Hhp = generate_hp_filter(fs_bb); % Better to pregenerate this and load it than waste time on this line
  end
  
  data_bb = filter(Hhp, data_bb);
  data_orig_slowtail = data_bb;
end

%% Return, if there are no impulses to clean
if isempty(t_imp_start)
%   fprintf('No impulses to clean.\n');
  data_cleaned = data_bb;
  return;
end

%% Find indices into the data where sferics start and end
t_data_bb = (0:length(data_bb)-1)/fs_bb;
bad_start_indices = interp1(t_data_bb, 1:length(t_data_bb), t_imp_start, 'nearest', 'extrap');

% t_imp_end is actually the time of the beginning of the good data;
% subtract one from the index to place the index at the end of the bad
% data.  It is pretty unlikely that this semantic issue will make any
% difference.
bad_end_indices = interp1(t_data_bb, 1:length(t_data_bb), t_imp_end, 'nearest', 'extrap') - 1;

%% Delete samples with sferics
data_sferics_blanked = data_bb;

for kk = 1:length(bad_start_indices)
  data_sferics_blanked(bad_start_indices(kk):bad_end_indices(kk)) = 0;
end

%% Interpolate across gaps
% With attention paid to the procedure from here:
% http://gwc.sourceforge.net/gwc_science/node7.html

data_cleaned = data_sferics_blanked;

% figure;
for kk = 1:length(bad_start_indices)
  % LPC coefficients are calculated using data_bb beginning with
  % idx_good_before(1) and ending with idx_good_after(end).
  % The calculated data_bb extends from idx_bad(1) through idx_smooth_after(end).
  idx_good_before = bad_start_indices(kk)-round(t_interp_before*fs_bb) : bad_start_indices(kk)-1; % Good data_bb before the sferic
  idx_good_after = bad_end_indices(kk)+1 : bad_end_indices(kk) + round(t_interp_after*fs_bb); % Good data_bb after the sferic
  idx_bad = bad_start_indices(kk) : bad_end_indices(kk); % Bad data_bb during the sferic, to be completely replaced

  idx_all = [idx_good_before, idx_bad, idx_good_after]; % All the points in question
%   idx_estimate = idx_good_before; % Indices to use for estimation
  idx_estimate = [idx_good_before, idx_good_after];
  
  n = length(idx_bad) + length(idx_estimate);
  
  % Adaptive LPC order, based on length of area to be replaced
  % This runs way slower than constant p = 31 !!
  % p must be less lower than the length of the data being measured
  % This crazy function gives a nice 
  p = max(min([round(5*sqrt(max(length(idx_bad) - 100, 1))), length(idx_good_before), 300]), 11);
%   p = max(min([round(5*sqrt(length(idx_bad))), length(idx_good_before), 300]), 11);
%   fprintf('%d, ', p);

  % In the unlikely event that the data used to estimate the LPC
  % coefficients is all 0, the LPC coefficients will have NaNs in them.
  % Instead, just dump 0s into the cleaned data
  if all(data_cleaned(idx_good_before) == 0)
    warning('SfericRemoval:BadPredData', 'Prediction data is all 0; inserting 0 in place of sferic (%0.4f to %0.4f sec)', t_imp_start(kk), t_imp_end(kk));
    data_cleaned(idx_bad) = 0;
    continue;
  end

  a = lpc(data_cleaned(idx_good_before), p);
  
  % Create the AR matrix
  A = spdiags(repmat(fliplr(a), n-p, 1), 0:p, n-p, n);
  
  % Need to add -idx_good_before + 1 to begin indices at 1
  Ak = A(:, idx_estimate - idx_good_before(1) + 1); % Columns for known data_bb
  Au = A(:, idx_bad - idx_good_before(1) + 1); % Columns for unknown data_bb
  
  sk = data_cleaned(idx_estimate); % Known data_bb
  su = -Au\Ak*sk; % Solve for unknown data_bb
  
  % Here's the problem as far as I can tell: because we're trying to
  % minimize the sum of Ak*sk + Au*su = e, the least squares solution tries
  % to stuff the trivial solution into su, since that's what would make e
  % the smallest and since Ak and Au are partitioned so they don't overlap.
  % The solution might be constrained least squares or something like that,
  
  % Insert the bad data_bb verbatim
  data_cleaned(idx_bad) = su;
  
%   plot(t_data_bb(idx_all), [data_bb(idx_good_before); nan(length(idx_bad), 1); data_bb(idx_good_after)], t_data_bb(idx_bad), su);
  
end

% %% Debug result
% if b_debug
%   figure(h_td);
%   s(end+1) = subplot(3, 1, 3);
%   plot(t_data, data_cleaned, 'b', t_data, data_bad, 'r');
%   grid on;
%   legend('Cleaned', 'Sferics');
%   increase_font;
%   
%   figure(h_spec);
%   s(end+1) = subplot(2, 1, 2);
%   spectrogram_dan(data_cleaned - mean(data_cleaned), window, noverlap, nfft, fs_bb);
%   s(end+1) = gca;
%   caxis([15 70]);
%   title('Result');
%   increase_font;
% 
%   linkaxes(s, 'x');
% end

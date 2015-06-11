function [b_is_sferics, sferic_params, rej_str] = ...
  emission_test_sferics_and_whistlers(peak, f, t_spec, spec, s_mediogram, thresh)
% Function to determine whether a given emission is likely a sferic/whistler or not
% 
% Helper function for find_single_event.m

% By Daniel Golden (dgolden1 at stanford dot edu) originally written
% September 2009, heavily revised September 2010
% $Id$

%% Setup
df = f(2) - f(1);
dt = t_spec(2) - t_spec(1);

sferic_params = struct('vcorr', [], 'slope', []);

%% Run
% Is it vertically correlated and what is the slope?
idx_this_em = peak.idx_lc:peak.idx_uc;

% Maximum number of lags to compute in the cross correlation
% (lower=faster).  Min_slope is the minimum slope that can be seen with
% this many lags
min_slope = 1000; % +/- Hz/sec 
maxlags = round(df/(dt*min_slope));

xc = zeros(length(idx_this_em) - 1, maxlags*2 + 1);
xc_centroid = zeros(length(idx_this_em) - 1, 1);
xc_centroid_ampl = zeros(length(idx_this_em) - 1, 1);
lags = (-maxlags:maxlags)*dt; % sec (positive lag = xc(k+1,:) advanced wrt. xc(k,:), i.e., positive slope)
slopes = lags/df; % sec/Hz

% Cross-correlate each row of the spectrogram with its adjacent rows.  This
% gives a measure of (a) how much one row relates to the next and (b) what
% the "dominant slope" of the spectrogram is
for kk = 1:(length(idx_this_em) - 1)
  this_ampl = log(spec(idx_this_em(kk), :)).';
  next_ampl = log(spec(idx_this_em(kk+1), :)).';
  xc(kk, :) = xcorr(next_ampl - mean(next_ampl), this_ampl - mean(this_ampl), maxlags, 'coeff');
  xc_centroid(kk) = centroid(lags, xc(kk, :));
  xc_centroid_ampl(kk) = interp1(lags, xc(kk, :), xc_centroid(kk));
end

xc_centroid_slope = centroid(slopes, mean(xc, 1)); % sec/Hz
xc_centroid_val = mean(interp1(slopes, xc.', xc_centroid_slope)); % unitless (mean correlation coefficient)

sferic_params.slope = 1/xc_centroid_slope; % convert slope to Hz/sec
sferic_params.vcorr = xc_centroid_val;

% Correlation coefficient above threshold AND slope is low
if sferic_params.vcorr > thresh.sferic_min_corr && sferic_params.slope >= thresh.sferic_max_slope
  b_is_sferics = true;
  rej_str = 'sferics/whistlers!';
else
  b_is_sferics = false;
  rej_str = '';
end

1;

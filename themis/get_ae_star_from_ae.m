function [ae_star, ae_star_epoch] = get_ae_star_from_ae(ae_epoch, ae)
% Determine AE*, the maximum AE in the past three hours

% By Daniel Golden (dgolden1 at stanford dot edu) October 2011
% $Id$

addpath(fullfile(danmatlabroot, 'vlf', 'minmaxfilter'));

d_ae_epoch = median(diff(ae_epoch));
numtaps = round(3/24/d_ae_epoch);
ae_star = -minmaxfilt1(-ae, numtaps, [], 'same'); % minmaxfilt1 only does minimum filtering
if mod(numtaps, 2) == 0
  % Even number of taps; there is one more tap before the epoch than after
  % it
  ae_star_epoch = ae_epoch + numtaps/2*d_ae_epoch;
else
  ae_star_epoch = ae_epoch + floor(numtaps/2)*d_ae_epoch;
end

1;

% Whoa, this way takes a LONG time
% lastprint = -inf;
% ae_star = nan(size(ae_star_epoch));
% t_start = now;
% for kk = 1:length(ae_star_epoch)
%   ae_star(kk) = max_in_last_three_hours(epoch, ae, ae_star_epoch(kk));
%   
%   if kk > lastprint + length(ae_star_epoch)*0.01
%     fprintf('Processed %d out of %d AE* values (%0.0f%%) in %s\n', ...
%       kk, length(ae_star_epoch), kk/length(ae_star_epoch)*100, time_elapsed(t_start, now));
%     lastprint = kk;
%   end
% end

function val = max_in_last_three_hours(epoch, x, this_epoch)
%% Function: get the maximum value of a vector in the last three hours

d_epoch = diff(epoch);

assert(isscalar(this_epoch)); % One epoch at a time
assert(all(abs(d_epoch - median(d_epoch)) < 1/86400)); % Make sure time between samples is constant to within one sec

idx = epoch <= this_epoch & epoch > this_epoch - 3/24;
val = max(x(idx));

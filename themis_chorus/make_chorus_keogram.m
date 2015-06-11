function [epoch, MLT, keogram] = make_chorus_keogram(chorus_ampl, epoch_vec, L_centers, MLT_centers, lat_centers, L_lim)
% Make a chorus "keogram" (MLT vs epoch time plot of chorus amplitude)
% keogram is a cell array of keograms, one for each latitude

% By Daniel Golden (dgolden1 at stanford dot edu) January 2012
% $Id$

%% Setup
if ~exist('L_lim', 'var') || isempty(L_lim)
  L_lim = [min(L_centers) max(L_centers)];
end

if ndims(chorus_ampl) ~= 4
  error('chorus_ampl should have 4 dimensions: L, MLT, latitude and epoch');
end

%% Make keogram
MLT = linspace(0, 25, 49); % Interpolate MLT so that image isn't antialiased in inkscape
epoch = epoch_vec;

for kk = 1:length(lat_centers)
  map{kk} = squeeze(nanmean(chorus_ampl(L_centers >= L_lim(1) & L_centers <= L_lim(2), :, kk, :)));
  keogram{kk} = interp1(MLT_centers, map{kk}, MLT, 'nearest', 'extrap');
end

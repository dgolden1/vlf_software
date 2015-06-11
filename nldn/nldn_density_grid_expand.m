function N = nldn_density_grid_expand(nldn, idx, bin_lat, bin_lon)
% N = nldn_density_grid_expand(nldn, idx, bin_lat, bin_lon)
% Function to compute NLDN flash density given flash latitude, longitude
% and number of strokes, as well as bins.
% 
% This function INCORPORATES number of strokes (which is hard to do without
% an n-dimensional histogram)
% 
% bin_lat and bin_lon are the lower edges; the last upper edge is added by
% this function

% By Daniel Golden (dgolden1 at stanford dot edu) July 2009
% $Id$

%% The expanded low-res data way
nldn = expand_nldn_low_res(nldn, idx);

N = hist3([nldn.lat, nldn.lon], 'Edges', {[bin_lat Inf], [bin_lon Inf]});
assert(all(N(end,:) == 0) && all(N(:,end) == 0)); % These are strokes that land on Inf (i.e., none)
N = N(1:end-1, 1:end-1);

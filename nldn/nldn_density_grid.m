function N = nldn_density_grid(nldn, idx, bin_lat, bin_lon)
% N = nldn_density_grid(nldn, idx, bin_lat, bin_lon)
% Function to compute NLDN flash density given flash latitude, longitude
% and number of strokes, as well as bins.
% 
% This function INCORPORATES number of strokes
% 
% bin_lat and bin_lon are the lower edges; the last upper edge is added by
% this function

% By Daniel Golden (dgolden1 at stanford dot edu) July 2009
% $Id$

N = zeros(length(bin_lat), length(bin_lon));
% if isempty(lat)
% 	return;
% end

max_multiplicity = 10;
N_raw = histcn([nldn.lat(idx), nldn.lon(idx), nldn.nstrokes(idx)], [bin_lat bin_lat(end)+1], [bin_lon bin_lon(end)+1], [1:max_multiplicity Inf]);
N_raw = N_raw(1:length(bin_lat), 1:length(bin_lon), 1:max_multiplicity); % In case a value hits the right border, N_raw increases in size

for kk = 1:max_multiplicity
	N = N + N_raw(:, :, kk)*kk;
end

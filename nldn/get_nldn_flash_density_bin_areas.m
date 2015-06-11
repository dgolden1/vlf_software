function [Bin_area, bin_lat, bin_lon] = get_nldn_flash_density_bin_areas(lat_min, lat_max, lon_min, lon_max, binsize)
% [Bin_area, Bin_lat, Bin_lon] = get_nldn_flash_density_bin_areas(lat_min, lat_max, lon_min, lon_max, binsize)
% 
% Function to get bin areas for normalization purposes; support function for
% get_nldn_flash_density()
% 
% all values in degrees

% By Daniel Golden (dgolden1 at stanford dot edu) July 2009
% $Id$

%% Setup
if ~exist('binsize', 'var') || isempty(binsize)
	binsize = 1;
end

%% Process

bin_lon_orig = lon_min:binsize:lon_max;
bin_lat_orig = lat_min:binsize:lat_max;
[Bin_lon_orig, Bin_lat_orig] = meshgrid(bin_lon_orig, bin_lat_orig);
Bin_area = Inf(size(Bin_lon_orig));
earth_ellipsoid_km = almanac('earth','ellipsoid','kilometers');
for ii = 1:(length(bin_lon_orig) - 1)
	for jj = 1:(length(bin_lat_orig) - 1)
		Bin_area(jj, ii) = areaquad(Bin_lat_orig(jj, ii), Bin_lon_orig(jj, ii), Bin_lat_orig(jj + 1, ii + 1), Bin_lon_orig(jj + 1, ii + 1), earth_ellipsoid_km);
	end
end

% % The original version actually represent the corners of the bins; change
% % the output so they represent the centers of the bins
% bin_lat = bin_lat_orig + 0.5;
% bin_lon = bin_lon_orig + 0.5;

bin_lat = bin_lat_orig;
bin_lon = bin_lon_orig;

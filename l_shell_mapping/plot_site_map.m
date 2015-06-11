function plot_site_map
% plot_site_map
% plot VLF sites in the world with L-shell lines

% By Daniel Golden (dgolden 1 at stanford dot edu) July 2008
% $Id$

% close all;
clear;

plot_l_map_world_surface;
load sites.mat;

hold on;
% Broadband sites
h_bb = plotm(lat(bb), lon(bb), 'ro', 'markerfacecolor', 'r');

% Narrowband sites
h_nb = plotm(lat(~bb), lon(~bb), 'bo', 'markerfacecolor', 'b');

t = [];
for kk = 1:length(lat)
	t(kk) = textm(lat(kk), lon(kk), ['  ' sitename{kk}], 'FontWeight', 'bold');
% 	t = textm(lat(kk), lon(kk), ['  ' sitename{kk}]);
	if bb(kk)
		set(t, 'color', 'r');
	else
		set(t, 'color', 'b');
	end
end

legend([h_bb h_nb], 'BB', 'NB');

set(gca, 'Position', [0.05 0 0.9 0.97]);

function plot_l_map_world_surface(h_ax)
% Make a map with l-shell lines

% By Daniel Golden (dgolden1 at stanford dot edu) using Ryan Said's
% underlying code.
% September 2007

%% Setup
% close all;
if ~exist('h_ax', 'var') || isempty(h_ax)
  figure('color', 'w');
  h_ax = gca;
else
  saxes(h_ax);
end

%% Map the world
plot_worldmap([], gca);

%% Map the l-shells
l_shells = [1.5 2 3 6];
[lats_n,lons_n,lats_s,lons_s] = LShell_lines([2001 1 1 0 0 0],l_shells,100,100);
for kk = 1:length(l_shells)
	plotm(lats_n(kk,:),lons_n(kk,:), 'm-');
	plotm(lats_s(kk,:),lons_s(kk,:), 'm-');
end
% [L_15_N, L_15_S, L_20_N, L_20_S, L_30_N, L_30_S, L_40_N, L_40_S, L_50_N, L_50_S] =/home/dgolden/vlf/vlf_software/dgolden/l_shell_mapping
%  moco_l_shells;
% plotm(L_15_N);
% plotm(L_15_S);
% plotm(L_20_N);
% plotm(L_20_S);
% plotm(L_30_N);
% plotm(L_30_S);
% plotm(L_40_N);
% plotm(L_40_S);
% plotm(L_50_N);
% plotm(L_50_S);

%% Annotate the lines
for kk = 1:length(l_shells)
	ii = find(lons_s(kk,:) == min(lons_s(kk,:)), 1);
	t = textm(lats_s(kk,ii), lons_s(kk,ii), sprintf('L=%0.1f', l_shells(kk)), ...
		'color', 'm', 'horizontalalignment', 'center', 'fontweight', 'bold');
end

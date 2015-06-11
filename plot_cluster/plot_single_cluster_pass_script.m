% plot_single_cluster_pass_script
% Run plot_single_cluster_pass() a bunch of times

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

close all;
clear;

d = dir('/home/dgolden/vlf/case_studies/cluster_palmer_2001_2002/cluster_position/newer/*cluster.txt');
for kk = 1:length(d)
	[pathstr, name, ext] = fileparts(d(kk).name);
	plot_single_cluster_pass(name);
end

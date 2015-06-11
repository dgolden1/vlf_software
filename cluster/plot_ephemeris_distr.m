function plot_ephemeris_distr
% Plot cluster ephemeris data, binned by dipole MLT and L

% By Daniel Golden (dgolden1 at stanford dot edu) February 2011
% $Id$

%% Load Data
data_dir = '~/vlf/case_studies/cluster_ephemeris';
[data, info] = cdfread(fullfile(data_dir, 'cluster1_20110228132342_20042.cdf'));

idx_L = strcmp({info.Variables{:,1}}, 'L_VALUE');
idx_mlt = strcmp({info.Variables{:,1}}, 'SM_LCT_T');

L_data = [data{:,idx_L}].';
mlt_data = [data{:, idx_mlt}].';

%% Create histogram
l_edges = (1:0.25:15).';
mlt_edges = (0:24).';

N = hist3([L_data mlt_data], 'edges', {l_edges, mlt_edges});

% The value at MLT = 24 is the same as the value at MLT = 0
N(:, mlt_edges == 24) = N(:, mlt_edges == 0);

% Chop off the last L value, since its bin is empty (the last bin has
% values that fall on the bin edge, not within a bin)
N(end, :) = [];
l_edges(end, :) = [];

%% Plot
[L, MLT] = ndgrid(l_edges, mlt_edges);

% Make sure data gaps are colored white
new_N = log10(N);
new_N(new_N < 0) = nan;

plot_l_mlt(L, MLT, new_N)

c = colorbar;
ylabel(c, 'log_{10} minutes in bin');

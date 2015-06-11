function plot_effective_num_samples
% Plot effective number of samples at different latitudes vs L and MLT

% By Daniel Golden (dgolden1 at stanford dot edu) April 2012
% $Id$

%% Setup
close all;

%% Load data
n = [];
load(fullfile(vlfcasestudyroot, 'themis_chorus', 'themis_chorus_regression.mat'));

[L_mat, MLT_mat] = ndgrid(L_centers, MLT_centers);

%% Plot
plot_one(L_mat, MLT_mat, L_edges, MLT_edges, lat_centers, n);
set(gcf, 'name', 'n');
plot_one(L_mat, MLT_mat, L_edges, MLT_edges, lat_centers, n_eff);
set(gcf, 'name', 'n_eff');

function plot_one(L_mat, MLT_mat, L_edges, MLT_edges, lat_centers, n)
%% Function: Plot a single version of n
% super_subplot parameters
nrows = 3;
ncols = 4;
hspace = 0;
vspace = 0;
hmargin = 0;
vmargin = 0;

figure;
figure_grow(gcf, 2);
for kk = 1:length(lat_centers)
   h(kk) = super_subplot(nrows, ncols, kk, hspace, vspace, hmargin, vmargin);
   
   this_n = n(:,:,kk);
   idx_plot = isfinite(log10(this_n));
   plot_l_mlt(L_mat(idx_plot), MLT_mat(idx_plot), L_edges, MLT_edges,  log10(this_n(idx_plot)), ...
     'scaling_function', 'none', 'b_shading_interp', false, 'b_oversample_mlt', true, ...
     'b_white_zeros', false, 'MLT_gridlines', 0:2:22, 'h_ax', h(kk));

   c = colorbar;
   caxis([0 3]);
   axis off;
   title(sprintf('\\lambda = %0.1f^\\circ', lat_centers(kk)));
   % ylabel(c, 'log_{10} Effective sample size');
end


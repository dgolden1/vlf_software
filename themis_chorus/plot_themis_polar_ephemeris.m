function plot_themis_polar_ephemeris
% Plot L-MLT plots of the THEMIS and Polar ephemeris, to find regions of
% overlap

% By Daniel Golden (dgolden1 at stanford dot edu) February 2011
% $Id$

%% Setup
close all;

addpath(fullfile(danmatlabroot, 'vlf', 'themis'));

%% Make Polar plots
polar = load('/home/dgolden/vlf/case_studies/polar/PolarChorusDatabase_p.mat', 'Epoch', 'Xsm', 'Ysm', 'Zsm', 'Bw');
fn = fieldnames(polar);
for kk = 1:length(fn)
  polar.(fn{kk}) = polar.(fn{kk}).';
end

polar.xyz_sm = [polar.Xsm polar.Ysm polar.Zsm];

idx = polar.Bw > 0;

make_plots(polar.xyz_sm(idx,:), 'Polar');

clear polar

%% Make THEMIS plots
[~, them] = get_combined_them_power('chorus');

idx = them.field_power > 0;
% idx = them.L > 5;

make_plots(them.xyz_sm(idx,:), 'THEMIS');

clear them


function make_plots(xyz_sm, name)
%% Function: make some plots

[lat, MLT, L, r] = xyz_to_lat_mlt_L(xyz_sm);


%% Make plots by L and MLT
% latitude_edges = [4 15 25 35 45];
latitude_edges = [0 5 10 15 20 25 30 35 40 45];
dMLT = 1;
dL = 0.5;

% super subplot
hspace = -0.05;
vspace = -0.05;
hmargin = [0 0.05];
vmargin = [0 0.05];

figure;
for kk = 1:(length(latitude_edges) - 1)
  idx = lat >= latitude_edges(kk) & lat < latitude_edges(kk+1);
  
  % h = subplot(3, 3, kk);
  h = super_subplot(3, 3, kk, hspace, vspace, hmargin, vmargin);
  plot_l_mlt(L(idx), MLT(idx), 1:dL:10, 0:dMLT:24, 1, 'h_ax', h, 'solid_lines_L', 5);
  
  axis off
  caxis([0.5 2.5]);
  c = colorbar;
  ylabel(c, 'log_{10} # samples');
  title(sprintf('%s %d < \\lambda < %d', name, latitude_edges(kk), latitude_edges(kk+1)));
  increase_font;
end

figure_grow(gcf, 2);

%% Make plots by R and lat
MLT_edges = [21 03 09 15 21];
dR = 0.5;
dlat = 5;

% super subplot
hspace = 0.05;
vspace = 0.05;
hmargin = [0.05 0.05];
vmargin = [0 0.05];

figure;
% figure_grow(gcf, 1, 1);

for kk = 1:(length(MLT_edges) - 1)
  if MLT_edges(kk) > MLT_edges(kk+1)
    idx = MLT >= MLT_edges(kk) | MLT < MLT_edges(kk+1);
  else
    idx = MLT >= MLT_edges(kk) & MLT < MLT_edges(kk+1);
  end
  
  h = super_subplot(2, 2, kk, hspace, vspace, hmargin, vmargin);
  plot_r_lat(r(idx), lat(idx), 0:dR:8, 0:dlat:90, 1, 'h_ax', h, 'solid_lines_R', 5);
  
  axis off
  caxis([1 3.5]);
  c = colorbar;
  ylabel(c, 'log_{10} # samples');
  title(sprintf('%s %d < MLT < %d', name, MLT_edges(kk), MLT_edges(kk+1)));
  increase_font;
end

%% Make kernel density plots averaged over MLT
figure;
for kk = 1:(length(MLT_edges) - 1)
  if MLT_edges(kk) > MLT_edges(kk+1)
    idx = MLT >= MLT_edges(kk) | MLT < MLT_edges(kk+1);
  else
    idx = MLT >= MLT_edges(kk) & MLT < MLT_edges(kk+1);
  end
  
  h = super_subplot(2, 2, kk, hspace, vspace, hmargin, vmargin);
  [~, dens, X, Y] = kde2d([r(idx).*cos(lat(idx)*pi/180), r(idx).*sin(lat(idx)*pi/180)], 2^8, [0, 0], [8, 8]);
  dens(dens < 0) = 0;
  imagesc(X(1,:), Y(:,1), log10(dens));
  axis xy equal;
  make_lat_plot_grid('h_ax', gca, 'R_max', 8, 'lat_gridlines', 0:15:90, 'solid_lines_R', 5, 'linecolor', 'w');
  
  axis off
  caxis([-5 0]);
  c = colorbar;
%   ylabel(c, 'log kernel amplitude');
  title(sprintf('%s %d < MLT < %d', name, MLT_edges(kk), MLT_edges(kk+1)));
  increase_font;
end

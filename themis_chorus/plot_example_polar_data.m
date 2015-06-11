function plot_example_polar_data
% Plot some example Polar data, just to figure out if I can read Nick's
% data properly

% By Daniel Golden (dgolden1 at stanford dot edu) January 2012
% $Id$

%% Setup
close all;
% clear;
load('/home/dgolden/vlf/case_studies/polar/PolarChorusDatabase_p.mat', 'Bw', 'Xsm', 'Ysm', 'Zsm')

%% Arrange data
R = sqrt(Xsm.^2 + Ysm.^2 + Zsm.^2);
lat = atan2(Zsm, sqrt(Ysm.^2 + Xsm.^2))*180/pi;
MLT = mod(atan2(Ysm, Xsm) + pi, 2*pi)*24/(2*pi);
R_edges = 1:0.5:8;
lat_edges = -90:15:90;
durations = 1;

idx_chorus = Bw > 0;

%% Plot
plot_r_lat(R, lat, R_edges, lat_edges, 1, 'b_white_zeros', false);
title('Num samples');
c = colorbar;
ylabel(c, 'log_{10} num 32-sec samples');
increase_font;
figure_grow(gcf, 0.6, 1)
print('-dpng', '-r90', sprintf('~/temp/ephemeris'));

plot_r_lat(R(idx_chorus), lat(idx_chorus), R_edges, lat_edges, durations, 'b_white_zeros', false);
title('Num samples with chorus');
c = colorbar;
ylabel(c, 'log_{10} num 32-sec samples');
increase_font;
figure_grow(gcf, 0.6, 1)

%% Occurrence rate plots like from Nick's 2012 paper
% [N_total, r, theta] = plot_r_lat(R, lat, R_edges, lat_edges, 1, 'b_white_zeros', false, 'b_plot', false);
% N_with_chorus = plot_r_lat(R(idx_chorus), lat(idx_chorus), R_edges, lat_edges, 1, 'b_white_zeros', false, 'b_plot', false);
% 
% [R_edges_mat, lat_edges_mat] = ndgrid(R_edges(1:end-1), lat_edges(1:end-1));
% 
% idx = N_total > 0 & (MLT >= 21 | MLT < 03);
% plot_r_lat(R_edges_mat(idx), lat_edges_mat(idx), R_edges, lat_edges, N_with_chorus(idx)./N_total(idx), ...
%   'scaling_function', 'none', 'b_white_zeros', false);
% title('2100 -- 0300');
% 
% idx = N_total > 0 & MLT >= 03 & MLT < 09;
% plot_r_lat(R_edges_mat(idx), lat_edges_mat(idx), R_edges, lat_edges, N_with_chorus(idx)./N_total(idx), ...
%   'scaling_function', 'none', 'b_white_zeros', false);
% title('0300 -- 0900');
% 
% idx = N_total > 0 & MLT >= 09 & MLT < 15;
% plot_r_lat(R_edges_mat(idx), lat_edges_mat(idx), R_edges, lat_edges, N_with_chorus(idx)./N_total(idx), ...
%   'scaling_function', 'none', 'b_white_zeros', false);
% title('0900 -- 1500');
% 
% idx = N_total > 0 & MLT >= 15 & MLT < 21;
% plot_r_lat(R_edges_mat(idx), lat_edges_mat(idx), R_edges, lat_edges, N_with_chorus(idx)./N_total(idx), ...
%   'scaling_function', 'none', 'b_white_zeros', false);
% title('1500 -- 2100');

for kk = 0:4
  plot_norm_occur_by_mlt(kk, R, lat, MLT, R_edges, lat_edges, idx_chorus);
end

function plot_norm_occur_by_mlt(kk, R, lat, MLT, R_edges, lat_edges, idx_chorus)

switch kk
  case 0
    idx_mlt = true(size(MLT));
    title_text = 'All MLT';
  case 1
    idx_mlt = MLT >= 21 | MLT < 03;
    title_text = '2100-0300 MLT';
  case 2
    idx_mlt = MLT >= 03 & MLT < 09;
    title_text = '0300-0900 MLT';
  case 3
    idx_mlt = MLT >= 09 & MLT < 15;
    title_text = '0900-1500 MLT';
  case 4
    idx_mlt = MLT >= 15 & MLT < 21;
    title_text = '1500-2100 MLT';
end

[N_total, r, theta] = plot_r_lat(R(idx_mlt), lat(idx_mlt), R_edges, lat_edges, 1, 'b_white_zeros', false, 'b_plot', false);
N_with_chorus = plot_r_lat(R(idx_chorus & idx_mlt), lat(idx_chorus & idx_mlt), R_edges, lat_edges, 1, 'b_white_zeros', false, 'b_plot', false);
idx_finite = N_total > 0;

[R_edges_mat, lat_edges_mat] = ndgrid(R_edges(1:end-1), lat_edges(1:end-1));


plot_r_lat(R_edges_mat(idx_finite), lat_edges_mat(idx_finite), R_edges, lat_edges, ...
  N_with_chorus(idx_finite)./N_total(idx_finite), 'b_white_zeros', false, 'scaling_function', 'none');
c = colorbar;
ylabel(c, 'Norm occur');
caxis([0 0.5]);
title(title_text);
figure_grow(gcf, 0.6, 1);
increase_font;

print('-dpng', '-r90', sprintf('~/temp/norm_occur_%s', strrep(title_text, ' ', '_')));

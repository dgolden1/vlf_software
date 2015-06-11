function varargout = plot_model_performance(L_edges, L_centers, MLT_edges, MLT_centers, lat_edges, lat_centers, r, n_eff, str_plot_plane)
% Plot model performance (coefficient of determination) and effective
% number of samples
% 
% [h_r, h_neff] = plot_model_performance(L_edges, L_centers, MLT_edges, MLT_centers, lat_edges, lat_centers, r, n_eff, str_plot_plane)
% 
% str_plot_plane can be either 'L-MLT' (default) for view in the
% L-MLT plane or 'meridional' for a vew in the meridional plane

% By Daniel Golden (dgolden1 at stanford dot edu) March 2012
% $Id$

%% Setup
if ~exist('str_plot_plane', 'var') || isempty(str_plot_plane)
  str_plot_plane = 'L-MLT';
%   str_plot_plane = 'meridional';
end

if nargin == 0
  % Load everything but X, which can be a monster (though, in later
  % iterations, it just wasn't saved)
  load(fullfile(vlfcasestudyroot, 'themis_chorus', 'themis_chorus_regression.mat'), '-regexp', '^(?!X).*');
end

if length(lat_centers) ~= size(r, 3)
  error('Length of lat_centers ~= size(r, 3)');
end

%% Make maps
if exist('n_eff', 'var') && ~isempty(n_eff) && strcmp(str_plot_plane, 'L-MLT')
  [h_r, h_n_eff] = plot_r_n_eff_equatorial(L_edges, L_centers, MLT_edges, MLT_centers, lat_edges, lat_centers, r, n_eff);
elseif strcmp(str_plot_plane, 'L-MLT')
  h_r = plot_r_n_eff_equatorial(L_edges, L_centers, MLT_edges, MLT_centers, lat_edges, lat_centers, r);
elseif exist('n_eff', 'var') && ~isempty(n_eff) && strcmp(str_plot_plane, 'meridional')
  [h_r, h_n_eff] = plot_r_n_eff_meridional(L_edges, L_centers, MLT_edges, MLT_centers, lat_edges, lat_centers, r, n_eff);
elseif strcmp(str_plot_plane, 'meridional')
  h_r = plot_r_n_eff_meridional(L_edges, L_centers, MLT_edges, MLT_centers, lat_edges, lat_centers, r);
else
  error('Unknown string for str_plot_plane: %s', str_plot_plane);
end

%% Output arguments
if nargout > 0
  varargout{1} = h_r;
end
if nargout > 1 && exist('h_n_eff', 'var')
  varargout{2} = h_n_eff;
end

function [h_r, h_n_eff] = plot_r_n_eff_equatorial(L_edges, L_centers, MLT_edges, MLT_centers, lat_edges, lat_centers, r, n_eff)
%% Function: plot in L-MLT plane

%% Make an L-MLT grid
dL = median(diff(L_edges));
dMLT = median(diff(MLT_edges));
[L_mat, MLT_mat] = ndgrid(L_centers, MLT_centers);

%% Plot model performance
for kk = 1:size(r, 3)
  this_r = r(:,:,kk);
  idx_plot = isfinite(this_r);
  plot_l_mlt(L_mat(idx_plot), MLT_mat(idx_plot), L_edges, MLT_edges, this_r(idx_plot).^2, ...
    'scaling_function', 'none', 'b_shading_interp', false, 'b_oversample_mlt', true, 'MLT_gridlines', 0:2:22);
  c = colorbar;
  ylabel(c, 'r^2');
  title(sprintf('Model Performance \\lambda=%0.1f^\\circ', lat_centers(kk)));
  increase_font;
  axis off

  h_r(kk) = gcf;
end

%% Plot effective number of samples
if exist('n_eff', 'var')
  for kk = 1:size(n_eff, 3)
    this_n_eff = n_eff(:,:,kk);
    
    idx_plot = isfinite(log10(this_n_eff));
    plot_l_mlt(L_mat(idx_plot), MLT_mat(idx_plot), L_edges, MLT_edges,  log10(this_n_eff(idx_plot)), ...
      'scaling_function', 'none', 'b_shading_interp', false, 'b_oversample_mlt', true, 'MLT_gridlines', 0:2:22);
    c = colorbar;
    ylabel(c, 'log_{10} Effective sample size');
    cax = caxis;
    c_tick = ceil(cax(1)):floor(cax(2));
    set(c, 'ytick', c_tick);
    title(sprintf('Bin size is %0.1f L and %0.0f hrs MLT, \\lambda=%0.1f^\\circ', dL, dMLT, lat_centers(kk)));
    increase_font;
    axis off

    h_n_eff(kk) = gcf;
  end
end

function [h_r, h_n_eff] = plot_r_n_eff_meridional(L_edges, L_centers, MLT_edges, MLT_centers, lat_edges, lat_centers, r, n_eff)
%% Function: plot in meridional plane

% Super subplot parameters
nrows = length(MLT_centers);
ncols = 2;
hspace = 0.05;
vspace = 0.05;
hmargin = 0.05;
vmargin = 0.05;

cax_rsq = [0 0.5];
cax_n_eff = [0 4];

b_interp = true; % Shading method

figure;
figure_grow(gcf, 1.5, 2);

for kk = 1:length(MLT_centers)
  % Average over two adjacent MLT sectors, starting with dawn
  % this_mlt_idx = mod((kk-2)*2 + [1 2], length(MLT_centers)) + 1;
  % this_MLT_center = mod(MLT_centers(this_mlt_idx(1)) + angledist(MLT_centers(this_mlt_idx(1))*pi/12, MLT_centers(this_mlt_idx(2))*pi/12, 'rad')*12/pi/2, 24);
  this_mlt_idx = kk;
  this_MLT_center = MLT_centers(kk);

  %% Plot model r^2
  h_r(kk) = super_subplot(nrows, ncols, (kk-1)*2 + 1, hspace, vspace, hmargin, vmargin);
  this_r = squeeze(nanmean(r(:,this_mlt_idx,:), 2));
  
  plot_meridional(L_edges, L_centers, lat_edges, lat_centers, this_r.^2, 'cax', cax_rsq, 'b_interp', b_interp, 'h_ax', h_r(kk));
  title(sprintf('MLT = %0.0f', this_MLT_center));
  c = colorbar;
  ylabel(c, 'r^2');
  
  %% Plot effective number of samples
  h_n_eff(kk) = super_subplot(nrows, ncols, (kk-1)*2 + 2, hspace, vspace, hmargin, vmargin);
  this_n_eff = squeeze(nansum(n_eff(:,this_mlt_idx,:), 2));
  
  plot_meridional(L_edges, L_centers, lat_edges, lat_centers, log10(this_n_eff), 'cax', cax_n_eff, 'b_interp', b_interp, 'h_ax', h_n_eff(kk));
  title(sprintf('MLT = %0.0f', this_MLT_center));
  c = colorbar;
  ylabel(c, 'log_{10} n_{eff}');
end

increase_font;

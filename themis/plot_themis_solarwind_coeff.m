function plot_themis_solarwind_coeff
% Compare per-bin coefficients for THEMIS solar wind regression model

% By Daniel Golden (dgolden1 at stanford dot edu) November 2011
% $Id$

%% Setup
close all;

%% Load data
regress_filename = fullfile(vlfcasestudyroot, 'themis_emissions', 'themis_hiss_solarwind_regression.mat');
load(regress_filename, 'L_edges', 'L_centers', 'MLT_edges', 'MLT_centers', 'beta');

features_filename = fullfile(vlfcasestudyroot, 'themis_emissions', 'themis_hiss_solarwind_features.mat');
load(features_filename, 'X_names');

% output_dir = '~/temp';
output_dir = '/home/dgolden/vlf/presentations/2011-12-15_AGU_statistical_hiss_prediction/images';

%% Plot L-MLT maps
[L_mat, MLT_mat] = ndgrid(L_centers, MLT_centers);

idx_plot = ~cellfun(@isempty, beta);
beta_plot = cell2mat(beta(idx_plot).').'; % matrix: num bins by num betas
for kk = 1:numel(beta{1})
  plot_l_mlt(L_mat(idx_plot), MLT_mat(idx_plot), L_edges, MLT_edges,  beta_plot(:, kk), 'scaling_function', 'none', 'b_shading_interp', false);
%   plot_l_mlt(L_mat(idx_plot), MLT_mat(idx_plot), L_edges, MLT_edges,  beta_plot(:, kk), 'scaling_function', 'none');
  axis off
  axis([-1 1 -1 1]*10)
  
%   % Allow use of the 'interp' facecolor style with NaNs (bins with 0s on a
%   % log scale)
%   cax = caxis;
%   cdata = get(findobj(gca, 'type', 'surface'), 'cdata');
%   cdata(isnan(cdata)) = -inf;
%   [new_image_data, new_color_map, new_cax] = colormap_white_bg(cdata, jet, cax);
%   set(findobj(gca, 'type', 'surface'), 'cdata', new_image_data);
%   colormap(jet_with_white); % I'm supposed to use 'new_color_map' here, but jet_with_white is more aesthetic
%   caxis(new_cax);

  
  if kk == 1
    this_name = 'constant';
  else
    this_name = X_names{kk - 1};
  end
  c = colorbar;
  ylabel(c, sprintf('%s', kk, strrep(strrep(this_name, '_', '\_'), '^', '\^')));
  
  increase_font
  
%   figure_grow(gcf, 0.6, 0.5);
%   output_filename = fullfile(output_dir, sprintf('raw_regress_coeff_%02d_map.png', kk));
  output_filename = fullfile(output_dir, sprintf('raw_regress_coeff_%02d_map.png', kk));
  print('-dpng', '-r120', output_filename);
  unix(sprintf('mogrify -trim -density 2 -resample 1 %s', output_filename));
%   unix(sprintf('mogrify -trim %s', output_filename));
  fprintf('Wrote %s\n', output_filename);
end

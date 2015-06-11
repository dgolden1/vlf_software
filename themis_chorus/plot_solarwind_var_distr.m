function plot_solarwind_var_distr
% Plot distributions of solar wind parameters

% By Daniel Golden (dgolden1 at stanford dot edu) May 2012
% $Id$

close all;

qd = load(fullfile(vlfcasestudyroot, 'indices', sprintf('QinDenton_01min_pol_them.mat')));
fn = fieldnames(qd);
fn = fn(~strcmp(fn, 'epoch')); % Remove epoch

for kk = 1:length(fn)
  name = fn{kk};
  var = qd.(fn{kk});
  [f, xi] = ksdensity(var);
  
  figure;
  plot(xi, f, 'linewidth', 2);
  grid on;
  
  xlabel(strrep(name, '_', '\_'));
  ylabel('PDF');
  title('PDF, 10, 50, 90% percentiles shown');
  
  quantiles = quantile(var, [0.1 0.5 0.9]);
  
  hold on;
  plot(quantiles, interp1(xi, f, quantiles), 'ro', 'markerfacecolor', 'r', 'markersize', 10);
  
  increase_font(gcf, 18);
  
  output_filename = sprintf('~/temp/solarwind_pdf_%s.png', name);
  print('-dpng', '-r90', output_filename);
  mogrify('-trim', output_filename, true);
end

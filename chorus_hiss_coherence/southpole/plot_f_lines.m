function plot_f_lines(f)
% Plot frequency lines on radial cumulative spectrogram

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$


r_min = 0.3;
r_max = 1;
theta = linspace(0, 2*pi, 50);
linecolor = [1 1 1]*0.5;
f_plot = [300, 1e3, 3e3, 1e4, 3e4];
for kk = 1:length(f_plot)
  if kk == length(f_plot)
    textcolor = [1 1 1]*1;
  else
    textcolor = [1 1 1]*1;
  end
  
  if f_plot(kk) < 1e3
    this_f = f_plot(kk);
    suffix = 'Hz';
  else
    this_f = f_plot(kk)/1e3;
    suffix = 'kHz';
  end
  
%   r = r_min + (log10(f_plot(kk)) - log10(min(f)))/(log10(max(f)) - log10(min(f)))*(r_max - r_min); % Assume f_min = r_min
  r = r_min + (log10(max(f)) - log10(f_plot(kk)))/(log10(max(f)) - log10(min(f)))*(r_max - r_min); % Assume f_min = r_min
  plot(r*cos(theta), r*sin(theta), '--', 'color', linecolor, 'linewidth', 1);
%   text(r, 0, sprintf('%d', f_plot(kk)), 'color', textcolor, 'fontweight', 'bold', 'horizontalalignment', 'left', 'verticalalignment', 'middle');
  text(0, -r, sprintf('%d %s', this_f, suffix), 'color', textcolor, 'fontweight', 'bold', 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
end

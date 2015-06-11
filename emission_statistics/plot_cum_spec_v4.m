function plot_cum_spec_v4(datenums, f, columns, varargin)
% A cleaner, more general version of plot_cum_spec
% 
% Plot a cumulative spectrogram, where columns are placed in the image
% according to their datenum, and columns which share a datenum are
% averaged together
% 
% plot_cum_spec(datenums, f, columns, 'param', value, ...)
% 
% INPUTS
% datenums: list of n datenums which correspond to the input columns;
%  should be between 0 and 1.
% f: vector of m frequencies (the y-axis)
% columns: mxn matrix of n columns, each of which has length m, where m is
%  the length of m
% 
% PARAMETERS
% min_img_val: minimum value in the columns (e.g., in dB)
% norm_datenums: a vector of all datenums for which we have data, whether
%  there's an emission or not; used to normalize the plot by samples
%  instead of by number of emissions
% b_radial: plot a radial view instead of a flat one
% mlt_offset: MLT offset in hours from utc; e.g., what is the MLT here at
%  midnight UTC
% freq_lines: if plotting radially, plot these grid lines of constant
% frequency
% h_ax: axis on which to plot

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('min_img_val', -20);
p.addParamValue('norm_datenums', []);
p.addParamValue('b_radial', false);
p.addParamValue('mlt_offset', 0);
p.addParamValue('freq_lines', []);
p.addParamValue('h_ax', []);
p.parse(varargin{:});
min_img_val = p.Results.min_img_val;
norm_datenums = p.Results.norm_datenums;
b_radial = p.Results.b_radial;
mlt_offset = p.Results.mlt_offset;
freq_lines = p.Results.freq_lines;
h_ax = p.Results.h_ax;

%% Convert to MLT
assert(all(datenums >= 0 & datenums < 1));
datenums = mod(datenums + mlt_offset/24, 1);

if ~isempty(norm_datenums)
  norm_datenums = fpart(norm_datenums);
  norm_datenums = mod(norm_datenums + mlt_offset/24, 1);
end

%% Make sure columns are spaced appropriately
% assert(length(datenums) == size(columns, 2));
% 
% dt_vec = diff(sort(datenums));
% assert(all(dt_vec == 0 | dt_vec >= 1/86400)); % Make sure columns are spaced more than 1 second apart
% 
% dt = min(dt_vec(dt_vec ~= 0));
% tlim = [min(datenums), max(datenums)];

% t = tlim(1):dt:tlim(2);
% t = sort(mod(min(datenums):dt:(min(datenums)+1-dt), 1));
t = 0:1/96:(1 - 1/96);

%% Cycle through events and add them to the spectrogram
cum_spec = nan(length(f), length(t));
cum_spec_count = zeros(1, length(t));

idx_list = interp1(t, 1:length(t), datenums, 'nearest', 'extrap');
for kk = 1:length(datenums)
  f_idx = ~isnan(columns(:, kk));
  cum_spec(f_idx & isnan(cum_spec(:, idx_list(kk))), idx_list(kk)) = 0;
  cum_spec(f_idx, idx_list(kk)) = cum_spec(f_idx, idx_list(kk)) + max(0, columns(f_idx, kk) - min_img_val);
  cum_spec_count(idx_list(kk)) = cum_spec_count(idx_list(kk)) + 1;
  
%   imagesc(t, f, cum_spec); axis xy; colorbar;
end

%% Normalize by number of samples in each bin
if ~isempty(norm_datenums)
  n_total = histc(norm_datenums, [t inf]); n_total = n_total(1:end-1);
  
  cum_spec_norm = cum_spec./repmat(n_total(:).', length(f), 1) + min_img_val;
else
  cum_spec_norm = cum_spec./repmat(cum_spec_count, length(f), 1) + min_img_val;
end

%% Set only areas without data to nan
min_n_samples = 10; % Epochs without this many samples are set to nan

cum_spec_norm(isnan(cum_spec_norm)) = min_img_val;
cum_spec_norm(:, n_total < min_n_samples) = nan;

%% Plot radial spectrogram
if ~isempty(h_ax)
  axes(h_ax);
else
  figure;
end
  
if b_radial
  r_min = 0.3;
  r_max = 1;
  theta = mod(t*2*pi + pi, 2*pi);
  theta = [theta, theta(1)]; % Add the first value again or the plot won't close
  r = r_min + (max(f) - f)/(max(f) - min(f))*(r_max - r_min);
  [Theta, R] = meshgrid(theta, r);
  X = R.*cos(Theta);
  Y = R.*sin(Theta);
  
  hold on;
  
  p = pcolor(X, Y, [cum_spec_norm, cum_spec_norm(:, 1)]);
  set(p, 'linestyle', 'none');
  title('Cumulative Spectrogram');
  set(p, 'facecolor', 'interp');
  
  % Plot day/night disc
  patch_r_max = r_min*0.75;
  patch_r_min = 0;
  patch_t = linspace(-pi/2, pi/2);
  patch_x = [patch_r_min*cos(patch_t), patch_r_max*cos(fliplr(patch_t))];
  patch_y = [patch_r_min*sin(patch_t), patch_r_max*sin(fliplr(patch_t))];
  patch(patch_x, patch_y, 'w');
  patch(-patch_x, patch_y, 'k');
  
  % Plot radial lines
  hours = 0:2:23;
  line_color = [1 1 1]*0;
  for kk = 1:length(hours)
    theta = hours(kk)/24*2*pi + pi;
    plot([r_min*cos(theta), r_max*cos(theta)], [r_min*sin(theta), r_max*sin(theta)], '--', 'color', line_color);
  end
  
  % Plot frequency lines
  theta = linspace(0, 2*pi, 50);
  for kk = 1:length(freq_lines)
    r_fl = r_min + (max(f) - freq_lines(kk))/(max(f) - min(f))*(r_max - r_min);
    plot(r_fl*cos(theta), r_fl*sin(theta), '--', 'color', line_color);
%     text(0, -r_fl, sprintf('%0.0f', freq_lines(kk)), 'color', line_color, ...
%       'verticalalignment', 'middle', 'horizontalalignment', 'center', 'fontweight', 'bold');
  end
  

  axis square tight off

%% Plot spectrogram
else
  imagesc(t, f, cum_spec_norm);
  axis xy;
  title('Cumulative Spectrogram');
  xlabel('Time');
  ylabel('Freq');
  set(gca, 'tickdir', 'out');
  grid on;
end

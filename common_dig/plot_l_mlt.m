function varargout = plot_l_mlt(L_values, MLT_values, L_edges, MLT_edges, durations, varargin)
% [N, r, theta] = plot_l_mlt(L_values, MLT_values, L_edges, MLT_edges, durations, 'param', value, ...)
% 
% Plot a histogram of data distributed in L and MLT
% 
% INPUTS
% L_values: L values of a given sample (Re)
% MLT_values: MLT values of a given sample (hours)
% L_edges: edges of L bins
% MLT_edges: edges of MLT bins, generally including both 0 and 24 (e.g.,
% 0:24)
% durations: amount of time for each sample.  If durations is a scalar, it
% is assumed that all samples have equal duration.  The resulting plot will
% have the same units as durations, whatever that is (e.g., seconds,
% minutes, samples, whatever).
% h_ax: optional axis handle
% 
% PARAMETERS
% L_weights: vector of weights for the L bins; should be length 
%  length(L_edges)-1
% MLT_weights: vector of weights for the MLT bins; should be length
%  length(MLT_edges)-1
% MLT_gridlines: array of MLTs on which to plot grid lines (default: 0:23)
% h_ax: axis on which to plot
% scaling_function: function to apply to scale the values of the histogram
%  bins (default: @log10).  Use 'none' for no scaling.
% solid_lines_L: L shells at which to mark solid lines, helpful for
% counting shells if there are a lot (default: [])
% b_plot: set to false to not plot (useful to only get the resulting
%  histogram without making a plot)
% b_shading_interp: true (default) to use interpolated shading.  False to
%  use flat shading.  This fixes the way that pcolor's flat shading has the
%  grid points offset from the vertices in a funny way
% b_oversample_mlt: Set to true to to oversample MLT when using
%  flat shading. This just has the effect of "rounding" the azimuthal part
%  of bin edges when using wide bins; the intra-bin colors and MLT edges do
%  not change. Default: false
% b_white_zeros: true (default) to set bins with height of 0 to nan, so
%  they appear white when plotted
% 
% OUTPUTS
% N: histogram value (NOT scaled by the scaling_function)
% r: plot radius
% theta: plot angle

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('h_ax', []);
p.addParamValue('L_weights', ones(length(L_edges) - 1, 1));
p.addParamValue('MLT_weights', ones(length(MLT_edges) - 1, 1));
p.addParamValue('MLT_gridlines', 0:23);
p.addParamValue('scaling_function', @log10);
p.addParamValue('solid_lines_L', []);
p.addParamValue('b_plot', true);
p.addParamValue('b_shading_interp', true);
p.addParamValue('b_oversample_mlt', false);
p.addParamValue('b_white_zeros', true);
p.parse(varargin{:});
h_ax = p.Results.h_ax;
L_weights = p.Results.L_weights;
MLT_weights = p.Results.MLT_weights;
MLT_gridlines = p.Results.MLT_gridlines;
scaling_function = p.Results.scaling_function;
solid_lines_L = p.Results.solid_lines_L;
b_plot = p.Results.b_plot;
b_shading_interp = p.Results.b_shading_interp;
b_oversample_mlt = p.Results.b_oversample_mlt;
b_white_zeros = p.Results.b_white_zeros;

if ischar(scaling_function) && strcmpi('none', scaling_function)
  scaling_function = @(x) x; % No function
end

%% Setup
if ~b_shading_interp
  % If we don't do this, pcolor doesn't plot the outermost bin
  L_edges = [L_edges(:); L_edges(end) + diff(L_edges(end-1:end))];
  if all(L_weights == 1) && length(L_weights) == length(L_edges) - 2
    L_weights = [L_weights; 1];
  end
end

[L_mat, MLT_mat] = ndgrid(L_edges + diff(L_edges(1:2))/2, MLT_edges + diff(MLT_edges(1:2))/2);

if any(isnan(L_values) | isnan(MLT_values))
  error('L_values and MLT_values may not have NaN values');
end

MLT_values = mod(MLT_values, 24);

%% Make histogram
if isscalar(durations)
  N = hist3([L_values(:), MLT_values(:)], 'edges', {L_edges, MLT_edges});
  N = N*durations;
  
  if sum(MLT_edges == 0) ~= 1 || sum(MLT_edges == 24) ~= 1
    error('MLT_edges must contain both 0 and 24 for scalar duration');
  end
  
else
  if numel(durations) ~= numel(L_values)
    error('Length of durations, MLT_values and L_values must be the same');
  end
  
%   % Throw away NaN durations
%   idx_valid = isfinite(durations);
%   L_values = L_values(idx_valid);
%   MLT_values = MLT_values(idx_valid);
%   durations = durations(idx_valid);
  if any(isnan(durations))
    error('durations may not have NaN values');
  end
  
  % The FAST way to bin the data
  numbins = length(L_edges)*length(MLT_edges);
  [~, idx_L] = histc(L_values, L_edges);
  [~, idx_MLT] = histc(MLT_values, MLT_edges);
  % Allow a bin that spans midnight, which will start at a negative time
  % In this case, the first bin edge is negative, and the last bin edge is
  % the same MLT, mod 24, as the first edge
  if MLT_edges(1) < 0 && mod(MLT_edges(1), 24) == mod(MLT_edges(end), 24)
    idx_MLT(idx_MLT == 0) = 1;
  end
  
  
  idx_valid = idx_L > 0 & idx_MLT > 0;
  
  IDX = sub2ind([length(L_edges) length(MLT_edges)], idx_L(idx_valid), idx_MLT(idx_valid));
  N = reshape(accumarray(IDX, durations(idx_valid), [numbins 1]), length(L_edges), length(MLT_edges));
    
  
%   % The SLOW way to bin the data (results are the same)
%   N_slow = zeros(length(L_edges), length(MLT_edges));
%   for row = 1:length(L_edges)-1
%     for col = 1:length(MLT_edges)-1
%       idx = L_values >= L_edges(row) & L_values < L_edges(row+1) & ...
%             MLT_values >= MLT_edges(col) & MLT_values < MLT_edges(col+1);
%       N_slow(row, col) = sum(durations(idx));
%     end
%   end

end

%% Apply weights
N(1:end-1, :) = N(1:end-1, :) .* repmat(L_weights(:), 1, size(N, 2));
N(:, 1:end-1) = N(:, 1:end-1) .* repmat(MLT_weights(:).', size(N, 1), 1);


%% Massage histogram values
% The value at MLT = 24 is the same as the value at MLT = 0
N(:, MLT_edges == 24) = N(:, MLT_edges == 0);

N(end, :) = [];

scaled_N = scaling_function(N);

zeros = N == 0;
if b_white_zeros
  scaled_N(zeros) = nan; % Make bins with no data white
end

%% Plot
if b_shading_interp
  r = L_mat(1:end-1, :);
  theta = (MLT_mat(1:end-1, :) + 12)*2*pi/24;
  
  if b_oversample_mlt
    theta = unwrap(theta.').'; % Oversampled flat shading doesn't work unless theta is unwrapped
    theta_diff = median(diff(theta(1,:)));
    oversample_factor = max(1, round(theta_diff*24/(2*pi)*2) - 1);
    if mod(oversample_factor, 2) == 0
      oversample_factor = oversample_factor - 1;
    end
    
    old_theta_vec = mod(theta(1,:), 2*pi);
    old_r = r(:,1);
    new_theta_vec = linspace(0, 2*pi, 49) + min(mod(old_theta_vec, 2*pi));
    theta = repmat(new_theta_vec, length(old_r), 1);
    r = repmat(old_r, 1, length(new_theta_vec));
    
    [old_theta_vec_sorted, sort_i] = sort(old_theta_vec(1:end-1));
    scaled_N_sorted = scaled_N(:, sort_i);
    old_theta_vec_sorted(end+1) = old_theta_vec_sorted(1) + 2*pi;
    scaled_N_sorted(:, end+1) = scaled_N_sorted(:, 1);
    
    % Interpolating NaNs is OK; we set 0 values to NaN
    warning('off', 'MATLAB:interp1:NaNinY');
    new_scaled_N = interp1(unwrap(old_theta_vec_sorted), scaled_N_sorted.', unwrap(new_theta_vec)).';
    warning('on', 'MATLAB:interp1:NaNinY');
    new_scaled_N(:,end) = new_scaled_N(:,1);

    old_scaled_N = scaled_N;
    scaled_N = new_scaled_N;
  end
else
  r = L_mat(1:end-1, :) - median(diff(L_edges))/2;
  theta = (MLT_mat(1:end-1, :) - median(diff(MLT_edges))/2 + 12)*2*pi/24;

  if b_oversample_mlt
    theta = unwrap(theta.').'; % Oversampled flat shading doesn't work unless theta is unwrapped

    oversample_factor = max(1, round(median(diff(theta(1,:)))*24/(2*pi)*2));

    old_idx = 1:size(r, 2);
    new_idx = linspace(old_idx(1), old_idx(end), (length(old_idx) - 1)*oversample_factor + 1);

    r = interp1(old_idx, r.', floor(new_idx), 'nearest').';
    theta = interp1(old_idx, theta.', new_idx).';

    nanwarn = warning('off', 'MATLAB:interp1:NaNinY');
    scaled_N = interp1(old_idx, scaled_N.', floor(new_idx), 'nearest').';
    warning(nanwarn.state, 'MATLAB:interp1:NaNinY');
  end
end

if b_plot
  if ~isempty(h_ax)
    saxes(h_ax);
  else
    figure;
    h_ax = gca;
  end

  p = pcolor(r.*cos(theta), r.*sin(theta), scaled_N);
  set(p, 'linestyle', 'none');
  if b_shading_interp
    set(p, 'facecolor', 'interp'); % Cell color is linearly interpolated from the value of its four vertices
  end

  xlabel('X_{SM}');
  ylabel('Y_{SM}');

  if b_shading_interp
    L_max = ceil(max(L_edges(:)));
  else
    % Don't include the last edge because we added one on in the SETUP
    % section to deal with the weird way that pcolor plots data on the
    % edges
    L_max = ceil(max(L_edges(1:end-1)));
  end
  make_mlt_plot_grid('h_ax', gca, 'L_max', L_max, 'MLT_gridlines', MLT_gridlines, 'solid_lines_L', solid_lines_L);

  axis([-1 1 -1 1]*L_max*1.05);
  axis equal
end

%% Output arguments
if nargout >= 1
  varargout{1} = N;
  varargout{2} = r;
  varargout{3} = theta;
  varargout{4} = scaled_N;
end

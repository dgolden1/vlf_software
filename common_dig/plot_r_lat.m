function varargout = plot_r_lat(R_values, lat_values, R_edges, lat_edges, durations, varargin)
% [N, r, theta] = plot_r_lat(R_values, lat_values, R_edges, lat_edges, durations, 'param', value, ...)
% 
% Plot a histogram of data distributed in R and magnetic latitude
% 
% INPUTS
% R_values: R values of a given sample (Re)
% lat_values: latitude values of a given sample (degrees)
% R_edges: edges of R bins
% lat_edges: edges of latitude bins
% durations: amount of time for each sample.  If durations is a scalar, it
% is assumed that all samples have equal duration.  The resulting plot will
% have the same units as durations, whatever that is (e.g., seconds,
% minutes, samples, whatever).
% h_ax: optional axis handle
% 
% PARAMETERS
% R_weights: vector of weights for the R bins; should be length 
%  length(R_edges)-1
% lat_weights: vector of weights for the lat bins; should be length
%  length(lat_edges)-1
% lat_gridlines: array of latitudes on which to plot grid lines (default:
%  -90:15:90 for data with negative latitudes or 0:15:90 for data with only
%  positive latitudes)
% L_gridlines: true to plot default L_gridlines, or specify specific L-shells to
%  plot (default: no L lines)
% h_ax: axis on which to plot
% scaling_function: function to apply to scale the values of the histogram
%  bins (default: @log10).  Use 'none' for no scaling.
% solid_lines_R: R values at which to mark solid lines, helpful for
%  counting lines if there are a lot (default: [])
% b_plot: set to false to not plot (useful to only get the resulting
%  histogram without making a plot)
% b_shading_interp: true (default) to use interpolated shading.  False to
%  use flat shading.  This fixes the way that pcolor's flat shading has the
%  grid points offset from the vertices in a funny way
% b_white_zeros: true (default) to set bins with height of 0 to nan, so
%  they appear white when plotted
% 
% OUTPUTS
% N: histogram value
% r: plot radius
% theta: plot angle

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('h_ax', []);
p.addParamValue('R_weights', ones(length(R_edges) - 1, 1));
p.addParamValue('lat_weights', ones(length(lat_edges) - 1, 1));
p.addParamValue('lat_gridlines', []);
p.addParamValue('L_gridlines', []);
p.addParamValue('scaling_function', @log10);
p.addParamValue('solid_lines_R', []);
p.addParamValue('b_plot', true);
p.addParamValue('b_shading_interp', true);
p.addParamValue('b_oversample_lat', false);
p.addParamValue('b_white_zeros', true);
p.parse(varargin{:});
h_ax = p.Results.h_ax;
R_weights = p.Results.R_weights;
lat_weights = p.Results.lat_weights;
scaling_function = p.Results.scaling_function;
solid_lines_R = p.Results.solid_lines_R;
b_plot = p.Results.b_plot;
b_shading_interp = p.Results.b_shading_interp;
b_oversample_lat = p.Results.b_oversample_lat;
b_white_zeros = p.Results.b_white_zeros;

% If there are negative latitude edges, extend latitude gridlines down to
% -90; otherwise, start at 0
lat_gridlines = p.Results.lat_gridlines;
if isempty(lat_gridlines)
  if any(lat_edges < 0)
    lat_gridlines = -90:15:90;
  else
    lat_gridlines = 0:15:90;
  end
end

L_gridlines = p.Results.L_gridlines;
if isscalar(L_gridlines) && ~L_gridlines
  L_gridlines = [];
elseif isscalar(L_gridlines) && islogical(L_gridlines) && L_gridlines
  L_gridlines = 2:1:ceil(max(R_edges));
end

if ischar(scaling_function) && strcmpi('none', scaling_function)
  scaling_function = @(x) x; % No function
end

%% Setup
if ~b_shading_interp
  % If we don't do this, pcolor doesn't plot the outermost bin
  R_edges = [R_edges(:); R_edges(end) + diff(R_edges(end-1:end))];
  if all(R_weights == 1) && length(R_weights) == length(R_edges) - 2
    R_weights = [R_weights; 1];
  end
end

R_centers = R_edges + diff(R_edges(1:2))/2;
lat_centers = lat_edges + diff(lat_edges(1:2))/2;
[R_mat, lat_mat] = ndgrid(R_centers, lat_centers);

if any(isnan(R_values) | isnan(lat_values))
  error('R_values and lat_values may not have NaN values');
end

% Wrap any latitudes outside the range -90 to 90 to that range
lat_values(abs(lat_values) > 90) = 180 - lat_values(abs(lat_values) > 90);


%% Make histogram
if isscalar(durations)
  N = hist3([R_values(:), lat_values(:)], 'edges', {R_edges, lat_edges});
  N = N*durations;
  
  if (sum(lat_edges == -90) ~= 1 && sum(lat_edges == 0) ~= 1) || sum(lat_edges == 90) ~= 1
    error('lat_edges must contain both -90 (or 0) and 90');
  end
  
else
  if numel(durations) ~= numel(R_values) || numel(R_values) ~= numel(lat_values)
    error('Length of durations, lat_values and R_values must be the same');
  end

  if any(isnan(durations))
    error('durations may not have NaN values');
  end
  
  % The FAST way to bin the data
  numbins = length(R_edges)*length(lat_edges);
  [~, idx_R] = histc(R_values, R_edges);
  [~, idx_lat] = histc(lat_values, lat_edges);
  idx_valid = idx_R > 0 & idx_lat > 0;
  
  IDX = sub2ind([length(R_edges) length(lat_edges)], idx_R(idx_valid), idx_lat(idx_valid));
  N = reshape(accumarray(IDX, durations(idx_valid), [numbins 1]), length(R_edges), length(lat_edges));
    
  
%   % The SLOW way to bin the data (results are the same)
%   N_slow = zeros(length(R_edges), length(lat_edges));
%   for row = 1:length(R_edges)-1
%     for col = 1:length(lat_edges)-1
%       idx = R_values >= R_edges(row) & R_values < R_edges(row+1) & ...
%             lat_values >= lat_edges(col) & lat_values < lat_edges(col+1);
%       N_slow(row, col) = sum(durations(idx));
%     end
%   end
end

%% Apply weights
N(1:end-1, :) = N(1:end-1, :) .* repmat(R_weights(:), 1, size(N, 2));
N(:, 1:end-1) = N(:, 1:end-1) .* repmat(lat_weights(:).', size(N, 1), 1);


%% Massage histogram values
% Chop off last R value (number of times R_values==R_edges(end), which is
% generally 0)
N(end, :) = [];

% Ditto for latitude if we're plotting using interpolated values
if b_shading_interp
  N(:, end) = [];
end

scaled_N = scaling_function(N);

zeros = N == 0;
if b_white_zeros
  scaled_N(zeros) = nan; % Make bins with no data white
end
%% Plot
if b_shading_interp
  r = R_mat(1:end-1, 1:end-1);
  theta = lat_mat(1:end-1, 1:end-1)*pi/180;
  
  if b_oversample_lat
    error('Not implemented');
    
    theta = unwrap(theta.').'; % Oversampled flat shading doesn't work unless theta is unwrapped
    theta_diff = median(diff(theta(1,:)));
    
    old_theta_vec = mod(theta(1,:), 2*pi);
    old_r = r(:,1);
    new_theta_vec = linspace(-pi/2, pi/2, 25) + min(mod(old_theta_vec, 2*pi));
    theta = repmat(new_theta_vec, length(old_r), 1);
    r = repmat(old_r, 1, length(new_theta_vec));
    
    [old_theta_vec_sorted, sort_i] = sort(old_theta_vec(1:end-1));
    scaled_N_sorted = scaled_N(:, sort_i);
    old_theta_vec_sorted(end+1) = old_theta_vec_sorted(1) + 2*pi;
    scaled_N_sorted(:, end+1) = scaled_N_sorted(:, 1);
    
    new_scaled_N = interp1(unwrap(old_theta_vec_sorted), scaled_N_sorted.', unwrap(new_theta_vec)).';
    new_scaled_N(:,end) = new_scaled_N(:,1);

    old_scaled_N = scaled_N;
    scaled_N = new_scaled_N;
  end
else
  r = R_mat(1:end-1, :) - median(diff(R_edges))/2;
  theta = (lat_mat(1:end-1, :) - median(diff(lat_edges))/2)*pi/180;

  if b_oversample_lat
    theta = unwrap(theta.').'; % Oversampled flat shading doesn't work unless theta is unwrapped

    oversample_factor = max(1, round(median(diff(theta(1,:)))*24/(2*pi)*4));

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
    shading interp; % Cell color is linearly interpolated from the value of its four vertices
  end

  xlabel('R');
  ylabel('Z');

  if b_shading_interp
    R_max = ceil(max(R_edges(:)));
  else
    % Don't include the last edge because we added one in the SETUP
    % section to deal with the weird way that pcolor plots data on the
    % edges
    R_max = ceil(max(R_edges(1:end-1)));
  end
  make_lat_plot_grid('h_ax', gca, 'R_max', R_max, 'lat_gridlines', lat_gridlines, ...
    'L_gridlines', L_gridlines, 'solid_lines_R', solid_lines_R);

  axis equal
  
  if any(lat_gridlines < 0)
    Y_min = -1;
  else
    Y_min = 0;
  end
  axis([0 1 Y_min 1]*R_max*1.05);
end

%% Output arguments
if nargout >= 1
  varargout{1} = N;
  varargout{2} = r;
  varargout{3} = theta;
end

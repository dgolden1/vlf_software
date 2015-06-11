function idx = xy_to_l_mlt_idx(xy, L_centers, MLT_centers, b_verbose)
% Get index into a matrix of L and MLT values based on x and y image
% coordinates (e.g., from ginput)
% 
% The matrix have size [length(L_centers), length(MLT_centers)], e.g., L
% should change with changing row, and MLT should change with changing
% column

%% Setup
if ~exist('b_verbose', 'var') || isempty(b_verbose)
  b_verbose = true;
end

x = xy(:,1);
y = xy(:,2);

if ~issorted(MLT_centers)
  error('MLT_centers must be sorted');
end

%% Convert to L/MLT and find indices
this_MLT = mod((atan2(y, x) + pi)*12/pi, 24);
this_L = sqrt(x^2 + y^2);

L_idx = interp1(L_centers, 1:length(L_centers), this_L, 'nearest', 'extrap');
MLT_idx = interp1(MLT_centers, 1:length(MLT_centers), this_MLT, 'nearest', 'extrap');

idx = sub2ind([length(L_centers), length(MLT_centers)], L_idx, MLT_idx);

%% Print
if isscalar(x) && b_verbose
  fprintf('Nearest bin: L=%0.1f, MLT=%0.0f hrs\n', L_centers(L_idx), MLT_centers(MLT_idx));
end

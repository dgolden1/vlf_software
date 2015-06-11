function chorus_ampl_map = run_chorus_model(X_all, X_names_all, model, lat)
% Run model to make an L-MLT map for a given time point
% X_in does NOT need to be for a single time point

% By Daniel Golden (dgolden1 at stanford dot edu) January 2012
% $Id$

%% Setup
% Get nearest lat index to this latitude
if length(model.lat_centers) > 1
  lat_idx = interp1(model.lat_centers, 1:length(model.lat_centers), lat, 'nearest', 'extrap');
else
  % We might not be parameterizing by latitude, so there's only one point
  lat_idx = 1;
end

% Get slices of variables for this latitude
beta = model.beta(:,:,lat_idx);
feature_names = model.feature_names(:,:,lat_idx);

% chorus_ampl_map(L, MLT, lat, epoch)
chorus_ampl_map = nan(size(model.beta, 1), size(model.beta, 2), size(model.beta, 3), size(X_all, 1));

%% Run model for each bin
for kk = 1:numel(chorus_ampl_map(:,:,:,1))
  % Skip bins with empty beta; these are ones with too few measurements for
  % a model
  if isempty(beta{kk}) || ~any(isfinite(beta{kk}))
    continue;
  end
  
  % For the subsequent "ismember" syntax to work, feature names need to be
  % sorted
  assert(issorted(X_names_all) && issorted(feature_names{kk}));

  % Parse out features for this bin
  X_in = X_all(:, ismember(X_names_all, feature_names{kk}));

  % Run the model for all the epochs at once
  [i, j, k] = ind2sub(size(chorus_ampl_map(:,:,:,1)), kk);
  chorus_ampl_map(i, j, k, :) = [ones(size(X_in, 1), 1) X_in]*beta{kk}; % log10(pT)
end

% If any of the predictors are invalid, just leave the whole map as NaNs
% instead of modeling the few bins that would work
invalid_vals = any(isnan(X_all), 2);
chorus_ampl_map(:,:,:,invalid_vals) = nan;


1;

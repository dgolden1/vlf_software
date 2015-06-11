function [selected_idx, X_names_selected, selected_idx_ordered] = them_chorus_select_features(X, X_names, y, epoch, max_num_features, b_verbose)
% Sequential feature selection for THEMIS/Polar data
% 
% OUTPUTS
% selected_idx: binary indices of X_names that were selected
% X_names_selected: equal to X_names(selected_idx)
% selected_idx_ordered: indices into X_names that were chosen, sorted by
%  selection order

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

%% Setup
b_parallel = false;

if ~exist('max_num_features', 'var') || isempty(max_num_features)
  max_num_features = Inf;
end
if ~exist('b_verbose', 'var') || isempty(b_verbose)
  b_verbose = true;
end

%% Do feature selection
if b_parallel && matlabpool('size') == 0
  matlabpool('open');
end
    
% The 'streams' business ensures that parallel computation is reproducable
if b_verbose
  opts = statset('display','iter');
else
  opts = statset('display','off');
end
if b_parallel
  opts = statset(opts, 'useparallel', 'always', 'UseSubstreams', 'always', 'Streams', RandStream('mlfg6331_64'));
end

% % Cross-validation with random partitioning
% [inmodel_orig_rand, history_rand] = sequentialfs(@sfsfun, X, y, 'options', opts);

% Cross-validation with contiguous partitioning
[inmodel_orig, history] = sequentialfs(@(x, y) sfsfun_contigpart(x, y, epoch), X, y, 'cv', 'none', 'options', opts);

% What if no features are selected?
if sum(inmodel_orig) == 0 || max_num_features == 0
  selected_idx = [];
  X_names_selected = {};
  selected_idx_ordered = [];
  return;
end

%% Reduce number of features if necessary
history.In = history.In(1:min(size(history.In, 1), max_num_features), :);
inmodel = history.In(end,:);

%% Print results
% Get order of variable selection
if size(history.In, 1) > 1
  d = [history.In(1,:); diff(history.In, 1)];
else
  d = history.In(1,:);
end

for kk = 1:size(d, 1)
  history_ordered(kk) = find(d(kk,:));
end

selected_idx = find(inmodel);

if b_verbose
  fprintf('Selected %d of %d features\n', sum(inmodel), length(inmodel));
  fprintf('\nSorted by rank:\n\n')
  for kk = 1:length(history_ordered)
    fprintf('%02d: %s\n', kk, X_names{history_ordered(kk)});
  end

  fprintf('Sorted by name:\n\n')
  for kk = 1:length(selected_idx)
    fprintf('%02d: %s\n', find(history_ordered == selected_idx(kk)), X_names{selected_idx(kk)});
  end
end

%% Save output variables
selected_idx_ordered = history_ordered;
X_names_selected = X_names(selected_idx);

1;

function criterion = sfsfun(xtrain, ytrain, xtest, ytest)
%% Function: sequential feature selection cross validation function

% Least squares regression criteria
b = [ones(size(ytrain)) xtrain]\ytrain;
yhat = [ones(size(ytest)) xtest]*b;
criterion = sum((ytest - yhat).^2);

function criterion = sfsfun_contigpart(x, y, epoch)
%% Function: sequential feature selection with contiguous partitioning during cross validation

% Partition data CONTIGUOUSLY using k-fold cross validation; data in the
% test set is contiguous. This is important for time-series data which is
% highly autocorrelated

kfold = 10;
[~, partition_idx_cell] = partition_contig_by_epoch(epoch, kfold);
criterion_vec = nan(kfold, 1);
for kk = 1:kfold
  idx_test = partition_idx_cell{kk};
  idx_train = ~idx_test;
  
  xtrain = x(idx_train, :);
  ytrain = y(idx_train);
  xtest = x(idx_test, :);
  ytest = y(idx_test);

  % Least squares regression criteria
  b = [ones(size(ytrain)) xtrain]\ytrain;
  yhat = [ones(size(ytest)) xtest]*b;
  criterion_vec(kk) = sum((ytest - yhat).^2);
end

criterion = sum(criterion_vec)/length(x);

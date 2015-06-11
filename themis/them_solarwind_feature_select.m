function [X_new, X_names_new] = them_solarwind_feature_select(Y, X, X_names, max_num_features)
% Select subset of predictors using cross-validation

% By Daniel Golden (dgolden1 at stanford dot edu) November 2011
% $Id$

% NOTE: Because it is "cheating" to use future time series values to
% predict earlier time series values, the proper way to do this
% cross-validation is to somehow force the test set to have exclusively
% later values than the training set.  But maybe it doesn't matter if we
% validate using normal regression instead of ARMAX...?

%% Setup
if ~exist('max_num_features', 'var') || isempty(max_num_features)
  max_num_features = inf;
end

% crossval_fun_name = 'armax';
crossval_fun_name = 'regress';

switch crossval_fun_name
  case 'armax'
    crossval_fun = @them_crossval_fun_armax;
  case 'regress'
    crossval_fun = @them_crossval_fun_regress;
end

%% Run sequential feature selection
fprintf('Running sequential feature selection using ''%s'' model\n', crossval_fun_name);

% The 'streams' business ensures that parallel computation is reproducable
opts = statset('display','iter', 'useparallel', 'always', 'UseSubstreams', 'always', 'Streams', RandStream('mlfg6331_64'));

warning('off', 'stats:parallel:NoMatlabpool'); % Allow multithreading without separate MDL workers
[~, history] = sequentialfs(crossval_fun, X, Y, 'options', opts);
warning('on', 'stats:parallel:NoMatlabpool');

% Only take max_num_features features
inmodel = history.In(min(size(history.In, 1), max_num_features), :);

X_new = X(:,inmodel);
X_names_new = X_names(inmodel);

1;

function criterion = them_crossval_fun_armax(X_train, Y_train, X_test, Y_test)
%% Function: cross-validation test function for ARMAX model

R = 1; % Num AR coefficients
M = 0; % Num MA coefficients
spec = garchset('R', R, 'M', M, 'display', 'off');
[Coeff,Errors,LLF,Innovations,Sigmas,Summary] = garchfit(spec, Y_train, X_train);

Y_hat = Coeff.C + Coeff.AR*mean(Y_test) + X_test*Coeff.Regress(:);

criterion = sum((Y_hat - Y_test).^2);

function criterion = them_crossval_fun_regress(X_train, Y_train, X_test, Y_test)
%% Function: cross-validation test function for regular regression model

b = [ones(size(Y_train)) X_train]\Y_train;
Y_hat = [ones(size(Y_test)) X_test]*b;

criterion = sum((Y_hat - Y_test).^2);

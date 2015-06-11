function [X, X_names] = set_up_predictor_matrix_ae_kp(epoch_combined, b_include_kp)
% Set up a predictor matrix of only Kp and AE* data 
% 
% This follows the method of Shprits et al, 2007, doi: 10.1029/2006GL029050

% By Daniel Golden (dgolden1 at stanford dot edu) October 2011
% $Id$

%% Setup
if ~exist('b_include_kp', 'var') || isempty(b_include_kp)
  b_include_kp = true;
end

ae = load(fullfile(vlfcasestudyroot, 'indices', 'ae_1min.mat'));
kp = load('kp.mat');


%% Solar wind predictors
X = zeros(length(epoch_combined), 0);
X_names = {};

if b_include_kp
  X(:, end+1) = interp1(kp.kp_date, kp.kp, epoch_combined);
  X_names{end+1} = 'kp';
end

[ae_star, ae_star_epoch] = get_ae_star_from_ae(ae.epoch, ae.ae);
X(:, end+1) = interp1(ae_star_epoch, ae_star, epoch_combined);
X_names{end+1} = 'ae_star';


assert(length(X_names) == size(X, 2)); % Make sure I didn't forget a name or index

1;

function themis_solarwind_armax(em_type, b_nnet, output_dir, pool_size)
% Predict THEMIS emission amplitude using solar wind

% By Daniel Golden (dgolden1 at stanford dot edu) October 2011
% $Id$

%% Setup
close all;

if ~exist('em_type', 'var') || isempty(em_type)
  em_type = 'hiss';
end
if ~exist('b_nnet', 'var') || isempty(b_nnet)
  b_nnet = false;
end
if ~exist('output_dir', 'var') || isempty(output_dir)
  if b_nnet
    [~, hostname] = system('hostname');
    if strcmp(hostname(1:end-1), 'quadcoredan.stanford.edu')
      output_dir = '/home/dgolden/temp';
    else
      output_dir = '/home/dgolden/shared/them_sw_regress'; % Nansen
    end
  else
    output_dir = fullfile(vlfcasestudyroot, 'themis_emissions');
  end
end


% Parallel
if exist('pool_size', 'var') && ~isempty(pool_size) && matlabpool('size') == 0
  matlabpool('open', pool_size);
end    

b_use_kp_ae = false;


%% Load THEMIS data
t_them_start = now;
[epoch_combined, them_combined] = get_combined_them_power(em_type);
fprintf('Loaded THEMIS data in %s\n', time_elapsed(t_them_start, now));


%% Set up predictor matrix
t_pred_start = now;
if b_use_kp_ae
  b_include_kp = false;
  [X, X_names_full] = set_up_predictor_matrix_ae_kp(epoch_combined, b_include_kp);
  X_in = X;
else
  % Load selected feature names
  feature_filename = fullfile(vlfcasestudyroot, 'themis_emissions', 'themis_hiss_solarwind_features.mat');
  load(feature_filename, 'X_names');
  
  % Get rid of the L and MLT features; they're not needed anymore since
  % we're binning by L and MLT
  X_names(ismember(X_names, {'abs(log(them_combined.L - 1) - log(4 - 1))', 'cos(them_combined.MLT/24*2*pi)'})) = [];
  [X, X_names_full] = set_up_predictor_matrix_v1(epoch_combined, 'them_combined', them_combined);

%   X_names(~cellfun(@isempty, strfind(X_names, 'them_combined'))) = [];
%   [X, X_names_full] = set_up_predictor_matrix_v1(epoch_combined);
  
  assert(sum(ismember(X_names_full, X_names)) == length(X_names));
  X_in = X(:, ismember(X_names_full, X_names));
  
  assert(length(X_names) == size(X_in, 2));
end

idx_sample_valid = them_combined.field_power > 0 & all(isfinite(X), 2);
Y_in = log10(them_combined.field_power(idx_sample_valid));
X_in = X_in(idx_sample_valid, :);

fprintf('Generated predictor matrix in %s\n', time_elapsed(t_pred_start, now));


%% Make a different model for each L/MLT bin

dL = 1;
L_edges = 2:dL:10;
L_centers = L_edges + dL/2;

dMLT = 2;
MLT_edges = 0:dMLT:24;
MLT_centers = MLT_edges + dMLT/2;

% Bin by L and MLT (stolen from plot_l_mlt.m)
[~, idx_L] = histc(them_combined.L(idx_sample_valid), L_edges);
[~, idx_MLT] = histc(them_combined.MLT(idx_sample_valid), MLT_edges);

% Initialize output matrices
r = nan(length(L_centers), length(MLT_centers)); % Correlation coefficient between Y_in and Y_hat from model
beta = cell(size(r)); % Regression coefficients on X_in
Y = cell(size(r));
X = cell(size(r));
Y_hat = cell(size(r));
n = nan(size(r));
n_eff = nan(size(r));

if b_nnet
  net = cell(size(r));
end

mat_size = size(r);
r_numel = prod(mat_size);

t_start = now;
progress_temp_dirname = parfor_progress_init;

% warning('Parfor disabled!');
% for kk = 1:r_numel
parfor kk = 1:r_numel
  t_bin_start = now;

  [row, col] = ind2sub(mat_size, kk);
  idx = idx_L == row & idx_MLT == col;
  n(kk) = sum(idx);

  % Perform the modeling
  if sum(idx) < 3
    % The AR(1) coefficient isn't defined for fewer than 3 samples
    n_eff(kk) = sum(idx);
    continue;
  else
    n_eff(kk) = effective_data_size(Y_in(idx));
  end

  % Only make a model if the effective data size is 10 times larger than
  % the number of model predictors
  if n_eff(kk) >= 10*size(X_in, 2)
    if b_nnet
      [net{kk}, r(kk), Y_hat{kk}] = model_one_bin_nnet(Y_in(idx), X_in(idx,:));
    else
      [beta{kk}, r(kk), Y_hat{kk}] = model_one_bin_regress(Y_in(idx), X_in(idx,:));
    end
    Y{kk} = Y_in(idx);
    X{kk} = X_in(idx,:);
  end

  iteration_number = parfor_progress_step(progress_temp_dirname, kk);
  fprintf('Modeled bin %d of %d (L = %0.2f, MLT = %0.1f) in %s\n', ...
    iteration_number, r_numel, L_centers(row), MLT_centers(col), ...
    time_elapsed(t_bin_start, now));
end
parfor_progress_cleanup(progress_temp_dirname);

fprintf('Modeling complete for %d bins in %s\n', length(L_centers)*length(MLT_centers), time_elapsed(t_start, now));

if b_nnet
  net = reshape(net, size(r));
else
  net = [];
end

%% Plot map of correlation coefficients
dL = median(diff(L_edges));
dMLT = median(diff(MLT_edges));
[L_mat, MLT_mat] = ndgrid(L_centers, MLT_centers);

% Plot effective number of samples
idx_plot = isfinite(log10(n_eff));
plot_l_mlt(L_mat(idx_plot), MLT_mat(idx_plot), L_edges, MLT_edges,  log10(n_eff(idx_plot)), ...
  'scaling_function', 'none', 'b_shading_interp', false, 'b_oversample_mlt', true, 'MLT_gridlines', 0:2:22);
c = colorbar;
ylabel(c, 'log_{10} Effective sample size');
cax = caxis;
c_tick = ceil(cax(1)):floor(cax(2));
set(c, 'ytick', c_tick);
title(sprintf('Bin size is %0.1f L and %0.0f hrs MLT', dL, dMLT));
increase_font;

% Plot model performance
% bins.r(:,end) = bins.r(:,1);
idx_plot = isfinite(r);
plot_l_mlt(L_mat(idx_plot), MLT_mat(idx_plot), L_edges, MLT_edges, r(idx_plot).^2, ...
  'scaling_function', 'none', 'b_shading_interp', false, 'b_oversample_mlt', true, 'MLT_gridlines', 0:2:22);
c = colorbar;
ylabel(c, 'r^2');
increase_font;


%% Save output
if b_use_kp_ae
  if b_include_kp
    output_filename = fullfile(output_dir, 'themis_hiss_solarwind_regression_kp_ae.mat');
  else
    output_filename = fullfile(output_dir, 'themis_hiss_solarwind_regression_kp.mat');
  end
elseif b_nnet
  output_filename = fullfile(output_dir, 'themis_hiss_solarwind_regression_nnet.mat');
else
  output_filename = fullfile(output_dir, 'themis_hiss_solarwind_regression.mat');
end

t_save_start = now;
save(output_filename, 'L_edges', 'L_centers', 'MLT_edges', 'MLT_centers', 'X_names', ...
  'r', 'beta', 'Y', 'X', 'Y_hat', 'n_eff', 'net');
fprintf('Saved %s in %s\n', output_filename, time_elapsed(t_save_start, now));

% Find bin using ginput
% [x, y] = ginput(1);
% L = sqrt(x^2 + y^2);
% MLT = mod((atan2(y, x) + pi)*24/(2*pi), 24);
% idx = sub2ind(size(bins.r), interp1(L_centers, 1:length(L_centers), L, 'nearest'), ...
%   interp1(MLT_centers, 1:length(MLT_centers), MLT, 'nearest'))


function [b, r, Y_hat] = model_one_bin_regress(Y_in, X)
%% Function: make a model for a single L/MLT bin

%% Feature Selection via cross-validation

% t_cross_start = now;
% fprintf('Feature selection begun at %s; %d features to check for %d samples\n', ...
%   datestr(t_cross_start), size(X_orig, 2), size(X_orig, 1));
% [X_in, X_names] = them_solarwind_feature_select(Y_in, X_orig, X_names_orig);
% fprintf('Selected %d of %d features in %s\n', size(X_in, 2), size(X_orig, 2), time_elapsed(t_cross_start, now));


%% Run regression model

% R = 1; % Num AR coefficients
% M = 0; % Num MA coefficients
% spec = garchset('R', R, 'M', M, 'display', 'off');
% [Coeff,Errors,LLF,Innovations,Sigmas,Summary] = garchfit(spec, Y_in, X_in);
% Y_hat = Coeff.C + Coeff.AR*mean(Y_in) + X_in*Coeff.Regress.';
% 
% garchdisp(Coeff, Errors);
% 
% % See Chatterjee and Hadi (book) pages 33-34
% tvals = [Coeff.C, Coeff.AR, Coeff.Regress]./[Errors.C, Errors.AR, Errors.Regress];
% pvals = tcdf(-abs(tvals), length(Y_in) - size(X_in, 2) - R - M - 1)*2;
% 
% fprintf('p-values:\n');
% fprintf('%0.3f: %s\n', pvals(1), 'constant');
% fprintf('%0.3f: %s\n', pvals(2), 'AR(1)');
% for kk = 1:size(X_in, 2)
%   this_name = X_names{kk};
%   this_p = pvals(kk+2);
%   fprintf('%0.3f: %s\n', this_p, this_name);
% end
% 

b = [ones(size(Y_in)) X]\Y_in;
Y_hat = [ones(size(Y_in)) X]*b;
r = corr(Y_in, Y_hat);

% fprintf('r = %0.2f; model explains %0.0f%% of variance\n', r, r^2*100);
% scatter(Y_in, Y_hat);
% box on
% hold on;
% plot([min(Y_in) max(Y_in)], [min(Y_in) max(Y_in)], 'r-');
% axis equal
% xlabel('Y_{in}');
% ylabel('Y_{out}');
% title(sprintf('r^2 = %0.2f', r^2));
% 
% output_filename = '~/temp/blah.mat';
% save(output_filename);
% fprintf('Saved %s\n', output_filename);

function [net, r, Y_hat] = model_one_bin_nnet(Y_in, X)

inputs = X.';
targets = Y_in.';

% Create a Fitting Network
hiddenLayerSize = 5;
net = fitnet(hiddenLayerSize);

% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

% Make the stopping conditions more lax so training the network doesn't
% take so bloody long
net.trainParam.min_grad = 1e-4;
net.trainParam.epochs = 100;

% Train the Network
net.trainParam.showWindow = 0;
[net,tr] = train(net,inputs,targets);

% Test the Network
outputs = net(inputs);
errors = gsubtract(targets,outputs);
performance = perform(net,targets,outputs);

Y_hat = outputs.';

% Plot performance
% plotperf(tr);
% plotregression(targets(tr.trainInd), outputs(tr.trainInd), 'Main', ...
%   targets(tr.valInd), outputs(tr.valInd), 'Validation', ...
%   targets(tr.testInd), outputs(tr.testInd), 'Test', ...
%   targets, outputs, 'Total');

r = corr(Y_in, Y_hat);

1;

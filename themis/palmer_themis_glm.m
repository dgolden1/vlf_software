function palmer_themis_glm(em_type)
% Make a generalized linear model or neural network to predict THEMIS hiss
% amplitude from various geophysical parameters and Palmer

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Setup
close all;

if ~exist('em_type', 'var') || isempty(em_type)
  em_type = 'hiss';
end

load(sprintf('palmer_themis_common_epoch_%s.mat', em_type), 'epoch', 'palmer_em_pow', 'them');

%% Multiple regression model
glm_palmer_only(epoch, palmer_em_pow, them);
% glm_ampl(epoch, palmer_em_pow, them);
% nnet_ampl(epoch, palmer_em_pow, them);
% glm_prob(epoch, palmer_em_pow, them);

function [X, X_names, idx_palmer_dark, idx_palmer_light] = set_up_predictor_matrix_pt(palmer_power_combined, them_combined, epoch_combined, varargin)
%% Function: set up the predictor matrix

%% Parse input arguments
p = inputParser;
p.addParamValue('optimize_for', 'none');
p.parse(varargin{:});
optimize_for = p.Results.optimize_for;

%% Setup
palmer_mlt_offset = -4; % local MLT at midnight UTC

darkness = load('palmer_darkness.mat', 'epoch', 'idx_darkness', 'time_to_term');
qd_15min = load('QinDenton_15min_2008-2010.mat', 'epoch', 'ByIMF', 'BzIMF', 'Pdyn', 'V_SW', 'Dst', 'AE');

% Solar wind coupling function from [Newell et al., 2007,
% doi:10.1029/2006JA012015]
qd_15min.Bt = sqrt(qd_15min.ByIMF.^2 + qd_15min.BzIMF.^2); % Transverse B
qd_15min.theta_c = atan2(qd_15min.ByIMF, qd_15min.BzIMF); % IMF clock angle
qd_15min.dphi_mp_dt = qd_15min.V_SW.^(4/3).*qd_15min.Bt.^(2/3).*abs(sin(qd_15min.theta_c/2).^(8/3));
qd_15min.p12_dphi_mp_dt = sqrt(qd_15min.Pdyn).*qd_15min.dphi_mp_dt; % This function correlates best with Dst

% Other solar wind coupling functions
qd_15min.Ewv = abs(qd_15min.V_SW.^(4/3).*qd_15min.Bt.*sin(qd_15min.theta_c/2).^4.*qd_15min.Pdyn.^(1/6)); % [Vasyliunas et al, 1982]
qd_15min.Ewav = abs(qd_15min.V_SW.*qd_15min.Bt.*sin(qd_15min.theta_c/2).^4); % [Wygant et al, 1983]
qd_15min.vBs = qd_15min.V_SW.*max(0, qd_15min.BzIMF); % [Burton et al, 1975]


[~, month] = datevec(epoch_combined);

%% Set up individual predictors
X = zeros(length(epoch_combined), 0);
X_names = {};

% We intentionally interpolate across vectors containing NaNs (particularly
% the TS05 vectors) since we want the output values to be NaN where the
% interpolation isn't valid.  glmfit() deals with this automatically.
warning('off', 'MATLAB:interp1:NaNinY');

% 0-N hour history of parameters
n_hours_history = 0:4;
for kk = 1:length(n_hours_history)
  this_n_hours_history = n_hours_history(kk);
  if this_n_hours_history == 0
    this_time_range = [0 0];
  else
    this_time_range = [-this_n_hours_history -(this_n_hours_history - 1)]/24;
  end
  
  X(:, end+1) = avg_var_history(qd_15min.epoch, qd_15min.AE, epoch_combined, this_time_range);
  X(:, end+1) = avg_var_history(qd_15min.epoch, qd_15min.Dst, epoch_combined, this_time_range);
  X(:, end+1) = log10(avg_var_history(qd_15min.epoch, qd_15min.Pdyn, epoch_combined, this_time_range));
  X(:, end+1) = max(0, avg_var_history(qd_15min.epoch, qd_15min.BzIMF, epoch_combined, this_time_range));
  X(:, end+1) = avg_var_history(qd_15min.epoch, qd_15min.dphi_mp_dt, epoch_combined, this_time_range);
  X(:, end+1) = avg_var_history(qd_15min.epoch, qd_15min.p12_dphi_mp_dt, epoch_combined, this_time_range);
  X(:, end+1) = avg_var_history(qd_15min.epoch, qd_15min.Ewv, epoch_combined, this_time_range);
  X(:, end+1) = avg_var_history(qd_15min.epoch, qd_15min.Ewav, epoch_combined, this_time_range);
  X_names{end+1} = sprintf('AE (t-%dhrs)', this_n_hours_history);
  X_names{end+1} = sprintf('Dst (t-%dhrs)', this_n_hours_history);
  X_names{end+1} = sprintf('Pdyn (t-%dhrs)', this_n_hours_history);
  X_names{end+1} = sprintf('Bs (t-%dhrs)', this_n_hours_history);
  X_names{end+1} = sprintf('dphi_mp_dt (t-%dhrs)', this_n_hours_history);
  X_names{end+1} = sprintf('p^(1/2)*dphi_mp_dt (t-%dhrs)', this_n_hours_history);
  X_names{end+1} = sprintf('Ewv (t-%dhrs)', this_n_hours_history);
  X_names{end+1} = sprintf('Ewav (t-%dhrs)', this_n_hours_history);
end

this_palmer_darkness = darkness.idx_darkness(interp1(darkness.epoch, 1:length(darkness.epoch), epoch_combined, 'nearest'));

warning('on', 'MATLAB:interp1:NaNinY');

%% Set up Palmer predictors
palmer_mlt = fpart(epoch_combined + palmer_mlt_offset/24)*24;
mlt_offset = angledist(palmer_mlt/24*2*pi, them_combined.MLT/24*2*pi, 'rad', true)*24/(2*pi);

mlt_offset_lower_lim = -1;
mlt_offset_upper_lim = 1;
idx_palmer_dark = mlt_offset > mlt_offset_lower_lim & mlt_offset < mlt_offset_upper_lim & this_palmer_darkness;
idx_palmer_light = mlt_offset > mlt_offset_lower_lim & mlt_offset < mlt_offset_upper_lim & ~this_palmer_darkness;
                 
b_palmer_emission = palmer_power_combined > 0 & (idx_palmer_dark | idx_palmer_light);
% b_palmer_emission = 10*log10(palmer_power_combined); b_palmer_emission(~isfinite(b_palmer_emission) | ~idx_palmer_range) = 0;

%% Plot normalized occurrence for Palmer emissions
% edges = -50:5:-20;
% centers = edges + diff(edges(1:2))/2;
% n_em = histc(10*log10(them_combined.field_power(them_combined.field_power > 0 & b_palmer_emission)), edges);
% n_no_em = histc(10*log10(them_combined.field_power(them_combined.field_power > 0 & b_palmer_no_emission)), edges);
% n_total = histc(10*log10(them_combined.field_power(them_combined.field_power > 0 & idx_palmer_range)), edges);
% figure;
% bar(centers(1:end-1) + 60, n_em(1:end-1)./n_total(1:end-1), 1, 'facecolor', [1 1 1]*0.8);
% [m, pm] = agresti_coull(n_total(1:end-1), n_em(1:end-1), 0.05);
% hold on;
% h = errorbar(centers(1:end-1) + 60, m, pm);
% set(h, 'linestyle', 'none', 'color', 'k');
% ylim([0 1]);
% grid on;
% xlabel('THEMIS Hiss Power (dB-pT)');
% ylabel('Normalized occurrence');
% title(sprintf('%0.0f <= MLT <= %0.0f, %d <= month <= %d, %0.0f <= MLT offset <= %0.0f, total: %d/%d', ...
%   mlt_lower_lim, mlt_upper_lim, month_lower_lim, month_upper_lim, mlt_offset_lower_lim, mlt_offset_upper_lim, sum(n_em), sum(n_total)));

%% Set up predictor matrix
X(:,end+1) = abs(log(them_combined.L - 1) - log(4 - 1));
X_names{end+1} = 'abs(log(them_combined.L - 1) - log(4 - 1))';
X(:,end+1) = abs(sin(them_combined.MLT/24*2*pi));
X_names{end+1} = 'abs(sin(them_combined.MLT/24*2*pi))';
X(:,end+1) = cos(them_combined.MLT/24*2*pi);
X_names{end+1} = 'cos(them_combined.MLT/24*2*pi)';
X(:,end+1) = cos(them_combined.lat*pi/180);
X_names{end+1} = 'cos(them_combined.lat*pi/180)';


% Add Palmer occurrence
if ~strcmp(optimize_for, 'nopalmer')
  num_params = length(X_names);
  for kk = 1:num_params
    X(:,num_params+kk) = b_palmer_emission.*X(:,kk);
    X_names{num_params+kk} = ['b_palmer_emission.*' X_names{kk}];
  end
  X(:,end+1) = b_palmer_emission;
  X_names{end+1} = 'b_palmer_emission';
end

% When using Bz, if I leave this in, the GLM breaks and I don't know why
% X_names(strcmp(X_names, 'b_palmer_emission.*log10(this_ae_3hr)')) = [];
% X_names(strcmp(X_names, 'b_palmer_emission.*this_Bs_6hr')) = [];
% X_names(strcmp(X_names, 'b_palmer_emission.*log10(this_ae_6hr)')) = [];

assert(length(X_names) == size(X, 2)); % Make sure I didn't forget a name or index

1;

function [X_out, X_names_out] = optimize_glm_fwd_new(X_in, X_names, Y_in, glm_type)
%% Function: optimize X to minimize BIC using sequentialfs() and ARMAX
% INPUTS
% X_in: NxP matrix of N measurements of P predictors
% X_names: name of each predictor, in order
% Y_in Nx1 matrix of N true/false measurements
% glm_type: must be 'normal'
% 
% OUTPUTS
% X_out: the chosen predictor matrix
% X_names_out: names of the chosen predictors

assert(strcmp(glm_type, 'normal'));

if matlabpool('size') == 0, matlabpool('open'); end


% We get a lot of these errors due to some weirdness in some of our
% predictors.  Ignore them, since we're pretty sure that predictors will be
% rejected as being ineffective in the cross-validation stage if the linear
% fitting fails.
spmd
  warning('off', 'MATLAB:nearlySingularMatrix');
end
t_start = now;

% Use 10-fold cross-validation; this way is SLOW but more meaningful
% opts = statset('UseParallel', 'always', 'Display', 'iter');
% [inmodel, history] = sequentialfs(@sequential_fs_fun_cv, X_in, Y_in, 'options', opts);

% Don't use cross-validation; just quit when decrease in SSE is less than
% that predicted by chance, which is chi2inv(0.95, 1)
opts = statset('UseParallel', 'always', 'Display', 'iter');
[inmodel, history] = sequentialfs(@sequential_fs_fun_nocv, X_in, Y_in, 'cv', 'none', 'options', opts);

fprintf('Finished parameter selection in %s\n', time_elapsed(t_start, now));
spmd
  warning('on', 'MATLAB:nearlySingularMatrix');
end


X_out = X_in(:,inmodel);
X_names_out = X_names(inmodel);

1;

function criterion = sequential_fs_fun_cv(X_train, Y_train, X_test, Y_test)
%% Objective function for ARMAX variable selection (BIC)

% Use glmfit
% [b, dev, stats] = glmfit(X_train, Y_train, 'normal');
% Y_hat = glmval(b, X_test, 'identity');

% Use garchfit
spec = garchset('R', 0, 'M', 4, 'Display', 'off');
[Coeff,Errors,LLF,Innovations,Sigmas,Summary] = garchfit(spec, Y_train, X_train);
Y_hat = Coeff.C + X_test*Coeff.Regress.';

criterion = sum((Y_hat - Y_test).^2); % Sum of squared error for test set

1;

function criterion = sequential_fs_fun_nocv(X, Y)
%% Objective function for ARMAX variable selection (BIC)

% Use glmfit
% [b, dev, stats] = glmfit(X_train, Y_train, 'normal');
% Y_hat = glmval(b, X_test, 'identity');

n = size(X, 1);
p = size(X, 2);

% Use garchfit
spec = garchset('R', 0, 'M', 4, 'Display', 'off');
[Coeff,Errors,LLF,Innovations,Sigmas,Summary] = garchfit(spec, Y, X);

AIC = n*log(sum(Innovations.^2)/n) + 2*p;
BIC = n*log(sum(Innovations.^2)/n) + p*log(n);

% criterion = sum(Innovations.^2); % Sum of squared error for test set
criterion = AIC; % Sum of squared error for test set

1;

function [X_out, X_names_out, X_out_rank] = optimize_glm_bkwd(X_in, X_names, Y_in, glm_type)
%% Function: optimize X to minimize BIC using reverse search
% INPUTS
% X_in: NxP matrix of N measurements of P predictors
% X_names: name of each predictor, in order
% Y_in Nx1 matrix of N true/false measurements
% glm_type: must be 'logit'
% 
% OUTPUTS
% X_out: the chosen predictor matrix
% X_names_out: names of the chosen predictors
% X_out_rank: rank of each predictor; 1 is most important.

assert(strcmp(glm_type, 'logit'));

idx_samples = all(isfinite([X_in Y_in]), 2); % Make sure all BIC calculations use the same samples
idx_predictors = true(size(X_in, 2), 1); % We'll disable predictors with high p-values
idx_whitelist = [];
whitelist_bic = [];
attempts = 0;

% Get initial BIC
[prev_bic, this_p] = get_bic(X_in(idx_samples, idx_predictors), Y_in(idx_samples));
prev_p = this_p;

worst_idx_list = [];
bic_list = prev_bic; % This is the BIC BEFORE removing the associated worst_idx_list variable

while sum(idx_predictors) > 0 || attempts < 3 && any(this_p > 0.05)
  % Remove the predictor with the worst p-val.  If we already tried that
  % and it didn't help the BIC (attempts > 0), try the next one
  if attempts == 0
    [~, high_pvals] = sort(this_p);
  end
  candidate_predictors = find(idx_predictors);
  worst_idx = high_pvals(end - attempts);
  worst_p = this_p(worst_idx);

  idx_predictors(candidate_predictors(worst_idx)) = false;
  
%   sfigure(1);
%   clf;
%   plot(candidate_predictors, this_p, '.');
%   hold on;
%   plot(candidate_predictors(worst_idx), abs(this_p(worst_idx)), 'ro');
  
  worst_idx_list(end+1) = candidate_predictors(worst_idx);
  [this_bic, this_p] = get_bic(X_in(idx_samples, idx_predictors), Y_in(idx_samples));
  bic_list(end+1) = this_bic;
  
  if this_bic < prev_bic
    fprintf('Deleted variable %d with p-val %0.2f; BIC %0.1f -> %0.1f (%s)\n', ...
      candidate_predictors(worst_idx), worst_p, prev_bic, this_bic, X_names{candidate_predictors(worst_idx)});

    prev_bic = this_bic;
    prev_p = this_p;
    attempts = 0;
    idx_whitelist = [];
    whitelist_bic = [];
  else
    fprintf('Retained variable %d with p-val %0.2f; BIC %0.1f -> %0.1f (%s)\n', ...
      candidate_predictors(worst_idx), worst_p, prev_bic, this_bic, X_names{candidate_predictors(worst_idx)});

    attempts = attempts + 1;

    idx_predictors(candidate_predictors(worst_idx)) = true;
    worst_idx_list(end) = [];
    bic_list(end) = [];
    idx_whitelist(end+1) = candidate_predictors(worst_idx);
    whitelist_bic(end+1) = this_bic;
    this_p = prev_p;
    
    % If we've already retained three variables, drop the worst one
    if attempts >= min(3, sum(idx_predictors))
      [~, worst_whitelist_idx] = min(whitelist_bic);
      idx_predictors(idx_whitelist(worst_whitelist_idx)) = false;
      
      worst_idx_list(end+1) = idx_whitelist(worst_whitelist_idx);
      [this_bic, this_p] = get_bic(X_in(idx_samples, idx_predictors), Y_in(idx_samples));
      bic_list(end+1) = this_bic;
      
      fprintf('Deleted variable %d; BIC %0.1f -> %0.1f (%s)\n', ...
        idx_whitelist(worst_whitelist_idx), prev_bic, this_bic, X_names{idx_whitelist(worst_whitelist_idx)});

      prev_bic = this_bic;
      prev_p = this_p;
      attempts = 0;  
      idx_whitelist = [];
      whitelist_bic = [];
    end
  end
end

% Find where BIC started rising monotonically
[~, best_bic_idx] = min(bic_list);
idx_predictors(worst_idx_list((1:length(worst_idx_list)) >= best_bic_idx)) = true;
predictor_rank = length(worst_idx_list):-1:1;
[~, s] = sort(worst_idx_list);
X_out_rank = predictor_rank(s);
X_out_rank = X_out_rank(idx_predictors);

X_out = X_in(:, idx_predictors);
X_names_out = X_names(idx_predictors);

1;

function [X_out, X_names_out] = optimize_glm_fwd(X_in, X_names, Y_in, glm_type)
%% Function: optimize X to minimize BIC using forward search

warning('optimize_glm_bkwd is more advanced and probably more "correct" than optimize_glm_fwd');

assert(strcmp(glm_type, 'logit'));

idx_samples = all(isfinite([X_in Y_in]), 2); % Make sure all BIC calculations use the same samples
idx_predictors = false(1, size(X_in, 2)); % We'll enable predictors with low p-values
idx_probation = false(size(idx_predictors)); % We'll try to add variables even if they increase BIC, in which case they'll be on probation

% Get initial BIC
prev_bic = get_bic(X_in(idx_samples, idx_predictors), Y_in(idx_samples));

% While there are still some predictors not included in the model...
while any(~idx_predictors)
  % Add the predictor that isn't on the blacklist and correlates best with
  % the residual
  candidate_predictors = find(~idx_predictors);
%   candidate_bic = zeros(size(candidate_predictors));
  candidate_rho = zeros(size(candidate_predictors));
  candidate_p = {};
  [current_bic, current_p, current_stats] = get_bic(X_in(idx_samples, idx_predictors), Y_in(idx_samples));
  for kk = 1:length(candidate_predictors)
    this_idx_predictors = idx_predictors;
    this_idx_predictors(candidate_predictors(kk)) = true;
%     [candidate_bic(kk), candidate_p{kk}, stats] = get_bic(X_in(idx_samples, this_idx_predictors), Y_in(idx_samples));
    candidate_rho(kk) = corr(current_stats.resid, X_in(idx_samples, candidate_predictors(kk)));
  end
  
%   [~, min_bic_idx] = min(candidate_bic);
  [~, min_rho_idx] = max(abs(candidate_rho));
  best_candidate_idx = min_rho_idx;
  
%   sfigure(1);
%   clf;
%   plot(candidate_predictors, abs(candidate_rho), '.');
%   hold on;
%   plot(candidate_predictors(best_candidate_idx), abs(candidate_rho(best_candidate_idx)), 'ro');
  
  idx_predictors_with_best_candidate = idx_predictors;
  idx_predictors_with_best_candidate(candidate_predictors(best_candidate_idx)) = true;
  [best_candidate_bic, best_candidate_p] = get_bic(X_in(idx_samples, idx_predictors_with_best_candidate), Y_in(idx_samples));
  
  % If the best added variable does reduce BIC, enable it
  if best_candidate_bic < prev_bic || sum(idx_probation) < 3
    if best_candidate_bic < prev_bic
      % Either this variable or several variables working together have
      % successfully reduced BIC; release the variables from probation
      idx_probation(:) = false;
      str_probation = 'permanently';
    else
      idx_probation(candidate_predictors(best_candidate_idx)) = true;
      str_probation = 'PROVISIONALLY';
    end
    
    idx_predictors(candidate_predictors(best_candidate_idx)) = true;
    
    fprintf('Added idx %d (%s) %s; BIC %0.1f -> %0.1f\n', candidate_predictors(best_candidate_idx), ...
      X_names{candidate_predictors(best_candidate_idx)}, str_probation, prev_bic, best_candidate_bic);
    
    if best_candidate_bic < prev_bic
      prev_bic = best_candidate_bic;
    else
      probation_list_str = sprintf('%d ', find(idx_probation));
      fprintf('On probation: %s\n', probation_list_str);
    end
  % Otherwise, quit
  else
    % The variables on probation have failed; eject them from the list of
    % predictors
    if any(idx_probation)
      fprintf('Removed variable %s\n', X_names{idx_probation});
      idx_predictors(idx_probation) = false;
    end
    break;
  end
end

X_out = X_in(:, idx_predictors);
X_names_out = X_names(idx_predictors);

1;

function [bic, p, stats] = get_bic(X, Y)
%% Function: get BIC for a GLM fit
% INPUTS
% X: NxP matrix of N measurements of P predictors
% Y_in Nx1 matrix of N true/false measurements
% 
% OUTPUTS
% bic: bayesian information criteria
% p: p-values of the predictors EXCLUDING the constant
% stats: the stats output from glmfit()

lastwarn('');

[b, dev, stats] = glmfit(X, Y, 'binomial', 'logit');
Y_out = glmval(b, X, 'logit', stats);
log_likelihood = sum(log(binopdf(Y, ones(size(Y)), Y_out)));
bic = -2*log_likelihood + length(b)*log(length(Y));
p = stats.p(2:end);

[msgstr, msgid] = lastwarn;
if strcmp(msgid, 'stats:glmfit:IterationLimit')
  error('GLM failed');
end

function glm_palmer_only(epoch, palmer_em_pow_orig, them)
%% Function: fit a GLM model of various parameters to predict THEMIS emissions

%% Setup
[epoch_combined, them_combined, palmer_power_combined] = combine_them_simple(them, epoch, palmer_em_pow_orig);
[X_orig, X_names_orig, idx_dark, idx_light] = ...
  set_up_predictor_matrix_pt(palmer_power_combined, them_combined, epoch_combined, 'optimize_for', 'palmer');

X_column_idx = ismember(X_names_orig, {'b_palmer_emission', 'cos(them_combined.MLT/24*2*pi)', 'abs(sin(them_combined.MLT/24*2*pi))', 'abs(log(them_combined.L - 1) - log(4 - 1))', 'cos(them_combined.lat*pi/180)'});
X_names = X_names_orig(X_column_idx);

% Select dark or light Palmer
% idx_palmer_range = idx_dark & them_combined.MLT < 12; idx_str = 'Palmer Darkness, MLT < 12';
% idx_palmer_range = idx_light & them_combined.MLT < 12; idx_str = 'Palmer Sunlight, MLT < 12';
idx_palmer_range = idx_light & them_combined.MLT >= 12; idx_str = 'Palmer Sunlight, MLT > 12';

idx_valid = idx_palmer_range & them_combined.field_power > 0;
X_in = X_orig(idx_valid, X_column_idx);
Y_in = log10(them_combined.field_power(idx_valid))/2 + 3; % log10 pT

%% Calculate the fit using valid values
% [b, dev, stats] = glmfit(X_in, Y_in);
% Y_out = glmval(b, X_in, 'identity');

R = 1; % Num AR coefficients
M = 0; % Num MA coefficients
spec = garchset('R', R, 'M', M, 'display', 'off');
[Coeff,Errors,LLF,Innovations,Sigmas,Summary] = garchfit(spec, Y_in, X_in);

fprintf('Model ''%s'', n = %d\n', idx_str, length(Y_in));

garchdisp(Coeff, Errors);
% Y_out = Coeff.C + Coeff.AR*mean(Y_in) + X_in*Coeff.Regress.'; % Estimates without AR model

% See Chatterjee and Hadi (book) pages 33-34
tvals = [Coeff.C, Coeff.AR, Coeff.Regress]./[Errors.C, Errors.AR, Errors.Regress];
pvals = tcdf(-abs(tvals), length(Y_in) - size(X_in, 2) - R - M - 1)*2;

fprintf('p-values:\n');
fprintf('%0.3f: %s\n', pvals(1), 'constant');
fprintf('%0.3f: %s\n', pvals(2), 'AR(1)');
for kk = 1:size(X_in, 2)
  this_name = X_names{kk};
  this_p = pvals(kk+2);
  fprintf('%0.3f: %s\n', this_p, this_name);
end

%% Output Latex Table for my paper
latex_table = {'Predictor', '$\boldsymbol{\beta}$', 'SE', '$\boldsymbol{p}$'};
latex_table(2:(length(X_names)+3), 1) = {'Constant ($C$)', 'AR(1)', '$|\ln(L-1) - \ln(3)|$', 'abs(sin(MLT))', 'cos(MLT)', 'cos($\lambda$)', 'Palmer Hiss (Bool)'};
latex_table(2, 2:end) = {num2str(Coeff.C, '%0.3f'), num2str(Errors.C, '%0.3f'), num2str(pvals(1), '%0.3f')};
latex_table(3, 2:end) = {num2str(Coeff.AR, '%0.3f'), num2str(Errors.AR, '%0.3f'), num2str(pvals(2), '%0.3f')};
for kk = 1:length(X_names)
  latex_table(3+kk, 2:end) = {num2str(Coeff.Regress(kk), '%0.3f'), num2str(Errors.Regress(kk), '%0.3f'), num2str(pvals(2+kk), '%0.3f')};
end
latex_table = strrep(latex_table, '0.000', '$<$0.001');

for kk = 1:size(latex_table, 1)
  for jj = 1:(size(latex_table, 2) - 1)
    if kk == 1 && jj == 1
      prefix = '\multicolumn{1}{l}{\textbf{';
      suffix = '}}';
    elseif kk == 1
      prefix = '\multicolumn{1}{c}{\textbf{';
      suffix = '}}';
    else
      prefix = '';
      suffix = '';
    end
  
    fprintf('%s%s%s & ', prefix, latex_table{kk, jj}, suffix);
  end
  fprintf('%s%s%s \\\\ \\hline\n', prefix, latex_table{kk, end}, suffix);
end
fprintf('\n');

%% Plot results
% figure;
% subplot(2, 1, 1);
% parcorr(stats.resid);
% ylabel('parcorr glm resid');
% title('');
% subplot(2, 1, 2);
% parcorr(Innovations);
% ylabel('parcorr garch resid');
% title('');
% increase_font;

edges = -65:5:-30;
centers = edges(1:end-1) + median(diff(edges))/2;
n_total = histc(10*log10(them_combined.field_power(idx_valid)), edges);
n_total(end) = [];
n_p = histc(10*log10(them_combined.field_power(idx_valid & palmer_power_combined > 0)), edges);
n_p(end) = [];

a = corr(Y_in(1:end-1), Y_in(2:end)); % AR(1) coefficient
n_total_eff_mean = n_total.*(1 + 2./n_total.*(1/(1-a)).*(a*(n_total - 1/(1-a)) - a.^n_total*(1 - 1/(1-a)))).^(-1); % Effective n, for mean; see [Mudelsee, 2010, Eq. 2.7]
n_total_eff_var = n_total.*(1 + 2./n_total.*(1/(1-a^2)).*(a^2*(n_total - 1/(1-a^2)) - a.^(2*n_total)*(1 - 1/(1-a^2)))).^(-1); % Effective n for variance; see [Mudelsee, 2010, Eq. 2.7]

n_p_eff_mean = n_p.*n_total_eff_mean./n_total;
n_p_eff_var = n_p.*n_total_eff_var./n_total;
% n_p_eff = n_p.*(1 + 2./n_p.*(1/(1-a)).*(a*(n_p - 1/(1-a)) - a.^n_p*(1 - 1/(1-a)))).^(-1); % Effective n, see [Mudelsee, 2010, Eq. 2.7]
% n_p_eff = n_p_eff(1:end-1);
x = -60:5:-30;

figure;
bar(centers, n_p./n_total, 1, 'facecolor', [1 1 1]*0.5);
hold on;
[m, pm] = agresti_coull(n_total_eff_mean, n_p_eff_mean);
h = errorbar(centers, m, pm);
set(h, 'linestyle', 'none', 'color', 'k');
ylim([0 0.7]);
xlim([edges(1) edges(end)]);
grid on;

xlabel('THEMIS hiss amplitude (dB-nT)');
ylabel('Palmer normalized occurrence');
increase_font;

plot_l_mlt(them_combined.L(idx_valid), them_combined.MLT(idx_valid), 1.5:0.25:6, 0:24, 1);
axis off tight equal;
c = colorbar;
ylabel(c, 'log_{10} num samples');
increase_font;

1;

function nnet_ampl(epoch, palmer_em_pow_orig, them)
%% Function: use a neural network to predict THEMIS amplitude

%% Setup
palmer_mlt_offset = -4; % local MLT at midnight UTC

darkness = load('palmer_darkness.mat', 'epoch', 'idx_darkness', 'time_to_term');
ae = load('ae.mat', 'ae', 'epoch');
TS05 = load('TS05.mat', 'epoch', 'Pdyn', 'BzIMF', 'ByIMF');

[epoch_combined, them_combined, palmer_power_combined] = combine_them_simple(them, epoch, palmer_em_pow_orig);
[X, X_names, idx_palmer_range] = set_up_predictor_matrix_pt(palmer_power_combined, them_combined, epoch_combined);
Y = 10*log10(them_combined.field_power);

%% Create neural network using valid values
idx_in = them_combined.field_power > 0 & all(isfinite(X), 2) & idx_palmer_range;% & palmer_power_combined > 0;
Y_in = Y(idx_in);
X_in = X(idx_in,:);

inputs = X_in';
targets = Y_in';

% % Create a Fitting Network
% hiddenLayerSize = 3;
% net = fitnet(hiddenLayerSize);
% 
% % Setup Division of Data for Training, Validation, Testing
% net.divideParam.trainRatio = 70/100;
% net.divideParam.valRatio = 15/100;
% net.divideParam.testRatio = 15/100;
% 
% % Train the Network
% [net,tr] = train(net,inputs,targets);

% save them_ampl_nnet.mat inputs targets net tr
load('them_ampl_nnet.mat', 'inputs', 'targets', 'net', 'tr');

% Test the Network
outputs = net(inputs);
errors = gsubtract(targets,outputs);
performance = perform(net,targets,outputs);

% Plot result
figure;
[n_out, x] = hist(outputs - targets);
n_mean = hist(mean(targets) - targets, x);
bar(x, [n_out; n_mean].', 1);
legend(sprintf('NN Output, \\sigma = %0.2g', std(outputs - targets)), ...
  sprintf('Mean estimator, \\sigma = %0.2g', std(mean(targets) - targets)));
xlabel('Error');
ylabel('Count');
% ploterrhist(outputs(tr.trainInd) - targets(tr.trainInd), 'Main', ...
%             outputs(tr.valInd) - targets(tr.valInd), 'Validation', ...
%             outputs(tr.testInd) - targets(tr.testInd), 'Test');

figure;
plotregression(targets(tr.trainInd), outputs(tr.trainInd), 'Main', ...
               targets(tr.valInd), outputs(tr.valInd), 'Validation', ...
               targets(tr.testInd), outputs(tr.testInd), 'Test', ...
               targets, outputs, 'Total');

n = length(Y_in);
p = size(X, 2);
test_statistic = tinv(1 - 0.05/2, n - p - 1);
s = sqrt(sum((outputs - targets).^2)/(n - p - 1));
se = zeros(size(Y_in));
for kk = 1:length(se)
  se(kk) = s*sqrt(1 + X_in(kk,:)*inv(X_in.'*X_in)*X_in(kk,:).');
end
LL = outputs(:) - test_statistic*se;
UL = outputs(:) + test_statistic*se;

% figure
% plot(Y_in, outputs, 'b.', Y_in, LL, 'r.', Y_in, UL, 'g.');
             
1;

function glm_ampl(epoch, palmer_em_pow_orig, them)
%% Function: fit a GLM model of various parameters to predict THEMIS emissions

%% Setup
[epoch_combined, them_combined, palmer_power_combined] = combine_them_simple(them, epoch, palmer_em_pow_orig);
[X_orig, X_names_orig, idx_palmer_range] = set_up_predictor_matrix_pt(palmer_power_combined, them_combined, epoch_combined, 'optimize_for', 'palmer');
Y = 10*log10(them_combined.field_power);

%% Calculate the fit using valid values
idx_in = them_combined.field_power > 0 & all(isfinite(X_orig), 2) & idx_palmer_range;% & palmer_power_combined > 0;
Y_in = Y(idx_in);

[X_in, X_names] = optimize_glm_fwd_new(X_orig(idx_in,:), X_names_orig, Y_in, 'normal'); % Choose best subset of predictors

[b, dev, stats] = glmfit(X_in, Y_in);
% Y_out = glmval(b, X_in, 'identity');

spec = garchset('R', 0, 'M', 4);
[Coeff,Errors,LLF,Innovations,Sigmas,Summary] = garchfit(spec, Y_in, X_in);
Y_out = Coeff.C + X_in*Coeff.Regress.'; % Estimates without AR model
% Y_out = Y_in - Innovations;

% See Chatterjee and Hadi (book) pages 33-34
tvals = Coeff.Regress./Errors.Regress;
pvals = tcdf(-abs(tvals), length(Y_in) - size(X_in, 2) - 1)*2;

figure;
subplot(2, 1, 1);
parcorr(stats.resid);
ylabel('parcorr glm resid');
title('');
subplot(2, 1, 2);
parcorr(Innovations);
ylabel('parcorr garch resid');
title('');
increase_font;

[~, name_sort_idx] = sort(X_names);
fprintf('p-values:\n');
for kk = 1:size(X_in, 2)
  this_name = X_names{name_sort_idx(kk)};
%   this_p = stats.p(1 + name_sort_idx(kk));
  this_p = pvals(name_sort_idx(kk));
  
  fprintf('%0.3f: %s\n', this_p, this_name);
end

% Test for colinearity (see Chatterjee and Hadi (2006) page 243)
% I think I'm doing this right, but it's kind of confusing
% assert(size(X, 2) < 40); % Big number of columns will cause corr function to use up all the OS's memory
% corr_mtx = corr(X(all(isfinite(X), 2), :));
% corr_eig = eig(corr_mtx);
% fprintf('Condition number (test of coliniearity; <15 good, >30 bad): %0.1f\n', ...
%   sqrt(max(corr_eig)/min(corr_eig)));

% Goodness of fit metric
r_squared = corr(Y_in, Y_out)^2;
fprintf('Goodness of fit (R^2): %0.3f\n', r_squared);

% Cross validation error standard deviation
cvvals = crossval(@sequential_fs_fun_cv, X_in, Y_in);
cvvals_naive = crossval(@sequential_fs_fun_cv, ones(length(Y_in), 1), Y_in);

fprintf('Average CV RMS error for regression model: %g\n', sqrt(sum(cvvals)/length(Y_in)));
fprintf('Average CV RMS error for naive model: %g\n', sqrt(sum(cvvals_naive)/length(Y_in)));


%% Plot results
lims = [-50 -20];
bin_size = 2;

figure;
subplot(4, 4, [2 3 4 6 7 8 10 11 12]);
scatter(Y_in, Y_out);
title(sprintf('R^2 = %0.3f', r_squared));
axis([lims lims]);
grid on;

subplot(4, 4, [1 5 9]);
edges = lims(1):bin_size:lims(2);
centers = edges + diff(edges(1:2))/2;
n = histc(Y_out, edges);
barh(centers, n, 1);
ylim(lims);
set(gca, 'xscale', 'log');
grid on;
ylabel('Y_{out} (dB-nT)');

subplot(4, 4, [14 15 16]);
n = histc(Y_in, edges);
bar(centers, n, 1);
xlim(lims);
set(gca, 'yscale', 'log');
grid on;
xlabel('Y_{in} (dB-nT)');

increase_font;

save ~/temp/blah.mat

1;

function glm_prob(epoch, palmer_em_pow_orig, them)
%% Function: fit a GLM model of various parameters to predict THEMIS emissions

%% Setup
palmer_mlt_offset = -4; % local MLT at midnight UTC

darkness = load('palmer_darkness.mat', 'epoch', 'idx_darkness', 'time_to_term');
ae = load('ae.mat', 'ae', 'epoch');
TS05 = load('TS05.mat', 'epoch', 'Pdyn', 'BzIMF', 'ByIMF');

[epoch_combined, them_combined, palmer_power_combined] = combine_them_simple(them, epoch, palmer_em_pow_orig);
themis_db_thresh = -35;
Y = 10*log10(them_combined.field_power) > themis_db_thresh;
[X, X_names_orig, idx_palmer_range, palmer_restr] = set_up_predictor_matrix_pt(palmer_power_combined, them_combined, epoch_combined, 'optimize_for', 'palmer');

idx_in = them_combined.field_power > 0 & all(isfinite(X), 2) & idx_palmer_range;
Y_in = Y(idx_in);
X_in_preopt = X(idx_in,:);
[X_in, X_names, X_in_rank] = optimize_glm_bkwd(X_in_preopt, X_names_orig, Y_in, 'logit');
% [X_in, X_names] = optimize_glm_fwd(X_in_preopt, X_names_orig, Y_in, 'logit');


%% Calculate the fit using valid values
[b, dev, stats] = glmfit(X_in, Y_in, 'binomial', 'logit');
Y_out = glmval(b, X_in, 'logit', stats);

[~, i_rank] = sort(X_in_rank);
fprintf('p-values, beta/std\n');
for ii = 1:length(X_names)
  kk = i_rank(ii);
  fprintf('%0.3f, % 8.2f (%02d %s)\n', stats.p(kk+1), b(kk+1)/std(X_in(X_in(:, kk) ~= 0, kk)), kk, X_names{kk});
end

% Test for colinearity (see Chatterjee and Hadi (2006) page 243)
% I think I'm doing this right, but it's kind of confusing
% assert(size(X, 2) < 40); % Big number of columns will cause corr function to use up all the OS's memory
% corr_mtx = corr(X(all(isfinite(X), 2), :));
% corr_eig = eig(corr_mtx);
% fprintf('Condition number (test of coliniearity; <15 good, >30 bad): %0.1f\n', ...
%   sqrt(max(corr_eig)/min(corr_eig)));

% Bayesian information criterion (BIC) (see
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/237941)
log_likelihood = sum(log(binopdf(Y_in, ones(size(Y_in)), Y_out)));
BIC = -2*log_likelihood + length(b)*log(length(Y_in));
fprintf('BIC: %0.2f\n', BIC);

%% Plot results
edges = 0:0.2:1;
% edges = quantile(Y_out, linspace(0, 1, floor(length(Y_out)/50))); edges(1) = 0; edges(end) = 1;
centers = edges(1:end-1) + diff(edges)/2;
n_total = histc(Y_out, edges);
n = histc(Y_out(Y_in), edges);

figure;
subplot(3, 1, [1 2]);
bar_by_edges(edges, n(1:end-1)./n_total(1:end-1), 'vertical', [1 1 1]*0.8);
% bar(centers, n(1:end-1)./n_total(1:end-1), 1, 'facecolor', [1 1 1]*0.8);
[m, pm] = agresti_coull(n_total(1:end-1), n(1:end-1), 0.05);
hold on;
h = errorbar(centers, m, pm);
set(h, 'linestyle', 'none', 'color', 'k');
plot([0 1], [0 1], 'r-', 'linewidth', 1.5);
axis([0 1 0 1]);
grid on;
% xlabel(sprintf('Model probability hiss > %0.0f dB-pT', themis_db_thresh + 60));
ylabel(sprintf('Normalized occurrence of hiss > %0.0f dB-pT', themis_db_thresh + 60));
title(sprintf('%0.0f <= MLT <= %0.0f, %0.0f <= MLT offset <= %0.0f, total: %d/%d', ...
  palmer_restr.mlt(1), palmer_restr.mlt(2), palmer_restr.mlt_offset(1), palmer_restr.mlt_offset(2), ...
  sum(n), sum(n_total)));

subplot(3, 1, 3);
bar(centers, log10(n_total(1:end-1)), 1, 'facecolor', [1 1 1]*0.5);
grid on;
ylabel('log_{10} n');
xlabel(sprintf('Model probability hiss > %0.0f dB-pT', themis_db_thresh + 60));

increase_font;

1;

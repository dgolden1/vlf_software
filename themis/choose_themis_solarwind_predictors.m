function choose_themis_solarwind_predictors
% Choose optimal set of THEMIS/solar wind predictors using cross
% validation, averaged over entire data set

% By Daniel Golden (dgolden1 at stanford dot edu) November 2011
% $Id$

%% Setup
close all;

if ~exist('em_type', 'var') || isempty(em_type)
  em_type = 'hiss';
end

% output_filename = fullfile(scottdataroot, 'themis', 'themis_hiss_solarwind_features.mat');
output_filename = fullfile(vlfcasestudyroot, 'themis_emissions', 'themis_hiss_solarwind_features.mat');

% When I changed from Dst to SYM-H, the number of features increased by 2,
% which excluded a bin within L < 5, which messes up my plots.
% Cap the features at this many to ensure that there are enough bins with
% enough samples with # samples >= 10* # bins
max_num_features = 23;

%% Load THEMIS data
t_them_start = now;
[epoch_combined, them_combined] = get_combined_them_power(em_type);

% Subsample THEMIS data or else this process takes too long
dec_factor = 100;
idx = mod(1:length(epoch_combined), dec_factor) == 1;
[epoch_combined, them_combined] = subsample_them(epoch_combined, them_combined, idx);

fprintf('Loaded THEMIS data in %s\n', time_elapsed(t_them_start, now));


%% Set up predictor matrix
t_pred_start = now;
[X, X_names_full] = set_up_predictor_matrix_v1(epoch_combined, 'them_combined', them_combined);

idx_sample_valid = them_combined.field_power > 0 & all(isfinite(X), 2);
Y_in = log10(them_combined.field_power(idx_sample_valid));
X_orig = X(idx_sample_valid,:);

fprintf('Generated predictor matrix in %s\n', time_elapsed(t_pred_start, now));


%% Feature Selection via cross-validation

% List potential features to understand iteration display from sequentialfs
% for kk = 1:length(X_names_full)
%   fprintf('%02d %s\n', kk, X_names_full{kk});
% end

t_cross_start = now;
fprintf('Feature selection begun at %s; %d features to check for %d samples\n', ...
  datestr(t_cross_start), size(X_orig, 2), size(X_orig, 1));

[X_in, X_names] = them_solarwind_feature_select(Y_in, X_orig, X_names_full, max_num_features);
X_names_rejected = X_names_full(~ismember(X_names_full, X_names));

fprintf('Selected %d of %d features in %s\n', size(X_in, 2), size(X_orig, 2), time_elapsed(t_cross_start, now));

% fprintf('\nSELECTED FEATURES\n');
% for kk = 1:length(X_names)
%   fprintf('%s\n', X_names{kk});
% end
% fprintf('\nREJECTED FEATURES\n');
% for kk = 1:length(X_names_rejected)
%   fprintf('%s\n', X_names_rejected{kk});
% end
% fprintf('\n');

%% Print result of ARMAX model

R = 1; % Num AR coefficients
M = 0; % Num MA coefficients
spec = garchset('R', R, 'M', M, 'display', 'off');
[Coeff,Errors,LLF,Innovations,Sigmas,Summary] = garchfit(spec, Y_in, X_in);
Y_hat = Coeff.C + Coeff.AR*mean(Y_in) + X_in*Coeff.Regress.';

garchdisp(Coeff, Errors);

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



%% Save output
save(output_filename, 'X_in', 'Y_in', 'X_names_full', 'X_names', 'X_names_rejected', 'pvals');
fprintf('Saved %s\n', output_filename);

1;

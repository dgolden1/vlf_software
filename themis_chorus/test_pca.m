% function test_pca
% Test principal component analysis on solar wind/geomagnetic index data
% for features in the chorus model

% By Daniel Golden (dgolden1 at stanford dot edu) Apr 2012
% $Id$

%% Setup
close all;
clear;

%% Get data
epoch = datenum([2011 1 1 0 0 0]):(1/24):datenum([2011 7 1 0 0 0]);
[X_all, X_names_all] = set_up_predictor_matrix_v2(epoch);

idx_valid = all(isfinite(X_all), 2);

%% Calculate principal components
[coeff, score, latent] = princomp(zscore(X_all(idx_valid, :)));

%% Determine variance explained by each component
for kk = 1:length(latent)
  fprintf('Fraction of variance explained by %d components: %0.4f\n', kk, sum(latent(1:kk))/sum(latent));
end

%% Plot first two components
figure;
plot(score(:,1), score(:,2), '.')
xlabel('1st Principal Component')
ylabel('2nd Principal Component')

%% Plot components with original vectors overlaid
biplot(coeff(:,1:2), 'scores', score(:,1:2), 'varlabels', X_names_all);

1;

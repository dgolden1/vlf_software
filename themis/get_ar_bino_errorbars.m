function [m, pm] = get_ar_bino_errorbars(data, n_total, n)
% Get Agresti-Coull error bars for autocorrelated data
% 
% For "effective data size", see Mudelsee (2010)
% doi:10.1007/978-90-481-9482-7, chapter 2, equations (2.7) (mean) and
% (2.35) (variance)

% By Daniel Golden (dgolden1 at stanford dot edu) November 2011
% $Id$

if size(n, 1) == size(n_total, 1) && size(n, 2) > size(n_total, 2) && size(n_total, 2) == 1
  n_total = repmat(n_total, 1, size(n, 2)/size(n_total, 2));
end

% Effective data size
a = corr(data(1:end-1), data(2:end)); % AR(1) coefficient
n_total_eff_mean = n_total.*(1 + 2./n_total.*(1/(1-a)).*(a*(n_total - 1/(1-a)) - a.^n_total*(1 - 1/(1-a)))).^(-1); % Effective n, for mean; see [Mudelsee, 2010, Eq. 2.7]
n_total_eff_var = n_total.*(1 + 2./n_total.*(1/(1-a^2)).*(a^2*(n_total - 1/(1-a^2)) - a.^(2*n_total)*(1 - 1/(1-a^2)))).^(-1); % Effective n for variance; see [Mudelsee, 2010, Eq. 2.7]

% Effective number of samples for estimates of mean and variance
n_p_eff_mean = n.*n_total_eff_mean./n_total;
n_p_eff_var = n.*n_total_eff_var./n_total;

% Agresti-Coull confidence interval using effective number of samples for
% estimate of mean
[m, pm] = agresti_coull(n_total_eff_mean, n_p_eff_mean);

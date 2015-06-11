function get_exponential_models
% Function to determine coefficient and number of hours history for
% exponential models of hiss predictors

% By Daniel Golden (dgolden1 at stanford dot edu) July 2011
% $Id$

%% Setup
close all;

qd = load('QinDenton_15min_2008-2010.mat');
th = load('palmer_themis_common_epoch_hiss.mat');

%% Caculate indices
qd.Bt = sqrt(qd.ByIMF.^2 + qd.BzIMF.^2);
qd.theta_c = atan2(qd.ByIMF, qd.BzIMF);
qd.dphi_mp_dt = qd.V_SW.^(4/3).*qd.Bt.^(2/3).*abs(sin(qd.theta_c/2).^(8/3)); % [Newell et al, 2007]
qd.p12_dphi_mp_dt = sqrt(qd.Pdyn).*qd.dphi_mp_dt;
qd.Ewv = abs(qd.V_SW.^(4/3).*qd.Bt.*sin(qd.theta_c/2).^4.*qd.Pdyn.^(1/6)); % [Vasyliunas et al, 1982]
qd.Ewav = abs(qd.V_SW.*qd.Bt.*sin(qd.theta_c/2).^4); % [Wygant et al, 1983]
qd.vBs = qd.V_SW.*max(0, qd.BzIMF); % [Burton et al, 1975]

%% Choose epochs
them_epoch = th.them(1).epoch(th.them(1).MLT >= 14 & th.them(1).MLT < 22 & th.them(1).L >= 2 & th.them(1).L < 7 & th.them(1).field_power > 0);
them_power = interp1(th.them(1).epoch, th.them(1).field_power, them_epoch, 'nearest');
qd_epoch = qd.epoch;

%% Determine model order for each parameter
qd = rmfield(qd, 'epoch');
fn = {'dphi_mp_dt', 'p12_dphi_mp_dt', 'Ewav', 'Ewv', 'vBs', 'AE', 'Dst'};
for kk = 1:length(fn)
%   qd_idx = isfinite(qd.(fn{kk}));
%   them_idx = them_epoch <= max(qd_epoch(qd_idx)) & them_epoch >= min(qd_epoch(qd_idx));
  if strcmp(fn{kk}, 'AE')
    index = log(qd.(fn{kk}));
  else
    index = qd.(fn{kk});
  end
  [min_order, w, orders, ws, inv_r] = get_optimal_order(log(them_power), index, them_epoch, qd_epoch);
  plot_order(min_order, w, orders, ws, 1 - inv_r, fn{kk});
  print('-dpng', '-r90', sprintf('~/temp/them_%s', fn{kk}));
end


function plot_order(min_order, w, orders, ws, r, name)
%% Function: make a pretty plot of the SSE vs. model order

name = strrep(name, '_', '\_');

figure;
subplot(2, 1, 1);
plot(orders, r, 'bo-', min_order, r(orders == min_order), 'ro', 'linewidth', 2);
ylabel('corr coeff (r)');
title(sprintf('%s: Best order: %d, w = %0.2f', name, min_order, w));
grid on;

subplot(2, 1, 2);
plot(orders, ws, 'bo-', min_order, ws(ws == w), 'ro', 'linewidth', 2);
xlabel('Order');
ylabel('w');
grid on;
increase_font;

function [min_order, w, orders, ws, inv_r] = get_optimal_order(y_orig, x, y_epoch, x_epoch)
%% Function: Nonlinear regression between dphi_mp_dt and AE
% See https://ccrma.stanford.edu/~jos/fp/Markov_Parameters.html for
% description of model which may or may not be relevant

if ~exist('y_epoch', 'var') || isempty(y_epoch) || ~exist('x_epoch', 'var') || isempty(x_epoch)
  y_epoch = 1:length(y_orig);
  x_epoch = y_epoch;
end

opts = statset('display', 'off');

orders = 0:40;
sse = zeros(size(orders));
for kk = 1:length(orders)
  order = orders(kk);
  x_lags = lagmatrix(x, 0:order);
%   x_lags(isnan(x_lags)) = 0; % This is not strictly mathematically right, but it doesn't matter
  warning('off', 'MATLAB:interp1:NaNinY');
  x_lags = interp1(x_epoch, x_lags, y_epoch, 'nearest');
  warning('on', 'MATLAB:interp1:NaNinY');
  
  % Sometimes y is nan, or x has been interpolated outside of y's range;
  % delete those epochs
  idx_valid = all(~isnan(x_lags), 2) & ~isnan(y_orig);
  x_lags(~idx_valid, :) = [];
  y = y_orig(idx_valid);
  
%   regress_fun = @(b,x) regress_fun_with_order(b, x, order);
%   [beta{kk},r,J,COVB,mse] = nlinfit(x_lags, y, regress_fun, [0 1 0.5], opts);
%   sse(kk) = sum(r.^2);
  
  opt = optimset('display', 'off');
  
%   % First estimate of beta0 and beta1 is from the model with order 0
%   % I have to normalize the betas since beta(1:2) can be vastly different
%   % from beta(3)
%   beta0 = regress(y, [ones(size(x_lags(:,1))) x_lags(:,1)]); 
%   b_norm_factor = [beta0(1), beta0(2), 1];
%   regress_fun = @(b) regress_fun_with_order_resid(b, x_lags, y, order, b_norm_factor);
%   
%   lb = [-inf -inf 0];
%   ub = [inf inf 1];
%   [beta{kk}, sse(kk), exitflag, output] = fmincon(regress_fun, [1 1, 0.5], [], [], [], [], lb, ub, [], opt);
%   beta{kk} = beta{kk}.*b_norm_factor;

  regress_fun = @(w) corr_fun(w, x_lags, y, order);
  lb = 0;
  ub = 1;
  [ws(kk), inv_r(kk), exitflag, output] = fmincon(regress_fun, 0.5, [], [], [], [], lb, ub, [], opt);
end

[~, minorder_idx] = min(inv_r);

min_order = orders(minorder_idx);
w = ws(minorder_idx);

1;

function out = regress_fun_with_order(b, x_lags, order)
%% Function: nonlinear regression to determine state space order
% x is a matrix where row M is an epoch and column N is a single
% time-point lagged version of column N-1

out = b(1) + b(2)*x_lags*b(3).^(0:order).';

function out = regress_fun_with_order_resid(b_norm, x_lags, y, order, b_norm_factor)
%% Function: nonlinear regression to determine state space order
% x is a matrix where row M is an epoch and column N is a single
% time-point lagged version of column N-1

b = b_norm.*b_norm_factor;

out = sum((y - (b(1) + b(2)*x_lags*b(3).^(0:order).')).^2);

function out = corr_fun(w, x_lags, y, order)
%% Function: get correlation coefficient for given exponential weight

r = corr(y, x_lags*w.^(0:order).');

out = 1 - abs(r);

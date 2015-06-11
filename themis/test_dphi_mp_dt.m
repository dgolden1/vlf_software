function test_dphi_mp_dt
% Perform some tests on the solar wind index "dphi_mp_dt" from [Newell,
% 2007, doi:10.1029/2006JA012015]
% 
% It should have a correlation of around 0.83

% By Daniel Golden (dgolden1 at stanford dot edu) July 2011
% $Id$

close all;
% clear;

%% Correlation between dphi_mp_dt and AE
load QinDenton_15min_2008-2010.mat

Bt = sqrt(ByIMF.^2 + BzIMF.^2);
theta_c = atan2(ByIMF, BzIMF);
% theta_c = atan(ByIMF./BzIMF); % atan2 is clearly correct and atan is wrong
dphi_mp_dt = V_SW.^(4/3).*Bt.^(2/3).*abs(sin(theta_c/2).^(8/3));

epoch_hourly = downsample(epoch, 4, 3);
AE_hourly = downsample(filter([1 1 1 1]/4, 1, AE), 4, 3);
dphi_mp_dt_hourly = downsample(filter([1 1 1 1]/4, 1, dphi_mp_dt), 4, 3);

idx = isfinite(AE_hourly) & isfinite(dphi_mp_dt_hourly);
epoch_hourly = epoch_hourly(idx);
AE_hourly = AE_hourly(idx);
dphi_mp_dt_hourly = dphi_mp_dt_hourly(idx);

dphi_mp_dt_smooth = filter((.69*[1 1 1]).^[1 2 3], 1, dphi_mp_dt_hourly);

scatter(AE_hourly, dphi_mp_dt_smooth);
xlabel('AE');
ylabel('dphi-mp-dt');
title(sprintf('r = %g', corr(AE_hourly, dphi_mp_dt_smooth)));
increase_font;

%% Correlation between dphi_mp_dt and hiss amplitude
load palmer_themis_common_epoch_hiss

field_power_hourly = exp(interp1(them(1).epoch, log(them(1).field_power), epoch_hourly));
L_hourly = interp1(them(1).epoch, them(1).L, epoch_hourly);

% MLT is cyclical, so interpolting across MLT = 0 will give the wrong
% answer (e.g., interp1([1 2], [23.5 0.5], 1.5 should give 0, but it
% gives 12). Instead interpolate the complex exponential and get the angle
MLT_hourly = mod(angle(interp1(them(1).epoch, exp(j*them(1).MLT*2*pi/24), epoch_hourly))*24/(2*pi), 24);

tidx = MLT_hourly >= 9 & MLT_hourly < 15 & L_hourly >= 3 & L_hourly < 7 & field_power_hourly > 0;

% corr(field_power_hourly(tidx), dphi_mp_dt_smooth(tidx))

%% Determine optimal order of exponential model

[min_order, w, orders, ws, sse] = get_optimal_order(field_power_hourly(tidx), dphi_mp_dt_hourly, epoch_hourly(tidx), epoch_hourly);

figure;
subplot(2, 1, 1);
plot(orders, sse, 'bo-', min_order, sse(orders == min_order), 'ro', 'linewidth', 2);
ylabel('SSE');
title(sprintf('Best order: %d, w = %0.2f', min_order, w));
grid on;

subplot(2, 1, 2);
plot(orders, ws, 'bo-', min_order, ws(ws == w), 'ro', 'linewidth', 2);
xlabel('Order');
ylabel('w');
grid on;
increase_font;

1;

function [min_order, w, orders, ws, sse] = get_optimal_order(y, x, y_epoch, x_epoch)
%% Function: Nonlinear regression between dphi_mp_dt and AE
% See https://ccrma.stanford.edu/~jos/fp/Markov_Parameters.html for
% description of model which may or may not be relevant

if ~exist('y_epoch', 'var') || isempty(y_epoch) || ~exist('x_epoch', 'var') || isempty(x_epoch)
  y_epoch = 1:length(y);
  x_epoch = y_epoch;
end

opts = statset('display', 'off');

orders = 0:8;
sse = zeros(size(orders));
for kk = 1:length(orders)
  order = orders(kk);
  x_lags = lagmatrix(x, 0:order);
  x_lags(isnan(x_lags)) = 0; % This is not strictly mathematically right, but it doesn't matter
  x_lags = interp1(x_epoch, x_lags, y_epoch, 'nearest');
  
%   regress_fun = @(b,x) regress_fun_with_order(b, x, order);
%   [beta{kk},r,J,COVB,mse] = nlinfit(x_lags, y, regress_fun, [0 1 0.5], opts);
%   sse(kk) = sum(r.^2);
  
  regress_fun = @(b) regress_fun_with_order_resid(b, x_lags, y, order);
  lb = [-inf -inf 0];
  ub = [inf inf 1];
  opt = optimset('display', 'off');
  [beta{kk}, sse(kk), exitflag, output] = fmincon(regress_fun, [0 1 0.5], [], [], [], [], lb, ub, [], opt);
end

[~, minorder_idx] = min(sse);

min_order = orders(minorder_idx);
w = beta{minorder_idx}(3);
ws = zeros(size(beta));
for kk = 1:length(ws)
  ws(kk) = beta{kk}(3);
end

1;

function out = regress_fun_with_order(b, x_lags, order)
%% Function: nonlinear regression to determine state space order
% x is a matrix where row M is an epoch and column N is a single
% time-point lagged version of column N-1

out = b(1) + b(2)*x_lags*b(3).^(0:order).';

function out = regress_fun_with_order_resid(b, x_lags, y, order)
%% Function: nonlinear regression to determine state space order
% x is a matrix where row M is an epoch and column N is a single
% time-point lagged version of column N-1

out = sum((y - (b(1) + b(2)*x_lags*b(3).^(0:order).')).^2);

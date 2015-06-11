function test_garch
% A little script to test how sequentialfs and garchfit work
% By Daniel Golden (dgolden1 at stanford dot edu) July 2011

% $Id$

%% Setup
close all;

%% Construct x and y
% ae = load('ae.mat');
% kp = load('kp.mat');
% 
% epoch = kp.kp_date(kp.kp_date >= datenum([2009 01 01 0 0 0]) & kp.kp_date < datenum([2010 01 01 0 0 0]));
% 
% myae = log10(interp1(ae.epoch, ae.ae, epoch));
% mykp = interp1(kp.kp_date, kp.kp, epoch, 'nearest');

dx = randn(1000, 2);
x_full = filter(1, [1 -0.8], dx);
% x_full = [filter(1, [1 -0.8], dx(:,1)) dx(:,2)];
x = x_full(:,1:1); % Second term is the error
y = x_full(:,1) + x_full(:,2);
t = 0:(length(y) - 1);

figure
subplot(2, 1, 1);
parcorr(y, 10);
title('Partial correlation of Y');
subplot(2, 1, 2);
plot(t, x_full, t, y);
legend('x1', 'x2', 'y');
increase_font;


%% Simple regression to determine correlation of error 

[b,bint,resid,rint,stats] = regress(y, [ones(size(x,1), 1) x]);
y_hat = b(1) + sum(repmat(b(2:end).', size(x, 1), 1).*x, 2);

fprintf('Simple regression b:\n');
fprintf('%g\n', b);

figure
subplot(2, 1, 1);
scatter(y, y_hat);
hold on;
x_lim = xlim;
plot(x_lim, x_lim, 'r-', 'linewidth', 2);
grid on;
xlabel('y');
ylabel('simple y_{hat}');
subplot(2, 1, 2);
parcorr(resid, 10);
ylabel('parcorr');
title('Simple residual parcorr');
increase_font;


%% Create a GARCH model with all coefficients
% Choose an ARMA model with the moving average (error history) component
% set to 1.  This is based on observation (using parcorr) that the error of
% the simple regression at time t is well-correlted with the error at time
% t-1, but not other errors 
spec = garchset('R', 1, 'M', 0, 'display', 'off');
[Coeff,Errors,LLF,Innovations,Sigmas,Summary] = garchfit(spec, y, x);
garchdisp(Coeff, Errors);
y_hat_garch = Coeff.C + Coeff.AR*mean(y) + Coeff.Regress*x;

figure
subplot(2, 1, 1);
scatter(y, y_hat_garch);
hold on;
x_lim = xlim;
plot(x_lim, x_lim, 'r-', 'linewidth', 2);
grid on;
xlabel('y');
ylabel('ARMAX y_{hat}');
subplot(2, 1, 2);
parcorr(Innovations, 10);
ylabel('parcorr');
title('ARMAX residual parcorr');
increase_font;

1;

function criterion = seq_crit_fun(X_train, Y_train, X_test, Y_test)

% Choose an ARMA model with the moving average (error history) component
% set to 1.  This is based on observation (using parcorr) that the error of
% the simple regression at time t is well-correlted with the error at time
% t-1, but not other errors 
spec = garchset('R', 0, 'M', 1);

[Coeff,Errors,LLF,Innovations,Sigmas,Summary] = garchfit(spec, Y_train, X_train);

% A very simple test of signal interpolation using Least Squares
% AutoRegressive Interpolation from
% http://gwc.sourceforge.net/gwc_science/node7.html

% By Daniel Golden (dgolden1 at stanford dot edu) August 2010
% $Id$

clear;

t = (1:200).'; % Time
s = sin(2*pi*t/20); % Signal
n = length(s);
p = 2; % LPC order

good_samples = true(size(s));
good_samples(90:110) = false;

a = lpc(s.*good_samples, p)

A = sparse(n-p, n);
for jj = 1:p+1
  A((n-p)*(jj-1)+1 : n-p+1 : end) = a(end-jj+1);
end

% Partition predictor matrix
sk = s(good_samples);
Au = A(:, ~good_samples);
Ak = A(:, good_samples);

su = -Au\Ak*sk

s_interp = s;
s_interp(~good_samples) = su;

% Plot results
figure;
plot(t, s, t, s_interp);
legend('Original', 'Interpolated');

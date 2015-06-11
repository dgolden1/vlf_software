function [c, delays] = xorxcorr(a, b)
% [c, delays] = xorxcorr(a, b)
% Sort of a cross correlation of two binary vectors
% 
% For different delays of both vectors, return the number of values where
% both vectors were true divided by the number of values where at least one
% vector was true (discard "both false" values)
% 
% 'delays' is the number of points that a LAGS b (negative values indicate
% that a LEADS b)

% By Daniel Golden (dgolden1 at stanford dot edu) September 2008
% $Id$

if ~exist('b', 'var')
	b = a;
end

assert(length(a) == length(b));

n = length(a);

c = zeros(1, 2*length(a) - 1);

for kk = 1:n
	idx_a = (n - kk + 1):n;
	idx_b = 1:kk;

	res_and = and(a(idx_a), b(idx_b));
	res_or = or(a(idx_a), b(idx_b));
	c(kk) = sum(res_and)/sum(res_or);
end
for kk = (n+1):length(c)
	idx_a = 1:(n - (kk - n));
	idx_b = (kk - n + 1):n;

	res_and = and(a(idx_a), b(idx_b));
	res_or = or(a(idx_a), b(idx_b));
	c(kk) = sum(res_and)/sum(res_or);
end

delays = [-(length(a) - 1):(length(a) - 1)];

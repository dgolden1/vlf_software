function J = ecg_get_jet(m)

if ~exist('m', 'var'), m = 256; end

assert(m/4 == floor(m/4));

n = m/4;
assert(n/2 == ceil(n/2));
assert(mod(m,4) ~= 1);

u = [(1:1:n)/n ones(1,n-1) (n:-1:1)/n]';
g = n/2 + (1:length(u))';
r = g + n;
b = g - n;
g(g>m) = [];
r(r>m) = [];
b(b<1) = [];
J = zeros(m,3);
J(r,1) = u(1:length(r));
J(g,2) = u(1:length(g));
J(b,3) = u(end-length(b)+1:end);

function N = hist3_weight(X_orig, W, ctrs)
% A histogram with weighted values
% Just replicates each value of X_orig according to its weight. Assumes all
% weights are integers.
% 
% This is a kludge. It's embarrasing. I don't want to talk about it.
% It's also slow. Use histcn() instead.

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

assert(size(X_orig, 1) == length(W))

X = zeros(sum(W), 2);
X_orig_pos = 1;
X_pos = 1;
while X_orig_pos < length(W)
	X(X_pos:X_pos + W(X_orig_pos) - 1, 1) = X_orig(X_orig_pos, 1);
	X(X_pos:X_pos + W(X_orig_pos) - 1, 2) = X_orig(X_orig_pos, 2);
	
	X_pos = X_pos + W(X_orig_pos);
	X_orig_pos = X_orig_pos + 1;
end

N = hist3(X, ctrs);

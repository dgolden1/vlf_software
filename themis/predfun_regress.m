function y_test = predfun_regress(x_train, y_train, x_test)
% Prediction function for crossval() using straight up regression

% By Daniel Golden (dgolden1 at stanford dot edu) November 2011
% $Id$

b = [ones(size(y_train)), x_train]\y_train;
y_test = [ones(size(x_test, 1), 1), x_test]*b;

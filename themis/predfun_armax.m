function y_test = predfun_armax(x_train, y_train, x_test)
% Prediction function for crossval() using ARMAX regression

% By Daniel Golden (dgolden1 at stanford dot edu) November 2011
% $Id$
R = 1; % Num AR coefficients
M = 0; % Num MA coefficients
spec = garchset('R', R, 'M', M, 'display', 'off');
[Coeff,Errors,LLF,Innovations,Sigmas,Summary] = garchfit(spec, y_train, x_train);

y_test = Coeff.C + Coeff.AR*mean(y_train) + x_test*Coeff.Regress.';

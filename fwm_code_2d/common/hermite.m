function y=hermite(n,x)
%HERMITE Hermite function
y=exp(-x.^2/2).*hermite_poly(n,x)/sqrt(factorial(n)*2^n*sqrt(pi));

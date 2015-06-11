function y=hermite_poly(n,x)
%HERMITE_POLY Hermite polynomial
if round(n)~=n | n<0
    error('n must be a non-negative integer')
end
if n==0
    y=ones(size(x));
    return
elseif n==1
    y=2*x;
else
    y=2*x.*hermite_poly(n-1,x)-2*(n-1)*hermite_poly(n-2,x);
end

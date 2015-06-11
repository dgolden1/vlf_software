function y0=dequantize(x0,y)
% Divide into quantized regions
x=x0(:)';
y=y(:)';
n=length(x);
if length(y)~=n
    error('different length')
end
ii=find(diff(y));
xp=[x(1) 0.5*(x(ii)+x(ii+1)) x(n)];
y1=0.5*(y(ii)+y(ii+1));
m=length(y1);
if m>1
    yp=[y(1) y(1) y1(2:m-1) y(n) y(n)];
elseif m==0
    yp=[y(1) y(n)];
else
    % m==1
    yp=[y(1) y(1) y(n)];
end
y0=interp1(xp,yp,x0);

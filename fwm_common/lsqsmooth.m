function [ys,a,x]=lsqsmooth(y,N)
if nargin<2
    N=1;
end
n=length(y);
x=y; % copy size
x(:)=([0:n-1].')/(n-1);
p=zeros(2*N+1,1);
yp=zeros(N+1,1);
for k=0:2*N
    p(k+1)=sum(x.^k);
end
for k=0:N
    yp(k+1)=sum(y.*(x.^k));
end
A=zeros(N+1,N+1);
for k=0:N
    for l=0:N
        A(k+1,l+1)=p(k+l+1);
    end
end
a=A\yp;
ys=zeros(size(y));
for k=0:N
    ys=ys+x.^k*a(k+1);
end

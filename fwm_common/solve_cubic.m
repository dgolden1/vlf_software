function [x,err]=solve_cubic(a0,b0,c0,d0)
%SOLVE_CUBIC Solve a*x^3+b*x^2+c*x+d=0
% function [x,err]=solve_cubic(a,b,c,d)
% Can take 1D (column) arrays of a,b,c,d.
% See Wikipedia.

% Extensive error checking in the beginning
if any(a0==0)
    error('a==0');
end
a0=a0(:); b0=b0(:); c0=c0(:); d0=d0(:);
lengths=[length(a0),length(b0),length(c0),length(d0)];
n=max(lengths);
if n>1
    if length(a0)==1
        a0=repmat(a0,n,1);
    end
    if length(b0)==1
        b0=repmat(b0,n,1);
    end
    if length(c0)==1
        c0=repmat(c0,n,1);
    end
    if length(d0)==1
        d0=repmat(d0,n,1);
    end
end
lengths=[length(a0),length(b0),length(c0),length(d0)];
if any(lengths~=n)
    error('wrong lengths');
end

% To form x^3+3*a*x^2+b*x+c=0:
a=b0./a0/3; b=c0./a0; c=d0./a0;
% Depressed cubic: t^3+3*p*t+2*q=0, x=t-a
p=b/3-a.^2; q=c/2+a.^3-a.*b/2;
[t,err]=solve_depressed_cubic(p,q);
x=t-repmat(a,1,3);

function [x,err]=solve_quartic(a0,b0,c0,d0,e0)
%SOLVE_QUARTIC Solve a*x^4+b*x^3+c*x^2+d*x+e=0
% function [x,err]=solve_quartic(a,b,c,d,e)
% Can take 1D (column) arrays a,b,c,d,e.
% See Wikipedia.

% Extensive error checking in the beginning
if any(a0==0)
    error('a==0');
end
a0=a0(:); b0=b0(:); c0=c0(:); d0=d0(:); e0=e0(:);
lengths=[length(a0),length(b0),length(c0),length(d0),length(e0)];
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
    if length(e0)==1
        e0=repmat(e0,n,1);
    end
end
lengths=[length(a0),length(b0),length(c0),length(d0),length(e0)];
if any(lengths~=n)
    error('wrong lengths');
end

% Form with a=1
b=b0./a0; c=c0./a0; d=d0./a0; e=e0./a0;

% Depressed form u^4+alfa*u^2+beta*u+gamma=0
% x=u-b/4
alpha = -3*b.^2/8 + c;
beta  =  b.^3/8 - b.*c/2 + d;
gamma = -3*b.^4/256 + c.*b.^2/16 - b.*d/4 + e;
[u,err]=solve_depressed_quartic(alpha,beta,gamma);
x=u-repmat(b/4,1,4);


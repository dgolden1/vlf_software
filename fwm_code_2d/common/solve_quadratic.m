function x=solve_quadratic(a0,b0,c0)
%SOLVE_QUADRATIC Solve a*x^2+b*x+c=0
% Can take 1D column arrays of a,b,c.

% Extensive error checking in the beginning
if any(a0==0)
    error('a==0');
end
a0=a0(:); b0=b0(:); c0=c0(:);
lengths=[length(a0),length(b0),length(c0)];
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
end
lengths=[length(a0),length(b0),length(c0)];
if any(lengths~=n)
    error('wrong lengths');
end

% To form x^2+2*p*x+q=0
p=b0./a0/2; q=c0./a0;
r=sqrt(p.^2-q);
x=[-p+r,-p-r];
%a0*x.^2+b0*x+c0

function [t0,err]=solve_depressed_cubic(p0,q0)
%SOLVE_DEPRESSED_QUBIC Solve t^3+3*p*t+2*q=0
% Can take 1D (column) arrays of p and q.
% Use Cardano method.
% See Wikipedia.

% Check the sizes
p0=p0(:); q0=q0(:);
lengths=[length(p0),length(q0)];
n=max(lengths);
if n>1
    if length(p0)==1
        p0=repmat(p0,n,1);
    end
    if length(q0)==1
        q0=repmat(q0,n,1);
    end
end
lengths=[length(p0),length(q0)];
if any(lengths~=n)
    error('wrong lengths');
end

% Collect data here
t0=nan(n,3);

% Scale the coefficients, so that |p|<=1, |q|<=1:
s=max(sqrt(abs(p0)),abs(q0).^(1/3));
% Trivial equation
trivial=(s==0);
if any(trivial)
	iit=find(trivial);
    t0(iit,:)=0;
end
if all(trivial)
	err=0
    return
end

iint=find(~trivial);
p=p0(iint)./s(iint).^2; q=q0(iint)./s(iint).^3;
% Main thing here
[t,err]=solve_cardano_aux(p,q);
% Merge with trivial solutions
t0(iint,:)=repmat(s(iint),1,3).*t;

function [u0,err]=solve_depressed_quartic(alpha0,beta0,gamma0)
%SOLVE_DEPRESSED_QUARTIC Solve u^4+alfa*u^2+beta*u+gamma=0
% Can take 1D (column) arrays of alpha, beta, gamma.
% See Wikipedia.

% Check the sizes
alpha0=alpha0(:); beta0=beta0(:); gamma0=gamma0(:);
lengths=[length(alpha0),length(beta0),length(gamma0)];
n=max(lengths);
if n>1
    if length(alpha0)==1
        alpha0=repmat(alpha0,n,1);
    end
    if length(beta0)==1
        beta0=repmat(beta0,n,1);
    end
    if length(gamma0)==1
        gamma0=repmat(gamma0,n,1);
    end
end
lengths=[length(alpha0),length(beta0),length(gamma0)];
if any(lengths~=n)
    error('wrong lengths');
end

% Collect data here
u0=nan(n,4);

% We must handle the instabilities here!
% Scale so that |alpha|<=1, |beta|<=1, |gamma|<=1
s=max([sqrt(abs(alpha0)),abs(beta0).^(1/3),abs(gamma0).^(1/4)],[],2);
% Trivial equation
trivial=(s==0);
iit=find(trivial);
if any(trivial)
    u0(iit,:)=0;
end
if all(trivial)
	err=0;
    return
end

iint=find(~trivial);
alpha=alpha0(iint)./s(iint).^2;
beta=beta0(iint)./s(iint).^3;
gamma=gamma0(iint)./s(iint).^4;

% Main thing here
[u,err]=solve_quartic_2quadratic_aux(alpha,beta,gamma);

% Merge with trivial solutions
u0(iint,:)=repmat(s(iint),1,4).*u;


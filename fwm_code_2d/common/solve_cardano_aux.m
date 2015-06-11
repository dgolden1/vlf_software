function [t,err]=solve_cardano_aux(p,q)
%SOLVE_CARDANO_AUX Solve t^3+3*p*t+2*q=0
% Auxiliary routine, don't call. Use SOLVE_DEPRESSED_CUBIC instead.

% Collect the solutions here
n=length(p);
t=nan(n,3);

% Cubic roots of 1:
r1=-1/2+i*sqrt(3)/2;
r2=-1/2-i*sqrt(3)/2;

% Case of zero p:
zerop=(p==0);
izp=find(zerop);
if any(zerop)
    % Because of scaling, |q|=1
    x=(-2*q(izp)).^(1/3);
    t(izp,:)=[x,x*r1,x*r2];
end
if any(~zerop)
	% General case
	inp=find(~zerop);
    % Cardano's method: find t=u-v.
	% v^3-u^3=2*q; u*v=p => 
    % v=p/u => u^6+2*q*u^3-p^3=0
    % -v is the other root
	p1=p(inp); q1=q(inp);
    s=sqrt(q1.^2+p1.^3);
	% usol=[u1,u2];
    usol=[s-q1,-(s+q1)].^(1/3);
	% Both u1 and u2 cannot be zero, because |t|<=|u|+|v|=|u1|+|u2| and there are
	% nonzero solutions.
	[dummy,ii]=max(abs(usol),[],2);
	u=usol(n*(ii-1)+[1:n]'); % We use the way MATLAB stores 2D arrays
	v=p./u;
    t(inp,:)=[u-v,u*r2-v*r1,u*r1-v*r2];
end

% Check the solution
pr=repmat(p,1,3); qr=repmat(q,1,3);
rhs=t.^3+3*pr.*t+2*qr;
% Check if they are a complete solution
delta=[sum(t,2),prod(t,2)+2*q,...
    t(:,1).*t(:,2)+t(:,1).*t(:,3)+t(:,2).*t(:,3)-3*p];
err=max(max(max(abs(rhs))),max(max(abs(delta))));
if err > eps('single')
    error('loss of precision')
end

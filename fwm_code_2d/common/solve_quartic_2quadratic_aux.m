function [u,err]=solve_quartic_2quadratic_aux(alpha,beta,gamma)
%SOLVE_QUARTIC_2QUADRATIC_AUX Solve u^4+alpha*u^2+beta*u+gamma=0
% Auxiliary routine, don't call. Use SOLVE_DEPRESSED_QUARTIC instead.

% Collect the solutions here
n=length(alpha);
% u^4+alpha*u^2+beta*u+gamma=(u^2+p*u+q)(u^2-p*u+s)=0
% If we substitute y=p^2, t=beta/p,
% then q and s are expressed in terms of p:
%   q=(alpha+y-t)/2; s=(alpha+y+t)/2;
% The equation for p becomes, after substituting t^2=beta^2/y:
%  (alpha+y)^2-beta^2/y=4*gamma
% or
%  y^3+2*alpha*y^2+(alpha^2-4*gamma)*y-beta^2=0

y=solve_cubic(1,2*alpha,alpha.^2-4*gamma,-beta.^2);
% To find t=beta/p, we must choose the y with max(abs(y)):
[dummy,ii]=max(abs(y),[],2);
y1=y(n*(ii-1)+[1:n]'); % We use the way MATLAB stores 2D arrays


% Since equation was scaled, abs(y1) must be ~ 1 => avoid division by zero.
% All y==0 only if 2*alpha=0, -beta^2==0 and alpha^2-4*gamma=0, i.e.,
% alpha=beta=gamma=0, which is impossible.
p=sqrt(y1); t=beta./p;
q=(alpha+y1-t)/2; s=(alpha+y1+t)/2;
u=[solve_quadratic(1,p,q),solve_quadratic(1,-p,s)];

% Check the solution
ar=repmat(alpha,1,4); br=repmat(beta,1,4); gr=repmat(gamma,1,4);
rhs=u.^4+ar.*u.^2+br.*u+gr;
% Check if they are a complete solution
delta=[sum(u,2), prod(u,2)-gamma, ...
    u(:,1).*u(:,2)+u(:,1).*u(:,3)+u(:,1).*u(:,4)+ ...
	u(:,2).*u(:,3)+u(:,2).*u(:,4)+u(:,3).*u(:,4)-alpha, ...
    u(:,1).*u(:,2).*u(:,3)+u(:,1).*u(:,2).*u(:,4)+ ...
	u(:,1).*u(:,3).*u(:,4)+u(:,2).*u(:,3).*u(:,4)+beta];
err=max(max(max(abs(rhs))),max(max(abs(delta))));
if err > eps('single')
    error('loss of precision')
end

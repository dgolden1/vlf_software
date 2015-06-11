function [xb,x,f0arr,relerror]=bestgrid(fun,params,xb,dx0,retol,miniter,quiet)
%BESTGRID Find the best grid for trapezoidal integration
% Usage:
%   [xb,x,f0arr,relerror]=bestgrid(fun,params,xb,dx0,retol);
% The method is based that the integration error is |f"|*dx^3/24.
% Inputs:
%   fun -- a function which is being integrated;
%   params -- additional parameters for the function, {} if none;
%   xb -- starting values of boundaries of intervals;
%   dx0 -- minimum tolerable dx;
%   retol -- tolerance of the relative integration error
% Output:
%   xb -- new boundaries
% Optional outputs:
%   f0arr -- values of the function at x=(xb1+xb2)/2
%   relerror -- relative integration error
if nargin<7
    quiet=[];
end
if nargin<6
    miniter=[];
end
if isempty(miniter)
    miniter=1;
    % Do at least one iteration before exiting, so that we don't use
    % the initial inefficient grid (to save time, the result should not
    % change).
end
if isempty(quiet)
    quiet=0;
end
xb=xb(:);
iteration=0;
while 1
    N=length(xb)-1;
    if ~quiet
        if iteration==0
            disp(['BESTGRID: Initial estimate, N=' num2str(N)]);
        else
            disp(['BESTGRID: Re-do, iteration=' num2str(iteration) ', N=' num2str(N)]);
        end
    end
    dxb=diff(xb);
    x=(xb(1:N)+xb(2:N+1))/2;
    dx=diff(x);
    dxav=(dx(1:N-2)+dx(2:N-1))/2;
    f0arr=fun(x,params{:}); % The first dimension of f0arr corresponds to x
    s=size(f0arr);
    if length(s)<3
        si=[s(2) 1];
    else
        si=s(2:end);
    end
    ns=prod(si);
    f0=reshape(f0arr,[N ns]);
    abserror=zeros(si);
    total=zeros(si);
    ga=zeros(N,ns);
    f2=zeros(N,ns);
    for k=1:ns
        % The integration error is = |f"|*dx^3
        f2(:,k)=[0 ; abs(diff(diff(f0(:,k))./dx)./dxav) ; 0];
        % - approximation to |f"|
        total(k)=sum(abs(f0(:,k)).*dxb); % integral
        % We coarsen the mesh at some points but preserve the
        % relative error
        %figure; plot(abs(f2(:,k)))
        abserror(k)=max(abs(f2(:,k)).*dxb.^3);
    end
    total;
    relerror=abserror/max(total(:));
    if ~quiet
        disp('Mean relative error=');
        disp(mean(relerror(:)));
    end
    if max(relerror(:))<retol & iteration>=miniter
        break
    end
    % EXIT FROM THE CYCLE IS HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    e0=retol*max(total(:))/10; % target for |f"|*dx^3
    % Estimate for new value of 1/dx
    g=max((max(f2,[],2)/e0).^(1/3),1/dx0);
    % -- take max of g over the spectator indeces
    G=[0 ; cumsum(g.*dxb)]; % dG=1 if dn is optimal
    Gd=linspace(G(1),G(end),ceil(G(end)-G(1))).';
    % The new grid
    xb=interp1(G,xb,Gd);
    iteration=iteration+1;
end

function pointillism(x,y,f,n,markersize)
%POINTILLISM Plot a function with points
% Plot a function with values given at arbitrary (x,y) with point markers.
% Usage:
%    pointillism(x,y,f[,n,markersize])
% Default arguments: markersize=2, n=size of the current colormap

% Get rid of nans
ii=(~isnan(f) & isfinite(f));
x=x(ii); y=y(ii); f=f(ii);
if any(isnan(f))
    error('isnan(f)');
end
c0=colormap;
if nargin<4
    n=[];
end
if isempty(n)
    c=c0;
    n=size(c,1);
else
    n0=size(c0,1);
    c=interp1([0:n0-1]/(n0-1),c0,[0:n-1]/(n-1));
end
fmin=min(f);
fscaled=floor(1+n*(f-fmin)/(max(f)-fmin));
fscaled(find(fscaled==n+1))=n;
for k=1:n
    ii=find(fscaled==k);
    if ~isempty(ii)
        if nargin<5
            plot(x(ii),y(ii),'.','color',c(k,:));
        else
            plot(x(ii),y(ii),'.','color',c(k,:),'markersize',2);
        end
    end
    if k==1
        hold on
    end
end
hold off

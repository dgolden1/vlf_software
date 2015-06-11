function hatchcoor=hatchregion(x,y,a,d,doplot)
% x,y - coordinates of a closed curve to be hatched
% a - angle (in radians) from the vertical clockwise
% d - distance between strokes

% Input arguments
if nargin<5
    doplot=0;
end
n=length(x);
if length(y)~=n
    error('x,y must be same length')
end
% 1. Rotate so that hatching is vertical
x0=x*cos(a)-y*sin(a);
y0=x*sin(a)+y*cos(a);
y0s=y0([2:n 1]);
dy0=y0s-y0;
% Min and max x
[xmin,ixmin]=min(x0);
[xmax,ixmax]=max(x0);
% The x-coordinates of the hatch
xrange=xmax-xmin;
nhatch=ceil(xrange/d);
xhatch=xmin+(xrange-(nhatch-1)*d)/2+[0:nhatch-1]*d;

nstrokes=1;
for k=1:nhatch
    dx=x0-xhatch(k);
    dxs=dx([2:n 1]);
    ii=find(dx.*dxs<=0 & dxs~=0);
    ni=length(ii)/2;
    if ni~=round(ni)
        error('ni');
    end
    di=-dx(ii)./(dxs(ii)-dx(ii));
    yh=sort(y0(ii)+di.*dy0(ii));
    xh=ones(1,2*ni)*xhatch(k);
    % Rotate
    xc=xh*cos(a)+yh*sin(a);
    yc=-xh*sin(a)+yh*cos(a);
    for kk=1:ni
        nstrokes=nstrokes+1;
        ind=[2*kk-1 2*kk];
        hatchcoor(nstrokes,:)=[xc(ind) yc(ind)];
    end
end

% Plotting
if doplot
    s=ishold;
    for kk=1:nstrokes
        plot(hatchcoor(kk,1:2),hatchcoor(kk,3:4));
        if kk==1
            hold on
        end
    end
    % Restore the hold status
    if ~s
        hold off
    end
end

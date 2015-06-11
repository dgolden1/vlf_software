function hatchcoor=hatchcurve(x,y,a,d,l,doplot)
% x,y - coordinates of a closed curve to be hatched
% a - angle (in radians) from the vertical clockwise
% d - distance between strokes

% Input arguments
if nargin<6
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
xrange=x0(n)-x0(1);
nhatch=ceil(xrange/d);
xhatch=xmin+(xrange-(nhatch-1)*d)/2+[0:nhatch-1]*d;
yhatch=interp1(x0,y0,xhatch);
dx=l*sin(a);
dy=l*cos(a);
xc=xhatch*cos(a)+yhatch*sin(a);
yc=-xhatch*sin(a)+yhatch*cos(a);

hatchcoor=[xc ; xc+dx ; yc ; yc+dy ].';
if doplot
    s=ishold;
    for kk=1:nhatch
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

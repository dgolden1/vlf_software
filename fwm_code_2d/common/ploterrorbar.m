function ploterrorbar(x,y,barlen,linewidth,color,arrowlen)
% PLOTERRORBAR Plot error bar, vertical or horizontal
% If the limit is offscale, the arrow is plotted.
% For the sizes of "barlen" and "arrowlen", the relative sizes are used
% (the fraction of the axes size).
% Usage:
%   ploterrorbar(x,y,barlen,linewidth,color,arrowlen)
% Inputs:
%   x,y -- the coordinates of the tips of the bar: if length(x)==1,
%       vertical bar, if length(y)==1, horizontal bar
%   barlen -- the length of the ticks on the tips of the bar
%   linewidth -- default=0.5
%   color -- default is blue
%   arrowlen -- the size of the arrow for off-plot points; default=0.2

% Default arguments
barlen=barlen/2;
if nargin<6
    arrowlen=.2;
end
if nargin<5
    color=[];
end
if nargin<4
    linewidth=[];
end
if isempty(color)
    color=[0 0 1];
end
if isempty(linewidth)
    linewidth=0.5;
end
% Check the sizes for the plotting
if ((size(y)==[1 2] | size(y)==[2 1]) & size(x)==[1 1])
    transp=0;
elseif ((size(x)==[1 2] | size(x)==[2 1]) & size(y)==[1 1])
    transp=1;
else
    error('Incorrect sizes for plotting');
end
% Switch the x and y if necessary for universality
if transp
    x0=y;
    yy=x;
else
    x0=x;
    yy=y;
end
% - now x0 is a number, yy is a vector of length 2.
xylim=zeros(2,2);
xylim(1,:)=get(gca,'xlim');
xylim(2,:)=get(gca,'ylim');

% Get the positions for plotting
[xrel0,yyrel]=convcoorxy(x0,yy,1,transp,xylim);
if yyrel(2)==-inf
    return % nothing to plot
end
doarrow=(yyrel(1)==-inf); % plot an arrow
if doarrow
    yyrel(1)=max(0,yyrel(2)-arrowlen);
end
xbar=xrel0+barlen*[-1 1];
if doarrow
    x3=xrel0+barlen*[-1 0 1];
    y3=yyrel(1)*[1 1 1]+barlen*2*[1 0 1];
    linereltr(x3,y3,transp,xylim,linewidth,color)
else
    linereltr(xbar,yyrel(1)*[1 1],transp,xylim,linewidth,color)
end
linereltr([xrel0 xrel0],yyrel,transp,xylim,linewidth,color)
linereltr(xbar,yyrel(2)*[1 1],transp,xylim,linewidth,color)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function linereltr(x0,y0,transp,xylim,linewidth,color)
[x,y]=convcoorxy(x0,y0,0,transp,xylim);
if transp
    line(y,x,'linewidth',linewidth,'color',color);
else
    line(x,y,'linewidth',linewidth,'color',color);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x0,y0]=convcoorxy(x,y,torel,transp,xylim);
if transp
    x0=convcoor(x,'y',torel,xylim);
    y0=convcoor(y,'x',torel,xylim);
else
    x0=convcoor(x,'x',torel,xylim);
    y0=convcoor(y,'y',torel,xylim);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x0=convcoor(x,xory,torel,xylim)
% Must work when x is a matrix
islog=strcmp(get(gca,[xory 'scale']),'log');
%lim=get(gca,[xory 'lim']);
switch xory
 case 'x'
  lim=xylim(1,:);
 case 'y'
  lim=xylim(2,:);
end
if islog
    lim=log(lim);
end
dlim=lim(2)-lim(1);
if torel
    if islog
        i0=find(x>0);
        i1=find(x<=0);
        x(i0)=log(x(i0));
        x(i1)=-inf;
    end
    x0=(x-lim(1))/dlim;
else
    x0=lim(1)+x*dlim;
    if islog
        x0=exp(x0);
    end
end

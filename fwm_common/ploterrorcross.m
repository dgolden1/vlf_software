function ploterrorcross(x,y,dx,dy)
% PLOTERRORCROSS Plot error cross on a 2D plot
% Usage: ploterrorcross(x,y,dx,dy)
ploterrorbar([x-dx x+dx],y,0.01,2,'k')
ploterrorbar(x,[y-dy y+dy],0.01,2,'k')

function [x_peak y_peak] = Quadratic_Interpolation(x2,dx,y1,y2,y3)

% $Id$

x_adjust = dx*0.5*(y1-y3)/(y1-2*y2+y3);
x_peak = x2+x_adjust;
y_peak = y2-0.25*(y1-y3)*x_adjust;

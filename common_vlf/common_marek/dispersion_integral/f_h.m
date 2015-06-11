function [fh_val]=f_h(phi)
global L;
fh_val=8.736e5./((L*cos(phi).^2).^3).*sqrt(1+3*sin(phi).^2);

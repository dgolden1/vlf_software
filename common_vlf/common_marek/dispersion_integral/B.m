function [B_val]=B(phi)
global L;
B_val=3.12e-5./((L*cos(phi).^2).^3).*sqrt(1+3*sin(phi).^2);

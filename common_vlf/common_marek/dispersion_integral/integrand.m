function [inte]=integrand(phi)
% f=1000;
global f;
inte=fp(n(phi))./(sqrt(f).*sqrt(f_h(phi)).*(1-f./f_h(phi)).^(1.5)).*ds_dphi(phi);

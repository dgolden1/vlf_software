function sig=photoeffect(k,Z)
% (21.17) in Heitler
global rclass0
if isempty(rclass0)
    loadconstants
end
eion=Z^2/(2*137^2);
g=k+1;
p=sqrt(g.^2-1);
sig=4*pi*rclass0^2*Z^5/137^4./k.^5.*p.^3.*(...
    4/3+g.*(g-2)./(g+1).*(1-1./(2.*g.*p).*log((g+p)./(g-p))) );

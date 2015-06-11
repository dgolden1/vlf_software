function sig=annihilation(Ep)
global rclass0
if isempty(rclass0)
    loadconstants
end
pp=sqrt(Ep.^2-1);
sig=pi*rclass0^2./(Ep+1).*((Ep.^2+4*Ep+1)./(Ep.^2-1).*log(Ep+pp)...
    -(Ep+3)./pp);
sig(find(Ep<=1))=0;

function [nueff,weff]=get_effective_nu(h,w,do_correct)
global kB ech
if isempty(kB)
    loadconstants
end
nueff=h; % copy size
weff=h;
T=getTn(h);
Nm=getNm(h);
TeV=kB*T/ech;
M=length(h);
for iz=1:M
    [enT,neT]=getneT(TeV(iz),'nen',30000); % enT in eV, sum(neT)=1
    nuen=Nm(iz)*getnumom(enT);
    winu=w+i*nuen;
    if do_correct
        en=enT*2/3/TeV(iz); % Normalized enT to temperature
        tmp=sum(en.*neT./winu);
    else
        tmp=sum(neT./winu);
    end
    weff(iz)=real(1/tmp);
    nueff(iz)=imag(1/tmp);
end

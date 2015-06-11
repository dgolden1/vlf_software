function [numom_out,h_out]=plot_collisionrate(varargin)
global kB ech
if isempty(kB)
    loadconstants
end
[h,options]=parsearguments(varargin,0,{'doplot'});
if isempty(h)
    h=[0:120];
end
doplot=getvaluefromdict(options,'doplot',1);
T0=kB*getTn(h)/ech; % in eV
Nm=getNm(h); % in m^{-3}
numom=zeros(size(h));
for iz=1:length(h)
    [enT,neT]=getneT(T0(iz)); % enT in eV, sum(neT)=1
    numom(iz)=Nm(iz)*sum(getnumom(enT).*neT);
end
if nargout>0
    numom_out=numom;
    h_out=h;
end
if doplot
    semilogx(numom,h); grid on;
    xlabel('Momentum transfer rate, s^{-1}');
    ylabel('Altitude, km');
end

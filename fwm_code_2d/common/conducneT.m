function cres=conducneT(T,Nm,Ne,weff,doapprox)
%cres=conducneT(T,Nm,Ne,weff,doapprox)
% Thermal conductivity for given Ne
% ne does not have to be normalized.
% A particular case of "conducne.m" (can be a bit faster).
global ech me
if isempty(ech)
    loadconstants
end
if nargin<5
    doapprox=0;
end

% Catch the zero Ne case
if Ne<0 | isnan(Ne)
    error(['Ne=' num2str(Ne)]);
elseif Ne==0
    return
end

[en,ne]=getneT(T,'nen',800,'enmax',T*30);
numom=Nm*getnumom(en);
distr=ne/sum(ne);
if ~doapprox
    distr=2/3*en/T.*distr;
end
cres=Ne*ech^2/me*sum(distr./(numom-i*weff));

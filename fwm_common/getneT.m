function [en,neT]=getneT(varargin)
% [en,neT]=getneT(T,options) where options are 'enmax','nen' and 'den'.
% Units are eV.
[T,options]=parsearguments(varargin,1,{'enmax','nen','den','debug'});
nen=getvaluefromdict(options,'nen',[]);
if isempty(nen)
    nen=300;
end
den=getvaluefromdict(options,'den',[]);
if isempty(den)
    enmax=getvaluefromdict(options,'enmax',[]);
    if isempty(enmax)
        enmax=T*10;
    end
    den=enmax/nen;
end
en=[1:nen]'*den;
neT=sqrt(en).*exp(-en/T); % Maxwell's distribution
neT=neT/sum(neT); % Normalize

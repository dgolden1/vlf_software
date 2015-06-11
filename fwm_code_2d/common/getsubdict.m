function subdict=getsubdict(dict,keys,complement)
%GETSUBDICT Get a dictionary subset
% Usage:
%   subdict=getsubdict(dict,keys[,1])
% or
%   subdict=getsubdict(dict,keys,0)
% to get the subdictionary NOT containing the given keys.
% See also: GETVALUEFROMDICT, PARSEARGUMENTS
% Author: Nikolai G. Lehtinen

if nargin<3
    complement=1;
end
n=length(dict)/2;
subdict={};
for k=1:n
    ckey=dict{2*k-1}; cvalue=dict{2*k};
    ii=find(strcmp(ckey,keys));
    if length(ii)>1
        error(['multiple keys ' ckey])
    end
    if xor(complement,isempty(ii))
        subdict={subdict{:},ckey,cvalue};
    end
end

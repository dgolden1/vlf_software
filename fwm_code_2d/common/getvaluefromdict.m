function [value,found]=getvaluefromdict(dict,key,defaultvalue)
%GETVALUEFROMDICT Get the value by the key from a dictionary
%
% Usage:
%   value=getvaluefromdict(dict,key,defaultvalue);
%   [value,found]=getvaluefromdict(dict,key,defaultvalue);
% dict is a cell array {'key1',value1,'key2',value2,...}
% The keys can repeat, then the warning is generated and only the last
% value is used.
% Output variable found==0 indicates that defaultvalue is used.
% See also: PARSEARGUMENTS, GETSUBDICT
% Author: Nikolai G. Lehtinen

if ~iscell(dict)
    error('Dictionary cell array expected');
end
if rem(length(dict),2)~=0
   error('Key-value pairs expected.')
end
n=length(dict)/2;
value=defaultvalue;
found=0;
for k=1:n
    ckey=dict{2*k-1}; cvalue=dict{2*k};
    if strcmp(ckey,key)
        if found
            disp(['WARNING: resetting value of ''' key '''']);
        end
        value=cvalue;
        found=1;
    end
end

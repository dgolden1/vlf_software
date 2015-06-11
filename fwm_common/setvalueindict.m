function [dict,found]=setvalueindict(dict,key,value)
if ~iscell(dict)
    error('Dictionary cell array expected');
end
if rem(length(dict),2)~=0
   error('Key-value pairs expected.')
end
n=length(dict)/2;
found=0;
for k=1:n
    ckey=dict{2*k-1};
    if strcmp(ckey,key)
        if found
            disp(['WARNING: resetting value of ''' key '''']);
        end
        dict{2*k}=value;
        found=1;
    end
end
if ~found
    % Add another key-value pair
    dict={dict{:},key,value};
end

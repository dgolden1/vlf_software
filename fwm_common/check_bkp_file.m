function isvalid=check_bkp_file(bkp_file,s,args)
%CHECK_BKP_FILE Check if the file contains correct variables
% Usage:
%    isvalid=check_bkp_file('fname',struct('a',a,'b',b,'c',c));
% or
%    isvalid=check_bkp_file('fname',{'a','b','c'},{a,b,c});
% Meta programming
if iscell(s)
    % We have the name list instead of a structure
    names=s;
    n=length(names);
    s=struct();
    for c=1:n
        s=setfield(s,names{c},args{c});
    end
end
names=fieldnames(s); n=length(names);
sf=load(bkp_file,names{:}); % structure
isvalid=isequalwithequalnans(s,sf);
%for k=1:n
%    names{k}
%    isequalwithequalnans(getfield(s,names{k}),getfield(sf,names{k}))
%end

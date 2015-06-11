function varargout=parsearguments(args,nmin,allowedkeys)
%PARSEARGUMENTS Parse the input arguments for a function
%
% Usage example:
%   function result=myfunction(varargs)
%   allowedkeys={'key1','key2'};
%   nmin=2; % minimum required arguments of myfunction
%   [arg1,arg2,arg3,options]=parsearguments(varargs,nmin,allowedkeys)
%   value1=getvaluefromdict(options,'key1',defaultvalue1);
%   % options is a cell array with keys and values
% Then this function can be called like this:
%   res=myfunction(arg1,arg2,'key2',value2);
% Then arg3 will be assigned a value of empty matrix, OPTIONS is
% {'key2',value2}.
% The following usages of MYFUNCTION will generate an error:
%   res=myfunction(arg1,'key2',value2); % not enough arguments, nmin=2
%   res=myfunction(arg1,arg2,'key3',value3); % unknown key 'key3'
% This will give a warning (in GETVALUEFROMDICT):
%   res=myfunction(arg1,arg2,'key1',value1a,'key1',value1b);
% IMPORTANT NOTE: arguments after nmin cannot be strings!
% See also: GETVALUEFROMDICT, GETSUBDICT
% Author: Nikolai G. Lehtinen

% "Borrowed" from standard function "parseparams"
charsrch=[];
for i=nmin+1:length(args),
   charsrch=[charsrch ischar(args{i})];
end
charindx=nmin+find(charsrch);
if isempty(charindx),
   regargs=args;
   proppairs=args(1:0);
else
   regargs=args(1:charindx(1)-1);
   proppairs=args(charindx(1):end);
end

nmax=nargout-1;
nargs=length(regargs);
error(nargchk(nmin,nmax,nargs));
for k=1:nmax
    if k<=nargs
        varargout{k}=regargs{k};
    else
        varargout{k}=[];
    end
end
if rem(length(proppairs),2)~=0
   error('Option value pairs expected.')
end
nprop=length(proppairs)/2;
for k=1:nprop
    key=proppairs{2*k-1};
    ii=find(strcmp(key,allowedkeys));
    if isempty(ii)
        error(['Key ''' key ''' is not allowed']);
    end
end
varargout{nmax+1}=proppairs;

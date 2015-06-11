function s=hms(varargin)
% HMS Convert to a string of hours, minutes and seconds
% s=hms(t,[,'style',style,'zeros',{0|1}]), where style=='hms' or 'dots'
[t,options]=parsearguments(varargin,1,{'style','zeros','spacer','debug'});
if t<0
    error('t<0');
end
debugflag=getvaluefromdict(options,'debug',0);
style=getvaluefromdict(options,'style','hms');
z=getvaluefromdict(options,'zeros',0);
spacer=getvaluefromdict(options,'spacer','');

% Extract the hours, minutes and seconds
thms=zeros(1,3);
thms(3)=rem(t,60);
tmin=fix(t/60); thms(2)=rem(tmin,60);
thms(1)=fix(tmin/60);
if debugflag>0
    thms
end

switch style
    case 'hms'
        insert={'h','m','s'};
    case 'dots'
        insert={':',':',''};
end

s='';
for k=1:3
   if z | k==3 | thms(k)>0
       addition=[num2str(thms(k)) spacer insert{k}];
       if ~strcmp(s,'')
           s=[s spacer addition];
       else
           s=addition;
       end
   end
end

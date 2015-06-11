%play_again.m
t = cputime;

%plotting options
HH = findobj(gcf,'tag','figureNo');
figureNo = str2num(get(HH,'string'));
if(isempty(figureNo)|~isnumeric(figureNo)|round(figureNo)~=figureNo|figureNo<1|~isreal(figureNo))
    set(HHprogress,'string','ERROR: figure number must be a positive integer')
    break
end

HHprogress = findobj(gcf,'tag','progress');

try
    set(figureNo,'DoubleBuffer','on');
catch
    set(HHprogress,'string','ERROR: no movie available');
    break
end


HH = findobj(gcf,'tag','num_times');
num_times = str2num(get(HH,'string'));
if(isempty(num_times)|~isnumeric(num_times)|round(num_times)~=num_times|num_times<1|~isreal(num_times))
    set(HHprogress,'string','ERROR: number of playback cycles must be a positive integer')
    break
end

HH = findobj(gcf,'tag','num_fps');
num_fps = str2num(get(HH,'string'));
if(isempty(num_fps)|~isnumeric(num_fps)|num_fps<1|num_fps>60|~isreal(num_fps)|num_fps~=floor(num_fps))
    set(HHprogress,'string','ERROR: number of unique frames must be integer between 1 and 60')
    break
end



    set(HHprogress,'string','Playing movie ...');
try
    figure(figureNo)
    movie(h,M,num_times,num_fps);
catch
    set(HHprogress,'string','ERROR: no movie available');
end


 set(HHprogress,'string',['Done! (' num2str(cputime-t) ' seconds)  See Figure ' num2str(figureNo) '.']);
 

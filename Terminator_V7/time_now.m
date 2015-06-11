%time_now

%inputs current time and date in time and date fields
HHprogress = findobj(gcf,'tag','progress');

% HH = findobj(gcf,'tag','hour_adjust');
% addHours = str2num(get(HH,'string'));
% if(isempty(addHours)|~isnumeric(addHours)|addHours<-12|addHours>=11|~isreal(addHours)|addHours~=floor(addHours))
%     set(HHprogress,'string','ERROR: cpu time zone hour adjustment must be an integer between -12 and 11.')
%     break
% end

HH = findobj(gcf,'tag','time_zones');
zone_cell = get(HH,'string');
zone_index = get(HH,'Value');

addHours = -(mod(zone_index+24,24)-12);
if(addHours == 12)
    addHours = -12;
end
%addHours

T = datevec(datenum(clock)+addHours/24);


HH = findobj(gcf,'tag','year');
set(HH,'string',num2str(T(1)));

HH = findobj(gcf,'tag','month');
set(HH,'string',num2str(T(2)));

HH = findobj(gcf,'tag','day');
set(HH,'string',num2str(T(3)));

HH = findobj(gcf,'tag','hour');
set(HH,'string',num2str(T(4)));

HH = findobj(gcf,'tag','minute');
set(HH,'string',num2str(T(5)));

HH = findobj(gcf,'tag','second');
set(HH,'string',num2str(T(6)));

set(HHprogress,'string','Current UT posted');

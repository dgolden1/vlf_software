%zoomRange.m




HH = findobj(gcf,'tag','specify_coord');
specify_coord = get(HH,'Value');

HHllat = findobj(gcf,'tag','lower_lat');
lower_lat = str2num(get(HHllat,'string'));

HHulat = findobj(gcf,'tag','upper_lat');
upper_lat = str2num(get(HHulat,'string'));

HHllon = findobj(gcf,'tag','lower_lon');
lower_lon = str2num(get(HHllon,'string'));

HHulon = findobj(gcf,'tag','upper_lon');
upper_lon = str2num(get(HHulon,'string'));

HH = findobj(gcf,'tag','feedback_range');
feedback_range = get(HH,'Value');

HH = findobj(gcf,'tag','feedback_proj');
feedback_proj = get(HH,'Value');

HHprogress = findobj(gcf,'tag','progress');

HH = findobj(gcf,'tag','figureNo');
figureNo = str2num(get(HH,'string'));


try
    load(['fig_' num2str(figureNo) '_handle'],'h');
    [lat1,lon1] = inputm(1,h);
    [lat2,lon2] = inputm(1,h);
    lat = [lat1,lat2];
    lon = [lon1,lon2];
    minLat = min(lat);
    maxLat = max(lat);
    minLon = min(lon);
    maxLon = max(lon);
    
    set(HHllat,'string',num2str(minLat));
    set(HHulat,'string',num2str(maxLat));
    set(HHllon,'string',num2str(minLon));
    set(HHulon,'string',num2str(maxLon));
    
    plotm([minLat,maxLat,maxLat,minLat,minLat],[minLon,minLon,maxLon,maxLon,minLon],'-r')
    
catch
    set(HHprogress,'string',['Figure ' num2str(figureNo) ' not open'])
end



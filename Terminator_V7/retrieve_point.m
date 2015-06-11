%retrieve_point.m

HHlat_r = findobj(gcf,'tag','lat_r');


HHlon_r = findobj(gcf,'tag','lon_r');


HHprogress = findobj(gcf,'tag','progress');

HH = findobj(gcf,'tag','figureNo');
figureNo = str2num(get(HH,'string'));


try
    load(['fig_' num2str(figureNo) '_handle'],'h');
    [lat_r,lon_r] = inputm(1,h);

    
    set(HHlat_r,'string',num2str(lat_r));
    set(HHlon_r,'string',num2str(lon_r));

    
    plotm(lat_r,lon_r,'+r')
    
catch
    set(HHprogress,'string',['Figure ' num2str(figureNo) ' not open'])
end



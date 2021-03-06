%make_coord2

% coord = coordinates;
% 
% HH = findobj(gcf,'tag','Coordinate_list');
% coord_cell = get(HH,'string');
% coord_index = get(HH,'Value');
% coordinate = coord_cell{coord_index};
% 
% [lat,lon] = findCoordinate(coordinate,coord)

HH = findobj(gcf,'tag','lat_r');
lat_r = str2num(get(HH,'string'));
HH = findobj(gcf,'tag','lon_r');
lon_r = str2num(get(HH,'string'));

HH = findobj(gcf,'tag','spec_lat2');
set(HH,'string',num2str(lat_r));

HH = findobj(gcf,'tag','spec_lon2');
set(HH,'string',num2str(lon_r));

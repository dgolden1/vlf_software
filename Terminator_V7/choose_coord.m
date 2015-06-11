%choose_coord.m
coord = coordinates;

HH = findobj(gcf,'tag','Coordinate_list');
coord_cell = get(HH,'string');
coord_index = get(HH,'Value');
coordinate = coord_cell{coord_index};

[lat,lon] = findCoordinate(coordinate,coord);

HH = findobj(gcf,'tag','lat_r');
set(HH,'string',num2str(lat));

HH = findobj(gcf,'tag','lon_r');
set(HH,'string',num2str(lon));

function dist = distanceInKm(lat1,lon1,lat2,lon2)
%syntax: dist = distanceInKm(lat1,lon1,lat2,lon2)
%distance between [lat1,lon1] and [lat2,lon2] in kilometers

dist = distdim(distance(lat1,lon1,lat2,lon2,...
   almanac('earth','grs80','degrees'),'degrees'),'degree','km');


function [lat,lon] = findCoordinate(locationName,coord)

N = length(coord);
found = 0;
for (i = 1:N)
    if(strcmpi(locationName,coord{i}.name))
        lat = coord{i}.lat;
        lon = coord{i}.lon;
        found = found + 1;
    end
end

if(found~=1)
    lat = NaN;
    lon = NaN;
end



function name = findName(lat,lon,coord)

%matches to a coordinate if within 1/2000 of a degree in both longitude and latitude (56m accuracy)

N = length(coord);
found = 0;
for (i = 1:N)
    if(round(1000*lat)==round(1000*coord{i}.lat) ...
            &round(1000*lon)==round(1000*coord{i}.lon))
        name = coord{i}.name;
        found = found + 1;
    end
end

if(found~=1)
    name = '';
end



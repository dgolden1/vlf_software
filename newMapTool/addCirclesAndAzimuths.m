function addCirclesAndAzimuths(figureNo,lat,lon,distVec,distAzimuth,azimuthVec,azimuthDist,color)
%syntax: addCirclesAndAzimuths(figureNo,lat,lon,distVec,distAzimuth,azimuthVec,azimuthDist,color)
%
%Inputs
%------
%figureNo: figure number
%lat,lon: starting point [deg]
%distVec: vector of distances for small circles [km]
%distAzimuth: azimuth range [lo,hi] for small circles [deg]
%azimuthVec: vector of azimuths to draw great circle lines [deg]
%azimuthDist: range [min,max] for great circle lines [km]
%color: color string
%
%---- Ryan Said, 11/12/2006 ----

geoid = almanac('earth','ellipsoid','degrees');
figure(figureNo);
plotm(lat,lon,[color '+']);
line_width = 1;
%azimuths
for ii = 1:length(azimuthVec);
   [lat0,lon0] = reckon(lat,lon, km2deg(azimuthDist(1)), azimuthVec(ii), geoid,'degrees');
   [lat1,lon1] = reckon(lat,lon, km2deg(azimuthDist(2)), azimuthVec(ii), geoid,'degrees');
   [lats,lons] = track2(lat0,lon0,lat1,lon1,geoid,'degrees',100);
   plotm(lats,lons,'color',color,'linewidth',line_width);
end

%distance circles:
for ii = 1:length(distVec)
   [latc,lonc] = scircle1(lat,lon,km2deg(distVec(ii)),distAzimuth,geoid,'degrees',100); 
   plotm(latc,lonc,'color',color,'linewidth',line_width); 
end

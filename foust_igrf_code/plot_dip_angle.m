% Plot magnetic dip angle over the globe

% By Daniel Golden (dgolden1 at stanford dot edu) April 2008
% $Id$

%% Get dip angle
[longitude, latitude ] = meshgrid(-180:5:180,-90:5:90);
alt = zeros(size(latitude));
[ field_intensity,declination,inclination,horizontal,x_northward, y_eastward,z_vertical ] = geomag(2006, 1, 15, alt,latitude,longitude);


%% Map the world
figure;
h = worldmap('world');
setm(gca,'FFaceColor','w');
setm(h,'gcolor',[.2,.2,.2])
land = shaperead('landareas.shp', 'UseGeoCoords', true);
geoshow([land.Lat], [land.Lon], 'Color', [0.1 0.1 0.1]);
[pol_lat, pol_lon] = get_pol_lat_lon;
plotm(pol_lat, pol_lon, 'Color', [0.5 0.5 0.5]);

%% Plot dip angle
pcolorm(latitude, longitude, inclination);

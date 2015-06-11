function plot_mag_dir_map_world_surface
% Make a map with l-shell lines

% By Daniel Golden (dgolden1 at stanford dot edu) using Ryan Said's
% underlying code.
% September 2007

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'foust_igrf_code'));

%% Map the world
figure;
h = worldmap('world');
setm(gca,'FFaceColor','w');
setm(h,'gcolor',[.2,.2,.2])

%% Determine the horizontal magnetic field direction
year = 2001;
month = 1;
day = 1;
altitude = 0;

lat = linspace(-89, 89, 60);
lon = linspace(-180, 180, 100);

[Lat, Lon] = ndgrid(lat, lon);
Angle = nan(size(Lat));
Mag_h = nan(size(Lat));
Mag_v = nan(size(Lat));

for kk = 1:numel(Lat)
  % IGRF
  [field_intensity,declination,inclination,horizontal,x_northward,y_eastward,z_vertical] = geomag(year, month, day, altitude, Lat(kk), Lon(kk));
  
  Angle(kk) = declination; % Degrees East of North
  Mag_h(kk) = field_intensity*cos(inclination*pi/180); % nT
  Mag_v(kk) = field_intensity*sin(inclination*pi/180); % nT
end

%% Plot horizontal magnetic field magnitude
p = pcolorm(Lat, Lon, Mag_h/1e3);
% p = pcolorm(Lat, Lon, sqrt(Mag_h.^2 + Mag_v.^2)/1e3);
c = colorbar;
ylabel(c, 'B_Z (mT)');

% set(p, 'facealpha', 0.8);
% caxis([-1 1]*max(abs(Mag_h(:))));
% colormap(hotcold);

%% Plot continents and countries
land = shaperead('landareas.shp', 'UseGeoCoords', true);
geoshow([land.Lat], [land.Lon], 'Color', 0*[1 1 1]);
[pol_lat, pol_lon] = get_pol_lat_lon;
plotm(pol_lat, pol_lon, 'Color', 0.3*[1 1 1]);



%% Plot quiver plot
Idx = reshape(1:numel(Lat), size(Lat));
q_idx = Idx(1:6:end, 1:6:end);

U = Mag_h(q_idx).*cos(Angle(q_idx)*pi/180);
V = Mag_h(q_idx).*sin(Angle(q_idx)*pi/180);
% U = cos(Angle(q_idx)*pi/180);
% V = sin(Angle(q_idx)*pi/180);

quiverm(Lat(q_idx), Lon(q_idx), U, V, 'k');

1;

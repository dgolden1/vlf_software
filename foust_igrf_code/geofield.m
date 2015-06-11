function [dir_cartesian] = geofield(year, month, day, pos, direction);
  % Get the direction of the B field at a location pos in km (cartesian
  % coordinates).
 
  % convert from cartesian into latitude and longitude and altitude
  [altitude,longitude,latitude] = cart_to_altlonglat(pos);

  [field_intensity,declination,inclination,horizontal,x_northward,y_eastward,z_vertical] = geomag(year, month, day, altitude, latitude,longitude);
  
  % spherical coordinate version (r,theta,phi)
  dir_spherical = [-z_vertical, y_eastward, -x_northward];

  % Convert the direction into cartesian
  pos_spherical = cartesian_to_spherical(pos);
  r = pos_spherical(1);
  theta = pos_spherical(2);
  phi = pos_spherical(3);
  R = [cos(theta)*sin(phi), sin(theta)*sin(phi), cos(phi);
       -sin(theta), cos(theta), 0;
       cos(theta)*cos(phi), sin(theta)*cos(phi), -sin(phi)];
  dir_cartesian = R'*dir_spherical.';
  
  % Normalize
  dir_cartesian = dir_cartesian/norm(dir_cartesian);
  dir_cartesian = reshape(dir_cartesian,[3 1]);

  % Forward or back
  dir_cartesian = direction*dir_cartesian;

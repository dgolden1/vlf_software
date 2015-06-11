function [altitude,longitude,latitude] = cart_to_altlonglat(pos)

  pos_spherical = cartesian_to_spherical(pos);
  r = pos_spherical(1);
  theta = pos_spherical(2);
  phi = pos_spherical(3);
  
  altitude = r - 6371.2;
  longitude = theta/(2*pi/360);
  latitude = 90.0-phi/(2*pi/360);

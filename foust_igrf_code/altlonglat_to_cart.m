function [pos] = altlonglat_to_cart(altitude,longitude,latitude)

  r = altitude + 6371.2;
  theta = longitude*(2*pi/360);
  phi = (90.0-latitude)*(2*pi/360);

  pos = spherical_to_cartesian([r,theta,phi]);

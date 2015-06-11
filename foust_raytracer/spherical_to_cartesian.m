function [x] = spherical_to_cartesian(p)
  % Convert the input position (rho,theta,phi) to (x,y,z)
  x = zeros(size(p));
  x(1) = p(1)*cos(p(2))*sin(p(3));
  x(2) = p(1)*sin(p(2))*sin(p(3));
  x(3) = p(1)*cos(p(3));
  

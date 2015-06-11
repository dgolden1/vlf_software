function [p] = cartesian_to_spherical(x)
% Convert the input position (x,y,z) to (rho,theta,phi)
  p = zeros(size(x));
  p(1) = sqrt(sum(x.^2));
  p(2) = atan2(x(2),x(1));
  if( p(1) ~= 0 )
    p(3) = acos((x(3))/(p(1)));
  else
    % Arbitrary
    p(3) = 0;
  end;
  

function [x] = spherical_to_cartesian_vec(p, theta, phi)
  % Convert the input vector (p(1)*rhohat,p(2)*thetahat,p(3)*phihat) to 
  % (x(1)*xhat,x(2)*yhat,x(3)*zhat at the position (theta,phi)
   
  % convert cartesian unit vectors to spherical unit vectors.
  % The transpose will convert the spherical unit vectors to 
  % cartesian unit vectors.
  A = [cos(theta)*sin(phi), sin(theta)*sin(phi), cos(phi);...
       -sin(theta), cos(theta), 0;...
       cos(theta)*cos(phi), sin(theta)*cos(phi), -sin(phi)];
  
  x = A'*p;

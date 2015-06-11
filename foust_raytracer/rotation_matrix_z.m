function [R] = rotation_matrix_z(w)
  % Build a rotation matrix from the given input vector, assuming
  % rotational symmetry like in a plasma.
  % Typically in this case the input to this function would be B, the 
  % actual direction of the magnetic field
  
  w = w/norm(w);
  u=[w(3);w(3);-w(1)-w(2)]/sqrt(2*w(3)^2+(w(1)+w(2))^2);
  v=cross(w,u);
  R=[u,v,w];

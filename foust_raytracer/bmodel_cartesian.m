function [B] = bmodel_cartesian( x )
% Find the B field in cartesian coordinates
  physconst;
  % Note that the script bmodel uses elevation=theta, while we use the phi
  % convention.
  p = cartesian_to_spherical(x);
  [Brad,Bphi,Bmag] = bmodel( p(1)/R_E, p(3) );
  [B] = spherical_to_cartesian_vec([Brad;0;Bphi], p(2), p(3));

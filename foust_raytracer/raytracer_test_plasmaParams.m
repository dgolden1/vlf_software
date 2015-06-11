function [qs, Ns, ms, nus, B0] = raytracer_test_plasmaParams(x,cfg)
  physconst
  
  % TESTING BS LONGITUDINAL VARIATION
  %[p] = cartesian_to_spherical(x);
  %p(1) = p(1) + 4*R_E*sin(p(2)/2-.1*2*pi).^2 - .6*R_E;
  %[ce,ch,che,co] = dens_cartesian(spherical_to_cartesian(p),cfg);
  
  [ce,ch,che,co] = dens_cartesian(x,cfg);

  qs = 1.602e-19*[-1 1 1 1]';
  ms = [9.10938188e-31 1.6726e-27 4*1.6726e-27 16*1.6726e-27]';
  % Convert to m^-3;
  Ns = 1e6*[ce ch che co]';
  nus = [0 0 0 0]';
  B0 = bmodel_cartesian(x);

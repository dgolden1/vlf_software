function [ce,ch,che,co] = dens_cartesian(x,cfg)
  % Find ce,ch,che,co at the given cartesian position.  See dens.m for
  % explanations of the arguments below.

  % Convert x to L and lam
  physconst;
  % r,theta,phi <- x,y,z
  % theta is azimuth
  % phi is angle from the z axis
  [p] = cartesian_to_spherical(x);
  % L = r/(RE*sin^2(phi));
  if( R_E*sin(p(3))^2 ~= 0 )
    L = p(1)/(R_E*sin(p(3))^2);
  else
    L = 0;
  end;
  % NOTE lam is in degrees!
  lam = 90-(p(3)*360/2/pi);

  [ce,ch,che,co] = dens( ...
    L,lam*ones(size(L)), cfg.DSRRNG,cfg.DSRLAT,cfg.DSDENS,...
    cfg.THERM,cfg.RBASE,cfg.RZERO,cfg.SCBOT,...
    [1 cfg.ALPHA2 cfg.ALPHA3 cfg.ALPHA4],...
    cfg.KDUCTS,cfg.LK,cfg.EXPK,cfg.DDK,cfg.RCONSN,...
    cfg.SCR,cfg.L0,cfg.DEF,cfg.DD,cfg.RDUCLN,cfg.HDUCLN,cfg.RDUCUN,...
    cfg.HDUCUN,cfg.RDUCLS,cfg.HDUCLS,cfg.RDUCUS,cfg.HDUCUS,cfg.SIDEDU );


  

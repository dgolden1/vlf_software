function [h,ce,ch,che,co] = plot_neprofile( L, lam, cfg )
% [h,ce] = plot_neprofile( L, lam, cfg )

% now call dens() and plot the result
[ce,ch,che,co] = dens( ...
    L, lam, cfg.DSRRNG,cfg.DSRLAT,cfg.DSDENS,...
    cfg.THERM,cfg.RBASE,cfg.RZERO,cfg.SCBOT,...
    [1 cfg.ALPHA2 cfg.ALPHA3 cfg.ALPHA4],...
    cfg.KDUCTS,cfg.LK,cfg.EXPK,cfg.DDK,cfg.RCONSN,...
    cfg.SCR,cfg.L0,cfg.DEF,cfg.DD,cfg.RDUCLN,cfg.HDUCLN,cfg.RDUCUN,...
    cfg.HDUCUN,cfg.RDUCLS,cfg.HDUCLS,cfg.RDUCUS,cfg.HDUCUS,cfg.SIDEDU );

h = semilogy( L, ce );
if abs( cfg.DSRLAT - lam ) < .1,
  hold on; semilogy( cfg.DSRRNG, cfg.DSDENS, 'o' ); hold off;
end;
grid;

set( gca, 'ylim', [.1 1e6] );
axis('square');
xlabel('Earth Radii');
ylabel('Ne (el/cc)');
title( sprintf( 'Ne Density Profile @ mlat=%.1f', lam ));


physconst
cfg = read_newray_infile('data/newray.in');

L = linspace(1,8,100).';
lam = 0*ones(size(L));

plot_neprofile( L, lam, cfg );

% Compare with cartesian
figure
ceout = zeros(size(L));
for( ii=1:length(L) )
  x = [L(ii)*R_E;0;0];
  [ce,ch,che,co] = dens_cartesian(x,cfg);
  ceout(ii) = ce;
end;

h = semilogy( L, ceout );
if abs( cfg.DSRLAT - lam ) < .1,
  hold on; semilogy( cfg.DSRRNG, cfg.DSDENS, 'o' ); hold off;
end;
grid;
set( gca, 'ylim', [.1 1e6] );
axis('square');
xlabel('Earth Radii');
ylabel('Ne (el/cc)');
title( sprintf( 'Ne Density Profile @ mlat=%.1f', lam ));

figure
% 1e-3 is to avoid a singularity in denssub near the poles.  argh.
xplot=linspace(1e-3*R_E,8*R_E+1e-3*R_E,100);
zplot=linspace(-4*R_E,4*R_E,100);
[x,z] = ndgrid(xplot,zplot);
plotout = zeros(size(x));
for( ii=1:size(x,1) )
  for( jj=1:size(x,1) )
    [ce,ch,che,co] = dens_cartesian([x(ii,jj);0;z(ii,jj)],cfg);
    plotout(ii,jj) = ce;
  end;
end;
plotout(sqrt(x.^2+z.^2)<R_E) = 0;
imagesc(xplot,zplot,log10(plotout.'));
colorbar
axis equal
axis xy;
axis tight
ax=axis;
hold on
for( L=2:6 )
  plot_lshell(L,'w');
  hold on
end;

% Plot a half-circle in the x-z plane
phi = linspace(0,pi,100);
plot(R_E*sin(phi),R_E*cos(phi),'r');
axis(ax)

title('log10 of electron density in cc^{-1}');
xlabel('meters');
ylabel('meters');

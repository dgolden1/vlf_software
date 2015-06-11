physconst
% Draw out the field lines.  This is completely general and will work for
% any magnetic field model of the earth -- just replace the function
% bmodel_cartesian with your own that returns (Bx,By,Bz) given (x,y,z)

% Starting point, x=2*R_E, y=0, z=0

clf
for( L=2:6 )
  plot_lshell(L);
  hold on
end;

% Plot a half-circle in the x-z plane
phi = linspace(0,pi,100);
plot(R_E*sin(phi),R_E*cos(phi),'r');
axis equal


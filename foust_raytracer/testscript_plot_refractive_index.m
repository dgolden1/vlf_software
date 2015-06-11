% Test script to make sure everything is working right under rotations of B0


% Operating frequency
w = 2*pi*4e3;


root=2; % whistler in the magnetosphere
[phi,theta] = ndgrid(linspace(0,pi,1000), 0);

% Placeholder
pos = [6*R_E;0;0];

cfg = read_newray_infile('data/newray.in');
funcPlasmaParams = @(x) raytracer_test_plasmaParams(x,cfg);

clf
plot_refractive_index_surface(phi,theta,root,w,pos,...
                              funcPlasmaParams);
view(0,360);
axis tight
axis equal

xlabel('x')
ylabel('y')
zlabel('z')

physconst

ax=R_E*[0,7,-5,5,-5,5];
figure(7)
phi = linspace(0,pi,100);
subplot(2,2,1)
for( L=2:7 )
  plot_lshell3(L,'g--');
  hold on
end;
% Plot a half-circle in the x-z plane
plot3(R_E*sin(phi),0*phi,R_E*cos(phi),'r');
hold on
axis(ax);
xlabel('x'); ylabel('y'); zlabel('z'); 
view(90,270)
axis equal

subplot(2,2,2)
for( L=2:7 )
  plot_lshell3(L,'g--');
  hold on
end;
phi = linspace(0,pi,100);
physconst
plot3(R_E*sin(phi),0*phi,R_E*cos(phi),'r');
axis equal
hold on
axis(ax);
xlabel('x'); ylabel('y'); zlabel('z'); 
view(3)

subplot(2,2,3)
for( L=2:7 )
  plot_lshell3(L,'g--');
  hold on
end;
% Plot a half-circle in the x-z plane
phi = linspace(0,pi,100);
physconst
plot3(R_E*sin(phi),0*phi,R_E*cos(phi),'r');
axis equal
hold on
axis(ax);
xlabel('x'); ylabel('y'); zlabel('z'); 
view(90,0)
axis equal

subplot(2,2,4)
for( L=2:7 )
  plot_lshell3(L,'g--');
  hold on
end;
% Plot a half-circle in the x-z plane
phi = linspace(0,pi,100);
physconst
plot3(R_E*sin(phi),0*phi,R_E*cos(phi),'r');
axis equal
hold on
axis(ax);
xlabel('x'); ylabel('y'); zlabel('z'); 
view(0,180)
axis equal

physconst

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Set up the raytracer %%%%%%%%%%%%%%%%%%%%%%%%%%
cfg = read_newray_infile('data/newray.in');

% funcPlamsaParams should return the plasma parameters given a position x
% 
% function [qs, Ns, ms, nus, B0] = funcPlasmaParams(x)
% 
% where qs, Ns, ms, and nus are the charge, number density (m^-3), mass
% (kg), and collision frequency as column vectors, one per species.  B0 
% is the vector background magnetic field.
%
funcPlasmaParams = @(x) raytracer_test_plasmaParams(x,cfg);

% funcStopConditions should return an error code ~= 0 when some stopping
% criterion is met.  It will take as input position pos, wavenormal k,
% frequency w, relative (scaled by c) phase velocity vprel, relative (scaled
% by c) group velocity vgrel, and the current timestep dt.
%
% function [stop]=raytracer_stopconditions(pos, k, w, vprel, vgrel, dt)
%
funcStopConditions = @raytracer_stopconditions;

% Initial position
l=-48/360*2*pi;
pos0=(8200e3)*[cos(l);0;sin(l)];

% Frequency
w=2*pi*400;

% Initial direction
% Take direction along B
dir0 = bmodel_cartesian(pos0);
dir0 = dir0/norm(dir0);

% initial dt
dt0 = .05;

% Maximum dt allowed
dtmax = 1;

% Error control factor
maxerr = .001;

% Root choice (2=whistler at most normal frequencies)
root = 2;

% Maximum time
tmax = 10;

% Fixed step (1) or not (0)
fixedstep = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Run the raytracer %%%%%%%%%%%%%%%%%%%%%%%%%%%%
[pos,time,vprel,vgrel,n,stop] = raytracer(pos0, dir0, w, dt0, ...
                                          dtmax, maxerr, root, tmax, ...
                                          fixedstep, ...
                                          funcPlasmaParams, ...
                                          funcStopConditions);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for( ploti=1:4 )
  subplot(2,2,ploti)
  plot3(pos(1,:),pos(2,:),pos(3,:),'r')
end;

drawnow
 
% $$$ %%%%%%%%%%%%%%%%%%%%%%%%%% Output PNGs for a movie %%%%%%%%%%%%%%%%%%%%%%%%%
% $$$ figure(4)
% $$$ clf
% $$$ subplot(1,2,2);
% $$$ cla
% $$$ for( L=2:6 )
% $$$   plot_lshell3(L);
% $$$   hold on
% $$$ end;
% $$$ 
% $$$ % Plot a half-circle in the x-z plane
% $$$ phi = linspace(0,pi,100);
% $$$ physconst
% $$$ plot3(R_E*sin(phi),0*phi,R_E*cos(phi),'r');
% $$$ axis equal
% $$$ hold on
% $$$ view(0,360);
% $$$ 
% $$$ [phi,theta] = ndgrid( linspace(0,2*pi,100),0);
% $$$ 
% $$$ for( ii=1:length(time) )
% $$$   subplot(1,2,1)
% $$$   cla
% $$$   plot_refractive_index_surface(phi,theta,root,w0,pos(:,ii),funcPlasmaParams);
% $$$   view(0,360);
% $$$   hold on
% $$$   plot3(n(1,ii),n(2,ii),n(3,ii),'ok')
% $$$   quiver3(n(1,ii),n(2,ii),n(3,ii),vgrel(1,ii),vgrel(2,ii),vgrel(3,ii),300);
% $$$   axis equal
% $$$   axis(150*[-1 1 -1 1 -1 1])
% $$$   
% $$$   subplot(1,2,2);
% $$$   plot3(pos(1,ii),pos(2,ii),pos(3,ii),'rx')
% $$$   quiver3(pos(1,ii),pos(2,ii),pos(3,ii),...
% $$$           n(1,ii)/norm(n(:,ii)),n(2,ii)/norm(n(:,ii)),n(3,ii)/norm(n(:,ii)),...
% $$$           1e6, 'k');
% $$$   view(0,360);
% $$$   axis([0,4e7,-1.5e7,1.5e7,-1.5e7,1.5e7]);
% $$$ 
% $$$   hold on
% $$$   drawnow
% $$$ 
% $$$   %print('-dpng', '-r100', sprintf('testmovie%05d.png',ii-1));
% $$$   pause
% $$$ end;
% $$$ 
% $$$ 

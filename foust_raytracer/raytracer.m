function [pos,time,vprel,vgrel,n,stop] = raytracer(pos0, dir0, w0, dt0, ...
                                                  dtmax, maxerr, root, tmax, ...
                                                  fixedstep, ...
                                                  funcPlasmaParams, ...
                                                  funcStopConditions)
stop = 0;
pos = [];
time = [];
vprel = [];
vgrel = [];
n = [];

physconst

% Find k at the given direction
[k1mag,k2mag]=solve_dispersion_relation(dir0, w0, pos0, ...
                                        funcPlasmaParams);
if( root == 1 )
  k0mag = k1mag;
else
  k0mag = k2mag;
end;
k0 = k0mag*dir0;

% Our state vector -- position, k, and w respectively
x0 = [pos0; k0; w0];

f = @(t,x) raytracer_evalrhs( t, x, root, funcPlasmaParams );


dt = dt0;
x = x0;
t=0;
lastrefinedown = 0;
% Initialize vp and vg to something sensible for our stop condition check
cur_vprel = [1 0 0];
cur_vgrel = [1 0 0];

d = 1e-8;
dfdk = dispersion_relation_dFdk(x(4:6), w0, x(1:3), funcPlasmaParams, d);
dfdw = dispersion_relation_dFdw(x(4:6), w0, x(1:3), funcPlasmaParams, d);

pos = [x(1:3)];
time = [t];
n = [(x(4:6)*c/w0)];
vprel = [ n(:,end)/(norm(n(:,end))^2)];
vgrel = [-(dfdk./dfdw)/c];

while( t < tmax )
  % Check stop conditions
  stop = funcStopConditions( x(1:3), x(4:6), x(7), ...
                             vprel(:,end), vgrel(:,end), dt );
  if( stop ~= 0 )
    return;
  end;

  if( fixedstep == 0 )
    % Adaptive timesteps
    est1 = rk4(f,t,x,dt);
    est2 = rk4(f,t,x,dt/2);
    est2 = rk4(f,t+dt/2,est2,dt/2);
    dtincr = dt;
    
    % Only consider k in our relative error bound
    err = norm((est1(4:6)-est2(4:6))./norm(est2(4:6)));
    
    if( err > maxerr )
      % retry
      disp('Refine down');
      dt=dt/2;
      % Prevent refinement loops
      lastrefinedown = 1;
      continue;
    end;
    if( lastrefinedown==0 && ...
        err < maxerr/10 && dt*2 < dtmax )
      disp('Refine up');
      % Refine up
      dt=dt*2;
      lastrefinedown = 0;
      %continue;
    end;
  else
    % Fixed timesteps
    est2 = rk4(f,t,x,dt);
    dtincr = dt;
  end;

  cur_pos = est2(1:3);
  k = est2(4:6);
  w = est2(7);
  % Refine both estimates based on the physics (must satisfy dispersion
  % relation)
  [k1,k2]=solve_dispersion_relation(k, w, cur_pos, funcPlasmaParams);
  if( root == 1 ) 
    % Preserve direction
    k = k1*(k/norm(k));
  else
    % Preserve direction
    k = k2*(k/norm(k));
  end;

  % refine timestep if outside resonance cone
  if( norm(imag(k)) > 0 ) 
    if( fixedstep == 0 )
      % Force a refinement if we've popped outside the resonance cone.
      disp('Refine down: outside of resonance cone');
      dt=dt/4;
      lastrefinedown = 1;
      continue;
    else
      disp('Cannot continue with fixed timestep.  Outside resonance cone.');
      disp('Try reducing timestep or using adaptive timestepping.');
      return;
    end;
  end;
  
  % Update
  x = est2;
  x(4:6) = k;
  lastrefinedown = 0;
  t = t+dtincr;
  
  % Group velocity
  d = 1e-8;
  dfdk = dispersion_relation_dFdk(x(4:6), w, x(1:3), funcPlasmaParams, d);
  dfdw = dispersion_relation_dFdw(x(4:6), w, x(1:3), funcPlasmaParams, d);
  
  pos = [pos, x(1:3)];
  time = [time, t];
  n = [n, (x(4:6)*c/w)];
  vprel = [vprel,  n(:,end)/(norm(n(:,end))^2)];
  vgrel = [vgrel, -(dfdk./dfdw)/c];

  fprintf('t=%3.3g, x=(%3.3g,%3.3g,%3.3g), n=(%3.3g,%3.3g,%3.3g), vpr=(%3.3g,%3.3g,%3.3g), vgr=(%3.3g,%3.3g,%3.3g)\n', time(end), pos(1,end), pos(2,end), pos(3,end), n(1,end), n(2,end), n(3,end), vprel(1,end), vprel(2,end), vprel(3,end), vgrel(1,end), vgrel(2,end), vgrel(3,end));


end;



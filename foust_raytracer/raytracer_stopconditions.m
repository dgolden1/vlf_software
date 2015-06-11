function [stop]=raytracer_stopconditions(pos, k, w, vprel, vgrel, dt)
%
% function [stop]=raytracer_stopconditions(pos, k, w, vprel, vgrel, dt)
%
% funcStopConditions should return an error code ~= 0 when some stopping
% criterion is met.  It will take as input position pos, wavenormal k,
% frequency w, relative (scaled by c) phase velocity vprel, relative (scaled
% by c) group velocity vgrel, and the current timestep dt.
%

  physconst
  stop = 0;
  if( norm(pos) < R_E )
    % Hit the earth
    stop = 1;
    disp('Stopping integration.  Hit the earth.');
  elseif( norm(k) == 0 )
    % Nonsensical k
    stop = 2;
    disp('Stopping integration.  k=0.');
  elseif( norm(vgrel) > 1 )
    % Faster than light group velocity
    stop = 3;
    disp('Stopping integration.  Nonsensical group velocity.');
  elseif( norm(vprel) > 1 )
    % Faster than light phase velocity
    stop = 4;
    disp('Stopping integration.  Nonsensical phase velocity.');
  elseif( dt < 1e-10 )
    % dt too small
    disp('Stopping integration.  dt too small.');
    stop = 5;
  end;

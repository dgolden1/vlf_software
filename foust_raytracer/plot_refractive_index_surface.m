function plot_refractive_index_surface(phi,theta,root,w,pos,funcPlasmaParams)
% Plot the refractive index surface at the given phi,theta points in 
% spherical coordinates.
%
% funcPlamsaParams should return the plasma parameters given a position x
% 
% function [qs, Ns, ms, nus, B0] = funcPlasmaParams(x)
% 
% where qs, Ns, ms, and nus are the charge, number density (m^-3), mass
% (kg), and collision frequency as column vectors, one per species.  B0 
% is the vector background magnetic field.
physconst


ks = zeros(size(phi));
dFdns = zeros([size(phi),3]);
dFdws = zeros(size(phi));
kcarts = zeros([size(phi),3]);

% relative step size for the gradient calculation
d=1e-10;

for( ii=1:size(theta,1) )
  for( jj=1:size(theta,2) )
    % Find the direction vector
    direction = spherical_to_cartesian([1; theta(ii,jj); phi(ii,jj)]);
    % Find k at the given direction
    [k1,k2]=solve_dispersion_relation(direction, w, pos, funcPlasmaParams);
    if( root == 1 )
      ks(ii,jj) = k1;
    else
      ks(ii,jj) = k2;
    end;
    
    % Save cartesian coordinates in a vector for plotting
    kcart = spherical_to_cartesian([ks(ii,jj); theta(ii,jj); phi(ii,jj)]);
    kcarts(ii,jj,:) = kcart;

    % Find the gradients dF/dn and dF/dw
    dFdk = dispersion_relation_dFdk( kcart, w, pos, funcPlasmaParams, d );
    dFdw = dispersion_relation_dFdw( kcart, w, pos, funcPlasmaParams, d );
    
    % Save in a vector for plotting
    dFdks(ii,jj,:) = dFdk;
    dFdws(ii,jj) = dFdw;
  end;
end;

% Compute the group velocities
vg = zeros(size(dFdks));
for( ind=1:3 )
  vg(:,:,ind) = -real(dFdks(:,:,ind))./dFdws;
end;

x = (kcarts(:,:,1))*c/w;
y = (kcarts(:,:,2))*c/w;
z = (kcarts(:,:,3))*c/w;
x = x(:); y = y(:); z = z(:);

vgx = real(vg(:,:,1));
vgy = real(vg(:,:,2));
vgz = real(vg(:,:,3));
vgx = vgx(:); vgy = vgy(:); vgz = vgz(:);

maxvg =max(sqrt(vgx.^2+vgy.^2+vgz.^2)) 

plot3(real(x),real(y),real(z),'.');

hold on

hold on
axis equal
quiver3(x,y,z,vgx,vgy,vgz,1);

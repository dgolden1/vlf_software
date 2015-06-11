function [nz,Fext,a,b,c,d,e]=solve_booker_3d(perm,nx1,ny1,isotropic,nxy_are_arrays,zero_collisions)
%SOLVE_BOOKER_3D Solve the Booker equation for a 3D case
% Solve the Booker equation for a plasma or any other
% anisotropic medium. The Booker equation is
%   det(perm-(n.'*n)*eye(3)+n*n.')==0 in MATLAB notation, or
%   det(perm-(n^2)*Iperp)==0 in usual notation,
% where n=[nx;ny;nz] is the refraction coefficient vector. The equation is
% solved for nz, while nx and ny are known.
% Usage:
%   [nz,Fext]=solve_booker(perm,nx,ny,isotropic);
% Inputs:
%   perm     - 3 x 3 dielectric permittivity tensor;
%   nx,ny    - horizontal refraction coefficients nx=kx/k0, ny=ky/k0;
%              k0=w/c;
%   isotropic - a flag which shows if the medium is isotropic (perm is a
%              multiple of unit matrix).
% nx and ny can be 1D arrays of lengths Nx and Ny.
% Outputs:
%   nz   - 4 x Nx x Ny array of vertical refraction coefficients = kz/k0,
%          for 2 modes and 2 directions, sorted by decreasing imaginary
%          part, so that the first two values correspond to upgoing modes
%          (u1,u2) and the second two to downgoing modes (d1,d2), for each
%          value of nx and ny;
%   Fext - 6 x 4 x Nx x Ny matrix converting the mode variables
%          (u1,u2,d1,d2) into field (Ex,Ey,Ez,Z0*Hx,Z0*Hy,Z0*Hz) for each
%          value of nx and ny.
% NOTE: Z0=sqrt(mu0/eps0) is the impedance of free space.
% See also: FWM_RADIATION
% Newer versions: FWM_BOOKER
% Author: Nikolai G. Lehtinen

% nx, ny can be 1D arrays
if nargin<6
    zero_collisions=0;
end
if nargin<5
    nxy_are_arrays=0;
end
Nx=length(nx1);
Ny=length(ny1);
if nxy_are_arrays
    if Nx~=Ny
        error('Nx~=Ny');
    end
    nx=nx1(:); ny=ny1(:);
    N=Nx;
else
    N=Nx*Ny;
    [nxm,nym]=ndgrid(nx1,ny1);
    nx=nxm(:); ny=nym(:); % all possible combinations, column arrays
end
np2=nx.^2+ny.^2;

% lame temporary fix (nz=0 is not handled well ...)
ii=find(np2==1);
if ~isempty(ii)
    disp('SOLVE_BOOKER_3D: WARNING: Lame fix applied ...');
    nx(ii)=nx(ii)+1e-5;
    np2(ii)=nx(ii).^2+ny(ii).^2;
end

if ~isotropic
    % The coefficients of the quartic equation
    % a*nz^4+b*nz^3+c*nz^2+d*nz+e=0
    
    a = perm(3,3)*ones(size(nx));
    
    b = nx.*(perm(3,1)+perm(1,3)) + ny.*(perm(3,2)+perm(2,3));
    
    c = perm(2,3)*perm(3,2) + perm(1,3)*perm(3,1) ...
        - perm(3,3)*(perm(1,1)+perm(2,2)) ...
        + nx.^2*(perm(1,1)+perm(3,3)) ...
        + ny.^2*(perm(2,2)+perm(3,3)) ...
        + nx.*ny*(perm(1,2)+perm(2,1));
    
    d = nx.*(...
        perm(1,2)*perm(2,3) + perm(3,2)*perm(2,1) ...
        + (np2-perm(2,2))*(perm(1,3)+perm(3,1))...
        ) + ny.*(...
        perm(2,1)*perm(1,3)+perm(3,1)*perm(1,2) ...
        + (np2-perm(1,1))*(perm(2,3)+perm(3,2)) );
    
    e = (np2-perm(3,3)).* ...
        (perm(1,2)*perm(2,1)-perm(1,1)*perm(2,2)+...
          nx.*ny.*(perm(1,2)+perm(2,1))+nx.^2.*perm(1,1)+ny.^2.*perm(2,2)) ...
        + perm(1,2)*perm(2,3)*perm(3,1) ...
        + perm(1,3)*perm(3,2)*perm(2,1) ...
        + (nx.^2-perm(2,2)).*perm(1,3)*perm(3,1) ...
        + (ny.^2-perm(1,1)).*perm(2,3)*perm(3,2) ...
        + nx.*ny.*(perm(2,3)*perm(3,1)+perm(1,3)*perm(3,2));
    
    nz=solve_quartic(a,b,c,d,e);
    % Sort in descending order according to imaginary part
    [dummy,ii]=sort(imag(nz),2,'descend');
    for k=1:N
        nz(k,:)=nz(k,ii(k,:));
    end
    % Make sure that in the case of zero collisions nz(2) is still up, and
    % nz(3) is still down:
    if zero_collisions
        ii=find(real(nz(:,2))<0);
        tmp=nz(ii,2); nz(ii,2)=nz(ii,3); nz(ii,3)=tmp;
    end
else
    % isotropic medium
    nz0=sqrt(perm(1,1)-np2);
    % Make sure imag(nz0)>=0
    % This is only a problem for complex nx.
    ii=find(imag(nz0)<0);
    nz0(ii)=-nz0(ii);
    nz=[nz0,nz0,-nz0,-nz0];
end

% Find the normal modes:
% Solve
%  (perm-(nx^2+nz_k^2)*eye(3)+n*n.')*E_k=0
% where n=[nx; 0 ; nz_k].
% Then
%  Fext(1:3,k) = E_k;
%  Fext(4:6,k) = H_k = n x E_k
% This is a bottleneck.

% Convert nz to size 4 x N
nz=nz.';

Fext=zeros(6,4,N);
nvec=zeros(3,4,N);
nvec(1,:,:)=repmat(permute(nx,[2 3 1]),[1 4 1]);
nvec(2,:,:)=repmat(permute(ny,[2 3 1]),[1 4 1]);;
nvec(3,:,:)=permute(nz,[3 1 2]);
n2=permute(nvec(1,:,:).^2+nvec(2,:,:).^2+nvec(3,:,:).^2,[2 3 1]);

for knp=1:N
    % knp
    nx0=nx(knp); ny0=ny(knp);
    if ~isotropic
        %for ir=1:4
        %    Fext(:,ir,knx)=get_mode_field(perm,nx0,nz(ir,knx),method);
        %end
        % Same roots -- case still not handled!
        %[nm1,nm2]=ndgrid(nz(:,knx),nz(:,knx));
        for imode=1:4
            [v,dd]=eig(perm-n2(imode,knp)*eye(3) ...
                +nvec(:,imode,knp)*nvec(:,imode,knp).');
            [tmp,ii]=min(abs(diag(dd)));
            Fext(1:3,imode,knp)=v(:,ii);
        end
    else
        nz0=nz(1,knp); % >0 (at least for real np0), == sqrt(perm(1,1)-np0^2);
        n0=sqrt(perm(1,1));
        np0=sqrt(np2(knp)); % >0
        if np0>0
            cp=nx0/np0; sp=ny0/np0;
        else
            cp=1; sp=0;
        end
        ct=nz0/n0; st=np0/n0; % cos(th), sin(th), 0<th<pi, st>0
        % Isotropic medium:
        % Upgoing waves:
        % TE
        % Fext(:,1,knx)= ...
        %   [-sp ; cp ; 0 ; -nz0*cp ; -nz0*sp ; np0];
        % TM
        % Fext(:,2,knx)= ...
        %   [cp*ct ; sp*ct ; -st ; -n0*sp ; n0*cp ; 0];
        % Downgoing waves
        % Fext(:,3,knx)= ...
        %   [-sp ; cp ; 0 ; nz0*cp ; nz0*sp ; np0];
        % Fext(:,4,knx)= ...
        %   [cp*ct ; sp*ct ; st ; n0*sp ; -n0*cp ; 0];
        Fext(1:3,:,knp)=[-sp cp*ct -sp cp*ct ; cp sp*ct cp sp*ct ; 0 -st 0 st];
    end
end
Fext(4:6,:,:)=cross(nvec,Fext(1:3,:,:));

% Now we have to reshape nz and Fext to (6 x ) 4 x Nx x Ny shape
if ~nxy_are_arrays
    nz=reshape(nz,[4 Nx Ny]);
    Fext=reshape(Fext,[6 4 Nx Ny]);
end

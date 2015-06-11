function [nz,Fext,a,b,c,d,e]=solve_booker(perm,nx,isvacuum)
%SOLVE_BOOKER Solve the Booker equation
% Solve the Booker equation for a plasma or any other
% anisotropic medium. The Booker equation is
%   det(perm-(n.'*n)*eye(3)+n*n.')==0 in MATLAB notation, or
%   det(perm-(n^2)*Iperp)==0 in usual notation,
% where n=[nx;0;nz] is the refraction coefficient vector. The equation is
% solved for nz, while nx is known.
% Usage:
%   [nz,Fext]=solve_booker(perm,nx,isvacuum);
% Inputs:
%   perm     - 3 x 3 dielectric permittivity tensor;
%   nx       - horizontal refraction coefficient = kx/k0, k0=w/c;
%   isvacuum - a flag which shows if the medium is isotropic (perm is a
%              multiple of unit matrix).
% nx can be a 1D array of length N.
% Outputs:
%   nz   - 4 x N array of vertical refraction coefficient = kz/k0, for 2
%          modes and 2 directions, sorted by decreasing imaginary part, so
%          that the first two values correspond to upgoing modes (a1,a2)
%          and the second two to downgoing modes (b1,b2), for each value of
%          nx;
%   Fext - 6 x 4 x N matrix converting the mode variables (a1,a2,b1,b2)
%          into field (Ex,Ey,Ez,Z0*Hx,Z0*Hy,Z0*Hz) for each value of nx.
% NOTE: Z0=sqrt(mu0/eps0) is the impedance of free space.
% See also: REFLECTPLASMA, SOLVE_BOOKER_3D
% Author: Nikolai G. Lehtinen

% nx can be an array
nx=nx(:);
N=length(nx);

% lame temporary fix (nz=0 is not handled well ...)
nx(find(nx==-1))=-1.00001;
nx(find(nx==1))=1.00001;

% Check for isotropic medium
isotropic=isvacuum;
%isotropic=max(max(abs(perm/perm(1,1)-eye(3))))<eps('single')
%isotropic=all(all(perm==eye(3)*perm(1,1)))

if ~isotropic
    % The coefficients of the quartic equation
    % a*nz^4+b*nz^3+c*nz^2+d*nz+e=0
    a = perm(3,3)*ones(size(nx));
    b = nx.*(perm(3,1)+perm(1,3));
    c = perm(2,3)*perm(3,2) + perm(1,3)*perm(3,1) ...
        + nx.^2*(perm(1,1)+perm(3,3)) ...
        - perm(3,3)*(perm(1,1)+perm(2,2));
    d = nx.*(...
        perm(1,2)*perm(2,3) + perm(3,2)*perm(2,1) ...
        - (perm(2,2)-nx.^2)*(perm(1,3)+perm(3,1))...
        );
    e = (perm(3,3)-nx.^2).*(perm(1,1)*(perm(2,2)-nx.^2)-perm(1,2)*perm(2,1)) ...
        + perm(1,2)*perm(2,3)*perm(3,1) ...
        + perm(1,3)*perm(3,2)*perm(2,1) ...
        - perm(1,1)*perm(2,3)*perm(3,2) ...
        - (perm(2,2)-nx.^2)*perm(1,3)*perm(3,1);
    
    nz=solve_quartic(a,b,c,d,e);
    % Sort in descending order according to imaginary part
    [dummy,ii]=sort(imag(nz),2,'descend');
    for k=1:N
        nz(k,:)=nz(k,ii(k,:));
    end
else
    % isotropic medium
    nz0=sqrt(perm(1,1)-nx.^2);
    % Make sure imag(nz0)>=0
    % This is only a problem for complex nx.
    ii=find(imag(nz0)<0);
    nz0(ii)=-nz0(ii);
    nz=[nz0,nz0,-nz0,-nz0];
end
 

%nz2=solve_quadratic(a,c,e);
%size(nz)
%size(repmat(a,1,4))
%size(repmat(b,1,4))
%size(repmat(c,1,4))
%size(repmat(d,1,4))
%size(repmat(e,1,4))

%disp('solve_booker 2: abs(rhs)=');
%disp(abs(repmat(a,1,4).*nz.^4+repmat(b,1,4).*nz.^3 ...
%    +repmat(c,1,4).*nz.^2+repmat(d,1,4).*nz+repmat(e,1,4)));

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
nvec(2,:,:)=0;
nvec(3,:,:)=permute(nz,[3 1 2]);
n2=permute(nvec(1,:,:).^2+nvec(3,:,:).^2,[2 3 1]);

for knx=1:N
    % knx
    nx0=nx(knx);
    if ~isotropic
        %for ir=1:4
        %    Fext(:,ir,knx)=get_mode_field(perm,nx0,nz(ir,knx),method);
        %end
        % Same roots -- case still not handled!
        %[nm1,nm2]=ndgrid(nz(:,knx),nz(:,knx));
        for ir=1:4
            [v,dd]=eig(perm-n2(ir,knx)*eye(3)+nvec(:,ir,knx)*nvec(:,ir,knx).');
            [tmp,ii]=min(abs(diag(dd)));
            Fext(1:3,ir,knx)=v(:,ii);
        end
    else
        nz0=nz(1,knx); % >0, at least for real nx
        n0=sqrt(perm(1,1));
        % Isotropic medium:
        % TE
        %Fext(:,1,knx)=[0 ; 1 ; 0 ; -nz0 ; 0 ; nx0];
        % TM
        %Fext(:,2,knx)=[nz0/n0 ; 0 ; -nx0/n0 ; 0 ; n0 ; 0];
        % Downgoing waves
        %Fext(:,3,knx)=[0 ; 1 ; 0 ; nz0 ; 0 ; nx0];
        %Fext(:,4,knx)=[nz0/n0 ; 0 ; nx0/n0 ; 0 ; -n0 ; 0];
        Fext(1:3,:,knx)=[0 nz0/n0 0 nz0/n0 ; 1 0 1 0 ; 0 -nx0/n0 0 nx0/n0];
    end
end
Fext(4:6,:,:)=cross(nvec,Fext(1:3,:,:));

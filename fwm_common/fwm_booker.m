function [nz,Fext,a,b,c,d,e]=fwm_booker(perm,nx,ny)
%FWM_BOOKER Solve the Booker equation for a 3D case
% Solve the Booker equation for a plasma or any other
% anisotropic medium. The Booker equation is
%   det(perm-(n.'*n)*eye(3)+n*n.')==0 in MATLAB notation, or
%   det(perm-(n^2)*Iperp)==0 in usual notation,
% where n=[nx;ny;nz] is the refraction coefficient vector. The equation is
% solved for nz, while nx and ny are known.
% Usage:
%   [nz,Fext]=fwm_booker(perm,nx,ny);
% Inputs:
%   perm     - 3 x 3 dielectric permittivity tensor;
%   nx,ny    - horizontal refraction coefficients nx=kx/k0, ny=ky/k0;
%              k0=w/c;
% nx and ny are 1D arrays of length N.
% Outputs:
%   nz   - 4 x N array of vertical refraction coefficients = kz/k0,
%          for 2 modes and 2 directions, sorted by decreasing imaginary
%          part, so that the first two values correspond to upgoing modes
%          (u1,u2) and the second two to downgoing modes (d1,d2), for each
%          value of nx and ny;
%   Fext - 6 x 4 x N matrix converting the mode variables
%          (u1,u2,d1,d2) into field (Ex,Ey,Ez,Z0*Hx,Z0*Hy,Z0*Hz) for each
%          value of nx and ny.
% NOTE: Z0=sqrt(mu0/eps0) is the impedance of free space.
% See also: FWM_RGROUND, FWM_DEH, FWM_RADIATION, FWM_INTERMEDIATE
% Previous versions: SOLVE_BOOKER_3D (worked the same way, needed some
%   unnecessary arguments)
% Author: Nikolai G. Lehtinen

% nx, ny must be 1D arrays
nx=nx(:);
if length(ny)==1
    ny=ny*ones(size(nx));
end
ny=ny(:);
N=length(nx);
np2=nx.^2+ny.^2;

% lame temporary fix (nz=0 is not handled well ...)
ii=find(np2==1);
if ~isempty(ii)
    disp('FWM_BOOKER: WARNING: Lame fix applied ...');
    nx(ii)=nx(ii)+1e-5;
    np2(ii)=nx(ii).^2+ny(ii).^2;
end

epsilon=perm(1,1);
% Determine the special input: epsilon==Inf
if any(isnan(perm(:))) | any(isinf(perm(:)))
    % Infinite conductivity => perfect reflection
    nz=zeros(4,N); Fext=zeros(6,4,N);
    nz(1:2,:)=Inf; nz(3:4,:)=-Inf;
    np=sqrt(np2);
    inz=find(np~=0);
    cp=ones(size(np)); sp=zeros(size(np));
    cp(inz)=nx(inz)./np(inz); sp(inz)=ny(inz)./np(inz);
    Fext(4,1,:)=-cp; Fext(4,2,:)=-sp; Fext(4,3,:)=cp; Fext(4,4,:)=sp; 
    Fext(5,1,:)=-sp; Fext(5,2,:)=cp; Fext(5,3,:)=sp; Fext(5,4,:)=-cp;
    return;
end

isotropic=(max(max(abs(perm-eye(3)*epsilon)))<=10*eps);
% Determine if there is any absorption
permi=(perm-perm')/(2*i);
% - must be zero if no absorption, pos. determinate otherwise
no_absorption=(max(abs(permi(:)))/max(abs(perm(:)))<10*eps);

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
    
    nz=solve_quartic(a,b,c,d,e).';
    if no_absorption
        if 1
            % nz must be either real or imaginary
            criterion=(abs(imag(nz))<abs(real(nz)));
            is_real=find(criterion);
            is_imag=find(~criterion);
            % Get rid of erroneous real/imag part
            nz(is_real)=real(nz(is_real));
            nz(is_imag)=i*imag(nz(is_imag));
        end
        % Sort in descending order according to real part
        [dummy,ii]=sort(real(nz),1,'descend');
        nz=nz(ii+repmat([0:N-1]*4,4,1));
    end
    % Sort in descending order according to imaginary part
    [dummy,ii]=sort(imag(nz),1,'descend');
    nz=nz(ii+repmat([0:N-1]*4,4,1));
    %nzdebug=ii;
    %nzdebug=1+(ii-1)*N+repmat([0:N].'*3,1,3);
else
    % isotropic medium
    nz0=sqrt(epsilon-np2);
    % Make sure imag(nz0)>=0
    % This is only a problem for complex nx.
    ii=find(imag(nz0)<0);
    nz0(ii)=-nz0(ii);
    nz=[nz0,nz0,-nz0,-nz0].';
end
%nz=nz.'; % To 4 x N

% Find the normal modes:
% Solve
%  (perm-(nx^2+nz_k^2)*eye(3)+n*n.')*E_k=0
% where n=[nx; 0 ; nz_k].
% Then
%  Fext(1:3,k) = E_k;
%  Fext(4:6,k) = H_k = n x E_k
% This is a bottleneck.

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
        isdone=zeros(1,4);
        for imode=1:4
            if ~isdone(imode)
                isame=imode-1+find(nz(imode:4,knp)==nz(imode,knp));
                nsame=length(isame);
                [v,dd]=eig(perm-n2(imode,knp)*eye(3) ...
                    +nvec(:,imode,knp)*nvec(:,imode,knp).');
                if nsame==1
                    [dummy,ii]=min(abs(diag(dd)));
                    Fext(1:3,imode,knp)=v(:,ii);
                else
                    disp(['WARNING: ' num2str(nsame) ...
                        ' multiple roots at nx=' num2str(nx0) ', ny=' num2str(ny0)]);
                    [dummy,ii]=sort(abs(diag(dd)));
                    Fext(1:3,isame,knp)=v(:,ii(1:nsame));
                end
                isdone(isame)=1;
            end
        end
    else
        nz0=nz(1,knp); % >0 (at least for real np0), == sqrt(perm(1,1)-np0^2);
        n0=sqrt(epsilon);
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


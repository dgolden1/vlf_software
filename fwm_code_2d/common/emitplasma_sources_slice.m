function [DEHfxi,Jfxi]=emitplasma_sources_slice(ix,nx0,ny,Nx,Ny,z,J,...
    sxindex,syindex,szindex,k0dx,k0dy,method,perm)
%EMITPLASMA_SOURCES_SLICE Interpolate currents, and get Delta E,H
% Memory-saving version. Unfortunately, we do more computations than
% necessary.
% The horizontal coordinates are assumed to be
%  x=[1-Nx/2:Nx/2]*dx;
%  y=[1-Ny/2:Ny/2]*dy;

global impedance0
if isempty(impedance0)
    loadconstants
end
Ms=length(szindex);

M=length(z);
if nargin<14
    perm=repmat(eye(3),[1 1 Ms]);
end

% For Fourier transforms: useful indeces for shifting.
% This is assuming that the coordinates are
%  x=[1-Nx/2:Nx/2]*dx;
%  y=[1-Ny/2:Ny/2]*dy;
% and refracrive indeces are
%  nx=2*pi*[1-Nx/2:Nx/2]*(1/(dx*k0*Nx));
%  ny=2*pi*[1-Ny/2:Ny/2]*(1/(dy*k0*Ny));
indx=[Nx/2:Nx 1:Nx/2-1];
indy=[Ny/2:Ny 1:Ny/2-1];

% Convert to Delta E, Delta H in our mesh
% The surface currents that flow just above boundary between layers
tmp=diff(z);
dz=0.5*([0 tmp]+[tmp 0]);
% For a vertical current:
if nargin<11
    method='raw';
end
% The derivative is approximated as a difference
switch method
    case 'raw'
        % Use unmodified nx, ny -- good if waves with nperp>1 are
        % heavily attenuated, e.g. when calculating the emissions by a
        % ground-based antenna high in the ionosphere.
        % Works well for Ez, Hz close to the source, not so well for Ep, Hp
        [nyma,dzm]=ndgrid(ny,dz(szindex));
        nx0a=nx0;
    case 'advanced'
        % x'(n)=(x(n+1)-x(n))/dt
        % Works well only for Ep close to the source, not so well for
        % any other components
        [nyma,dzm]=ndgrid((exp(i*ny*k0dy)-1)/(i*k0dy),dz(szindex));
        nx0a=(exp(i*nx0*k0dx)-1)/(i*k0dx);
    case 'central'
        % x'(n)=(x(n+1)-x(n-1))/(2*dt)
        % Works best for E close to source (all components), not so
        % well for H (all components)
        % BEST METHOD SO FAR
        [nyma,dzm]=ndgrid(sin(ny*k0dy)/k0dy,dz(szindex));
        nx0a=sin(nx0*k0dx)/k0dx;
    case 'retarded'
        % x'(n)=(x(n)-x(n-1))/dt
        % Same as "advanced" in terms of stability.
        [nyma,dzm]=ndgrid((1-exp(-i*ny*k0dy))/(i*k0dy),dz(szindex));
        nx0a=(1-exp(-i*nx0*k0dx))/(i*k0dx);
    otherwise
        error('unknown method');
end

%Jfxi=zeros(Ny,Ms,3);
Jfs=zeros(length(sxindex),Ny,Ms,3);
Jfs(:,syindex,:,:)=J;
Jfs(:,indy,:,:)=fft(Jfs(:,indy,:,:),[],2); % Temporary
fftarr=exp(-2*pi*j*(ix-Nx/2)*(sxindex-Nx/2)/Nx);
fftarr=fftarr(:);
Jfxi=permute(sum(repmat(fftarr,[1 Ny Ms 3]).*Jfs,1),[2 3 4 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sources (Delta E, Delta H) in Fourier space
DEHfxi=zeros(4,Ny,Ms);
ezz=repmat(permute(perm(3,3,:),[1 3 2]),[Ny 1]);
exz=repmat(permute(perm(1,3,:),[1 3 2]),[Ny 1]);
eyz=repmat(permute(perm(2,3,:),[1 3 2]),[Ny 1]);
% The new boundary conditions for vertical sources immersed in medium
DEHfxi(1,:,:)=impedance0*dzm.*nx0a.*Jfxi(:,:,3)./ezz;
DEHfxi(2,:,:)=impedance0*dzm.*nyma.*Jfxi(:,:,3)./ezz;
DEHfxi(3,:,:)=impedance0*dzm.*(Jfxi(:,:,2)-Jfxi(:,:,3).*eyz./ezz);
DEHfxi(4,:,:)=-impedance0*dzm.*(Jfxi(:,:,1)-Jfxi(:,:,3).*exz./ezz);

function [DEHf,sindex,J,Jf]=emitplasma_sources(Jx0,Jy0,Jz0,x0,y0,z0,x,y,z,nx,ny)
%EMITPLASMA_SOURCES Interpolate currents, and get Delta E,H
% The coordinates are assumed to be
%  x=[1-Nx/2:Nx/2]*dx;
%  y=[1-Ny/2:Ny/2]*dy;

global impedance0
if isempty(impedance0)
    loadconstants
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sources (Delta E, Delta H) in configuration space

Nx=length(x);
Ny=length(y);
M=length(z);

% Find the interpolation domain (non-zero currents)
ix1=min(find(x>=x0(1)));
ix2=max(find(x<=x0(end)));
iy1=min(find(y>=y0(1)));
iy2=max(find(y<=y0(end)));
iz1=min(find(z>=z0(1)));
iz2=max(find(z<=z0(end)));

% Interpolation points
[xi,yi,zi]=ndgrid(x(ix1:ix2),y(iy1:iy2),z(iz1:iz2));
% Interpolated currents
J=zeros(Nx,Ny,iz2-iz1+1,3);
% Convert to Delta E, Delta H in our mesh
if ~isempty(Jx0)
    J(ix1:ix2,iy1:iy2,:,1)=interp3(x0,y0,z0,Jx0,xi,yi,zi);
end
if ~isempty(Jy0)
    J(ix1:ix2,iy1:iy2,:,2)=interp3(x0,y0,z0,Jy0,xi,yi,zi);
end
if ~isempty(Jz0)
    J(ix1:ix2,iy1:iy2,:,3)=interp3(x0,y0,z0,Jz0,xi,yi,zi);
end
% Find where the current is non-zero
sindex=[];
for nhs=iz1:iz2
    if ~all(all(all( permute(J(:,:,nhs-iz1+1,:),[1 2 4 3])==0 )))
        sindex=[sindex nhs];
    end
end
Ms=length(sindex);
% Compactify the current
J=J(:,:,sindex-iz1+1,:);

% For Fourier transforms: useful indeces for shifting.
% This is assuming that the coordinates are
%  x=[1-Nx/2:Nx/2]*dx;
%  y=[1-Ny/2:Ny/2]*dy;
% and refracrive indeces are
%  nx=2*pi*[1-Nx/2:Nx/2]*(1/(dx*k0*Nx));
%  ny=2*pi*[1-Ny/2:Ny/2]*(1/(dy*k0*Ny));
indx=[Nx/2:Nx 1:Nx/2-1];
indy=[Ny/2:Ny 1:Ny/2-1];

% Fourier components
Jf=zeros(Nx,Ny,Ms,3);
Jf(indx,:,:,:)=fft(J(indx,:,:,:),[],1); % Temporary
Jf(:,indy,:,:)=fft(Jf(:,indy,:,:),[],2);

% Convert to Delta E, Delta H in our mesh
% The surface currents that flow just above boundary between layers
tmp=diff(z);
dz=0.5*([0 tmp]+[tmp 0]);
[nxm,nym,dzm]=ndgrid(nx,ny,dz(sindex));
DEHf(1,:,:,:)=impedance0*dzm.*nxm.*Jf(:,:,:,3);
DEHf(2,:,:,:)=impedance0*dzm.*nym.*Jf(:,:,:,3);
DEHf(3,:,:,:)=impedance0*dzm.*Jf(:,:,:,2);
DEHf(4,:,:,:)=-impedance0*dzm.*Jf(:,:,:,1);


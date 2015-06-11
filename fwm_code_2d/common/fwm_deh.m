function DEH=fwm_deh(I,eiz,nx,ny)
%FWM_DEH Convert surface currents to boundary conditions for E,H
% Usage:
%    DEH=impedance0*fwm_deh(I,eiz,nx,ny);
% or
%    DEH=fwm_deh(impedance0*I,eiz,nx,ny);
% Inputs (Ms is the number of layers with currents, N is optional):
%    I (3 x Ms x N) - surface currents which are assumed to be just above
%       each boundary
%    eiz (3 x Ms) - z-column of the dielectric permittivity tensor, e.g.
%       eiz=permute(perm(:,3,layers),[1 3 2]);
%    nx, ny (N) - horizontal refractive index components
% Output:
%    DEH (4 x Ms x N) - Delta E, Delta H at the boundaries between layers
% NOTE: Instead of one extra dimension N we can have 2 extra dimensions
%    (N1, N2). In this case, we can use
%       eiz=repmat(permute(perm(:,3,layers),[1 3 2]),[1 1 N2]);
% Author: Nikolai G. Lehtinen
[is3,Ms,N]=size(I);
if is3~=3 | size(eiz,2)~=Ms | length(nx)~=N | length(ny)~=N
    error('incorrect size');
end
eizm=repmat(eiz,[1 1 N]);
nxm=repmat(permute(nx(:),[2 3 1]),[1 Ms 1]);
nym=repmat(permute(ny(:),[2 3 1]),[1 Ms 1]);
DEH=zeros(4,Ms,N);
% The new boundary conditions for vertical sources immersed in medium
% nxu is equal to nx or to sin(nx*k0*dx)/(k0*dx).
DEH(1,:,:)=nxm.*I(3,:,:)./eizm(3,:,:);
DEH(2,:,:)=nym.*I(3,:,:)./eizm(3,:,:);
DEH(3,:,:)=I(2,:,:)-I(3,:,:).*eizm(2,:,:)./eizm(3,:,:);
DEH(4,:,:)=-(I(1,:,:)-I(3,:,:).*eizm(1,:,:)./eizm(3,:,:));


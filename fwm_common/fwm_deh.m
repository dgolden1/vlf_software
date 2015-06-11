function DEH=fwm2_deh(I,eiz,nx,ny)
%FWM_DEH Convert surface currents to boundary conditions for E,H
% Usage:
%    DEH=fwm_deh(I,eiz,nx,ny);
% Inputs (Ms is the number of layers with currents, N is optional):
%    I (6 x Ms x N) - surface electric and magnetic currents (or current
%       moments) which are assumed to be just above each boundary, in
%       Budden's units (Je=Z0*Je_SI, Jm=Jm_SI), i.e. in V/m
%    eiz (3 x Ms) - z-column of the dielectric permittivity tensor, e.g.
%       eiz=permute(perm(:,3,layers),[1 3 2]);
%    nx, ny (N) - horizontal refractive index components
% Output:
%    DEH (4 x Ms x N) - Delta E, Delta H at the boundaries between layers
% Author: Nikolai G. Lehtinen
if isempty(I)
    error('no currents')
end
if length(ny)==1
    ny=ny*ones(size(nx));
end
[is6,Ms,N]=size(I);
if is6~=6 | size(eiz,2)~=Ms | length(nx)~=N | length(ny)~=N
    is6
    size(eiz)
    size(I)
    size(nx)
    size(ny)
    error('incorrect size');
end
eizm=repmat(eiz,[1 1 N]);
nxm=repmat(shiftdim(nx(:),-2),[1 Ms 1]);
nym=repmat(shiftdim(ny(:),-2),[1 Ms 1]);
DEH=zeros(4,Ms,N);
% The new boundary conditions for vertical sources immersed in medium
DEH(1,:,:)=nxm.*I(3,:,:)./eizm(3,:,:)-I(5,:,:);
DEH(2,:,:)=nym.*I(3,:,:)./eizm(3,:,:)+I(4,:,:);
DEH(3,:,:)=I(2,:,:)-I(3,:,:).*eizm(2,:,:)./eizm(3,:,:)+nxm.*I(6,:,:);
DEH(4,:,:)=-(I(1,:,:)-I(3,:,:).*eizm(1,:,:)./eizm(3,:,:))+nym.*I(6,:,:);

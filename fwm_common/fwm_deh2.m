function DEH=fwm_deh(Ie,Im,eiz,nx,ny)
%FWM_DEH Convert surface currents to boundary conditions for E,H
% Usage:
%    DEH=impedance0*fwm_deh(Ie,[],eiz,nx,ny);
% or
%    DEH=fwm_deh(impedance0*Ie,Im,eiz,nx,ny);
% Inputs (Ms is the number of layers with currents, N is optional):
%    Ie (3 x Ms x N) - surface electric currents which are assumed to be
%       just above each boundary
%    Im (empty matrix or 3 x Ms x N) - surface magnetic currents
%    eiz (3 x Ms) - z-column of the dielectric permittivity tensor, e.g.
%       eiz=permute(perm(:,3,layers),[1 3 2]);
%    nx, ny (N) - horizontal refractive index components
% Output:
%    DEH (4 x Ms x N) - Delta E, Delta H at the boundaries between layers
% Author: Nikolai G. Lehtinen
N=length(nx);
Ms=size(eiz,2);
if length(ny)==1
    ny=ny*ones(size(nx));
end
if length(ny)~=N
    size(nx)
    size(ny)
    error('incorrect size');
end
eizm=repmat(eiz,[1 1 N]);
nxm=repmat(permute(nx(:),[2 3 1]),[1 Ms 1]);
nym=repmat(permute(ny(:),[2 3 1]),[1 Ms 1]);
DEH=zeros(4,Ms,N);
% The new boundary conditions for vertical sources immersed in medium
% nxu is equal to nx or to sin(nx*k0*dx)/(k0*dx).
if ~isempty(Ie)
    [is3,Ms1,N1]=size(Ie);
    if is3~=3 | Ms1~=Ms | N1~=N
        is3
        size(eiz)
        size(Ie)
        size(nx)
        size(ny)
        error('incorrect size');
    end
    DEH(1,:,:)=nxm.*Ie(3,:,:)./eizm(3,:,:);
    DEH(2,:,:)=nym.*Ie(3,:,:)./eizm(3,:,:);
    DEH(3,:,:)=Ie(2,:,:)-Ie(3,:,:).*eizm(2,:,:)./eizm(3,:,:);
    DEH(4,:,:)=-(Ie(1,:,:)-Ie(3,:,:).*eizm(1,:,:)./eizm(3,:,:));
end
if ~isempty(Im)
    [is3,Ms1,N1]=size(Im);
    if is3~=3 | Ms1~=Ms | N1~=N
        is3
        size(Im)
        error('incorrect size');
    end
    DEH(1,:,:)=DEH(1,:,:)-Im(2,:,:);
    DEH(2,:,:)=DEH(2,:,:)+Im(1,:,:);
    DEH(3,:,:)=DEH(3,:,:)+nxm.*Im(3,:,:);
    DEH(3,:,:)=DEH(3,:,:)+nym.*Im(3,:,:);
end

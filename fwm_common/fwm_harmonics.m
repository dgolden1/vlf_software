function [Ih,np0,m]=fwm_harmonics(nx0,ny0,I,Nh,Nhshift)
%FWM_HARMONICS Convert the current to axial harmonics
% This is done for input into FWM_AXISYMMETRIC.
% Usage:
%    [np0,m,Ih]=fwm_harmonics(nx0,ny0,I);
% Arguments:
%    nx0 (Nnx0), ny0 (Nny0) - values of (nx,ny)
%    I (3 x Ms x Nnx0 x Nny0) - current
% Outputs:
%    np0 (Nnp0)
%    m (Nh)
%    Ih (3 x Ms x Nnp0 x Nh)
% See also: FWM_AXISYMMETRIC
% Author: Nikolai G. Lehtinen

% Convert to polar system of coordinates
if nargin<4
    Nh=2^5;
end
if nargin<5
    Nhshift=ceil(Nh/2);
end
th=[0:Nh-1]*2*pi/Nh;
nperpmax=max([nx0(:);ny0(:)]);
dnx0=min([diff(nx0(:));diff(ny0(:))]);
np0=[0:dnx0:nperpmax];
Nnp0=length(np0);
[npm,thm]=ndgrid(np0,th);
nxm=npm.*cos(thm);
nym=npm.*sin(thm);
Ms=size(I,2);
% Convert to I+, I-
tmp=I(1,:,:,:); % Ix
I(1,:,:,:)=tmp+i*I(2,:,:,:); % I+
I(2,:,:,:)=tmp-i*I(2,:,:,:); % I-
Ip=permute(I,[3 4 1 2]); % Nnx0 x Nny0 x 3 x Ms
%Inth=zeros(3,Ms,Nnp0,Nh);
Ih=zeros(3,Ms,Nnp0,Nh);
for ks=1:Ms
    for c=1:3
        %Inth(c,ks,:,:)=interp2(ny0,nx0,Ip(:,:,c,ks),nxm,nym);
        Ih(c,ks,:,:)=fft(interp2(ny0,nx0,Ip(:,:,c,ks),nxm,nym),[],2)/Nh;
    end
end
% Take into account that I+ == const corresponds to m==-1 etc.
Ih(1,:,:,:)=circshift(Ih(1,:,:,:),[0 0 0 -1]);
Ih(2,:,:,:)=circshift(Ih(2,:,:,:),[0 0 0 1]);
% Go back to Ix, Iy
tmp=Ih(1,:,:,:); % I+
Ih(1,:,:,:)=(tmp+Ih(2,:,:,:))/2; % Ix, or really, Ir
Ih(2,:,:,:)=(tmp-Ih(2,:,:,:))/(2*i); % Iy, or really, Iphi
% We could have also transformed (Ix,Iy)->(Ir,Iphi) and then do the Fourier
% transform in phi. Then there would be no need for dm == +-1 shifts.
% Do the shift to the center
shift=ceil(Nh/2);
Ih=circshift(Ih,[0 0 0 Nhshift]);
m=[0:Nh-1]-Nhshift;

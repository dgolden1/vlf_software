loadconstants
global clight impedance0

% Altitudes of boundaries between layers in km
h=[0 50:120].';
M=length(h);
Ne=getNe(h,'Stanford_eprof1'); % in m^{-3}
Ne(1)=0; % Important for separating TE and TM waves !!!
w=2*pi*2000
k0=w/clight
% The dielectric permittivity tensor "perm"
perm=get_perm(h,w,'Ne',Ne,'Bgeo',[0 1e-5 -5e-5]);
nz=zeros(4,M); Fext=zeros(6,4,M);
for k=1:M
    [nz(:,k),Fext(:,:,k)]=fwm_booker(perm(:,:,k),sin(pi/6),0);
end
F=Fext([1:2 4:5],:,:);

% Note: the boundary condition 'E=0' is not used for the calculation of
% Ru{l,h}
[Pu,Pd,Ux,Dx,Ruh,Rdl,Rul,Rdh] = fwm_radiation(h*1e3*k0,nz,F,'E=0');

% Reflection coefficient matrix at the ground
% components are [TE;TM]
R0=Rul(:,:,1)

% TE up (Eabs=1)
u=[1;0];
% TM:
%u=[0;1]

EHu=Fext(:,:,1)*[u;0;0]

% Reflected wave (if TE is original)
d=R0*u

EHd=Fext(:,:,1)*[0;0;d]

% Poynting vector
S=real(cross(conj(EHd(1:3)),EHd(4:6)))/2/impedance0

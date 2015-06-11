% The horizontal magnetic field - what is the emission?
% The timing (on NLPC):
% FWM is divided into
%   FWM_BESTGRID ~ 2 min
%   FWM_WAVES    ~ 13 min
%   FWM_ASSEMBLE ~ 3 min
global mu0 impedance0 eps0 clight
if isempty(mu0)
    loadconstants
end

% Assume horizontal current perpendicular to B
% The phase is the same.
f=1875; % Hz
w=2*pi*f;
k0=w/clight;
h=[0 55:120].'; % h in km
Bgeo=[0 3e-5 0]; % Geomagnetic field in T - along y
% The current density on the vertical z-axis
Jc=exp(-(h-79).^2/(2*3^2))*2.5e-9;
% Convert to the surface current for calculations
Ic=1e3*diff(h).*Jc(2:end);
%Ic=exp(-(h-79).^2/(2*3^2))*2.5e-6; % Will be in x-direction
% Limit the source in altitudes
ksa=find(Ic>max(Ic)*1e-6); % Index of layers with the source
Ms=length(ksa)
Ic=Ic(ksa);
Iwidth=2.3e4;
% - assume axially symmetric currents, with gaussian horizontal distribution

% Convert to (nx,ny) space
Icf=2*pi*Iwidth^2*Ic;
% Synthesize an approximate current
nwidth=1/(k0*Iwidth) % in n-space
% To size 3 x Ms x Nnx0 x Nny0
nperpmax=5;
nx0=[-nperpmax:.1:nperpmax];
ny0=nx0;
Nnx0=length(nx0); Nny0=length(ny0);
[nx0m,ny0m]=ndgrid(nx0,ny0);
prof=exp(-(nx0m.^2+ny0m.^2)/(2*nwidth^2));
I0=zeros(6,Ms,Nnx0,Nny0);
I0(1,:,:,:)=repmat(Icf(:),[1 Nnx0 Nny0]).*repmat(shiftdim(prof,-1),[Ms 1 1]);

Ne=getNe(h,'Stanford_eprof3');
perm=get_perm(h,w,'Ne',Ne,'Bgeo',Bgeo); % ..., 'nue',nue
eground='E=0'; % = 1 + i*sground/(w*eps0);
xkm=[-500:5:500]; % Horizontal output coordinates in km
ykm=xkm;
%rmaxkm=3000; % Optional
rmaxkm=[];
%hi=[0:5:70 72:2:120].'; % Output altitudes in km
hi=[0].';
Mi=length(hi);
drkm=[]; % Optional
retol=1e-4; % error tolerance, optional
coornperp=1; % cartesian
axisymmetric=0;
coorrperp=1; % cartesian
global output_interval backup_interval
output_interval=60 % To observe the progress every 60 sec
backup_interval=600 % Default = 3600 sec
bkp_file='fwmexample3'; % Backup file name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optional arguments can be skipped or replaced with []
nperp1=nx0; nperp2=ny0;
rperp1=xkm; rperp2=ykm;
[EH,EHf,nx,ny]=fwm_nonaxisymmetric(f,h,eground,perm,...
    ksa,coornperp,nx0,ny0,I0,...
    coorrperp,xkm,ykm,hi,...
    rmaxkm,drkm,retol,bkp_file);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Warning: do not forget to multiply EH (EHf) by impedance0
E=EH(1:3,:,:,:)*impedance0;
B=EH(4:6,:,:,:)*mu0;
Bp=squeeze(sqrt(sum(abs(B(1:2,:,:,:)).^2,1)));
% The Poynting vector
S=permute(real(cross(conj(E),B))/2/mu0,[2 3 4 1]);

figure;
subplot(1,2,1)
imagesc(xkm,ykm,real(squeeze(E(3,1,:,:)).')/1e-3);
set(gca,'ydir','normal'); axis equal tight; colorbar;
title('E_z at the ground, mV/m'); xlabel('x (E-W), km'); ylabel('y (S-N), km');
subplot(1,2,2)
imagesc(xkm,ykm,Bp.'/1e-12);
set(gca,'ydir','normal'); axis equal tight; colorbar;
title('B_\perp at the ground, pT'); xlabel('x (E-W), km');

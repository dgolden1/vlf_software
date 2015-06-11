% Example of the fwm_nonaxisymmetric usage
% See also: fwm_axisymmetric_antenna_example
% Timing on my laptop:
% FWM_BESTGRID ~ 9 min
% FWM_WAVES ~ 75 min
% FWM_ASSEMBLE ~ 110 min
% Total ~ 186 min (allowing ~ 2 min extra for other calculations)

global clight eps0 mu0 impedance0
if isempty(clight)
    loadconstants
end
h=[0 0.001 50:120].'; % altitudes in km
% We place the source at 1 m altitude, so that the field on the ground is
% calculated more accurately
f=5000; % frequency in Hz
w=2*pi*f; k0=w/clight;
%Bgeo=[0 0 -5e-5]; % The NONVERTICAL geomagnetic field
Bgeo=[0 1e-5 -4e-5]
Ne=getNe(h,'Stanford_eprof1'); % Electron density in 1/m^3
Ne(1:3)=0; % The ionosphere starts at 51 km, at 50 km it is still zero.
perm=get_perm(h,w,'Ne',Ne,'Bgeo',Bgeo);
sground=30e-3; % conductivity of the ground in S/m
%eground=1+i*sground/(eps0*w);
eground='E=0'

% Specify the current I in nperp=(nx,ny) space
% For a point source, the current is a constant in (nx,ny) space
np0=[]; % The points at which the current is given, =[] for point source
I0=[0;0;1;0;0;0]; % vertical current of moment = 1 A*m
ksa=[2]; % it is placed at h(ksa);
m=0; % the circular harmonic, Ir,Iphi,Iz(nx,ny)~exp(i*m*th)

% Output points
hi=[0;max(h)].'; % output altitudes in km
%rkm=[0:2000]; % output distances in km
xkm=[-500:5:500];
ykm=xkm;
if 0
	% Field for nx=0.5:
	hi1=[0:.1:max(h)].';
	zd=h*k0*1e3; zdi1=hi1*k0*1e3;
	[kia,dzl,dzh]=fwm_get_layers(zd,zdi1);
	EHf1=fwm_field(zd,eground,perm,ksa,.5,0,I0,kia,dzl,dzh);
	figure;
	plot(hi1,squeeze(real(EHf1)));
	xlabel('h, km'); title('Fields for n_x=0.5')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main program call:
global output_interval backup_interval
output_interval=60 % To observe the progress every 60 sec
backup_interval=600 % Default = 3600 sec
bkp_file='antennaground';
rperp1=xkm; rperp2=ykm;
coornperp=1; nperp1=[]; nperp2=[]; coorrperp=1;
retol=1e-4; drkm=[]; rmaxkm=[];
[EH,nx,ny,EHf]=fwm_nonaxisymmetric(f,h,eground,perm,...
    ksa,1,[],[],I0,...
    1,xkm,ykm,hi,...
    rmaxkm,drkm,retol,bkp_file);

%[EH,np,EHf0,ki2,npt,EHft0]=fwm_axisymmetric(f,h,eground,perm,ksa,np0,m,I0,rkm,hi);
% We could also call the wraper, fwm_axisymmetric_antenna.
% The result is in the same units as I0. To convert to V/m, multiply by
% Z0:
E=impedance0*EH(1:3,:,:,:);
% The magnetic field is in the same units as E. Convert to SI units:
B=mu0*EH(4:6,:,:,:);

% Plotting
Nyc=(length(xkm)+1)/2
for ki=1:2
    %ki=1; % on the ground
    %ki=2; % at 120 km
    figure;
    subplot(2,1,1);
    semilogy(xkm,squeeze(abs(E(:,ki,:,Nyc)))); legend('E_x','E_y','E_z')
    title(['E, V/m at ' num2str(hi(ki)) ' km']);
    xlabel('x, km')
    subplot(2,1,2);
    semilogy(xkm,squeeze(abs(B(:,ki,:,Nyc)))); legend('B_x','B_y','B_z')
    title(['B, T at ' num2str(hi(ki)) ' km']);
    xlabel('x, km')
end

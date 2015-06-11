function [xkm, ykm, hi, E, B] = whistler_penetration_3d(thB, f, x_lim, y_lim, gnd_type, ion_prof, b_double_tol, backup_filename)
% [xkm, ykm, hi, E, B] = whistler_penetration_3d(thB, f)
% 
% INPUTS
% thB: magnetic field angle in x-z plane from +z axis (radians)
% f: wave frequency (Hz)
% x_lim: limits on x (in km) - x(1) is km South (should be a negative number), x(2) is km North
% y_lim: limits on y (in km)
% gnd_type: one of 'conductor' or 'ice'
% ion_prof: nx2 matrix; ion_prof(:,1) is height (km), ion_prof(:,2) is
%  density (elec/m^3)
% 
% OUTPUTS
% xkm: x coordinates (km)
% ykm: y coordinates (km)
% hi: z coordinates (km)
% E: E-field (V/m) ([Ex Ey Ez], zdir, xdir, ydir)
% B: B-field (T) ([Bx By Bz], zdir, xdir, ydir)

% Developed by Nikolai Lehtinen (nleht at stanford dot edu),
% modified by Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'fwm_common'));

global clight impedance0 mu0 %#ok<NUSED>
if isempty(clight)
    loadconstants
end

if ~exist('thB', 'var') || isempty(thB)
	thB=pi/6; % The geomagnetic field is {Babs*sin(thB),0,Babs*cos(thB)}
end
if ~exist('f', 'var') || isempty(f)
	f = 1000; % Wave frequency (Hz)
end
if ~exist('x_lim', 'var') || isempty(x_lim)
	x_lim = [-500 500];
end
if ~exist('y_lim', 'var') || isempty(y_lim)
	y_lim = [-500 500];
end
if ~exist('gnd_type', 'var') || isempty(gnd_type)
	gnd_type = 'conductor';
end
if ~exist('b_double_tol', 'var') || isempty(b_double_tol)
	b_double_tol = false;
end
if ~exist('backup_filename', 'var') || isempty(backup_filename)
	backup_filename = 'whistlerpenetrfull';
end


%% Calculations
h=[0 55:104 130].'; % h in km
M=length(h);

% Get Ne
if exist('ion_prof', 'var') && ~isempty(ion_prof)
	if max(ion_prof(:,2)) < 1e6
		error('Electron density should be in Ne/m^3');
	end
	ion_prof((ion_prof(:,2) <= 0), 2) = 1;
    ion_prof = [0 1; ion_prof];
	Ne = 10.^interp1(ion_prof(:,1), log10(ion_prof(:,2)), h, 'linear', 'extrap');
else
	Ne=getNe(h,'Stanford_eprof3');
end
Ne(1)=0;
Ne(end) = Ne(end-1); % Prevent giant jumps in Ne

w=2*pi*f;
k0=w/clight;
Babs=5e-5;
perm=get_perm(h,w,'Ne',Ne,'Babs',Babs,'thB',thB);

%% Set up the initial wave packet
% This is the most difficult part - please set up your own packet
width=20e3;
nwidth=1/(k0*width);
perm0=get_perm(h(M),w,'Ne',Ne(M),'nu',0,'Babs',Babs,'thB',0);
n4=fwm_booker(perm0,0,0);
n0=n4(2);
nxc=-n0*sin(thB);
npmax=abs(nxc)+5*nwidth;
nx0=[-1:1e-2:1]*npmax;
Nnx0=length(nx0);
ny0=nx0;
Nny0=length(ny0);
[nxm,nym]=ndgrid(nx0,ny0);
wpshape=exp(-((nxm-nxc).^2+nym.^2)/(2*nwidth^2));

EHd1=[0;0;1;0]; % Start off with only Hx present
% Extract the whistler only
[nz,Fext]=fwm_booker(perm(:,:,M),nxm(:),nym(:));
EHfd0=zeros(4,Nnx0*Nny0);
I0=zeros(6,1,Nnx0*Nny0);
ksa=[M];
% Convert the field to surface electric and magnetic currents
EHd_to_I=[0 0 0 1;0 0 -1 0;0 -1 0 0;1 0 0 0];
for ip=1:Nnx0*Nny0
    F=Fext([1:2 4:5],:,ip);
	ud=F\EHd1;
	% We can just extract the downward modes - one of them evanesces
	% fast
	EHfd0(:,ip)=F*[0;0;ud(3);0]*wpshape(ip);
	% Convert to the currents (electric and magnetic)
	I0([1:2 4:5],1,ip)=EHd_to_I*EHfd0(:,ip);
end
EHfd0=reshape(EHfd0,[4 Nnx0 Nny0]);
I0=reshape(I0,[6 1 Nnx0 Nny0]);
% The initial field in real space
EHd0=zeros(4,Nnx0,Nny0);
indx=[(Nnx0+1)/2:Nnx0 1:(Nnx0-1)/2];
indy=indx;
EHd0(:,indx,:)=ifft(EHfd0(:,indx,:),[],2)*2*npmax*k0/(2*pi);
EHd0(:,:,indy)=ifft(EHd0(:,:,indy),[],3)*2*npmax*k0/(2*pi);
xkm0=[-(Nnx0-1)/2:(Nnx0-1)/2]*2*pi/(k0*2*npmax)/1e3;
ykm0=xkm0;
EHd0max=max(abs(EHd0(:)));
coef=1e-12*clight/EHd0max; % Start with 1 pT

%% Outputs
% Configuration space
num_space_pts = 100;
xkm = x_lim(1):abs(diff(x_lim))/num_space_pts:x_lim(2);
ykm = y_lim(1):abs(diff(y_lim))/num_space_pts:y_lim(2);

% xkm=[-500:10:500];
% ykm=xkm;

Nx=length(xkm);
Ny=length(ykm);
Nxc=find(xkm==0);
Nyc=find(ykm==0);
hi=[0:2:140].';
global output_interval backup_interval
output_interval=180; % To observe the progress every n sec
backup_interval=Inf; % Default = 3600 sec

%% Ground type
switch gnd_type
	case 'conductor'
		eground = 'E=0';
	case 'ice'
		eground = 3 + i*7;
	otherwise
		error('Weird ground type (''%s'')', gnd_type);
end

%% Run FWM
% if b_double_tol is true, tolerance will be 1e-8; 1e-4 otherwise
[EHraw,EHf,nx,ny,da,np,Nchi]=fwm_nonaxisymmetric(f,h,eground,perm,...
    ksa,1,nx0,ny0,I0,...
    1,xkm,ykm,hi,...
    [],[],1e-4*(1e-4)^(b_double_tol),backup_filename);

%% Normalize
EH=EHraw*coef;
E=EH(1:3,:,:,:);
B=EH(4:6,:,:,:)/clight;
Ba=squeeze(sqrt(sum(abs(B).^2)));

%% Plot
% figure;
% subplot(1,2,1)
% imagesc(xkm,ykm,real(squeeze(E(3,1,:,:)).')/1e-3);
% set(gca,'ydir','normal'); axis equal tight; colorbar;
% title('E_z at the ground, mV/m'); xlabel('x (E-W), km'); ylabel('y (S-N), km');
% subplot(1,2,2)
% imagesc(xkm,ykm,squeeze(Ba(1,:,:)).'/1e-12);
% set(gca,'ydir','normal'); axis equal tight; colorbar;
% title('B_\perp at the ground, pT'); xlabel('x (E-W), km');
% increase_font(gcf, 16);
% 
% figure
% imagesc(nx0,ny0,squeeze(real(EHfd0(3,:,:))).')
% set(gca,'ydir','normal'); axis equal tight; c = colorbar;
% set(get(c, 'ylabel'), 'string', 'fourier value');
% xlabel('n-space x'); ylabel('n-space y');
% title('Initial wave packet (n-space) Ez');
% increase_font(gcf, 16);
% 
% figure
% imagesc(xkm0,ykm0,squeeze(real(EHd0(3,:,:))).'*coef/clight/1e-12)
% set(gca,'ydir','normal'); axis equal tight; c = colorbar;
% set(get(c, 'ylabel'), 'string', 'pV/m');
% xlabel('x (km)'); ylabel('y (km)');
% title('Initial downgoing electric field')
% increase_font(gcf, 16);
% 
% figure
% imagesc(xkm,hi,Ba(:,:,Nyc)/1e-12)
% set(gca,'ydir','normal'); axis equal tight; c = colorbar;
% figure_squish(gcf, 1/1.5, 1.5);
% set(get(c, 'ylabel'), 'string', 'pT');
% xlabel('x (km)'); ylabel('z (km)');
% title('Slice at y=0');
% increase_font(gcf, 16);


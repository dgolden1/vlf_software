function varargout = fwm_whistler_penetration_2d(f, L, wn_angle, gnd_type, showplots, bEarthCurvatureCorrection)
% [S, x, hi, P_init] = fwm_whistler_penetration_2d(f, L, wn_angle, gnd_type, showplots, bEarthCurvatureCorrection)
% Field of a whistler penetrating into Earth-ionosphere waveguide, in 2D
% 
% wn_angle is in radians
% 
% gnd_type should be one of 'conductor' (default), 'seawater' or 'ice'
% 
% Optimized so that runs that keep f and L constant will be faster, and
% runs that also keep gnd_type constant will be WAY faster
% 
% If you're running this in nested loops, the loops should be f
% (outermost), L, gnd_type and wn_angle (innermost)

% Written by Nikolai Lehtinen
% Modified by Daniel Golden (dgolden1 at stanford dot edu) March 2008
% $Id$

%% Globals
global ech me clight eps0 REarth impedance0
if isempty(ech)
	addpath(genpath('./common'));
    loadconstants
end

%% Parameters
if ~exist('f', 'var') || isempty(f),                 f=1000; end % Wave center frequency
if ~exist('L', 'var') || isempty(L),                 L=2.44; end % L-shell (determines B angle)
if ~exist('wn_angle', 'var') || isempty(wn_angle),   wn_angle = 0; end % Wave-normal angle
if ~exist('gnd_type', 'var') || isempty(gnd_type),   gnd_type = 'ice'; end % Type of material for layer 0 (bottom)
if ~exist('showplots', 'var') || isempty(showplots), showplots = [1 1 1 1 1]; end % Select plots to show
if ~exist('bEarthCurvatureCorrection', 'var') || isempty(bEarthCurvatureCorrection), bEarthCurvatureCorrection = true; end % Correct for Earth's curvature

disp(sprintf('f = %0.1f kHz', f/1e3));
disp(sprintf('L = %0.2f', L));
disp(sprintf('Wave normal angle = %0.1f degrees', wn_angle*180/pi));
disp(sprintf('Ground type = %s', gnd_type));

hmax=120;
do_nighttime=1;

%% Set up the environment
w=2*pi*f;
k0=w/clight;
if do_nighttime
    h2=80;
else
    h2=41;
end
h=[0 h2:hmax].';
M=length(h);
zd=h*1e3*k0; % dimensionless h
if do_nighttime
    Ne=getNe(h,'Stanford_nighttime');
else
    Ne=getNe(h,'Stanford_daytime');
end
Ne(1)=0;

% The geomagnetic field
inv_lat = acos(sqrt(1/L));
thB = pi/2 - atan(2*tan(inv_lat));
% thB=pi/6;
disp(sprintf('theta_B = %0.1f degrees', thB*180/pi));
phB=0;
Babs=5e-5;

% Rotated geomagnetic field
Bgeo=get_Bgeo(0,'Babs',Babs,'thB',thB,'phB',phB);
% Permittivity components
[perm,isotropic]=get_perm(h,w,'Ne',Ne,'Bgeo',Bgeo);

% X-grid
Nx=2^12;
dx=3e3;
x=[1-Nx/2:Nx/2]*dx;
% The permutation of indeces so that if F(Nx) is a function of x, then
% F1=F(indx) has the first index corresponding to x==0, and should be used
% for FFT.
indx=[Nx/2:Nx 1:Nx/2-1];
% nx-grid (nx=kx/k0 is the horizontal refractive index), tailored for FFT
nx=2*pi*[1-Nx/2:Nx/2]*(1/(dx*k0*Nx));
% We can use permutation "indx" also with G(nx), since G1=G(indx) has G(1)
% corresponding to nx==0.

%% Set up the initial wave packet
% This is the most difficult part - please set up your own packet

Y=ech*Babs/me/w;
X=ech^2*Ne(M)/me/eps0/w^2;

% Superimposed wavenormals centered on the given wavenormal
wn_angle_spread = pi/12;
wn_angles = linspace(wn_angle - wn_angle_spread/2, wn_angle + wn_angle_spread/2, 50);
Hxi = zeros(size(x));
sigma_x=20e3; % Half the size of the initial packet, in meters

for kk = 1:length(wn_angles)
	nc=sqrt(appletonhartree(wn_angles(kk),X,Y,1));
	%nzc=-nc*cos(thB + wn_angles(kk));
	nxc=-nc*sin(thB + wn_angles(kk));
	Hxi = Hxi + exp(-x.^2/(2*sigma_x^2)).*exp(i*k0*nxc*x); % initial Hx field
end
Hxi = Hxi / length(wn_angles); % Divide by number of superimposed packets

Hxif=zeros(size(Hxi));
Hxif(indx)=fft(Hxi(indx));

%% Apply the full-wave method (FWM)

%% Calculate all modes

% This function is only dependent on f and L (not wn_angle and gnd_type),
% so make the output persistent between runs where f and L don't change
disp('1. Calculate the modes');
persistent nz Fext f_old L_old;
if isempty(f_old) || f ~= f_old || L ~= L_old
	nz=zeros(4,M,Nx); Fext=zeros(6,4,M,Nx);
	for k=1:M
		% nz - vertical refractive index
		% Fext - matrix converting (u,d) to (E,H)
		[nz(:,k,:),Fext(:,:,k,:)]=solve_booker_3d(perm(:,:,k),nx,0,isotropic(k)); % Depends on f, L
	end
end


%% Initial wave amplitudes at height h(M)
disp('2. Initial wave amplitudes');
FM=permute(Fext([1:2 4:5],:,M,:),[1 2 4 3]);
ampl=zeros(1,Nx);
for ip=1:Nx
    udi=FM(:,:,ip)\[0;0;Hxif(ip);0]; % (u,d)
    ampl(ip)=udi(3); % downward whistler mode
end

%% Propagate each partial wave in the packet

% This function is only dependent on f, L and gnd_type,
% so make the output persistent between runs where f, L and gnd_type don't change

disp('3. Apply FWM');
persistent ul0 dh0 gnd_type_old
if isempty(gnd_type_old) || f ~= f_old || L ~= L_old || ~strcmp(gnd_type, gnd_type_old)
	
		ul0=zeros(2,M,Nx); dh0=zeros(2,M-1,Nx);

		switch gnd_type % Depends on f, L, gnd_type
			case 'conductor'
				for ip=1:Nx
					F=Fext([1:2 4:5],:,:,ip);
					% Only the whistler downward mode as the oncoming wave
					dli=[1;0];
					[ul0(:,:,ip),dh0(:,:,ip)]=...
						fwm_radiation(zd,nz(:,:,ip),F,'E=0',[],[],[],dli);
				end
			case {'seawater', 'ice'}
				if strcmp(gnd_type, 'seawater')
					sground=5; % in S/m for water
					eground = 1 + i*sground/(w*eps0);
				elseif strcmp(gnd_type, 'ice')
					eground = 3 + i*7;
				end

				Rground=fwm_Rground(eground,nx,0);
				for ip=1:Nx
					F=Fext([1:2 4:5],:,:,ip);
					% Only the whistler downward mode as the oncoming wave
					dli=[1;0];
					[ul0(:,:,ip),dh0(:,:,ip)]=...
						fwm_radiation(zd,nz(:,:,ip),F,Rground(:,:,ip),[],[],[],dli);
				end
		end

	f_old = f;
	L_old = L;
	gnd_type_old = gnd_type;
end

% This part depends on everything
ul=zeros(2,M,Nx); dh=zeros(2,M-1,Nx);
for ip=1:Nx
    ul(:,:,ip)=ampl(ip)*ul0(:,:,ip);
    dh(:,:,ip)=ampl(ip)*dh0(:,:,ip);
end

%% Calculate the partial waves at the selected altitudes
hi=[0:hmax];
zdi=hi*1e3*k0; % dimensionless
Mi=length(hi);
% Find which layer these altitudes are in and what are the distances to
% nearest layer boundaries
layers=zeros(Mi,1);
dzl=zeros(Mi,1); dzh=dzl;
for ki=1:Mi
    % The altitudes
    zdi0=zdi(ki);
    k=max(find(zd<=zdi0)); % Which layer are we in?
    layers(ki)=k;
    dzl(ki)=zdi0-zd(k); % Distance to the boundary below
    if k<M
        dzh(ki)=zd(k+1)-zdi0; % Distance to the boundary above
    else
        dzh(ki)=nan;
    end
end
% Change the info for the last point, so that it is in M-1 layer
layers(Mi)=M-1;
dzl(Mi)=zd(M)-zd(M-1);
dzh(Mi)=0;

%% Calculate the wave amplitudes at the selected altitudes
disp('4. Wave amplitudes at intermediate points');
ud=fwm_intermediate(nz,ul,dh,layers,dzl,dzh);
% Convert to E, H (still in nx-space)
EHf=zeros(6,Mi,Nx);
for ki=1:Mi
    k=layers(ki);
    for ip=1:Nx
        EHf(:,ki,ip)=Fext(:,:,k,ip)*ud(:,ki,ip);
    end
end
% The initial wave (without reflected waves)
EHfi=zeros(6,Nx);
for ip=1:Nx
    EHfi(:,ip)=Fext(:,:,M-1,ip)*[0;0;ud(3,Mi,ip);0];
end

%% Reassemble the wave packet at the selected altitudes (nx -> x space)
disp('5. IFFT');
EH=zeros(6,Mi,Nx);
EH(:,:,indx)=ifft(EHf(:,:,indx),[],3);
EHi=zeros(6,Nx);
EHi(:,indx)=ifft(EHfi(:,indx),[],2);

%% Calculate power
Si=0.5*real(cross(conj(EHi(1:3,:)),EHi(4:6,:)))/impedance0;
Szi=Si(3,:);
P0_L0=-sum(Szi)*dx;
disp(['Initial power flux per unit y length=' num2str(P0_L0) ' W/m'])

S=0.5*real(cross(conj(EH(1:3,:,:)),EH(4:6,:,:)))/impedance0;

%% Apply Earth curvature attenuation correction factors
if bEarthCurvatureCorrection
	xRe = repmat(permute(x, [3 1 2]), [3 length(hi) 1])/(REarth*1e3);
	corr_factor = abs(1./(2*pi*(REarth*1e3)*sin(xRe)));
	S = S.*corr_factor;
end


%% Plot various measures of power
% Flux at -200 km
fignum = 1;
if showplots(fignum)
	% Avoid annoying figure focus stealing
	if ~ishandle(fignum)
		figure(fignum);
	else
		set(0, 'CurrentFigure', fignum);
		clf;
	end
	
	x0=-200e3;
	ix=find(x>x0, 1);
	plot(S(:,:,ix),hi, 'LineWidth', 2);
	grid on;
	titlestr = ['Power flux in x,y,z-direction at ' num2str(x0/1e3) ' km'];
	title(titlestr)
	xlabel('S_x, W/m^2')
	ylabel('h, km')
	legend('S_x','S_y','S_z')
	set(gcf, 'Name', titlestr);
end

% Power received on ground
fignum = 2;
if showplots(fignum)
	% Avoid annoying figure focus stealing
	if ~ishandle(fignum)
		figure(fignum);
	else
		set(0, 'CurrentFigure', fignum);
		clf;
	end

	plot(x/1e3, 10*log10(abs(squeeze(S(:,1,:)))), 'LineWidth', 2);
	grid on;
	xlim([-2000 2000]);
	xlabel('x, km');
	ylabel('Power (dBW/m^2)');
	titlestr = 'Power received on ground';
	title(titlestr);
	legend('S_x', 'S_y', 'S_z');
	set(gcf, 'Name', titlestr);
end

P = squeeze(sqrt(sum(S.^2)));

% 2-D Power
fignum = 3;
if showplots(fignum)
	% Avoid annoying figure focus stealing
	if ~ishandle(fignum)
		figure(fignum);
	else
		set(0, 'CurrentFigure', fignum);
		clf;
	end

	imagesc(x/1e3,hi,10*log10(P));
	set(gca,'ydir','normal','xlim',[-2000 2000],'ylim',[0 120]);
	xlabel('x, km'); ylabel('h, km')
	titlestr = 'Power (dBw/m^2)';
	title(titlestr);
	colorbar
	set(gcf, 'Name', titlestr);
end

% Plot resulting fields
fignum = 4;
if showplots(fignum)
	% Avoid annoying figure focus stealing
	if ~ishandle(fignum)
		figure(fignum);
	else
		set(0, 'CurrentFigure', fignum);
		clf;
	end

	EHp=permute(EH,[3 2 1]);
	imagesc(x/1e3,hi,log10(abs(EHp(:,:,4).'))); axis equal;
	set(gca,'ydir','normal','xlim',[-500 500],'ylim',[0 120]);
	xlabel('x, km'); ylabel('h, km')
	titlestr = 'log10(Z_0*H_x), V/m';
	title(titlestr);
	colorbar
	set(gcf, 'Name', titlestr);
end

% Quiver plot, which doesn't work
fignum = 5;
if showplots(fignum)
	% Avoid annoying figure focus stealing
	if ~ishandle(fignum)
		figure(fignum);
	else
		set(0, 'CurrentFigure', fignum);
		clf;
	end

	narrows = 10;
	xi = find(x/1e3 > -2000, 1, 'first'):find(x/1e3 < 2000, 1, 'last');
	xi = xi(1:floor(end/narrows):end);
	zi = find(hi > 0, 1, 'first'):find(hi < 120, 1, 'last');
	zi = zi(1:floor(end/narrows):end);
	Sx = squeeze(S(1,zi,xi));
	Sy = squeeze(S(2,zi,xi));
	Sz = squeeze(S(3,zi,xi));
	%quiver(x(xi)/1e3, hi(zi), sign(Sx).*(10*log10(abs(Sx))), sign(Sy).*(10*log10(abs(Sy))));
    Sxz=sqrt(Sx.^2+Sz.^2);
    Smin=min(Sxz(:));
    quiver(x(xi)/1e3, hi(zi), log10(Sxz/Smin).*Sx./Sxz, log10(Sxz/Smin).*Sz./Sxz);
	% set(gca,'xlim',[-2000 2000],'ylim',[0 120]);
	xlabel('x, km'); ylabel('h, km');
	titlestr = 'Power quiver plot';
	title(titlestr);
	set(gcf, 'Name', titlestr);
end

%% Assign output variables
if nargout >= 1, varargout{1} = S; end
if nargout >= 2, varargout{2} = x; end
if nargout >= 3, varargout{3} = hi; end
if nargout >= 4, varargout{4} = P0_L0; end

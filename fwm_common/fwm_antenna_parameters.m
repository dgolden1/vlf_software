% Parameters for FWM for a ground-based transmitter
global clight impedance0 me ech eps0
if isempty(clight)
    loadconstants
end

% Default Arguments
if ~given_args_fwm_antenna
    uniform_grid=0;
    NeProfile='nighttime';
    nuProfile='cold';
    ground_bc='E=0'; % is only used when sground==0
    sground=0;
    f=30000;
    Necoef=1;
    hdownshift=0;
    Mi=2;
    do_plots=1;
    retol=1e-6;
    Bgeo=[0 0 -5e-5];
    do_axisymmetric=1;
    dx=2e3;
    xmax=1000e3;
    dh=1;
end
output_interval=20;
backup_interval=3600;
hmax=120;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify datadir
if do_axisymmetric
    tmp='2D';
else
    tmp='3D';
end
datadir=['results/fwm_' tmp];
if Mi==1
    datadir=[datadir '_satellite/'];
else % Mi==2, no other values supported yet
    datadir=[datadir '_ground/'];
end
do_vacuum=strcmp(NeProfile,'vacuum')
if do_vacuum
    datadir=[datadir 'vacuum'];
else
    datadir=[datadir NeProfile];
    if Necoef~=1
        datadir=[datadir '_x' num2str(Necoef)];
    end
    if hdownshift~=0
        if hdownshift>0
            % Normal situation
            datadir=[datadir '_d' num2str(hdownshift) 'km'];
        else
            datadir=[datadir '_u' num2str(-hdownshift) 'km'];
        end
    end
    datadir=[datadir '_' nuProfile 'nu'];
    % Magnetic field
    if do_axisymmetric
        Babs=sqrt(sum(Bgeo.^2));
        Bgeo=[0 0 sign(Bgeo(3))*Babs]
    end
    BgeouT=round(Bgeo*1e6); % in microT
    if ~do_axisymmetric
        datadir=[datadir '_' sprintf('B_%d_%d_%d',BgeouT)];
    else
        datadir=[datadir '_' sprintf('Bz_%d',BgeouT(3))]; 
    end
    Bgeo=BgeouT/1e6;
end
if sground==0
    if ~ischar(ground_bc)
        error('need boundary condition')
    end
    if strcmp(ground_bc,'free')
        datadir=[datadir '_free'];
    end
else
    % The conductivity is given
    datadir=[datadir '_sg_' num2str(round(sground/1e-3))];
end
% Final step: the frequency
datadir=[datadir '/' num2str(f) '/']
mkdir(datadir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify parameters, and sources
w=f*2*pi;
k0=w/clight;
if do_axisymmetric
    x=[0:dx:xmax];
    Nx=length(x);
else
    % 2D grid
    x=[-xmax:dx:xmax];
    y=[-ymax:dy:ymax];
    Nx=length(x);
    Ny=length(y);
    need_2d=(need_2d & Nx>1 & Ny>1)
    % x=0 corresponds to index (Nx+1)/2
    Nx0=find(x==0);
    Ny0=find(y==0);
    if isempty(Nx0) | isempty(Ny0)
        error('Must have zero')
    end
end
% Maximum distance:
if do_axisymmetric
    rmax=max(abs(x));
    dr=dx;
else
    rmax=sqrt(max(x.^2)+max(y.^2));
    dr=max(dx,dy);
end
if k0*dr>pi
    disp('WARNING: the wave structure will not be resolved!');
    % However, it could be not necessary for certain applications.
end

% Altitude at which Ne starts
switch NeProfile
    case {'nightstep'}
        h2=80-hdownshift;
    case {'daystep','daytime'};
        h2=41-hdownshift;
    case {'dayhell','nighthell'}
        h2=60-hdownshift;
    case{'eprof1','eprof2','eprof3','nighttime'}
        h2=64-hdownshift;
    otherwise
        % A named profile
        htmp=[0:hmax].';
        h2=htmp(min(find(getNe(htmp,NeProfile)>0)))-hdownshift;
end
% Altitude grid
if length(NeProfile)>=4 & strcmp(NeProfile(end-3:end),'step') & ...
        strcmp(nuProfile,'zero')
    h=[0 h2 hmax].';
elseif strcmp(NeProfile,'vacuum')
    h=[0 hmax].';
else
    h=[0 h2:dh:hmax].';
end
M=length(h)
% Determine the latitude-dependent Ne coefficient, for Helliwell's profiles
if length(NeProfile)>=4 & strcmp(NeProfile(end-3:end),'hell')
    f0F2lat=[0:5:90];
    f0F2d=[13.2 14.5 14.6 14 13.2 12.5 12.1 12.2 12.5 13.4 13.9 14.1 14 ...
        13.5 12.4 10 7.6 6.7 6.5]/12.5;
    f0F2n=[8.5 10.2 11.5 11 9 7.2 6.5 5.9 5.6 5.4 5.3 5.2 5.1 5 5 5 5.1 ...
        5.3 5.6]/5.5;
    switch NeProfile
        case 'dayhell'
            f0F2=f0F2d;
            hhell=[60 100 200]; Nehell=[10 1e5 3e5]*1e6;
        case 'nighthell'
            f0F2=f0F2n;
            hhell=[60 110 200]; Nehell=[1 1e4 2e4]*1e6;
        otherwise
            error('unknown helliwell profile')
    end
    Necoefhell=interp1(f0F2lat,f0F2,geomag_latitude)^2
end
switch NeProfile
    case {'daytime','nighttime','eprof1','eprof2','eprof3'}
        Ne=getNe(h+hdownshift,['Stanford_' NeProfile]);
    case {'daystep','nightstep'}
        Ne=1e9*ones(size(h));
    case {'dayhell','nighthell'}
        Ne=Necoefhell*[0 ; exp(interp1(hhell-hdownshift,log(Nehell),h(2:M)))];
    case 'vacuum'
        Ne=zeros(size(h));
    otherwise
        disp(['Using Ne profile ' NeProfile ' starting at ' num2str(h2)]);
        Ne=getNe(h,NeProfile);
end
% Start with vacuum at h=0
Ne(1)=0;
Ne=Ne*Necoef;
switch nuProfile
    case 'zero'
        nu=zeros(size(h));
    case 'cold'
        nu=plot_collisionrate(h,'doplot',0);
    case 'hell'
        htmp=[60 110 120]; nutmp=[6e7 2e4 8e3];
        nu=[0 ; exp(interp1(htmp,log(nutmp),h(2:M)))];
    case 'warm'
        disp('WARNING: nu is not assigned')
        nu=[];
    otherwise
        error('unknown nu profile')
end
% Bgeo must be specified separately.
% We neglect B variation with altitude (but this is not necessary)
if strcmp(nuProfile,'warm')
    [perm,isotropic,Ne,nu,Sdiel,Pdiel,Ddiel]=...
        get_warm_perm(h,w,'Ne',Ne,'Bgeo',Bgeo,'numEnergies',30000);
else
    [perm,isotropic,Ne,nu,Sdiel,Pdiel,Ddiel]=...
        get_perm(h,w,'Ne',Ne,'Bgeo',Bgeo,'nu',nu);
end
zd=h*1e3*k0;
zero_collisions=strcmp(nuProfile,'zero');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up the initial np (=n_\perp) mesh -- it is not uniform!

% Resolution for np
Nr=2^11; % the real np only
given_Nr=1;

magic_scale=0.9; % 0.9 works for vacuum; probably =0.5 will work for anything.
% To resolve it, we need at least
dnrequired=magic_scale*2*pi/(k0*rmax)

evanescent_const=20; % we neglect exp(-evanescent_const)

if uniform_grid
    % Uniform grid
    npmax=sqrt(1+(evanescent_const/zdim(2))^2);
    if ~given_Nr
        Nr=ceil(1/dnrequired);
    end
    Nnp=ceil(Nr*npmax);
    dn0=npmax/Nnp;
    npb=[0:Nnp]*dn0;
    np=([0:Nnp-1]+0.5)*dn0;
    if given_Nr & dn0>dnrequired
        error(['WARNING: results only valid to r=' ...
            num2str(magic_scale*2*pi/(k0*dn0)/1e3) ' km, and rmax=' ...
            num2str(rmax/1e3) ' km']);
    end
else
    % Waves on the sphere, weighted appropriately
    if ~given_Nr
        Nr=ceil(pi/2/dnrequired); % Number of real thetas
    end
    dtheta0=(pi/2)/Nr
    if dtheta0>dnrequired
        error('Resolution is too small')
    end
    % Choose the extension into complex domain
    % use zdim(2)*sinh(pi/2*Nc/Nr)=const
    % Field at h(2) is ~ exp(-evanescent_const)
    a=asinh(evanescent_const/zd(2)); % theta goes to pi/2+i*a
    Nc=ceil(a/dtheta0);
    Nnp=Nr+Nc;
    % We only need theta > 0 for spherical calculations
    % Real thetas
    if given_Nr & dtheta0>dnrequired
        error(['WARNING: results only valid to r=' ...
            num2str(magic_scale*2*pi/(k0*dtheta0)/1e3) ' km, and rmax=' ...
            num2str(rmax/1e3) ' km']);
    end
    % Extend into complex angles domain a little bit
    theta=[[1/2:Nr-1/2]*dtheta0 pi/2+i*[1/2:Nc-1/2]*dtheta0];
    % Length along theta integration curve
    thetas=[[1/2:Nr-1/2]*dtheta0 pi/2+[1/2:Nc-1/2]*dtheta0];
    np=real(sin(theta));
    % Boundary np and theta points:
    thetab=[[0:Nr]*dtheta0 pi/2+i*[1:Nc]*dtheta0];
    thetabs=[[0:Nr]*dtheta0 pi/2+[1:Nc]*dtheta0];
    npb=real(sin(thetab));
end

common_save=['hmax f w k0 clight impedance0 h M zd perm isotropic Ne nu' ...
    ' ground_bc sground Mi retol output_interval Bgeo'];
if do_axisymmetric
    common_save=[common_save ' Nx x dx'];
else
    common_save=[common_save ' Nx x dx Ny y dy'];
end
eval(['save ' datadir 'common ' common_save])
eval(['save ' datadir 'perm Sdiel Pdiel Ddiel']); % For debugging mostly

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calibrate the current moment
% Ptot=233000; % total emitted power in W
if sground==0
    % Use ground_bc
    switch ground_bc
        case 'free'
            % Antenna in vacuum (no Earth):
            Iscaled=sqrt(12*pi*Ptot/k0^2/impedance0);
        case 'E=0'
            % Ground-based antenna (image + radiation into half-space only):
            Iscaled=sqrt(6*pi*Ptot/k0^2/impedance0);
        otherwise
            error('unknown ground_bc');
    end
else
    % Non-perfectly conducting Earth
    % Assume the same as with Earth
    Iscaled=sqrt(6*pi*Ptot/k0^2/impedance0);
end
% In case of FFT, If=fft(I)*dx*dy.
eval(['save ' datadir 'sources Ptot Iscaled']);

function [EH,nx,ny,EHf]=fwm1(axisymmetric,...
    f,h,perm,eground,...
    ksa,cartesian,arg1,arg2,I0,...
    xkm,ykm,hi,...
    rmaxkm,drkm,retol,bkp_file)
%FWM Full-wave method (the most general case)
% WARNING: CANNOT YET BE USED FOR SOURCE ON THE GROUND!
% Usage:
%    EH=impedance0*fwm(axisymmetric,...
%       f,h,perm,eground,...
%       ksa,{1,nx0,ny0|0,np0,m},I0,...
%       xkm,ykm,hi[,rmaxkm,drkm,retol,bkp_file]);
% Advanced usage:
%    [EH,nx,ny,EHf]=fwm(...);
% (must multiply by impedance0 after calculation);
% Inputs:
%    f - frequency (Hz)
%    h (M) - altitudes in km
%    perm (3 x 3 x M) - dielectric permittivity tensor
%    eground - ground bc (either dielectric permittivity or a boundary
%       condition like 'E=0' or 'free')
%    ksa, nx0, ny0, np0, m, I0 - the current
%       ksa (Ms) - indeces of layers in which current flows
%       Depending on the value of "cartesian":
%       cartesian==1:
%          nx0 (Nnx0), ny0 (Nny0) - cartesian coordinates (nx,ny) at which
%             the current is given;
%       cartesian==0:
%          np0 (Nnp0) - points in np at which the current is given
%          m (Nh) - harmonic, the current Ir,Ith,Iz~exp(i*m*th)
%       I0 (3 x Ms x Nnp0 x Nh) - the value of current moment at these
%          harmonics
%    xkm (Nx), ykm (Ny) - radial distance in km
%    hi (Mi) - output altitudes in km
% Optional inputs:
%    drkm (scalar) - the size of the source in km (important for a point
%       source and calculations on the ground), default==xkm(2)-xkm(1)
%    retol (scalar) - relative error tolerance, default=1e-4 (take a
%       smaller value for more accurate results)
% Output:
%    EH (6 x Nx x Mi) - E, H components on the positive x-axis at
%       coordinates (xkm,hi)
% Optional outputs:
%    nx (N) - values of nx at which the Fourier components EHf0 are
%       calculated
%    EHf (6 x N x Mi) - field values in nx-space
% Notes:
% 1. We must have h(1)==0 and h(2)>40 km if the source is on the ground for
%    efficient calculations
% 2. 
% Author: Nikolai G. Lehtinen
% See also: FWM_AXISYMMETRIC, FWM_FIELD, FWM_RADIATION

status={};

%%  Optional arguments
if nargin<17
    bkp_file=[];
end
if nargin<16
    retol=[];
end
if nargin<15
    drkm=[];
end
if nargin<14
    rmaxkm=[];
end

%% Choose the interpretation of arguments
% The current is given in what coordinates?
if cartesian
    if axisymmetric
        error('Please give current in harmonics, use FWM_HARMONICS');
    end
    nx0=arg1; ny0=arg2;
else
    % Axial harmonics
    np0=arg1; m=arg2;
end
point_source=isempty(arg1);

%% Default argument values
do_backups=~isempty(bkp_file);
if isempty(retol)
    retol=1e-4;
end
if isempty(drkm)
    drkm=min(min(diff(xkm)),min(diff(ykm)));
end
if isempty(rmaxkm)
    rmaxkm=sqrt(max(abs(xkm))^2+max(abs(ykm))^2);
end

%% Save a backup of all arguments
if do_backups
    disp(['Saving arguments into ' bkp_file '_FWMarg']);
    eval(['save ' bkp_file '_FWMarg axisymmetric f h perm eground ' ...
        ' ksa cartesian arg1 arg2 I0 xkm ykm hi ' ...
        ' rmaxkm drkm retol']);
end

%% Various constants
Ms=length(ksa);
global clight
if isempty(clight)
    loadconstants
end
w=2*pi*f;
k0=w/clight;
M=length(h);
z=h*1e3*k0;
Mi=length(hi);
zi=hi*1e3*k0;
zs=z(ksa); % source altitudes
isvac=zeros(size(h));
for k=1:M
    isvac(k)=(max(max(abs(perm(:,:,k)-eye(3))))<=eps);
end
kionosph=min(find(isvac==0)); % The ionosphere starts at h(kionsph)
x=xkm*1e3;
y=ykm*1e3;
drdamp=drkm*1e3;
if max(diff(x))*k0>1
    disp('WARNING: the wavelength is not resolved')
end
[kia,dzl,dzh]=fwm_get_layers(z,zi);

% The minimum dnperp, determined by max(x)
magic_scale=0.9; % 0.9 works for vacuum; probably =0.5 will work for anything.
% To resolve it, we need at least
dn0=magic_scale*2*pi/(k0*1e3*rmaxkm)

%% Determine the maximum nperp
evanescent_const=20; % we neglect exp(-evanescent_const)
if all(ksa<kionosph)
    % From evanescence between the source and the ionosphere
    % Choose the extension into complex domain
    % Field at h(kionosph) is ~ exp(-evanescent_const)
    dzionosph=z(kionosph)-max(zs)
    npmaxev=sqrt((evanescent_const/dzionosph)^2+1)
else
    dzionosph=0
    npmaxev=inf
end
% From the shape of the current
if point_source
    % We have a point source. Must introduce a finite
    % size of the current, take it to be dxdamp
    % See "efactor" variable in fwm_hankel
    npmaxcur=inf %sqrt(2*evanescent_const)/(dxdamp*k0)
else
    if cartesian
        if axisymmetric
            npmaxcur=max(nx0)
        else
            npmaxcur=max(max(nx0),max(ny0))
        end
    else
        npmaxcur=max(np0);
    end
end
% The last resort - if everything is infinite:
npmaxdamp=sqrt(2*evanescent_const)/(drdamp*k0)

if npmaxev<npmaxcur
    % Rely on evanescence
    drdamp1=0;
    npmax=npmaxev;
elseif npmaxcur==inf % npmaxev==inf, too
    % We have a point source NOT on the ground. Must bite the bullet.
    npmax=npmaxdamp;
    % dxdamp is kept finite
    drdamp1=drdamp;
else % nxmaxev > nxmaxcur, which is finite
    drdamp1=0; % we don't need damping - source is of finite size.
    npmax=npmaxcur;
end

%% Initial nx grid
% theta is the angle of incidence (nx==sin(theta))
if npmax>1
    a=acosh(npmax); % theta goes to pi/2+i*a
    Nr=ceil(pi/2/dn0); % Number of real thetas
    dth0r=(pi/2)/Nr; % <~ dn0
    Nc=ceil(a/dth0r);
    dth0c=a/Nc;
    % Boundary theta points:
    thb=[[0:Nr]*dth0r pi/2+i*[1:Nc]*dth0c];
else
    thmax=asin(npmax);
    Nr=ceil(thmax/dn0);
    dth0=thmax/Nr;
    thb=[0:Nr]*dth0;
end
% Boundary nx points:
npb0=real(sin(thb));

%% Find the best grid
if axisymmetric
    phitry=[0]; Nphitry=1;
else
    Nphitry=8;
    %phitry0=atan2(Bgeo(2),Bgeo(1));
    phitry=[0:Nphitry-1]*2*pi/Nphitry;
end
% Try twice, supposedly spend less time with coarser grids when many phi
% points
% I0 has size 3 x Ms [x Nnx0 [x Nny0]]
if axisymmetric
    [npb,np,EHf,relerror]=bestgrid(@fwm_aux,{[0],z,eground,perm,...
        ksa,cartesian,arg1,arg2,I0,...
        kia,dzl,dzh},...
        npb0,dn0,retol);
else
    program='FWM_BESTGRID';
    if do_backups
        bkp_file_ext=[bkp_file '_' program '.mat'];
        % See if we can retreive the best grid from the backup
        argnames={'axisymmetric','f','h','perm','eground',...
            'ksa','cartesian','arg1','arg2','I0','hi','retol'};
        args={axisymmetric,f,h,perm,eground,...
                ksa,cartesian,arg1,arg2,I0,hi,retol};
        if ~exist(bkp_file_ext,'file')
            disp(['Creating a new backup file ' bkp_file_ext])
            status='starting';
            save(bkp_file_ext,argnames{:},'status');
            restore=0
        elseif ~check_bkp_file(bkp_file_ext,argnames,args)
            disp(['WARNING: the backup file ' bkp_file_ext ' is invalid! Not doing backups']);
            do_backups=0;
        else % File exists and is valid
            disp(['Found backup file ' bkp_file_ext]);
            tmp=load(bkp_file_ext,'status');
            status=tmp.status;
            restore=strcmp(status,'done');
        end
    end
    if do_backups
        disp([program ' BACKUP STATUS = ' status]);
    end
    if do_backups & restore
        disp([program ': restoring from backup']);
        tmp=load(bkp_file_ext,'npb','np');
        npb=tmp.npb; np=tmp.np;
        % - results of bestgrid only!
    else
        disp([program ': starting a new calculation']);
        [npb,np,EHftry,relerror]=bestgrid(@fwm_aux,{[0],z,eground,perm,...
            ksa,cartesian,arg1,arg2,I0,...
            kia,dzl,dzh},...
            npb0,dn0,retol);
        % Don't have to improve the grid, miniter==0
        [npb,np,EHftry,relerror]=bestgrid(@fwm_aux,{phitry,z,eground,perm,...
            ksa,cartesian,arg1,arg2,I0,...
            kia,dzl,dzh},...
            npb,dn0,retol,0);
        if do_backups
            status='done';
            disp(['Saving results of ' program ' ...']);
            save(bkp_file_ext,'npb','np','status','-append');
            disp(' ... done');
        end
    end
end


%% Calculate the field in (nx,ny)-space
disp('***** Calculate the field in (nx,ny)-space *****');
if axisymmetric
    % Just reuse the calculated EHf
else
    % We discard the value of EHftry
    [Nphi,nx,ny,da,EHf]=fwm_waves1(z,eground,perm,dn0,npb,np,...
        ksa,cartesian,arg1,arg2,I0,kia,dzl,dzh,bkp_file);
end

%% Convert to x-space
disp('***** Sum the modes with appropriate weights (last step) *****');
% Was done by fwm_antenna_3d_assemble
if axisymmetric
    EH=zeros(6,Nx,Mi,Nh);
    for kh=1:Nh
        EH(:,:,:,kh)=fwm_hankel(k0,EHf,x,npb,dxdamp1,m(kh));
    end
else
    EH=fwm_assemble1(k0,nx,ny,da,EHf,x,y,bkp_file);
end

%if ~axisymmetric
%    return
%end

%% Determine if we need to extend the calculation to higher nx
% For these points, do only 2D calculation!
% Find where the output points are closer to the source than the distance
% between the source and the ionosphere
dzsi=zeros(size(zi));
for ki=1:Mi
    dzsi(ki)=min(abs(zs-zi(ki)));
end
dzsi

kie=find(dzsi<dzionosph)
if isempty(kie)
    return
end

zie=zi(kie);
zimin=min(dzsi(kie))
% We might have to extend the calculation
if zimin>0
    npmaxevi=sqrt((evanescent_const/zimin)^2+1)
else
    npmaxevi=inf
end
% This time, just choose the minimum of the three (nxmaxevi can be VERY
% big, we do not want to use it if nxmaxdamp is smaller)
if nxmaxdamp<min([nxmaxcur,nxmaxevi])
    drdamp2=drdamp
    npemax=npmaxdamp
else
    drdamp2=0
    npemax=min([npmaxdamp,npmaxcur,npmaxevi])
end

if npemax<=npmax
    % Do nothing
    return
end

%% Extend the calculation to higher np for cases that require it
disp('Extending np for the point source on the ground ...');
% Extend (only if evanescence is smaller than the effect of the
% size of the source)
Me=min([kionosph-1,max(ksa)])
ze=z(1:Me); perme=perm(:,:,1:Me); % only a few layers, to include the source
[kiavac,dzlvac,dzhvac]=fwm_get_layers(ze,zie);
nxeb0=[nxmax:dn0:nxemax+dn0];
if length(nx0)>1
    fun=@(nx_arg) permute(fwm_field(ze,eground,perme,nx_arg,0,ksa,...
        permute(interp1(nx0,I0p,nx_arg),[2 3 1]),kiavac,dzlvac,dzhvac),[2 1 3]);
else
    % Point source
    fun=@(nx_arg) permute(fwm_field(ze,eground,perme,nx_arg,0,ksa,...
        repmat(I0,[1 1 length(nx_arg)]),kiavac,dzlvac,dzhvac),[2 1 3]);
end
[nxeb,nxe,EHfe,relerror]=bestgrid(fun,{},nxeb0,dn0,retol);
EHfe=permute(EHfe,[2 1 3]);
% Concatenate two solutions and do the Hankel
nxt=[nx ; nxe];
nxtb=[nxb ; nxeb(2:end)];
if axisymmetric
    EHft=cat(2,EHf(:,:,kie),EHfe);
    % Sorry, have to discard the previous result for EH because dxdamp has
    % changed. However, we reuse EHf, which takes longer to calculate, so
    % there is still some efficiency.
    EH=zeros(6,Nx,Mi,Nh);
    for kh=1:Nh
        EH(:,:,kie,kh)=fwm_hankel(k0,EHft,x,npb,dxdamp1,m(kh));
    end
else
    disp('WARNING: 3D field on the ground is not completely implemented');
end

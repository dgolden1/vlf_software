function [EH,EHf,nx,ny,da,np,Nphi]=fwm_nonaxisymmetric(f,h,eground,perm,...
    ksa,coornperp,nperp1,nperp2,I0,...  % Input: the current
    coorrperp,rperp1,rperp2,hi,...      % Output: the spatial coordinates
    rmaxkm,drkm,retol,bkp_file)
%FWM_NONAXISYMMETRIC Full-wave method, the general case
% Usage:
%    EH=fwm_nonaxisymmetric(f,h,eground,perm,...
%       ksa,{1,nx0,ny0|2,np0,phi0|3,np0,m0},I0,...
%       {1,xkm,ykm|2,rkm,phi|3,rkm,m},hi ...
%       [,rmaxkm,drkm,retol,bkp_file]);
% Advanced usage:
%    [EH,EHf,nx,ny,da,np,Nphi]=fwm_nonaxisymmetric(...);
% (must multiply by impedance0 after calculation);
% Inputs:
%    f - frequency (Hz)
%    h (M) - altitudes in km
%    eground - ground permittivity (scalar) or boundary condition (string),
%       chosen from 'E=0','H=0' or 'free'
%    perm (3 x 3 x M) - dielectric permittivity tensor in each layer
%    ksa, coornperp, nperp1, nperp2, I0 - the current    
%       ksa (Ms) - indeces of altitudes in which the current is present,
%          i.e. at h(ksa)
%       Depending on the value of "coornperp":
%       coornperp==1: nperp1==nx0, nperp2==ny0
%          nx0 (Nnx0), ny0 (Nny0) - cartesian coordinates (nx,ny) at which
%             the current is given
%       coornperp==2: nperp1==np0, nperp2==phin0
%          np0 (Nnp0) - points in np at which the current is given
%          phin0 (Nphin0) - angles at which Ix,Iy,Iz are given
%       coornperp==3: nperp1==np0, nperp2==m0
%          np0 (Nnp0) - points in np at which the current is given
%          m0 (Nh0) - harmonic, the current Ir,Ith,Iz~exp(i*m*th)
%       I0 (6 x Ms x {Nnx0|Nnp0|Nnp0} x {Nny0|Nphin0|Nh0}) - the value of
%          the current moment or surface current at the given value of
%          nperp and h(ksa) (in V/m, both electric and magnetic)
%    coorrperp,rperp1,rperp2,hi - output coordinates
%       Depending on the value of "coorrperp":
%       coorrperp==1: rperp1==xkm, rperp2==ykm
%          xkm (Nx), ykm (Ny) - radial distance in km
%       coorrperp==2: rperp1==rkm, rperp2==phi
%          rperp1 (Nr) - distance in km
%          phi (Nphir) - 
%       hi (Mi) - output altitudes in km
% Optional inputs:
%    rmaxkm (scalar) - max perp distance at which the results are still
%       valid, default=sqrt(max(xkm)^2+max(ykm)^2)
%    drkm (scalar) - the size of the source in km (important for a point
%       source and calculations on the ground), default==xkm(2)-xkm(1)
%    retol (scalar) - relative error tolerance, default=1e-4 (take a
%       smaller value for more accurate results)
% Output:
%    EH (6 x Mi x {Nx|Nr} x {Ny|Nphi|Nh}) - E, H components on the positive
%       x-axis at coordinates (rperp,hi) (see note 1)
% Optional outputs (diagnostic):
%    EHf (6 x Mi x Nmodes) - field values in (nperp,z)-space. The grid is
%       specified by the following arguments.
%    nx (Nmodes), ny (Nmodes) - values of nperp at which the Fourier
%       components EHf are calculated
%    da (Nmodes) - the area elements in nperp plane
%    np (Nnp) - values of |nperp| on the grid
%    Nphi (Nnp) - number of points for each np(ip) at different angles,
%       phi==[0:Nphi(ip)-1]*2*pi/Nphi(ip);
% Notes (IMPORTANT!):
% 1. See notes 1-2 to FWM_AXISYMMETRIC, and note 3 if using axial harmonics
% Author: Nikolai G. Lehtinen
% See also: FWM_AXISYMMETRIC, FWM_FIELD, FWM_RADIATION
% Examples:
%    fwm_example_with_horizontal_B,
%    fwm_nonaxisymmetric_antenna_example,
%    fwm_nonaxisymmetric_antenna_horizb

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
point_source=isempty(nperp1);
if ~point_source
	switch coornperp
		case 1
			% cartesian
			nx0=nperp1; ny0=nperp2;
			np0max=max(max(nx0),max(ny0));
		case 2
			% polar
			np0=nperp1; phin0=nperp2;
			np0max=max(np0);
		case 3
			% harmonics
			np0=nperp1; m0=nperp2;
			np0max=max(np0);
		otherwise
			error(['unknown coordinate sys for nperp: ' num2str(coornperp)]);
	end
else
	% Ignore the given options
	np0max=[];
end
switch coorrperp
	case 1
		% cartesian
		xkm=rperp1; ykm=rperp2;
	case 2
		% polar
		rkm=rperp1; phir=rperp2;
	case 3
		% harmonics
		rkm=rperp1; mr=rperp2;
	otherwise
		error(['unknown coordinate sys for rperp: ' num2str(coorrperp)]);
end

%% Default argument values
do_backups=~isempty(bkp_file);
if isempty(retol)
    retol=1e-4;
end
if isempty(drkm)
	if coorrperp==1
		drkm=min(min(diff(xkm)),min(diff(ykm)));
	else
		drkm=min(diff(rkm));
	end
end
if isempty(rmaxkm)
	if coorrperp==1
		rmaxkm=sqrt(max(abs(xkm))^2+max(abs(ykm))^2);
	else
		rmaxkm=max(rkm);
	end
end

%% Save a backup of all arguments
if do_backups
    disp(['Saving arguments into ' bkp_file '_FWM_NONAXISYMMETRIC_arg']);
    eval(['save ' bkp_file '_FWM_NONAXISYMMETRIC_arg f h eground perm ' ...
        ' ksa coornperp nperp1 nperp2 I0 coorrperp rperp1 rperp2 hi ' ...
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
zd=h*1e3*k0;
Mi=length(hi);
zdi=hi*1e3*k0;
zds=zd(ksa); % source altitudes
switch coorrperp
	case 1
		x=xkm*1e3;
		y=ykm*1e3;
	case {2,3}
		r=rkm*1e3;
end
drdamp=drkm*1e3;
if max(diff(x))*k0>1
    disp('WARNING: the wavelength is not resolved')
end
[kia,dzl,dzh]=fwm_get_layers(zd,zdi);

% The minimum dnperp, determined by max(x)
magic_scale=0.9; % 0.9 works for vacuum; probably =0.5 will work for anything.
% To resolve it, we need at least
dn0=magic_scale*2*pi/(k0*1e3*rmaxkm)

%% Determine the maximum nperp
[npmax1,ki1,need_gauss1,kion,do_extend,npmax2,ki2,need_gauss2]=...
	fwm_npmax(zd,perm,zds,zdi,point_source,np0max,drdamp*k0)

%% Initial nx grid
% theta is the angle of incidence (nx==sin(theta))
if npmax1>1
    a=acosh(npmax1); % theta goes to pi/2+i*a
    Nr=ceil(pi/2/dn0); % Number of real thetas
    dth0r=(pi/2)/Nr; % <~ dn0
    Nc=ceil(a/dth0r);
    dth0c=a/Nc;
    % Boundary theta points:
    thb=[[0:Nr]*dth0r pi/2+i*[1:Nc]*dth0c];
else
    thmax=asin(npmax1);
    Nr=ceil(thmax/dn0);
    dth0=thmax/Nr;
    thb=[0:Nr]*dth0;
end
% Boundary nx points:
npbi=real(sin(thb));

%% Find the best grid
Nphitry=8;
%phitry0=atan2(Bgeo(2),Bgeo(1));
phitry=[0:Nphitry-1]*2*pi/Nphitry;

% Try twice, supposedly spend less time with coarser grids when many phi
% points
% I0 has size 6 x Ms [x Nnx0 [x Nny0]]
program='FWM_BESTGRID';
if do_backups
	bkp_file_ext=[bkp_file '_' program '.mat'];
	% See if we can retreive the best grid from the backup
	argnames={'f','h','perm','eground',...
		'ksa','coornperp','nperp1','nperp2','I0','hi','rmaxkm','retol'};
	args={f,h,perm,eground,...
		ksa,coornperp,nperp1,nperp2,I0,hi,rmaxkm,retol};
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
	[npb,np,EHftry,relerror]=bestgrid(@fwm_bestgrid,{[0],zd,eground,perm,...
		ksa,coornperp,nperp1,nperp2,I0,...
		kia,dzl,dzh},...
		npbi,dn0,retol);
	% Don't have to improve the grid, miniter==0
	[npb,np,EHftry,relerror]=bestgrid(@fwm_bestgrid,{phitry,zd,eground,perm,...
		ksa,coornperp,nperp1,nperp2,I0,...
		kia,dzl,dzh},...
		npb,dn0,retol,0);
	if do_backups
		status='done';
		disp(['Saving results of ' program ' into ' bkp_file_ext ' ...']);
		save(bkp_file_ext,'npb','np','status','-append');
		disp(' ... done');
	end
end


%% Calculate the field in (nx,ny)-space
disp('***** Calculate the field in (nx,ny)-space *****');
% We discard the value of EHftry
[EHf,nx,ny,da,Nphi]=fwm_waves(zd,eground,perm,dn0,npb,np,...
	ksa,coornperp,nperp1,nperp2,I0,kia,dzl,dzh,bkp_file);

%% Convert to x-space
disp('***** Sum the modes with appropriate weights (last step) *****');

% Was done by fwm_antenna_3d_assemble
if need_gauss1 || (do_extend && need_gauss2)
	nptmp=sqrt(nx.^2+ny.^2);
	nptmp=nptmp(:);
	efactor=exp(-(nptmp.*k0*drdamp).^2/2);
end
if do_extend
	EH=zeros(6,Mi,length(rperp1),length(rperp2));
	if need_gauss1
		EHf(:,ki1,:)=EHf(:,ki1,:).*repmat(shiftdim(efactor,-2),[6 length(ki1) 1]);
	end
	if need_gauss2
		EHf(:,ki2,:)=EHf(:,ki2,:).*repmat(shiftdim(efactor,-2),[6 length(ki2) 1]);
	end
	% NOTE: This is incomplete solution, the waves with np>npmax1 are
	% missing still for ki==ki2.
	EH1=fwm_assemble(k0,nx,ny,da,EHf,coorrperp,rperp1,rperp2,bkp_file);
else
	% Finish here
	if need_gauss1
		EHf=EHf.*repmat(shiftdim(efactor,-2),[6 Mi 1]);
	end
	EH=fwm_assemble(k0,nx,ny,da,EHf,coorrperp,rperp1,rperp2,bkp_file);
	npt=[]; EHft0=[]; ki2=[];
	return
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extend the calculation to higher np for cases that require it
disp('Extending ...');
% Use the axisymmetric calculation for EHf(:,ki2,:) at np>npmax1
Me=min([kion-1,max(ksa)])
zde=zd(1:Me); perme=perm(:,:,1:Me); % only a few layers, to include the source
[kiavac,dzlvac,dzhvac]=fwm_get_layers(zde,zdi(ki2));
npebi=[npmax1:dn0:npmax2+dn0].';
if point_source
    % Point source
    fun=@(np_arg) permute(fwm_field(zde,eground,perme,ksa,np_arg,0,...
        repmat(I0,[1 1 length(np_arg)]),kiavac,dzlvac,dzhvac),[3 1 2]);
else
	% Convert the current to harmonics
	Nh=3;
	Nhshift=1;
	% I0h is (6 x Ms x Nnp0 x Nh)
	% np0 is (Nnp0); m0 is (Nh)
	if coornperp~=1
		error('not implemented');
	end
	[I0h,np0,m0]=fwm_harmonics(nx0,ny0,I0,Nh,Nhshift);
	tmp=I0h(:,:,:,[1 3]);
	if any(tmp(:)~=0)
		error('not implemented');
	end
	% Only zeroth harmonic so far
	I0p=permute(I0h(:,:,:,2),[3 1 2]); % (Nnp0 x 6 x Ms)
	% - move the interpolation dimension to 1st place
    % Iip=interp1(nx0,I0p,nx_arg);
    % I0 is (6 x Ms x N)
	% I0p is (N x 6 x Ms)
    % We managed to squeeze the call into a lambda form
	% Output of fwm_field is EHf (6 x Mi x N);
	% BESTGRID takes (N x 6 x Mi)
    fun=@(np_arg) permute(fwm_field(zde,eground,perme,ksa,np_arg,0,...
        permute(interp1(np0,I0p,np_arg),[2 3 1]),kiavac,dzlvac,dzhvac),[3 1 2]);
end
[npeb,npe,EHfe0,relerror]=bestgrid(fun,{},npebi,dn0,retol);
EHfe0=permute(EHfe0,[2 3 1]); % (6 x Ms x N)
% Hankel transform of the zeroth mode only
if need_gauss2
	efactor=exp(-(npe.*k0*drdamp).^2/2);
	EHfe0=EHfe0.*repmat(shiftdim(efactor,-2),[6 length(ki2) 1]);
end
if coorrperp~=1
	error('not implemented');
end
dr=min(min(diff(x)),min(diff(y)))/10;
if drkm==0
	error('drkm==0');
end
drkminterp=min([min(diff(xkm)),min(diff(ykm))])/2;
r=[0:drkminterp:rmaxkm]*1e3;
m=0;
EHe0=k0^2*fwm_hankel(npeb,EHfe0,r*k0,m);
% Interpolate in cartesian coors
EH2=zeros(6,length(ki2),length(rperp1),length(rperp2));
[xm,ym]=ndgrid(x,y);
rm=sqrt(xm.^2+ym.^2);
EH2=permute(interp1(r,permute(EHe0,[3 1 2]),rm),[3 4 1 2]);
EH=EH1; % copy size
EH(:,ki2,:,:)=EH1(:,ki2,:,:)+EH2;


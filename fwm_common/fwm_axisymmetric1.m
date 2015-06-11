function [EH0,nx,EHf0,nxt,EHft0]=fwm_axisymmetric(f,h,perm,eground,...
	ksa,nx0,I0,m,xkm,hi,dxkm,retol,return_Epm)
%FWM_ANTENNA_AXISYMMETRIC Antenna radiation (axisymmetric)
% Calculation of the field from a source on the ground (axisymmetric case)
% Usage:
%    EH0=impedance0*fwm_axisymmetric(...
%       f,h,perm,eground,ks,nx0,I0,m,xkm,hi[,dxkm,retol])
% Advanced usage:
%    [EH0,nx,EHf0]=fwm_axisymmetric(...)
% Inputs:
%    f - frequency (Hz)
%    h (M) - altitudes in km
%    perm (3 x 3 x M) - dielectric permittivity tensor
%    eground - ground bc
%    ksa, nx0, I0, m - the current
%       ksa (Ms) - indeces of layers in which current flows
%       nx0 (N0) - points in nx at which the current is given
%       I0 (3 x Ms x N0) - the value of current moment
%       m (integer scalar) - harmonic, the current Ir,Ith,Iz~exp(i*m*th)
%    xkm (Nx) - radial distance in km
%    hi (Mi) - output altitudes in km
% Optional inputs:
%    dxkm (scalar) - the size of the source in km (for a point source and
%       calculations on the ground), default==xkm(2)-xkm(1)
%    retol (scalar) - relative error tolerance, default=1e-4 (take a
%       smaller value for more accurate results)
% Output:
%    EH0 (6 x Nx x Mi) - E, H components on the positive x-axis at
%       coordinates (xkm,hi)
% Optional outputs:
%    nx (N) - values of nx at which the Fourier components EHf0 are
%       calculated
%    EHf0 (6 x N x Mi) - field values in nx-space
% Notes:
% 1. We must have h(1)==0 and h(2)>40 km if the source is on the ground for
%    efficient calculations
% 2. 
% Author: Nikolai G. Lehtinen
% See also: FWM_FIELD, FWM_RADIATION

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optional arguments
if nargin<13
    return_Epm=[];
end
if nargin<12
    retol=[];
end
if nargin<11
    dxkm=[];
end
% Default argument values
if isempty(return_Epm)
    return_Epm=0;
end
if isempty(retol)
    retol=1e-4;
end
if isempty(dxkm)
    dxkm=xkm(2)-xkm(1);
end

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
dxdamp=dxkm*1e3;
if max(diff(x))*k0>1
    disp('WARNING: the wavelength is not resolved')
end
[kia,dzl,dzh]=fwm_get_layers(z,zi);

% The minimum dnperp, determined by max(x)
magic_scale=0.9; % 0.9 works for vacuum; probably =0.5 will work for anything.
% To resolve it, we need at least
dn0=magic_scale*2*pi/(k0*max(x))

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine the maximum nperp
evanescent_const=20; % we neglect exp(-evanescent_const)
if all(ksa<kionosph)
    % From evanescence between the source and the ionosphere
    % Choose the extension into complex domain
    % Field at h(kionosph) is ~ exp(-evanescent_const)
    dzionosph=z(kionosph)-max(zs)
    nxmaxev=sqrt((evanescent_const/dzionosph)^2+1)
else
    dzionosph=0
    nxmaxev=inf
end
% From the shape of the current
if length(nx0)>1
    if ~all(all(I0(:,:,end)==0))
        error('must have zero current at nxmax');
    end
    nxmaxcur=nx0(end)
else
    % We have a point source. Must introduce a finite
    % size of the current, take it to be dxdamp
    % See "efactor" variable in fwm_hankel
    nxmaxcur=inf %sqrt(2*evanescent_const)/(dxdamp*k0)
end
% The last resort - if everything is infinite:
nxmaxdamp=sqrt(2*evanescent_const)/(dxdamp*k0)

if nxmaxev<nxmaxcur
    % Rely on evanescence
    dxdamp1=0;
    nxmax=nxmaxev;
elseif nxmaxcur==inf % nxmaxev==inf, too
    % We have a point source NOT on the ground. Must bite the bullet.
    nxmax=nxmaxdamp;
    % dxdamp is kept finite
    dxdamp1=dxdamp;
else % nxmaxev > nxmaxcur, which is finite
    dxdamp1=0; % we don't need damping - source is of finite size.
    nxmax=nxmaxcur;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial nx grid
% theta is the angle of incidence (nx==sin(theta))
if nxmax>1
    a=acosh(nxmax); % theta goes to pi/2+i*a
    Nr=ceil(pi/2/dn0); % Number of real thetas
    dth0r=(pi/2)/Nr; % <~ dn0
    Nc=ceil(a/dth0r);
    dth0c=a/Nc;
    % Boundary theta points:
    thb=[[0:Nr]*dth0r pi/2+i*[1:Nc]*dth0c];
else
    thmax=asin(nxmax);
    Nr=ceil(thmax/dn0);
    dth0=thmax/Nr;
    thb=[0:Nr]*dth0;
end
% Boundary nx points:
nxb0=real(sin(thb));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the field
if length(nx0)>1
    I0p=permute(I0,[3 1 2]); % move the interpolation dimension to 1st place
    %Iip=interp1(nx0,I0p,nx_arg);
    % I must be is (3 x Ms x N)
    %Ii=permute(Iip,[2 3 1]);
    % We managed to squeeze the call into a lambda form
    fun=@(nx_arg) permute(fwm_field1(z,eground,perm,nx_arg,0,ksa,...
        permute(interp1(nx0,I0p,nx_arg),[2 3 1]),kia,dzl,dzh),[2 1 3]);
else
    % Point source - just repeat the matrix I0
    fun=@(nx_arg) permute(fwm_field1(z,eground,perm,nx_arg,0,ksa,...
        repmat(I0,[1 1 length(nx_arg)]),kia,dzl,dzh),[2 1 3]);
end
[nxb,nx,EHf0,relerror]=bestgrid(fun,{},nxb0,dn0,retol);
EHf0=permute(EHf0,[2 1 3]);

% Convert to x-space
EH0=fwm_hankel1(k0,EHf0,x,nxb,dxdamp1,m);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine if we need to extend the calculation to higher nx

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
    nxmaxevi=sqrt((evanescent_const/zimin)^2+1)
else
    nxmaxevi=inf
end
% This time, just choose the minimum of the three (nxmaxevi can be VERY
% big, we do not want to use it if nxmaxdamp is smaller)
if nxmaxdamp<min([nxmaxcur,nxmaxevi])
    dxdamp2=dxdamp
    nxemax=nxmaxdamp
else
    dxdamp2=0
    nxemax=min([nxmaxdamp,nxmaxcur,nxmaxevi])
end

if nxemax<=nxmax
    % Do nothing
    return
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extend the calculation to higher nx for cases that require it
disp('Extending ...');
% Extend (only if evanescence is smaller than the effect of the
% size of the source)
Me=min([kionosph-1,max(ksa)])
ze=z(1:Me); perme=perm(:,:,1:Me); % only a few layers, to include the source
[kiavac,dzlvac,dzhvac]=fwm_get_layers(ze,zie);
nxeb0=[nxmax:dn0:nxemax+dn0];
if length(nx0)>1
    fun=@(nx_arg) permute(fwm_field1(ze,eground,perme,nx_arg,0,ksa,...
        permute(interp1(nx0,I0p,nx_arg),[2 3 1]),kiavac,dzlvac,dzhvac),[2 1 3]);
else
    % Point source
    fun=@(nx_arg) permute(fwm_field1(ze,eground,perme,nx_arg,0,ksa,...
        repmat(I0,[1 1 length(nx_arg)]),kiavac,dzlvac,dzhvac),[2 1 3]);
end
[nxeb,nxe,EHfe0,relerror]=bestgrid(fun,{},nxeb0,dn0,retol);
EHfe0=permute(EHfe0,[2 1 3]);
% Concatenate two solutions and do the Hankel
nxt=[nx ; nxe];
nxtb=[nxb ; nxeb(2:end)];
EHft0=cat(2,EHf0(:,:,kie),EHfe0);
% Sorry, have to discard the previous result for EH0 because dxdamp has
% changed. However, we reuse EHf0, which takes longer to calculate, so
% there is still some efficiency.
EH0(:,:,kie)=fwm_hankel1(k0,EHft0,x,nxtb,dxdamp2,m,return_Epm);

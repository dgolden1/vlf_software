function [EH0,EHf0,np,ki2,npt,EHft0]=fwm_axisymmetric(f,h,eground,perm,...
	ksa,np0,m,I0,rkm,hi,rmaxkm,drkm,retol)
%FWM_AXISYMMETRIC Full-wave method for axisymmetric dielectric permittivity
% Calculation of the field from a source on the ground (axisymmetric case).
% The word "axisymmetric" only applies to the dielectric permittivity,
% i.e., it has to have a form which is invariant under rotations around
% z-axis, i.e.
%                   ( S -iD   0)
%     perm(:,:,k) = (iD   S   0)
%                   ( 0   0   P)
% at all altitudes. In plasma (ionosphere), it means that the geomagnetic
% field has to be vertical.
% The source currents, on the other hand, do not have to be axisymmetric.
% In general case, they have to be expanded in axial harmonics
% ~exp(i*m*phi). See note 3 below for details.
% Usage:
%    EH=fwm_axisymmetric(f,h,eground,perm,...
%       ksa,np0,I0,m,rkm,hi[,rmaxkm,drkm,retol])
% Advanced usage:
%    [EH,EHf,np]=fwm2_axisymmetric(...)
% Inputs:
%    f - frequency (Hz)
%    h (M) - altitudes in km
%    eground - ground permittivity (scalar) or boundary condition (string),
%       chosen from 'E=0','H=0' or 'free'
%    perm (3 x 3 x M) - dielectric permittivity tensor in each layer
%    ksa, np0, m, I0 - the current
%       ksa (Ms) - indeces of altitudes at which current flows, i.e. h(ksa)
%       np0 (N0) - points in np at which the current is given
%       m (integer scalar) - axial harmonic, so that the current
%          Ir,Iphi,Iz~exp(i*m*th) (see note 3!)
%       I0 (6 x Ms x N0) - the value of the electric and magnetic current
%          moments or surface currents (in rationalized units of V/m) at
%          altitudes h(ksa). Given are the current component
%          values on the positive x-axis (at phi==0) (see note 3!)
%    rkm (Nr) - radial distance in km
%    hi (Mi) - output altitudes in km
% Optional inputs:
%    rmaxkm (scalar) - maximum distance
%    drkm (scalar) - the size of the source in km (for a point source and
%       calculations on the ground), default==xkm(2)-xkm(1)
%    retol (scalar) - relative error tolerance, default=1e-4 (take a
%       smaller value for more accurate results)
% Output:
%    EH (6 x Mi x Nr) - E, H components on the positive x-axis at
%       coordinates (rkm,hi) (see note 3!)
% Optional outputs:
%    np (N) - values of nx at which the Fourier components EHf0 are
%       calculated
%    EHf (6 x Mi x N) - field values in np-space
% Notes (IMPORTANT!):
% 1. See notes to FWM2_FIELD!
% 2. To calculate field on the ground for a point source, choose
%    h(2)==0.001 and place the source at h(2) (i.e., ksa=[2]).
%    For efficient calculation, the ionosphere has to be far from the
%    ground. I.e., make sure that Ne(1:Mion)==0, where h(Mion+1) is the
%    height of ionosphere, > 40 km.
% 3. About axial harmonics:
%    We use the fact that the Fourier transform of any function of form
%       A(x,y)=A(r)*exp(i*n*phi)
%    is
%       A(kx,ky)=(2*pi)/i^n*A_n(k)*exp(i*n*chi),
%    where the 2D Fourier transform is defined as
%       A(kx,ky)= \int exp(-i*(kx*x+ky*y))*A(x,y) dx dy
%       A(x,y)  = \int exp(i*(kx*x+ky*y))*A(kx,ky) (dkx dky)/(2*pi)^2
%    with the integrals having infinite limits. The polar coordinates are
%       x=r*cos(phi), y=r*sin(phi)
%       kx=k*cos(chi), ky=k*sin(chi)
%    A_n(k) is the Hankel transform of A(r):
%       A_n(k) = \int_0^\infty A(r)*J_n(k*r)*r*dr
%       A(r)   = \int_0^\infty A_n(k)*J_n(k*r)*k*dk
%    The function A is a scalar, which can be any of the components of a
%    vector, e.g., Ix, Iy, or Iz. However, FWM_AXISYMMETRIC takes as an
%    input the values of {Ix,Iy,Iz} at chi==0. To calculate the fields
%    (even only at phi==0, as this program does), we need to know the
%    angular dependence Ix(chi) etc. The input to FWM_AXISYMMETRIC requires
%    that the polar components of the current in (kx,ky,z)-space
%       {Ik,Ichi,Iz}~exp(i*m*chi)
%    Then the polar components of fields EHf (in (kx,ky,z)-space), also
%    have the same chi-dependence (due to linearity and axial symmetry of
%    the dielectric permittivity):
%       {EHfk,EHfchi,EHfz}~exp(i*m*chi)
%    These are then converted to fields EH in (x,y,z)-space at phi==0 and
%    provided as an output of FWM_AXISYMMETRIC.
%    If we know (Ix,Iy,Iz) as a function of (k,chi), we first have to
%    convert the components from one coordinate system to another:
%       Ik   =  Ix*cos(chi)+Iy*sin(chi)
%       Ichi = -Ix*sin(chi)+Iy*cos(chi)
%    Note that chi-dependence of Ik,Ichi will be different from that
%    of Ix,Iy. To convert the axial harmonics efficiently, we use
%       Ik+i*Ichi= (Ix+i*Iy)*exp(-i*chi)
%       Ik-i*Ichi= (Ix-i*Iy)*exp(+i*chi)
%    Thus, n-th axial harmonic in Ix, Iy gives rize to (m==n+1)-th and
%    (m==n-1)-th harmonics in Ik, Ichi (while Iz does not change).
%    Let us elaborate. Assume
%       {Ix(kx,ky),Iy(kx,ky),Iz(kx,ky)}=={Ix(k),Iy(k),Iz(k)}*exp(i*n*chi)
%    A particular case, n==0 corresponds to an arbitrarily oriented
%    extended dipole of an axially-symmetric shape. If, moreover,
%    Ix(k)==const etc., this corresponds to a point dipole at x=0,y=0.
%    We have the following harmonics that should be passed to
%    FWM_AXISYMMETRIC (which has to be called three times!):
%       m == n   : {Ik(k),Ichi(k),Iz(k)} == {0,0,Iz(k)}
%       m == n-1 : {Ik(k),Ichi(k),Iz(k)} == (Ix(k)+i*Iy(k))*{1/2,-i/2,0}
%       m == n+1 : {Ik(k),Ichi(k),Iz(k)} == (Ix(k)-i*Iy(k))*{1/2,+i/2,0}
%    To calculate the fields at arbitrary phi based on the results of
%    FWM_AXISYMMETRIC, we use
%       Ex+i*Ey = (Er(phi)+i*Ephi(phi))*exp(+i*phi)
%       Ex-i*Ey = (Er(phi)-i*Ephi(phi))*exp(-i*phi)
%    Since the output of FWM_AXISYMMETRIC is at phi==0, we should use
%       Ex+i*Ey = (Er(phi==0)+i*Ephi(phi==0))*exp(i*(m+1)*phi)
%       Ex-i*Ey = (Er(phi==0)-i*Ephi(phi==0))*exp(i*(m-1)*phi)
% Author: Nikolai G. Lehtinen
% See also: FWM_NONAXISYMMETRIC, FWM_FIELD, FWM_RADIATION
% Examples: fwm_axisymmetric_antenna_example, fwm_axisymmetric_example

%% Optional arguments
if nargin<13
    retol=[];
end
if nargin<12
    drkm=[];
end
if nargin<11
	rmaxkm=[];
end
% Default argument values
if isempty(retol)
    retol=1e-4;
end
if isempty(drkm)
	if length(rkm)==1
		drkm=rkm;
	else
		drkm=min(diff(rkm));
	end
end
if isempty(rmaxkm)
	rmaxkm=max(rkm);
end

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
r=rkm*1e3;
Nr=length(r);
rmax=rmaxkm*1e3;
drdamp=drkm*1e3;
if max(diff(r))*k0>1
    disp('WARNING: the wavelength is not resolved')
end
[kia,dzl,dzh]=fwm_get_layers(zd,zdi);

% The minimum dnperp, determined by max(x)
magic_scale=0.9; % 0.9 works for vacuum; probably =0.5 will work for anything.
% To resolve it, we need at least
dn0=magic_scale*2*pi/(k0*rmax)


%% Determine the maximum nperp
% The effect of ionosphere is limited by evanescence of waves between the
% source and the ionosphere, or by nperp-size of the source. For point
% source, its shape is gaussian with width determined by dxdamp.
% For points close to the source (closer than the ionosphere), there is a
% different nperp, determined either by evanescence between source and
% point, or by nperp-size of the source, or by the gaussian profile point
% source.
point_source=(length(np0)<=1);
zds
[npmax1,ki1,need_gauss1,kion,do_extend,npmax2,ki2,need_gauss2]=...
	fwm_npmax(zd,perm,zds,zdi,point_source,max(np0),drdamp*k0)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial np grid
% theta is the angle of incidence (np==sin(theta))
if npmax1>1
    a=acosh(npmax1); % theta goes to pi/2+i*a
    N1=ceil(pi/2/dn0); % Number of real thetas
    dth1=(pi/2)/N1; % <~ dn0
    N2=ceil(a/dth1);
    dth2=a/N2;
    % Boundary theta points:
    thb=[[0:N1]*dth1 pi/2+i*[1:N2]*dth2];
else
    thmax=asin(npmax1);
    N=ceil(thmax/dn0);
    dth0=thmax/N;
    thb=[0:N]*dth0;
end
% Boundary np points (initial):
npbi=real(sin(thb));

%% Find the field in np-space
if point_source
	% Point source - just repeat the matrix I0 (3 x Ms)
    fun=@(np_arg) permute(fwm_field(zd,eground,perm,ksa,np_arg,0,...
        repmat(I0,[1 1 length(np_arg)]),kia,dzl,dzh),[3 1 2]);
else
   I0p=permute(I0,[3 1 2]);
	% - move the interpolation dimension to 1st place
    % Iip=interp1(nx0,I0p,nx_arg);
    % I0 is (3 x Ms x N)
	% I0p is (N x 3 x Ms)
    % We managed to squeeze the call into a lambda form
	% Output of fwm_field is EHf (6 x Mi x N);
	% BESTGRID takes (N x 6 x Mi)
    fun=@(np_arg) permute(fwm_field(zd,eground,perm,ksa,np_arg,0,...
        permute(interp1(np0,I0p,np_arg),[2 3 1]),kia,dzl,dzh),[3 1 2]);
end
[npb,np,EHf0,relerror]=bestgrid(fun,{},npbi,dn0,retol);
EHf0=permute(EHf0,[2 3 1]); % Back to (6 x Mi x N)

if do_extend
	EH0=zeros(6,Mi,Nr);
	EH0(:,ki1,:)=k0^2*fwm_hankel(npb,EHf0(:,ki1,:),r*k0,m);
else
	% Finish here
	if need_gauss1
		efactor=exp(-(np.*k0*drdamp).^2/2);
		EHf0=EHf0.*repmat(shiftdim(efactor,-2),[6 Mi 1]);
	end
	EH0=k0^2*fwm_hankel(npb,EHf0,r*k0,m);
	npt=[]; EHft0=[]; ki2=[];
	return
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extend the calculation to higher np for cases that require it
disp('Extending ...');
% Extend (only if evanescence is smaller than the effect of the
% size of the source)
Me=min([kion-1,max(ksa)])
zde=zd(1:Me); perme=perm(:,:,1:Me); % only a few layers, to include the source
[kiavac,dzlvac,dzhvac]=fwm_get_layers(zde,zdi(ki2));
npebi=[npmax1:dn0:npmax2+dn0].';
if point_source
    % Point source
    fun=@(np_arg) permute(fwm_field(zde,eground,perme,ksa,np_arg,0,...
        repmat(I0,[1 1 length(np_arg)]),kiavac,dzlvac,dzhvac),[3 1 2]);
else
    fun=@(np_arg) permute(fwm_field(zde,eground,perme,ksa,np_arg,0,...
        permute(interp1(np0,I0p,np_arg),[2 3 1]),kiavac,dzlvac,dzhvac),[3 1 2]);
end
[npeb,npe,EHfe0,relerror]=bestgrid(fun,{},npebi,dn0,retol);
EHfe0=permute(EHfe0,[2 3 1]);
% Concatenate two solutions and do the Hankel
npt=[np(:) ; npe];
nptb=[npb(:) ; npeb(2:end)];
EHft0=cat(3,EHf0(:,ki2,:),EHfe0);
if need_gauss2
	efactor=exp(-(npt.*k0*drdamp).^2/2);
	EHft0=EHft0.*repmat(shiftdim(efactor,-2),[6 length(ki2) 1]);
end
EH0(:,ki2,:)=k0^2*fwm_hankel(nptb,EHft0,r*k0,m);

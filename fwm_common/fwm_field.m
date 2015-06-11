function EHf=fwm2_field(zd,eground,perm,ksa,nx,ny,I,kia,dzl,dzh)
%FWM_FIELD Calculate E, H for given (nx,ny) and currents
% Usage:
%    EHf=fwm2_field(...
%        zd,eground,perm,ksa,nx,ny,I,kia,dzl,dzh);
% Inputs:
%    zd (M) - dimensionless altitudes (zd==z*k0, k0==w/c)
%    eground - ground permittivity (scalar) or boundary condition (string),
%       chosen from 'E=0','H=0' or 'free'
%    perm (3 x 3 x M) - dielectric permittivity tensor in each layer
%    nx (N), ny (N or scalar) - horizontal refractive index (=k/k0);
%       if ny is scalar, it is automatically extended to the same length as
%       nx
%    ksa (Ms) - number of layers with source currents
%    I (6 x Ms x N) - surface electric and magnetic currents for
%       fixed (nx,ny), in V/m (see note 2).
%    kia (Mi), dz{l|h} (Mi) - output layers and distances from the
%       output altitudes to lower|upper} boundary of the containing layer.
%       This is an output of FWM_GET_LAYERS. dz{l|h} are also
%       dimensionless (multiplied by k0=w/c). Default: only ground zd(1)
%       and satellite zd(M).
% Outputs:
%    EHf (6 x Mi x N) - the E, H field at output altitudes (Fourier
%       components for each (nx,ny)).
% Notes (IMPORTANT!):
% 1. We use "physics" convention for complex values E,H~exp(-i*w*t)
% 2. Magnetic field H in EH is given in V/m [Budden, 1985], so that
%    H_SI=H/impedance0, where impedance0=sqrt(mu0/eps0) is the impedance
%    of free space. The currents also are in the same units, i.e. electric
%    currents are Ie=impedance0*Ie_SI and magnetic currents Im=Im_SI.
% 3. At h(1)==0, there must be vacuum, perm(:,:,1)==eye(3), for correct
%    application of the boundary condition at h==0.
% See also: FWM_BOOKER, FWM_RADIATION, FWM_DEH, FWM_GET_LAYERS,
%    FWM_INTERMEDIATE
% Author: Nikolai G. Lehtinen

M=length(zd);
global output_interval
if isempty(output_interval)
    output_interval=20;
end
Ms=length(ksa); N=length(nx);
if length(ny)==1
    ny=ny*ones(size(nx));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Full-Wave Model starts here and consists of 4 parts
% In wavenumber space, instead of iterating over nx and ny separately,
% i.e., ix=1:Nx and iy=1:Ny, we iterate over all modes, kt=1:Ntot

% 1. Sources (Delta E, Delta H) in Fourier space
% This step is fast, no loading is necessary
%disp('1. Sources (Delta E, Delta H) in Fourier space');
% Only on the positive nx axis

[is3a,is3b,isM]=size(perm);
if is3a~=3 | is3b~=3 | isM~=M
	error('incorrect size of perm')
end
eiz=permute(perm(:,3,ksa),[1 3 2]);
% I must be (6 x Ms x N)
DEHf=fwm_deh(I,eiz,nx,ny);
% DEHf now has the size 4 x Ms x N

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Refractive index and mode structure in each layer
% Calculate nz and Fext for phi==0 only
nz=zeros(4,M,N); Fext=zeros(6,4,M,N);
tstart=now*24*3600; toutput=tstart; first_output=1;
for k=1:M
    [nz(:,k,:),Fext(:,:,k,:)]=fwm_booker(perm(:,:,k),nx,ny);
    timec=now*24*3600; ttot=timec-tstart;
    if timec-toutput>output_interval
        toutput=timec;
        if first_output
            disp('FWM_FIELD: 2. Refractive index and mode structure in each layer');
            first_output=0;
        end
        disp(['FWM_FIELD: Done=' num2str(k/M*100) '%; Time=' ...
            hms(ttot) ', ETA=' hms(ttot/k*(M-k))]);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. FWM solved for given DEH
Rground=fwm_Rground(eground,nx,ny);
ul=zeros(2,M,N); dh=zeros(2,M-1,N);
tstart=now*24*3600; toutput=tstart; first_output=1;
for ip=1:N
    [ul(:,:,ip),dh(:,:,ip)]=fwm_radiation(zd,nz(:,:,ip),...
        Fext([1:2 4:5],:,:,ip),Rground(:,:,ip),ksa,DEHf(:,:,ip));
    timec=now*24*3600; ttot=timec-tstart;
    if timec-toutput>output_interval
        toutput=timec;
        if first_output
            disp('FWM_FIELD: 3. FWM solved for given DEH');
            first_output=0;
        end
        disp(['FWM_FIELD: Done=' num2str(ip/N*100) '%; Time=' ...
            hms(ttot) ', ETA=' hms(ttot/ip*(N-ip))]);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Find the waves and fields at intermediate points
% This step is fast
% Output altitudes
if nargin<8
    % We only have 2 points:
    % z=z(1)=0, layer 1, so dz_low=0, dz_high=z(2),
    % and z=z(M), layer M, so dz_low=0, dz_high=nan.
    kia=[1 M]; dzl=[0 0]; dzh=[zd(2) nan];
end
Mi=length(kia);
ud=fwm_intermediate(nz,ul,dh,kia,dzl,dzh);
% For a correction to the vertical field due to vertical currents
dzdi=[1./diff(zd(:));0];
Izk=zeros(2,M,N);
for k=1:M
    Izk(:,k,:)=sum(I([3 6],find(ksa==k),:),2);
end
EHf=zeros(6,Mi,N);
tstart=now*24*3600; toutput=tstart; first_output=1;
for ip=1:N
    for ki=1:Mi
        k=kia(ki);
%         EHf(:,ki,ip)=Fext(:,:,k,ip)*ud(:,ki,ip);
        A=Fext(:,:,k,ip)*ud(:,ki,ip);
		A(3) = A(3)+Izk(1,k,ip)*dzdi(k)/(i*perm(3,3,k));
		A(6) = A(6)+Izk(2,k,ip)*dzdi(k)/i;
        % Correction to the vertical field due to sources
%         EHf(3,ki,ip)=EHf(3,ki,ip)+Izk(1,k,ip)*dzdi(k)/(i*perm(3,3,k));
%         EHf(6,ki,ip)=EHf(6,ki,ip)+Izk(2,k,ip)*dzdi(k)/i;
        if isnan(A(3)) | isnan(A(6))
%             dzdi(k)
%             perm(3,3,k)
%             tmp
%             Izk
            error('isnan EHf3');
		end
		EHf(:,ki,ip) = A;
    end
    timec=now*24*3600; ttot=timec-tstart;
    if timec-toutput>output_interval
        toutput=timec;
        if first_output
            disp('FWM_FIELD: 4. Find the waves and fields at intermediate points');
            first_output=0;
        end
        disp(['FWM_FIELD: Done=' num2str(ip/N*100) '%; Time=' ...
            hms(ttot) ', ETA=' hms(ttot/ip*(N-ip))]);
    end
end

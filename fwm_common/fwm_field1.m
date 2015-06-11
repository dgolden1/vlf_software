function EHf=fwm_field(zd,eground,perm,nx,ny,ksa,I,kia,dzl,dzh)
% FWM_FIELD Calculate E, H for given (nx,ny) and currents
% Usage:
%    EHf=impedance0*fwm_field(...
%        zd,eground,perm,nx,ny,ksa,I,kia,dzl,dzh);
% Inputs:
%    zd (M) - dimensionless altitudes (z*k0, k0=w/c)
%    eground - ground permittivity (scalar) or boundary condition (string),
%       chosen from 'E=0','H=0' or 'free'
%    perm (3 x 3 x M) - dielectric permittivity tensor in each layer
%    nx (N), ny (N or scalar) - horizontal refractive index (=k/k0)
%       If ny is scalar, it is automatically extended to the same length as
%       nx
%    ksa (Ms) - number of layers with source currents
%    I (3 x Ms x N or 3 x Ms) - surface currents (Fourier components for
%       each (nx,ny)), in A/m. If the last dimension is 1, it will be
%       extended to N (this is for point sources)
%    kia (Mi), dz{l|h} (Mi) - output layers and distances from the
%       output altitudes to lower|upper} boundary of the containing layer.
%       This is an output of FWM_GET_LAYERS. dz{l|h} are also
%       dimensionless (multiplied by k0=w/c). Default: only ground zd(1)
%       and satellite zd(M).
% Outputs:
%    EHf (6 x N x Mi) - the E, H field at output altitudes (Fourier
%       components for each (nx,ny)).
% Notes:
%    1. ~exp(-i*w*t) (physics convention)
%    2. Both E, H are in V/m [Budden].
%    3. Multiplication by impedance0 is necessary to convert the current to
%       the field
% See also: FWM_BOOKER, FWM_RADIATION, FWM_DEH, FWM_GET_LAYERS,
%    FWM_INTERMEDIATE
% Author: Nikolai G. Lehtinen

M=length(zd);
global output_interval
if isempty(output_interval)
    output_interval=20;
end
Ms=length(ksa); Nnp=length(nx);
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

eiz=permute(perm(:,3,ksa),[1 3 2]);
%if size(I,3)==1
    % constant in (nx,ny) <=> a delta function in (x,y)
    % This, BTW, means that I passed to this function is the current moment
    % (in A*m)
    % This probably only makes sense for Iz
%    I=repmat(I,[1 1 Nnp]);
%end
% I must be is (3 x Ms x Nnp)
DEHf=fwm_deh(I,eiz,nx,ny);
% DEHf now has the size 4 x Ms x Nnp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Refractive index and mode structure in each layer
% Calculate nz and Fext for phi==0 only
nz=zeros(4,M,Nnp); Fext=zeros(6,4,M,Nnp);
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
ul=zeros(2,M,Nnp); dh=zeros(2,M-1,Nnp);
tstart=now*24*3600; toutput=tstart; first_output=1;
for ip=1:Nnp
    [ul(:,:,ip),dh(:,:,ip)]=fwm_radiation(zd,nz(:,:,ip),...
        Fext([1:2 4:5],:,:,ip),Rground(:,:,ip),ksa,DEHf(:,:,ip));
    timec=now*24*3600; ttot=timec-tstart;
    if timec-toutput>output_interval
        toutput=timec;
        if first_output
            disp('FWM_FIELD: 3. FWM solved for given DEH');
            first_output=0;
        end
        disp(['FWM_FIELD: Done=' num2str(ip/Nnp*100) '%; Time=' ...
            hms(ttot) ', ETA=' hms(ttot/ip*(Nnp-ip))]);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Find the waves and fields at intermediate points
% This step is fast
% Output altitudes
if nargin<10
    % We only have 2 points:
    % z=z(1)=0, layer 1, so dz_low=0, dz_high=z(2),
    % and z=z(M), layer M, so dz_low=0, dz_high=nan.
    kia=[1 M]; dzl=[0 0]; dzh=[zd(2) nan];
end
Mi=length(kia);
ud=fwm_intermediate(nz,ul,dh,kia,dzl,dzh);
EHf=zeros(6,Nnp,Mi);
tstart=now*24*3600; toutput=tstart; first_output=1;
for ip=1:Nnp
    for izi=1:Mi
        EHf(:,ip,izi)=Fext(:,:,kia(izi),ip)*ud(:,izi,ip);
    end
    timec=now*24*3600; ttot=timec-tstart;
    if timec-toutput>output_interval
        toutput=timec;
        if first_output
            disp('FWM_FIELD: 4. Find the waves and fields at intermediate points');
            first_output=0;
        end
        disp(['FWM_FIELD: Done=' num2str(ip/Nnp*100) '%; Time=' ...
            hms(ttot) ', ETA=' hms(ttot/ip*(Nnp-ip))]);
    end
end

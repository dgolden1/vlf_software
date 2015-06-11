function EHf=fwm_antenna_field(zd,eground,perm,nx,ny,Mi)
% FWM_ANTENNA_FIELD Ground-based transmitter with unit current
% Calculate E, H in Fourier space at zmax and zmin
% This is same as FWM_ANTENNA_TRANSMITTER, but with unnecessary arguments
% removed.
% Usage:
%    EHf=Iscaled*impedance0*fwm_antenna_field(zd,eground,perm,nx,ny,Mi);
% Author: Nikolai G. Lehtinen

if nargin<6
    % Only satellite
    Mi=1;
    % If Mi==2, it means do also ground
end
slayers=[1];
M=length(zd);
output_interval=20;
Ms=length(slayers); Nnp=length(nx);
if length(ny)==1
    ny=ny*ones(size(nx));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Full-Wave Model starts here and consists of 4 parts
% In wavenumber space, instead of iterating over nx and ny separately,
% i.e., ix=1:Nx and iy=1:Ny, we iterate over all modes, kt=1:Ntot

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Sources (Delta E, Delta H) in Fourier space
% This step is fast, no loading is necessary
%disp('1. Sources (Delta E, Delta H) in Fourier space');
% Only on the positive nx axis

eiz=permute(perm(:,3,slayers),[1 3 2]);
% I must be is (3 x Ms x Nnp)
I=repmat([0;0;1],[1 Ms Nnp]);
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
            disp('FWM_TRANSMITTER: 2. Refractive index and mode structure in each layer');
            first_output=0;
        end
        disp(['FWM_TRANSMITTER: Done=' num2str(k/M*100) '%; Time=' ...
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
        Fext([1:2 4:5],:,:,ip),Rground(:,:,ip),slayers,DEHf(:,:,ip));
    timec=now*24*3600; ttot=timec-tstart;
    if timec-toutput>output_interval
        toutput=timec;
        if first_output
            disp('FWM_TRANSMITTER: 3. FWM solved for given DEH');
            first_output=0;
        end
        disp(['FWM_TRANSMITTER: Done=' num2str(ip/Nnp*100) '%; Time=' ...
            hms(ttot) ', ETA=' hms(ttot/ip*(Nnp-ip))]);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Find the waves and fields at intermediate points
% We only have 2 points:
% z=z(1)=0, layer 1, so dz_low=0, dz_high=z(2),
% and z=z(M), layer M, so dz_low=0, dz_high=nan.
% This step is fast
if Mi==1
    ilayers=[M]; dzl=[0]; dzh=[nan];
elseif Mi==2
    ilayers=[1 M]; dzl=[0 0]; dzh=[zd(2) nan];
end
ud=fwm_intermediate(nz,ul,dh,ilayers,dzl,dzh);
EHf=zeros(6,Nnp,Mi);
tstart=now*24*3600; toutput=tstart; first_output=1;
for ip=1:Nnp
    % Field at the intermediate points
    for izi=1:Mi
        EHf(:,ip,izi)=Fext(:,:,ilayers(izi),ip)*ud(:,ilayers(izi),ip);
    end
    timec=now*24*3600; ttot=timec-tstart;
    if timec-toutput>output_interval
        toutput=timec;
        if first_output
            disp('FWM_TRANSMITTER: 4. Find the waves and fields at intermediate points');
            first_output=0;
        end
        disp(['FWM_TRANSMITTER: Done=' num2str(ip/Nnp*100) '%; Time=' ...
            hms(ttot) ', ETA=' hms(ttot/ip*(Nnp-ip))]);
    end
end
if 0
% I don't like this part:
if Mi>1
    if ischar(eground) & strcmp(eground,'E=0')
        % Variables that are zero, except for some delta functions
        % Ex=nx (gives delta function derivative), Ey=0, Hz=0.
        EHf(1,:,2)=0;
        EHf(2,:,2)=0;
        EHf(6,:,2)=0;
    end
end
end

function EHk=fwm_antenna_transmitter(...
    do_vacuum,zdim,perm,isotropic,nx,ny,zero_collisions,ground_bc,Mi)
% FWM_ANTENNA_TRANSMITTER Ground-based transmitter with unit current
% Calculate E, H in Fourier space at zmax and zmin
% Usage:
%    EHf=Iscaled*impedance0*fwm_antenna_transmitter(...
%      do_vacuum,zdim,perm,isotropic,nx,ny,zero_collisions,ground_bc,Mi);
% Author: Nikolai G. Lehtinen

if nargin<9
    % Only satellite
    Mi=1;
    % If Mi==2, it means do also ground
end
if nargin<8
    ground_bc='E=0';
end
if nargin<7
    zero_collisions=0;
end
szindex=[1];
M=length(zdim);
output_interval=20;
Ms=length(szindex); Nnp=length(nx);
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

DEHf=fwm_deh(repmat([0;0;1],[1 Ms Nnp]),...
    permute(perm(:,3,szindex),[1 3 2]),nx,ny);
% DEHf now has the size 4 x Ms x Ntot or 4 x Ms x Nnp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Refractive index and mode structure in each layer
% Calculate nz and Fext for phi==0 only
nz=zeros(4,M,Nnp); Fext=zeros(6,4,M,Nnp);
tstart=now*24*3600; toutput=tstart; first_output=1;
for k=1:M
    [nz(:,k,:),Fext(:,:,k,:)]=fwm_booker(perm(:,:,k),nx,ny);
    timec=now*24*3600; ttot=timec-tstart;
    if timec-toutput>output_interval
        do_output=1;
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
ul=zeros(2,M,Nnp); dh=zeros(2,M-1,Nnp);
tstart=now*24*3600; toutput=tstart; first_output=1;
for ip=1:Nnp
    if ischar(ground_bc)
        [ul(:,:,ip),dh(:,:,ip)]=fwm_radiation(zdim,nz(:,:,ip),...
            Fext([1:2 4:5],:,:,ip),ground_bc,szindex,DEHf(:,:,ip));
    else
        [ul(:,:,ip),dh(:,:,ip)]=fwm_radiation(zdim,nz(:,:,ip),...
            Fext([1:2 4:5],:,:,ip),ground_bc(:,:,ip),szindex,DEHf(:,:,ip));
    end
    timec=now*24*3600; ttot=timec-tstart;
    if timec-toutput>output_interval
        do_output=1;
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
ud=fwm_intermediate(nz,ul,dh,[1 M],[0 0],[zdim(2) nan]);
EHk=zeros(6,Nnp,Mi);
tstart=now*24*3600; toutput=tstart; first_output=1;
for ip=1:Nnp
    % Field at the upper boundary (layer M):
    if do_vacuum
        EHk(:,ip,1)=Fext(:,:,M,ip)*ud(:,2,ip);
    else
        % Only whistler mode
        EHk(:,ip,1)=Fext(:,:,M,ip)*[0;ud(2,2,ip);0;0];
    end
    if Mi>1
        % Field on the ground
        EHk(:,ip,2)=Fext(:,:,1,ip)*ud(:,1,ip);
    end
    timec=now*24*3600; ttot=timec-tstart;
    if timec-toutput>output_interval
        do_output=1;
        toutput=timec;
        if first_output
            disp('FWM_TRANSMITTER: 4. Find the waves and fields at intermediate points');
            first_output=0;
        end
        disp(['FWM_TRANSMITTER: Done=' num2str(ip/Nnp*100) '%; Time=' ...
            hms(ttot) ', ETA=' hms(ttot/ip*(Nnp-ip))]);
    end
end
if Mi>1
    if ischar(ground_bc) & strcmp(ground_bc,'E=0')
        % Variables that are zero, except for some delta functions
        % Ex=nx (gives delta function derivative), Ey=0, Hz=0.
        EHk(1,:,2)=0;
        EHk(2,:,2)=0;
        EHk(6,:,2)=0;
    end
end

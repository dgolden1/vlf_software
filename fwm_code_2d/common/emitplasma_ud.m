function [Dud,ud,EHf,timec]=emitplasma_ud(varargin)
%EMITPLASMA_UD Find the wave amplitudes and fields in Fourier domain

[DEHf,sindex,Fext,R1,R2,A,B,options]=parsearguments(varargin,7,{'debug'});
debugflag=getvaluefromdict(options,'debug',0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the up and down waves from sources below and above, respectively,
% i.e. us and ds, on the basis of uplus and dminus
[dummy1,dummy2,Nx,Ny,M]=size(Fext);
Ms=length(sindex);
Dud=zeros(4,Nx,Ny,Ms);
EHf=zeros(Nx,Ny,M,6); % WARNING: switched dimensions compared to 2D case!
ud=zeros(4,Nx,Ny,M);
% Temporary variables
uplus=zeros(2,M); dminus=zeros(2,M);
us=zeros(2,M); ds=zeros(2,M);
tstart=now*24*3600;
for ix=1:Nx
    for iy=1:Ny
        % Find the up and down waves due to sources in immediate vicinity
        % of the sources, i.e. uplus and dminus
        %uplus(:,:)=0; dminus(:,:)=0;
        for nhs=1:Ms
            k=sindex(nhs);
            % Delta u, Delta d
            Dudtmp=Fext([1:2 4:5],:,ix,iy,k)\DEHf(:,ix,iy,nhs);
            Dud(:,ix,iy,nhs)=Dudtmp;
            r1=R1(:,:,k,ix,iy); r2=R2(:,:,k,ix,iy);
            i12=inv(eye(2)-r1*r2);
            tmp=i12*(Dudtmp(1:2)-r1*Dudtmp(3:4));
            uplus(:,k)=tmp;
            dminus(:,k)=r2*tmp-Dudtmp(3:4);
        end
        % Propagate up: find "us", up-wave due only to sources below (no
        % reflected waves coming from sources above)
        us(:,1)=uplus(:,1);
        for k=1:M-1
            us(:,k+1)=uplus(:,k+1)+A(:,:,k,ix,iy)*us(:,k);
        end
        % Propagate down: find "ds", down-wave due only to sources above
        % (no reflected waves coming from sources below). Note that these
        % are calculated just above the plane of the source.
        % ds(:,M)==0 because there are no sources at h>h(M)
        for k=M-1:-1:1
            ds(:,k)=B(:,:,k,ix,iy)*(ds(:,k+1)+dminus(:,k+1));
        end
        % Now, add up and down waves from all sources (not just in
        % direction of propagation) and find fields
        for k=1:M
            % The mode amplitudes
            ud(1:2,ix,iy,k)=us(:,k)+R1(:,:,k,ix,iy)*ds(:,k);
            ud(3:4,ix,iy,k)=ds(:,k)+R2(:,:,k,ix,iy)*us(:,k);
            % Fourier components of the fields
            EHf(ix,iy,k,:)=Fext(:,:,ix,iy,k)*ud(:,ix,iy,k);
        end
    end
    timec=now*24*3600-tstart;
    if debugflag>-1
        disp(['Done=' num2str(ix/Nx*100) '%, ETA=' hms(timec/ix*(Nx-ix))]);
    end
end
if debugflag>-1
    disp(['Time=' hms(timec)])
end


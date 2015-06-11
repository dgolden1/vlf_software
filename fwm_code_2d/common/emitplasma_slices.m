function [EHx,EHy,timec]=emitplasma_slices(varargin)
%EMITPLASMA_SLICES Additional calculations for EMITPLASMA
% For given vertical planes, calculate the fields in these planes, with a
% higher resolution than EMITPLASMA
% Implementation:
%  Use calculated ud, udprime to interpolate waves between boundaries
% Usage:
%  [EHx,EHy]=emitplasma_slices(...
%               zdim,nz,Fext,ud,udprime,zdimi[,xindex,zindex])
% See also: EMITPLASMA

[zdim,nz,Fext,ud,udprime,zdimi,xindex,yindex,options]=...
    parsearguments(varargin,6,{'debug'});
[dummy,Nx,Ny,M]=size(nz);
Mi=length(zdimi);
if isempty(xindex)
    xindex=[Nx/2]; % only x==0
end
if isempty(yindex)
    yindex=[Ny/2]; % only y==0
end
Nxi=length(xindex);
Nyi=length(yindex);
debugflag=getvaluefromdict(options,'debug',0);

% For Fourier transforms: useful indeces for shifting.
% This is assuming that the coordinates are
%  x=[1-Nx/2:Nx/2]*dx;
%  y=[1-Ny/2:Ny/2]*dy;
% and refracrive indeces are
%  nx=2*pi*[1-Nx/2:Nx/2]*(1/(dx*k0*Nx));
%  ny=2*pi*[1-Ny/2:Ny/2]*(1/(dy*k0*Ny));
indx=[Nx/2:Nx 1:Nx/2-1];
indy=[Ny/2:Ny 1:Ny/2-1];

% The fields at the vertical planes
EHx=zeros(Mi,Ny,6,Nxi);
EHy=zeros(Mi,Nx,6,Nyi);
% Temporary variables
EHfzi=zeros(Nx,Ny,6);
EHzi=zeros(Nx,Ny,6);
udzi=zeros(4,Nx,Ny);
tstart=now*24*3600;
for ki=1:Mi
    k=max(find(zdim<=zdimi(ki))); % Which layer are we in?
    dzdimd=zdimi(ki)-zdim(k); % Distance to the boundary below
    if dzdimd==0
        % Simple case -- the new refined mesh coincides with old mesh
        udzi=ud(:,:,:,k);
    else
        % This excludes the case of k==M, so k+1 is still valid
        dzdimu=zdim(k+1)-zdimi(ki); % Distance to the boundary above
        % Use the matrix capabilities of MATLAB.
        % Avoid instability: upward wave -- from below
        udzi(1:2,:,:)=exp(i*dzdimd*nz(1:2,:,:,k)).*ud(1:2,:,:,k);
        % Downward wave -- from above
        udzi(3:4,:,:)=exp(-i*dzdimu*nz(3:4,:,:,k)).*udprime(3:4,:,:,k);
    end
    % Convert udzi to field EHfzi:
    for ix=1:Nx
        for iy=1:Ny
            EHfzi(ix,iy,:)=Fext(:,:,ix,iy,k)*udzi(:,ix,iy);
        end
    end
    % Fourier transform -- take it right away, to save the memory.
    EHzi(indx,:,:)=ifft(EHfzi(indx,:,:),[],1); % Temporary
    EHzi(:,indy,:)=ifft(EHzi(:,indy,:),[],2);
    % Store the slices at needed x and y coordinates
    for ixi=1:Nxi
        EHx(ki,:,:,ixi)=permute(EHzi(xindex(ixi),:,:),[1 2 3]);
    end
    for iyi=1:Nyi
        EHy(ki,:,:,iyi)=permute(EHzi(:,yindex(iyi),:),[2 1 3]);
    end
    timec=now*24*3600-tstart;
    if debugflag>-1
        disp(['Done: ' num2str(ki/Mi*100) '%, ETA=' hms(timec/ki*(Mi-ki))])
    end
end
if debugflag>-1
    disp(['Time=' hms(timec)])
end

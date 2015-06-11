function [nz,Fext,timec]=emitplasma_modes(varargin)
%EMITPLASMA_MODES Pre-calculate nz and modes as a function of nx, ny
% Usage:
%  [nz,Fext]=emitplasma_modes(perm,nx,ny,isvacuum)
[perm,nx,ny,isvacuum,options]=parsearguments(varargin,4,{'debug'});
debugflag=getvaluefromdict(options,'debug',0);
Nx=length(nx);
Ny=length(ny);
M=length(isvacuum);
nz=zeros(4,Nx,Ny,M); Fext=zeros(6,4,Nx,Ny,M);
tstart=now*24*3600;
for k=1:M
    [nz(:,:,:,k),Fext(:,:,:,:,k)]=solve_booker_3d(perm(:,:,k),nx,ny,isvacuum(k));
    timec=now*24*3600-tstart;
    if debugflag>-1
        disp(['Done=' num2str(k/M*100) '%, ETA=' hms(timec/k*(M-k))]);
    end
end
if debugflag>-1
    disp(['Time=' hms(timec)])
end

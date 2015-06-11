function [R1,R2,A,B,timec]=emitplasma_reflect(varargin)
%EMITPLASMA_REFLECT Pre-calculate reflection coefs and mode structure
% Usage:
%  [Rd,Ru,U,D]=emitplasma_reflect(zdim,nz,Fext);

[zdim,nz,Fext,options]=parsearguments(varargin,3,{'debug','ground_bc'});
debugflag=getvaluefromdict(options,'debug',0);
ground_bc=getvaluefromdict(options,'ground_bc','E=0');
[dummy,Nx,Ny,M]=size(nz);
R1=zeros(2,2,M,Nx,Ny); R2=zeros(2,2,M,Nx,Ny);
A=zeros(2,2,M-1,Nx,Ny); B=zeros(2,2,M-1,Nx,Ny);
tstart=now*24*3600;
for ix=1:Nx
    for iy=1:Ny
        % Save some memory
        nztmp=permute(nz(:,ix,iy,:),[1 4 2 3]);
        Ftmp=permute(Fext([1:2 4:5],:,ix,iy,:),[1 2 5 3 4]);
        [R1(:,:,:,ix,iy),R2(:,:,:,ix,iy),A(:,:,:,ix,iy),B(:,:,:,ix,iy)]=...
            reflectplasma(zdim,nztmp,Ftmp,'ground_bc',ground_bc);
    end
    timec=now*24*3600-tstart;
    if debugflag>-1
        disp(['Done=' num2str(ix/Nx*100) '%, ETA=' hms(timec/ix*(Nx-ix))]);
    end
end
if debugflag>-1
    disp(['Time=' hms(timec)])
end

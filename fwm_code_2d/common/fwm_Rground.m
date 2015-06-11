function Rground=fwm_Rground(eground,nx,ny,nxy_are_arrays)
%FWM_RGROUND Ground reflection coefficient matrix
% Usage:
%    eground=1+i*sground/(w*eps0);
%    Rground=fwm_Rground(eground,nx,ny);
% to get 2 x 2 x Nx x Ny array Rground, or
%    Rground=fwm_Rground(eground,nx,ny,1);
% if nx, ny are of the same length (Np) to get 2 x 2 x Np array Rground.
% NOTES:
%    1. Since TE and TM modes separate, Rground(:,:,ip) is diagonal 2 x 2
%    2. eground can be Inf -- then Rground has -1 on diagonals
% Author: Nikolai G. Lehtinen
if nargin<5
    nxy_are_arrays=0;
end
% Handle special cases
if ischar(eground) | eground==1 | isinf(eground)
    Nx=length(nx);
    Ny=length(ny);
    if nxy_are_arrays
        if Nx~=Ny
            error('Nx~=Ny');
        end
        N=Nx;
    else
        N=Nx*Ny;
    end
    Rground=zeros(2,2,N);
    if (ischar(eground) & strcmp(eground,'E=0')) | isinf(eground)
        % Electric field does not penetrate
        Rground(1,1,:)=-1;
        Rground(2,2,:)=-1;
    elseif ischar(eground) & strcmp(eground,'H=0')
        Rground(1,1,:)=1;
        Rground(2,2,:)=1;
    elseif (ischar(eground) & strcmp(eground,'free')) | eground==1
        % stays zero
    else
        error('internal error')
    end
    if ~nxy_are_arrays
        Rground=reshape(Rground,[2 2 Nx Ny]);
    end
    return
end
[nz,Fext]=solve_booker_3d(eye(3)*eground,nx,ny,1,nxy_are_arrays);
[nz0,Fext0]=solve_booker_3d(eye(3),nx,ny,1,nxy_are_arrays);
[dummy,Nx,Ny]=size(nz);
Rground=zeros(2,2,Nx,Ny);
for ix=1:Nx
    for iy=1:Ny
        Tu=Fext0([1:2 4:5],:,ix,iy)\Fext([1:2 4:5],:,ix,iy);
        Rground(:,:,ix,iy)=Tu(1:2,3:4)/Tu(3:4,3:4);
    end
end

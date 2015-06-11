function Rground=fwm_Rground(eground,nx,ny)
%FWM_RGROUND Ground reflection coefficient matrix
% Usage:
%    eground=1+i*sground/(w*eps0);
%    Rground=fwm_Rground(eground,nx,ny);
% where nx, ny are of the same length (Np) to get 2 x 2 x Np array Rground.
% NOTES:
%    1. Since TE and TM modes separate, Rground(:,:,ip) is diagonal 2 x 2
%    2. eground can be Inf -- then Rground has -1 on diagonals
%    3. Special boundary conditions 'E=0','H=0' and 'free' are allowed.
%    4. We assume vacuum right above ground (perm===eye(3)).
% Author: Nikolai G. Lehtinen

if length(ny)==1
    ny=ny*ones(size(nx));
end
N=length(nx);
if length(ny)~=N
    error('Nx~=Ny');
end
% Handle special cases
if ischar(eground) | eground==1 | isinf(eground)
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
    return
end
[nz,Fext]=fwm_booker(eye(3)*eground,nx,ny);
[nz0,Fext0]=fwm_booker(eye(3),nx,ny);
Rground=zeros(2,2,N);
for ip=1:N
    Tu=Fext0([1:2 4:5],:,ip)\Fext([1:2 4:5],:,ip);
    Rground(:,:,ip)=Tu(1:2,3:4)/Tu(3:4,3:4);
end

function [J,sxindex,syindex,szindex]=emitplasma_sources_interp(Jx0,Jy0,Jz0,x0,y0,z0,x,y,z)
%EMITPLASMA_SOURCES_INTERP Interpolate currents
% % Find the interpolation domain (non-zero currents)

sxindex=find(x>=x0(1) & x<=x0(end));
syindex=find(y>=y0(1) & y<=y0(end));
szindex=find(z>=z0(1) & z<=z0(end));
% Interpolation points
[xi,yi,zi]=ndgrid(x(sxindex),y(syindex),z(szindex));
% Interpolated currents
J=zeros([size(xi) 3]);
% Convert to Delta E, Delta H in our mesh
%for k=1:Ms
    if ~isempty(Jx0)
        J(:,:,:,1)=interp3(x0,y0,z0,Jx0,xi,yi,zi);
    end
    if ~isempty(Jy0)
        J(:,:,:,2)=interp3(x0,y0,z0,Jy0,xi,yi,zi);
    end
    if ~isempty(Jz0)
        J(:,:,:,3)=interp3(x0,y0,z0,Jz0,xi,yi,zi);
    end
%end


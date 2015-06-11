function p=solve3d(a,r,xper,yper,zper,aflags,dbg)
%function p=solve3d(a,r,xper,yper,zper,aflags,dbg)
% Created on the basis of "solve2d".
% Solve a system of difference equations on a 3d "brick" grid.
% The unknown is a 3d array p(nx,ny,nz).
% The matrix a(nx,ny,3,3) determines the coefficients:
%   \sum_{ix,iy,iz} \sum_{dix,diy,diz} 
%      a(ix,iy,iz,2+dix,2+diy,2+diz)*p(ix+dix,iy+diy,iz+diz)=r(ix,iy,iz)
% It is implicitly assumed that a(1,:,:,2-1,:,:)==0 etc, unless some of the
% flags "*per" are set. E.g., if xper is set, than we assume that
% p(0,:,:)==p(nx,:,:) and p(nx+1,:,:)==p(1,:,:).
% String "aflags" determines nonzero elements of
% a(ix,iy,iz,2+dix,2+diy,2+diz):
%  'cross', 'default', [] - no diagonal elements;
%  'all' -- all elements are present.
% If it is not a string, the array of flags aflags(3,3,3) means that there
% are nonzero elements a(ix,iy,iz,2+dix,2+diy,2+diz) iff
% aflags(2+dix,2+diy,2+diz)~=0.
% Implementation: create a sparse matrix of elements.

% "r" might be empty
tmp=size(a);
nx=tmp(1); ny=tmp(2); nz=tmp(3);
% Create array of flags anotzero(3,3,3)
if nargin<5
    aflags=[];
end
if nargin<6
    dbg=0;
end
if dbg>0
    % Timing for profiling
    tinit=now*24*3600;
end
if isempty(aflags)
    aflags='cross'; % the default value
end
tmp=size(aflags);
if length(tmp)==3 & all(size(aflags)==[3 3 3])
    anotzero=aflags;
else
    switch aflags
        case {'cross','default'}
            anotzero=zeros(3,3,3);
            anotzero(2,2,2)=1;
            anotzero(2,2,1:2:3)=1;
            anotzero(2,1:2:3,2)=1;
            anotzero(1:2:3,2,2)=1;
        case 'all'
            anotzero=ones(3,3,3);
        otherwise
            error(['Unknown flag ' aflags]);
    end
end
if dbg>1
    anotzero
end

% Fill the middle elements
% Only (2:nx-1,2:nz-1)
[ixm,iym,izm]=ndgrid(2:nx-1,2:ny-1,2:nz-1);
ix=ixm(:)'; iy=iym(:)'; iz=izm(:)';
ixyz=(iz-1)*ny*nx+(iy-1)*nx+ix;
indi=[]; indj=[]; laps=[];
for dix=-1:1
    for diy=-1:1
        for diz=-1:1
            if anotzero(2+dix,2+diy,2+diz)
                indja=(iz+diz-1)*ny*nx+(iy+diy-1)*nx+ix+dix;
                if any(indja<0)
                    error('indja<0');
                end
                indi=[indi ixyz]; indj=[indj indja];
                % Here we can rely on the fact that MATLAB stores
                % multidimensional arrays so that the first index changes
                % faster
                tmp=a(:,:,:,2+dix,2+diy,2+diz);
                laps=[laps tmp(ixyz)];
            end
        end
    end
end

% The boundary -- treat it separately, for acceleration
% The "faces", "edges" and "verteces" -- threat them together
% x-faces (include the edges around them)
ix=[]; iy=[]; iz=[];
[iytmp,iztmp]=ndgrid(1:ny,1:nz);
ix=[ix ones(1,ny*nz) nx*ones(1,ny*nz)];
iy=[iy iytmp(:)' iytmp(:)'];
iz=[iz iztmp(:)' iztmp(:)'];
% y-faces
[iztmp,ixtmp]=ndgrid(1:nz,2:nx-1);
ix=[ix ixtmp(:)' ixtmp(:)'];
iy=[iy ones(1,nz*(nx-2)) ny*ones(1,nz*(nx-2))];
iz=[iz iztmp(:)' iztmp(:)'];
% z-faces (no edges)
[ixtmp,iytmp]=ndgrid(2:nx-1,2:ny-1);
ix=[ix ixtmp(:)' ixtmp(:)'];
iy=[iy iytmp(:)' iytmp(:)'];
iz=[iz ones(1,(nx-2)*(ny-2)) nz*ones(1,(nx-2)*(ny-2))];

ixyz=(iz-1)*ny*nx+(iy-1)*nx+ix;

for dix=-1:1
    for diy=-1:1
        for diz=-1:1
            if anotzero(2+dix,2+diy,2+diz)
                % Find where the indeces are valid
                ixa=ix+dix; iya=iy+diy; iza=iz+diz;
                c=ones(1,length(ixyz));
                % Periodic boundary conditions
                if xper
                    i1=find(ixa==0); i2=find(ixa==nx+1);
                    ixa(i1)=nx;
                    ixa(i2)=1;
                else
                    c=(c & ixa>=1 & ixa<=nx);
                end
                if yper
                    i1=find(iya==0); i2=find(iya==ny+1);
                    iya(i1)=ny;
                    iya(i2)=1;
                else
                    c=(c & iya>=1 & iya<=ny);
                end
                if zper
                    i1=find(iza==0); i2=find(iza==nz+1);
                    iya(i1)=nz;
                    iya(i2)=1;
                else
                    c=(c & iza>=1 & iza<=nz);
                end
                ii=find(c);
                indja=(iza-1)*ny*nx+(iya-1)*nx+ixa;
                if any(indja(ii)<0)
                    error('indja<0');
                end
                indi=[indi ixyz(ii)]; indj=[indj indja(ii)];
                tmp=a(:,:,:,2+dix,2+diy,2+diz);
                laps=[laps tmp(ixyz(ii))];
            end
        end
    end
end

if dbg>0
    tfill=now*24*3600;
end
S=sparse(indi,indj,laps,nx*ny*nz,nx*ny*nz);
if dbg>0
    tcreate=now*24*3600;
end
if isempty(r)
    % Just return the matrix we created
    p=S;
else
    p=reshape(S\r(:),[nx ny nz]);
end
if dbg>0
    dispstring=['Fill ' num2str(tfill-tinit) ' s, sparse '...
        num2str(tcreate-tfill) ' s'];
    if ~isempty(r)
        tfinish=now*24*3600;
        dispstring=[dispstring ', inv ' num2str(tfinish-tcreate) ' s'];
    end
    disp(dispstring);
end

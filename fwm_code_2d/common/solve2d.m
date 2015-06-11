function p=solve2d(a,r,xper,yper,aflags,dbg)
%function p=solve2d(a,r,xper,yper,aflags,dbg)
% Solve a system of difference equations on a 2d square grid.
% The unknown is a 2d array p(nx,ny).
% The matrix a(nx,ny,3,3) determines the coefficients:
%   \sum_{dix,diy} a(ix,iy,2+dix,2+diy)*p(ix+dix,iy+diy)=r(ix,iy)
% It is implicitly assumed that a(1,:,2-1,:)==0 etc, unless some of the
% flags xper, yper are set. E.g., if xper is set, than we assume that
% p(0,:)==p(nx,:) and p(nx+1,:)==p(1,:).
% String "aflags" determines nonzero elements of a(ix,iy,2+dix,2+diy):
%  'cross', 'default', [] - no diagonal elements;
%  'all' -- all elements are present.
% If it is not a string, the array of flags aflags(3,3) means that there
% are nonzero elements a(ix,iy,2+dix,2+diy) iff aflags(2+dix,2+diy)~=0
% Implementation: create a sparse matrix of elements.

% "r" might be empty
tmp=size(a);
nx=tmp(1); ny=tmp(2);
% Create array of flags anotzero(3,3)
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
if all(size(aflags)==[3 3])
    anotzero=aflags;
else
    switch aflags
        case {'cross','default'}
            anotzero=[0 1 0 ; 1 1 1 ; 0 1 0];
        case 'all'
            anotzero=ones(3,3);
        otherwise
            error(['Unknown flag ' aflags]);
    end
end
if dbg>1
    anotzero
end

% Fill the middle elements
% Only (2:nx-1,2:nz-1)
[ixm,iym]=ndgrid(2:nx-1,2:ny-1);
ix=ixm(:)'; iy=iym(:)';
ixy=(iy-1)*nx+ix;
indi=[]; indj=[]; laps=[];
for dix=-1:1
    for diy=-1:1
        if anotzero(2+dix,2+diy)
            indja=(iy+diy-1)*nx+ix+dix;
            if any(indja<0)
                error('indja<0');
            end
            indi=[indi ixy]; indj=[indj indja];
            % Here we can rely on the fact that MATLAB stores
            % multidimensional arrays so that the first index changes
            % faster
            tmp=a(:,:,2+dix,2+diy);
            laps=[laps tmp(ixy)];
        end
    end
end

% The boundary -- treat it separately, for acceleration
ix=[1:nx 1:nx ones(1,ny-2) nx*ones(1,ny-2)];
iy=[ones(1,nx) ny*ones(1,nx) 2:ny-1 2:ny-1];
ixy=(iy-1)*nx+ix;
for dix=-1:1
    for diy=-1:1
        if anotzero(2+dix,2+diy)
            % Find where the indeces are valid
            ixa=ix+dix; iya=iy+diy;
            c=ones(1,length(ixy));
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
            ii=find(c);
            indja=(iya-1)*nx+ixa;
            if any(indja(ii)<0)
                error('indja<0');
            end
            indi=[indi ixy(ii)]; indj=[indj indja(ii)];
            tmp=a(:,:,2+dix,2+diy);
            laps=[laps tmp(ixy(ii))];
        end
    end
end

if dbg>0
    tfill=now*24*3600;
end
S=sparse(indi,indj,laps,nx*ny,nx*ny);
if dbg>0
    tcreate=now*24*3600;
end
if isempty(r)
    % Just return the matrix we created
    p=S;
else
    p=reshape(S\r(:),nx,ny);
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

function r=matmul3d(a,p,xper,yper,zper,dbg)
%r=matmul3d(a,xper,yper,p)
% Operation inverse to SOLVE3D
if nargin<6
    dbg=0;
end
[nx,ny,nz]=size(p);
r=zeros(nx,ny,nz);
if dbg>0
    % Timing for profiling
    tinit=now*24*3600;
end
for j=-1:1
    for k=-1:1
        for l=-1:1
            if xper
                ixa=[1:nx];
                ixp=mod(ixa-1+j,nx)+1;
            else
                ixa=[max(1,1-j):min(nx,nx-j)];
                ixp=ixa+j;
            end
            if yper
                iya=[1:ny];
                iyp=mod(iya-1+k,ny)+1;
            else
                iya=[max(1,1-k):min(ny,ny-k)];
                iyp=iya+k;
            end
            if zper
                iza=[1:nz];
                izp=mod(iza-1+l,nz)+1;
            else
                iza=[max(1,1-l):min(nz,nz-l)];
                izp=iza+l;
            end
            r(ixa,iya,iza)=r(ixa,iya,iza)+a(ixa,iya,iza,2+j,2+k,2+l).*p(ixp,iyp,izp);
        end
    end
end
if dbg>0
    tfinish=now*24*3600;
    disp(['MATMUL3D: ' num2str(tfinish-tinit) ' s']);
end

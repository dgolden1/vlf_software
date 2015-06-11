function r=matmul2d(a,p,xper,yper,dbg)
%r=matmul2d(a,xper,yper,p)
% Operation inverse to SOLVE2D
if nargin<5
    dbg=0;
end
[nx,ny]=size(p);
r=zeros(nx,ny);
if dbg>0
    % Timing for profiling
    tinit=now*24*3600;
end
for j=-1:1
    for k=-1:1
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
        r(ixa,iya)=r(ixa,iya)+a(ixa,iya,2+j,2+k).*p(ixp,iyp);
    end
end
if dbg>0
    tfinish=now*24*3600;
    disp(['MATMUL2D: ' num2str(tfinish-tinit) ' s']);
end

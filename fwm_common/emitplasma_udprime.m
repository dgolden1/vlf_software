function [udprime,timec]=emitplasma_udprime(varargin)
%EMITPLASMA_UDPRIME Calculate (u_{k+1}',d_{k+1}')
% Calculate (u_{k+1}',d_{k+1}') -- the wave variables just below boundary
% k+1 (still in layer k), needed later for slice calculations.
% Usage:
%  udprime=emitplasma_udprime(Fext,ud,Dud,sindex);
% Arguments:
% See also: EMITSTRAT

[Fext,ud,Dud,sindex,options]=parsearguments(varargin,4,{'debug'});
debugflag=getvaluefromdict(options,'debug',0);
% u and d below the sources
udbelow=ud;
udbelow(:,:,:,sindex)=udbelow(:,:,:,sindex)-Dud;
[dummy1,dummy2,Nx,Ny,M]=size(Fext);
udprime=zeros(4,Nx,Ny,M-1);
tstart=now*24*3600;
for k=1:M-1
    for ix=1:Nx
        for iy=1:Ny
            % NOTE: this is (u_{k+1}',d_{k+1}'), although index is k
            udprime(:,ix,iy,k)=...
                Fext([1:2 4:5],:,ix,iy,k)\Fext([1:2 4:5],:,ix,iy,k+1)*udbelow(:,ix,iy,k+1);
        end
    end
    timec=now*24*3600-tstart;
    if debugflag>-1
        disp(['Done=' num2str(k/(M-1)*100) '%, ETA=' hms(timec/k*(M-1-k))]);
    end
end
if debugflag>-1
    disp(['Time=' hms(timec)])
end

function [CTM,CTE,alfTM,alfTE]=modefinder(varargin)
%MODEFINDER Find all the modes WITHOUT using the TR 1143 algorithm
% Works much faster.
% Usage: [CTM,CTE,alfTM,alfTE]=modefinder(f,h,sigtot)
% Inputs:
%   f      - frequency (Hz)
%   h      - altitudes (km)
%   sigtot - conductivities at h (mho/m)
% Outputs:
%   CTM, CTE     = kz/k0 for TM and TE modes
%   alfTM, alfTE - attenuation in dB/Mm
% See also: REFLECTSTRAT, MODEFINDER_SLOW
% Author: Nikolai G. Lehtinen

global ech clight eps0 mu0
if isempty(ech)
    loadconstants
end

keys={'dC','Crmin','Crmax','Cimin','Cimax','debug','numpoints'};
[f,h,sig,options]=parsearguments(varargin,3,keys);
debugflag=getvaluefromdict(options,'debug',0);

w=f*2*pi;
k0=w/clight;
z=h*1e3*k0; % dimensionless
epsc=1+i*sig/(eps0*w);

dC=getvaluefromdict(options,'dC',[]);
if isempty(dC)
    % Estimate the number of modes = zreflect/pi
    zreflect=z(min(find(imag(epsc)>1)));
    if isempty(zreflect)
        zreflect=max(z);
    end
    nmodesest=ceil(zreflect/pi);
    if debugflag>0
        disp(['Estimated number of modes = 2*' num2str(nmodesest)]);
    end
    % The mesh step
    numpoints=getvaluefromdict(options,'numpoints',5);
    dC=1/nmodesest/numpoints;
    if debugflag>0
        disp(['Step in C = ' num2str(dC)]);
    end
end


%nr=ceil(1/dC+1);
%ni=ceil(nr);

Crmin=getvaluefromdict(options,'Crmin',[]);
if isempty(Crmin)
    Crmin=0.01*dC;
end
Crmax=getvaluefromdict(options,'Crmax',[]);
if isempty(Crmax)
    Crmax=1;
end
Cimin=getvaluefromdict(options,'Cimin',[]);
if isempty(Cimin)
    Cimin=-0.1;
end
Cimax=getvaluefromdict(options,'Cimax',[]);
if isempty(Cimax)
    Cimax=0;
end


C0re1=[Crmin:dC:Crmax]; % ([0:nr-1]+0.01)*dC;
C0im1=[Cimin:dC:Cimax]; % [-ni+1:0]*dC;
nr=length(C0re1);
ni=length(C0im1);

[C0re,C0im]=ndgrid(C0re1,C0im1);
[indr,indi]=ndgrid(1:nr,1:ni);
C0=C0re+i*C0im;

FTM=zeros(nr,ni);
FTE=zeros(nr,ni);
for kr=1:nr
    for ki=1:ni
        FTM(kr,ki)=Flwpc(C0(kr,ki),{z,'TM',epsc,1});
        %reflectstrat(z,C0(kr,ki),'TM',epsc)-1;
        FTE(kr,ki)=Flwpc(C0(kr,ki),{z,'TE',epsc,-1});
        %reflectstrat(z,C0(kr,ki),'TE',epsc)+1;
    end
end
%disp('filled')
if debugflag>1
    figure; subplot(2,1,1);
    imagesc(C0re1,C0im1,log10(abs(FTM.'))); set(gca,'ydir','normal'); axis equal
    title('log10(R-1), TM mode'); colorbar;
    subplot(2,1,2);
    imagesc(C0re1,C0im1,log10(abs(FTE.'))); set(gca,'ydir','normal'); axis equal
    title('log10(R+1), TE mode'); colorbar;
    %disp('Press enter to continue')
    %pause;
end

for imode=1:2
    if imode==1
        mode='TM'; R=1;
    else
        mode='TE'; R=-1;
    end
    eval(['FT=F' mode ';']);

    params={z,mode,epsc,R};
% Find boxes in which imag(FT) and real(FT) change sign
tmpi=1*(imag(FT)>0);
tmpr=1*(real(FT)>0);
ifound=find(([diff(tmpi,[],1);zeros(1,ni)]~=0 | [diff(tmpi,[],2) zeros(nr,1)]~=0) ...
    & ([diff(tmpr,[],1);zeros(1,ni)]~=0 | [diff(tmpr,[],2) zeros(nr,1)]~=0) ...
    & indr<nr & indi<ni);
i1=indr(ifound);
i2=indi(ifound);
found=zeros(nr,ni);
found(ifound)=1;

nfound=length(ifound);
C0sol=zeros(1,nfound);
for k=1:nfound
    k;
    x1=C0(i1(k),i2(k));
    F1=Flwpc(x1,params); %reflectstrat(z,x1,mode,epsc)-R;
    x2=0.5*(C0(i1(k),i2(k))+C0(i1(k)+1,i2(k)+1));
    % Newton-Raphson method
    F2=Flwpc(x2,params); %reflectstrat(z,x2,mode,epsc)-R;
    while 1
        dx=-F2*(x2-x1)./(F2-F1);
        x1=x2;
        x2=x2+dx;
        F1=F2;
        F2=Flwpc(x2,params); %reflectstrat(z,x2,mode,epsc)-R;
        %F2=x2^2-2
        if abs(F2)<1e-6
            break
        end
        %pause
    end
    C0sol(k)=x2;
end

% Discard the same solutions
duplic=zeros(size(C0sol));
k=0;
while k<nfound
    k=k+1;
    if duplic(k)
        continue
    end
    ii=find(abs(C0sol-C0sol(k))<dC);
    if length(ii)>=2
        duplic(ii(2:end))=1;
    end
end
tmp=C0sol(find(~duplic));
[y,ii]=sort(real(tmp));
eval(['C' mode '=tmp(ii);']);

end % cycle over modes

% In dB/Mm
alfTM=20*k0*imag(sqrt(1-CTM.^2))/log(10)*1e6;
alfTE=20*k0*imag(sqrt(1-CTE.^2))/log(10)*1e6;

function res=Flwpc(C0,params)
zdim=params{1}; mode=params{2}; epsc=params{3}; R=params{4};
res=reflectstrat_Z(zdim,C0,mode,epsc)-R;

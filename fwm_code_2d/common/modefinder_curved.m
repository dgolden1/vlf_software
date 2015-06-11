function [CTM,CTE,alfTM,alfTE]=modefinder_curved(f,h,sigtot)
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

w=f*2*pi;
k0=w/clight;
z=h*1e3*k0; % dimensionless
epsc=1+i*sigtot/(eps0*w);
RE=6.378137e+06*k0

% Estimate the number of modes = max(z)/pi
nmodesest=ceil(max(z)/pi);

% The mesh step
dC=1/nmodesest/5;

nr=ceil(1/dC+1);
ni=ceil(nr/10);

C0re1=([0:nr-1]+0.1)*dC;
C0im1=[-ni+1:0]*dC;
[C0re,C0im]=ndgrid(C0re1,C0im1);
[indr,indi]=ndgrid(1:nr,1:ni);
C0=C0re+i*C0im;

FTM=zeros(nr,ni);
FTE=zeros(nr,ni);
for kr=1:nr
    for ki=1:ni
        FTM(kr,ki)=Flwpc(C0(kr,ki),{RE,z,'TM',epsc,1});
        %reflectstrat(z,C0(kr,ki),'TM',epsc)-1;
        FTE(kr,ki)=Flwpc(C0(kr,ki),{RE,z,'TE',epsc,-1});
        %reflectstrat(z,C0(kr,ki),'TE',epsc)+1;
    end
end
%disp('filled')

for imode=1:2
    if imode==1
        mode='TM'; R=1;
    else
        mode='TE'; R=-1;
    end
    eval(['FT=F' mode ';']);

    params={RE,z,mode,epsc,R};
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
    isout=0;
    while 1
        dx=-F2*(x2-x1)./(F2-F1);
        x1=x2;
        x2=x2+dx;
        if real(x2)<-.1 | real(x2)>1.1 | imag(x2)<-.2 | imag(x2)>.1
            isout=1;
            break;
        end
        F1=F2;
        F2=Flwpc(x2,params); %reflectstrat(z,x2,mode,epsc)-R;
        %F2=x2^2-2
        if abs(F2)<1e-6
            break
        end
        %pause
    end
    if ~isout
        C0sol(k)=x2;
    end
end

% Discard duplicate and unreliable solutions
duplic=zeros(size(C0sol));
k=0;
for k=1:nfound
    if isnan(C0sol(k))
        continue
    end
    ii=find(abs(C0sol-C0sol(k))<dC);
    if length(ii)>=2
        C0sol(ii(2:end))=NaN;
	end
	[R0,E,H,Ez,Hz,reliable]=reflectcurved(RE,z,C0sol(k),mode,epsc);
	if reliable>0.3
		C0sol(k)=NaN;
	end
end
tmp=C0sol(find(~isnan(C0sol)));
[y,ii]=sort(real(tmp));
eval(['C' mode '=tmp(ii);']);

end % cycle over modes

% In dB/Mm
alfTM=20*k0*imag(sqrt(1-CTM.^2))/log(10)*1e6;
alfTE=20*k0*imag(sqrt(1-CTE.^2))/log(10)*1e6;

function res=Flwpc(C0,params)
RE=params{1}; zdim=params{2}; mode=params{3}; epsc=params{4}; R=params{5};
res=reflectcurved(RE,zdim,C0,mode,epsc)-R;

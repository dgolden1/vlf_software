function [sigz,sigp,sigh]=conductivity_6spec(varargin)
% Nspec (cm^{-3}): nh x ns or nh x nt x ns
% h (km), ENm (Td): nh x 1
% sig (S/m): nh x 1 or nh x nt
% See also: CONDUCAIR
global uAtomic kB me ech
if isempty(uAtomic)
    loadconstants
end

keys={'w','EN','AtmProfile','use_T'};
[h,Nspec,ENm,B,options]=parsearguments(varargin,2,keys);
w=getvaluefromdict(options,'w',0);
AtmProfile=getvaluefromdict(options,'AtmProfile','HAARPsummernight');
EN=getvaluefromdict(options,'EN',0); % in Td
if length(EN)==1
    EN=EN*ones(size(h));
end
B=getvaluefromdict(options,'B',5.65764e-05); % Default B at HAARP's site
use_T=getvaluefromdict(options,'use_T',0);
if use_T
    error('not implemented');
    % Collision frequency as a function of electron energy
end

h=h(:); nh=length(h);
specnames={'Ne','Nneg','Nclus','NX','Nac','Npos'};
ns=length(specnames);
nh=length(h);
N0N=getNm(0)./getNm(h);
mui=2.3e-4*N0N; % in m^2/V/s
muclus=1e-4*N0N;
% The electron conductivity as a function of E field [Pasko et al, 1997]:
ENm=EN/1e21;
ENmmin=1.62e3/getNm(0);
ii=find(ENm<ENmmin);
ENm(ii)=ENmmin;
x=log10(ENm); a0=50.970; a1=3.0260; a2=8.4733e-2;
mue=10.^(a0+x.*(a1+x*a2)).*N0N/getNm(0);

mobil=[mue mui muclus mui zeros(size(h)) mui];
chsign=meshgrid([-1 -1 1 -1 0 1],1:nh); % The charge sign
mass=meshgrid([me uAtomic*[16 100 16*3+14 16 16+14]],1:nh);
nucorr=1-i*w*mobil./ech./mass; % nu -> nu-i*w==nu*nucorr
% Ratio of gyrofrequency to collision frequency
wHnu=B*(chsign.*mobil)./nucorr; % the correction is for w~=0
pcoef=1./(wHnu.^2+1); % Ratio of Pedersen to Parallel conductivity
hcoef=-wHnu./(wHnu.^2+1); % Ratio of Hall to Parallel conductivity
% Parallel conductivity
if ndims(Nspec)==2
    sigcomp=ech*mobil.*(1e6*Nspec); % - for the density in cm^{-3}
    sigz=sum(sigcomp,2);
    sigp=sum(sigcomp.*pcoef,2);
    sigh=sum(sigcomp.*hcoef,2);
elseif ndims(Nspec)==3
    % Nspec is nh x nt x ns
    nt=size(Nspec,3);
    sigz=zeros(nh,nt);
    sigp=zeros(nh,nt);
    sigh=zeros(nh,nt);
    for is=1:ns
        sigcomp=ech*ndgrid(mobil(:,is),1:nt).*(1e6*Nspec(:,:,is));
        sigz=sigz+sigcomp;
        sigp=sigz+sigcomp.*pcoef;
        sigh=sigz+sigcomp.*hcoef;
    end
end
% Correct the numerical error for the total Hall conductivity

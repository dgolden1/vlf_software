function [sige,sigi,sigtot,nuen,nuin]=conducair(h,B,w,profile,Ne)
% CONDUCAIR The background conductivity, including ions
% SI units are used (m^{-3} for densities).

% Default arguments
if nargin<4
    profile=[];
end
if nargin<3
    w=0;
end
if nargin<2
    B=[];
end
if isempty(B)
    B=5.65764e-05; % Default B at HAARP's site
    disp(['WARNING: using default B=' num2str(B) ' T']);
end

% Initialization
h=h(:);
nh=length(h);
sige=zeros(nh,3);
sigi=zeros(nh,3);
nuen=zeros(size(h));
global kB ech me uAtomic
if isempty(kB)
    loadconstants
end

% Electron profile
wH=ech*B/me;
if nargin<5
    Ne=getNe(h,profile);
else
    Ne=Ne(:);
end

% mui=2.3e-4 m^2/V/s [Pasko thesis, p. 33 (MISPRINT); Davies 1983; Horrak
% 2000 etc.]
Nm=getNm(h,profile);
mui=2.3e-4*getNm(0)./Nm;
M=uAtomic*(14+16); % NO+
Z=1;
nuin=Z*ech./mui/M; % Effective collision frequency with neutrals
WH=B*Z*ech/M; 
Ni=Ne/Z;


% % Holzworth et al [1985] conductivity profile
ii=find(h>=30 & h<90);
sigmeso=6e-13*exp(h(ii)/11);
% Dejnakarintra and Park [1974] conductivity profile
%s3=5e-14*exp(z/6);
Ni(ii)=Ni(ii)+M*sigmeso.*nuin(ii)/(Z*ech)^2;

% The low-altitude ion conductivity
% McGorman, Rust [1998], page 34:
ii=find(h<=30);
spos=3.33e-14*exp(0.254*h(ii)-0.00309*h(ii).^2);
sneg=5.34e-14*exp(0.222*h(ii)-0.00255*h(ii).^2);
sigstrato=spos+sneg;
% Scale it so that it fits the previous profile
coef=sigmeso(1)/sigstrato(end)
sigstrato(end)=0;
Ni(ii)=Ni(ii)+M*coef*sigstrato.*nuin(ii)/(Z*ech)^2;

Wp2eps0=Ni*(Z*ech)^2/M;
nuinw=nuin-i*w;
sigi(:,1)=Wp2eps0.*nuinw./(nuinw.^2+WH^2);
sigi(:,2)=-Wp2eps0.*WH./(nuinw.^2+WH^2);
sigi(:,3)=Wp2eps0./nuinw;

% Collision frequency as a function of electron energy
Tav=500*kB/ech;
nen=1000;
den=30*Tav/nen;
en=[1:nen]'*den;
ec=0.5*(en(1:nen-1)+en(2:nen));
numom0=getnumom(ec);
wp2eps0=Ne*ech^2/me;
% Electron conductivity
for ih=1:nh
    T0=getTn(h(ih),profile)*kB/ech;
    ne=sqrt(en).*exp(-en/T0);
    dn=(ne(2:nen)-ne(1:nen-1))/den;
    nc=0.5*(ne(1:nen-1)+ne(2:nen));
    distr=-2/3*(ec.*dn-nc/2)/sum(nc);
    numom=numom0*Nm(ih);
    nuen(ih)=sum(numom.*nc)/sum(nc);
    wp2eps0=Ne(ih)*ech^2/me;
    sige(ih,1)=wp2eps0*sum((numom-i*w).*distr./((numom-i*w).^2+wH^2));
    sige(ih,2)=wp2eps0*wH*sum(distr./((numom-i*w).^2+wH^2));
    sige(ih,3)=wp2eps0*sum(distr./(numom-i*w));
    %sige1(ih,:)=conducne(en,ne,Nm(ih),Ne(ih),wH,w,'phz').';
end
% Correct the numerical error for the total Hall conductivity
sigtot=sige+sigi;
t1=nuin.^2/WH^2; t2=nuen.^2/wH^2;
sigHall=Ne.*ech/B.*(t1-t2)./(1+t1)./(1+t2);
ii=find(sigHall<sigtot(:,2) & t1<0.1);
sigtot(ii,2)=sigHall(ii);
sige(:,2)=sigtot(:,2)-sigi(:,2);


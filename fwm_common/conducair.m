function [sige,sigi,sigtot,nuen,nuin]=conducair(varargin)
% CONDUCAIR The background conductivity, including ions
% SI units are used (m^{-3} for densities).
% Version 2 -- use ionochem_6spec to calculate ion densities for low
% altitudes.

global kB ech me uAtomic
if isempty(kB)
    loadconstants
end

% Parse arguments
keys={'AtmProfile','Ne','B','daytime','calculate_Nspec'};
[h,w,options]=parsearguments(varargin,1,keys);
B=getvaluefromdict(options,'B',5.65764e-05); % Default B at HAARP's site
AtmProfile=getvaluefromdict(options,'AtmProfile','HAARPsummernight');
Ne=getvaluefromdict(options,'Ne',getNe(h,AtmProfile));
calculate_Nspec=getvaluefromdict(options,'calculate_Nspec',0);
if isempty(w)
    w=0;
end
daytime_default=1*(isempty(findstr(AtmProfile,'night')));
if strcmp(AtmProfile,'GammaFlare2004')
    daytime_default=1;
end
daytime=getvaluefromdict(options,'daytime',daytime_default);

h=h(:);
nh=length(h);
wH=ech*B/me;

sige=zeros(nh,3);
sigi=zeros(nh,3);
nuen=zeros(size(h));

% Electron profile
if isempty(Ne)
Ne0given=getNe(h,profile);
else
    Ne=Ne(:);
end

% mui=2.3e-4 m^2/V/s [Pasko thesis, p. 33 (MISPRINT); Davies 1983; Horrak
% 2000 etc.]
Nm=getNm(h,AtmProfile);
Nm0=getNm(0,AtmProfile);
mui=2.3e-4*Nm0./Nm;


% Z=1;
M=uAtomic*(14+16); % NO+
nuin=ech./mui/M; % Effective collision frequency with neutrals
WH=B*ech/M; 
Nion=Ne;

if calculate_Nspec
    % We use default options for the chemistry model.
    ilow=find(Ne==0);
    if ~isempty(ilow)
        ii=[ilow(:)' max(ilow)+1]; % Leave 1 point
        Nspec=ionochem_6spec(AtmProfile,daytime,h(ii),Ne(ii)/1e6);
        % Nspec is in cm^{-3}
        Nion(ii)=1e6*sum(Nspec(:,[2 3 4 6]),2);
        Ne(ii)=1e6*Nspec(:,1);
    end
else
    disp('Using tabulated ion conductivity');
    % % Holzworth et al [1985] conductivity profile
    ii1=find(h>=30 & h<90);
    sigmeso=6e-13*exp(h(ii1)/11);
    % Dejnakarintra and Park [1974] conductivity profile
    %s3=5e-14*exp(z/6);
    Nion(ii1)=Nion(ii1)+M*sigmeso.*nuin(ii1)/ech^2;
    
    % The low-altitude ion conductivity
    % McGorman, Rust [1998], page 34:
    ii2=find(h<=30);
    if ~isempty(ii2)
		spos=3.33e-14*exp(0.254*h(ii2)-0.00309*h(ii2).^2);
		sneg=5.34e-14*exp(0.222*h(ii2)-0.00255*h(ii2).^2);
		sigstrato=spos+sneg;
		if ~isempty(ii1)
			% Scale it so that it fits the previous profile
			coef=sigmeso(1)/sigstrato(end)
			sigstrato(end)=0;
			Nion(ii2)=Nion(ii2)+M*coef*sigstrato.*nuin(ii2)/ech^2;
		end
    end
end

Wp2eps0=Nion*ech^2/M;
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
Tn=getTn(h,AtmProfile)*kB/ech;
for ih=1:nh
    ne=sqrt(en).*exp(-en/Tn(ih));
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
nuenw=nuen-i*w;
t1=nuinw.^2/WH^2; t2=nuenw.^2/wH^2;
sigHall=Ne.*ech/B.*(t1-t2)./(1+t1)./(1+t2);
ii=find(abs(sigHall)<abs(sigtot(:,2)) & t1<0.1);
sigtot(ii,2)=sigHall(ii);
%sige(:,2)=sigtot(:,2)-sigi(:,2);


function [perm,isotropic,Ne,nu,perme]=get_perm_with_ions(varargin)
% Take ions into account in the permittivity
global me ech eps0 uAtomic
if isempty(me)
    loadconstants
end
Bgeo_keys=get_Bgeo('get_keys');
keys={'Ne','NeProfile','nu','daytime','AtmProfile','Nin','Nip',Bgeo_keys{:}};
if length(varargin)==1
    s=varargin{1};
    if ischar(s)
        switch s
            case 'get_keys'
                perm=keys;
            otherwise
                error(['unknown command: ' s])
        end
        return
    else
        error('wrong arguments')
    end
end
[h,w,options]=parsearguments(varargin,2,keys);
h=h(:);
M=length(h);
needNe=0;
Ne=getvaluefromdict(options,'Ne',[]);
if isempty(Ne)
    needNe=1;
    NeProfile=getvaluefromdict(options,'NeProfile','HAARPsummernight');
    Ne=getNe(h,NeProfile);
end
Nip=getvaluefromdict(options,'Nip',[]);
Nin=getvaluefromdict(options,'Nin',[]);
if isempty(Nip) & isempty(Nin)
    disp('Please wait while we calculate the ion densities ... ');
    daytime=getvaluefromdict(options,'daytime',0);
    % The profile here is only needed for O and Nm and Tn:
    AtmProfile=getvaluefromdict(options,'AtmProfile','HAARPsummernight');
    Nspec0=1e6*ionochem_6spec(AtmProfile,daytime,h,Ne/1e6);
    Ne=Nspec0(:,1);
    Nip=sum(Nspec0(:,[3 6]),2); % Positive ions
    Nin=sum(Nspec0(:,[2 4]),2); % Negative ions
elseif isempty(Nin)
    Nin=Nip-Ne;
elseif isempty(Nip)
    Nip=Nin+Ne;
else
    % Both Nin and Nip are given
    if ~needNe
        % Nin, Nip and Ne are all given
        disp('WARNING: the value of Ne is discarded')
    end
    Ne=Nip-Nin;
end
% - Convert to m^{-3} -- IMPORTANT!
% Electron collision frequency
nu=getvaluefromdict(options,'nu',plot_collisionrate(h,'doplot',0));
% Geomagnetic field
Bgeo_options=getsubdict(options,Bgeo_keys);
[Bgeo,Babs,thB,phB]=get_Bgeo(h,Bgeo_options{:});
% The mobilities -- inversely proportional to neutral density
% See Horrak et al [2000] or Pasko et al [1997]:
N0N=getNm(0)./getNm(h);
% mue=1.4*N0N; % electrons -- not needed
Mi=uAtomic*18; % atomic water
mui=2e-4*N0N; % all ions - average, in m^2/V/s
nui=ech./(mui*Mi); % Ion collision frequency

% Calculate the permittivity
wH=ech*Babs/me; % Electron gyrofrequency
wp2=Ne*ech^2/(me*eps0); % Plasma frequency (squared)
R=1-wp2./w./(w+i*nu-wH);
L=1-wp2./w./(w+i*nu+wH);
S=(R+L)/2;
D=(R-L)/2;
P=1-wp2./w./(w+i*nu);
perme=zeros(3,3,M);
for iz=1:M
    perme(:,:,iz)=rotated_perm(S(iz),P(iz),D(iz),thB(iz),phB(iz));
end
% Ion counterpart
WH=ech*Babs/Mi; % ion gyrofrequency
Wpp2=Nip*ech^2/(Mi*eps0); % Plasma frequency (squared)
Wpn2=Nin*ech^2/(Mi*eps0); % Plasma frequency (squared)
% we switch R and L for positive ions
dR=-Wpp2./w./(w+i*nui+WH)-Wpn2./w./(w+i*nui-WH);
dL=-Wpp2./w./(w+i*nui-WH)-Wpn2./w./(w+i*nui+WH);
dS=(dR+dL)/2;
dD=(dR-dL)/2;
dP=-(Wpp2+Wpn2)./w./(w+i*nui);
permi=zeros(3,3,M);
for iz=1:M
    permi(:,:,iz)=rotated_perm(dS(iz),dP(iz),dD(iz),thB(iz),phB(iz));
end
perm=perme+permi;
isotropic=((Ne==0 & Nin==0) | Babs==0);

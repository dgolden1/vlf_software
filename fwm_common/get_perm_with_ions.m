function [perm,S,P,D]=get_perm_with_ions(varargin)
% If w==0, calculate the conductivity
% Take ions into account in the permittivity
% Version 2: the real positive ions, with a better ion-neutral collision
% rate.
global me ech eps0 uAtomic
if isempty(me)
    loadconstants
end
Bgeo_keys=get_Bgeo('get_keys');
% For each species of ions, we must know its atomic mass, density, charge
keys={'Ne','IonosphereProfile','nue','need_ions','ui','Zi','Ni','nui',Bgeo_keys{:}};
% ui - atomic mass
% Zi - charge and
% Ni - densities of ions
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
do_cond=(w==0);
h=h(:);
M=length(h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the ionosphere
[NeProfile,givenNeProfile]=...
	getvaluefromdict(options,'IonosphereProfile','HAARPsummernight');
% Electrons
[Ne,givenNe]=getvaluefromdict(options,'Ne',getNe(h,NeProfile));
% Electron collision frequency
nue=getvaluefromdict(options,'nue',get_nu_electron_neutral_swamy92(h));
nue(find(isnan(nue)))=0;

% Ions
need_ions=getvaluefromdict(options,'need_ions',1);
if need_ions
    ui=getvaluefromdict(options,'ui',[]);
    if isempty(ui)
		if givenNe
			error('Ne given but not Ni, Zi or ui')
		end
        [Ni,givenNi]=getvaluefromdict(options,'Ni',[]);
        [Zi,givenZi]=getvaluefromdict(options,'Zi',[]);
        if ~isempty(Ni) || ~isempty(Zi)
            error('must give ui (masses)');
        end
        % Load the real ionosphere
        % Neglect the negative ions
        ions={'NO+','O+','H+','O2+','N+','He+'};
        Ni=getSpecies(ions,h,NeProfile);
        ui=[30 16 1 32 14 2];
        Zi=[1 1 1 1 1 1];
    else
        Ni=getvaluefromdict(options,'Ni',[]);
        Zi=getvaluefromdict(options,'Zi',[]);
        if isempty(Ni) | isempty(Zi)
            error('empty Ni or Zi');
        end
    end
    % Check the sizes
    Nsp=length(ui);
    if length(Zi)~=Nsp | size(Ni,2)~=Nsp
        error('Ni, Zi of incorrect size');
    end
    % Enforce the quasineutrality
    Ne=sum(Ni.*repmat(Zi,[M 1]),2);
    % Ion collision frequency - only important for NO+
    nuiNOI=get_nu_ion_neutral_davies97(h);
    nuiNOI(find(isnan(nuiNOI)))=0;
    nui=getvaluefromdict(options,'nui',repmat(nuiNOI,1,Nsp));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Permittivity tensor

% Geomagnetic field
Bgeo_options=getsubdict(options,Bgeo_keys);
[Bgeo,Babs,thB,phB]=get_Bgeo(h,Bgeo_options{:});

% Calculate the electron permittivity
wH=ech*Babs/me; % Electron gyrofrequency
wp2=Ne*ech^2/(me*eps0); % Plasma frequency (squared)
wnue=w+i*nue;
if do_cond
    R=i*wp2./(wnue-wH)*eps0;
    L=i*wp2./(wnue+wH)*eps0;
    P=i*wp2./(wnue)*eps0;
else
    R=1-wp2./w./(wnue-wH);
    L=1-wp2./w./(wnue+wH);
    P=1-wp2./w./(wnue);
end
S=(R+L)/2;
D=(R-L)/2;

% Add ion counterpart
if need_ions
    for isp=1:Nsp
        Mi=ui(isp)*uAtomic;
        Qi=Zi(isp)*ech;
        WH=Qi*Babs/Mi; % ion gyrofrequency (for positive ions)
        Wp2=Ni(:,isp)*Qi^2/(Mi*eps0); % Plasma frequency (squared)
        % we switch R and L for positive ions
        wnui=w+i*nui(:,isp);
        if do_cond
            R=i*Wp2./(wnui+WH)*eps0;
            L=i*Wp2./(wnui-WH)*eps0;
            P=P+i*Wp2./wnui*eps0;
        else
            R=-Wp2./w./(wnui+WH);
            L=-Wp2./w./(wnui-WH);
            P=P-Wp2./w./wnui;
        end
        S=S+(R+L)/2;
        D=D+(R-L)/2;
    end
end
perm=zeros(3,3,M);
for iz=1:M
    perm(:,:,iz)=rotated_perm(S(iz),P(iz),D(iz),thB(iz),phB(iz));
end
% perm is the conductivity tensor for w=0
% [sp, sh, sz] == [S i*D P];
if do_cond
	D=i*D; % sh
end

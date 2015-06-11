function [perm,isotropic,Ne,nu,S,P,D]=get_warm_perm(varargin)
%GET_WARM_PERM Permittivity tensor using kinetic theory
% Usage:
%    keys=get_warm_perm('get_keys');
%    [perm,isotropic]=get_warm_perm(h,w[,options]);
% With optional (debugging) outputs:
%    [perm,isotropic,Ne,nu,S,P,D]=get_warm_perm(h,w[,options]);
% Inputs:
%    h - altitudes in km
%    w - frequency in rad/sec
% Options:
%    Bgeo, Babs, thB, phB - options for get_Bgeo
%    Ne - electron density profile at altitudes h, in m^{-3}
%    NeProfile - if Ne is not given, load Ne from a profile by getNe
%       (default='HAARPwinternight')
%    numEnergies - number of points in electron energy distribution
%       (default=300, but it is advisable to use more)
% Options that are unlikely to be used:
%    T - temperature profile (in K), default = loaded by getTn
%    do_correct - boolean, mostly for debugging
% Outputs:
%    keys - list of available options
%    perm - 3 x 3 permittivity tensor
%    isotropic - boolean, tells if the tensor is isotropic
% Optional outputs:
%    Ne - electron density profile at altitudes h, in m^{-3}
%    nu - average collision rate from kinetic theory (NOTE: this is NOT the
%       value that is used for this calculation)
%    S,P,D - components of permittivity tensor (see ROTATED_PERM)
% Note:
%    Usage is almost the same as for GET_PERM, except that you cannot
%    specify the collision rate profile.
% See also: GET_PERM, GET_BGEO, ROTATED_PERM
% Author: Nikolai G. Lehtinen
global me ech eps0 kB
if isempty(me)
    loadconstants
end
Bgeo_keys=get_Bgeo('get_keys');
keys={'Ne','NeProfile','T','numEnergies','do_correct',Bgeo_keys{:}};
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
do_correct=getvaluefromdict(options,'do_correct',1);
h=h(:);
M=length(h);
Ne=getvaluefromdict(options,'Ne',[]);
Ne=Ne(:);
if isempty(Ne)
    NeProfile=getvaluefromdict(options,'NeProfile','HAARPwinternight');
    Ne=getNe(h,NeProfile);
end
T=getvaluefromdict(options,'T',getTn(h));
% in eV
TeV=kB*T/ech;
TeV=TeV(:);
Bgeo_options=getsubdict(options,Bgeo_keys);
[Bgeo,Babs,thB,phB]=get_Bgeo(h,Bgeo_options{:});
wH=ech*Babs/me; % Gyrofrequency
wp2=Ne*ech^2/(me*eps0); % Plasma frequency (squared)
perm=zeros(3,3,M);
Nm=getNm(h);
S=zeros(size(h));
D=S; P=S; nu=S;
numEnergies=getvaluefromdict(options,'numEnergies',[]);
for iz=1:M
    [enT,neT]=getneT(TeV(iz),'nen',numEnergies); % enT in eV, sum(neT)=1
    nuen=Nm(iz)*getnumom(enT);
    winu=w+i*nuen;
    if do_correct
        ne=neT.*enT*2/3/TeV(iz);
        % -- multiplied by normalized enT to temperature
    else
        ne=neT;
    end
    R=1-wp2(iz)/w*sum(ne./(winu-wH(iz)));
    L=1-wp2(iz)/w*sum(ne./(winu+wH(iz)));
    P(iz)=1-wp2(iz)/w*sum(ne./winu);
    S(iz)=(R+L)/2;
    D(iz)=(R-L)/2;
    nu(iz)=sum(neT.*nuen);
    perm(:,:,iz)=rotated_perm(S(iz),P(iz),D(iz),thB(iz),phB(iz));
end
isotropic=(Ne==0 | Babs==0);

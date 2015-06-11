function [perm,isotropic,Ne,nu,S,P,D]=get_perm(varargin)
%GET_PERM Permittivity tensor
% For usage, see GET_WARM_PERM
% Differences in usage: you can specify collision rate profile in option
% 'nu'. Default: loaded from kinetic theory.
% See also: GET_WARM_PERM, GET_BGEO
% Author: Nikolai G. Lehtinen
global me ech eps0
if isempty(me)
    loadconstants
end
Bgeo_keys=get_Bgeo('get_keys');
keys={'Ne','NeProfile','nu',Bgeo_keys{:}};
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
Ne=getvaluefromdict(options,'Ne',[]);
Ne=Ne(:);
if isempty(Ne)
    NeProfile=getvaluefromdict(options,'NeProfile','HAARPwinternight');
    Ne=getNe(h,NeProfile);
end
nu=getvaluefromdict(options,'nu',plot_collisionrate(h,'doplot',0));
nu=nu(:);
Bgeo_options=getsubdict(options,Bgeo_keys);
[Bgeo,Babs,thB,phB]=get_Bgeo(h,Bgeo_options{:});
wH=ech*Babs/me; % Gyrofrequency
wp2=Ne*ech^2/(me*eps0); % Plasma frequency (squared)
R=1-wp2./w./(w+i*nu-wH);
L=1-wp2./w./(w+i*nu+wH);
S=(R+L)/2;
D=(R-L)/2;
P=1-wp2./w./(w+i*nu);
perm=zeros(3,3,M);
for iz=1:M
    perm(:,:,iz)=rotated_perm(S(iz),P(iz),D(iz),thB(iz),phB(iz));
end
isotropic=(Ne==0 | Babs==0);

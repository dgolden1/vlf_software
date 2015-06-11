function [EH,Ne,perm]=fwm_1d(varargin)
%FWM_1D Reflection from ionosphere in 1D
% This is a simple demonstration of the usage of SOLVE_BOOKER_3D,
% FWM_RADIATION and FWM_INTERMEDIATE
% Usage:
%    % To calculate reflection from the ionosphere
%    EH=fwm_1d(h,f[,hi,np,options]);
%    % To calculate emission by sources
%    EH=fwm_1d(h,f,hi,np,si,I[,options]);
% Inputs (with sizes):
%    h (M) - array of heights in km;
%    f     - frequency
% Optional inputs:
%    hi (Mi) - heights (in km) at which we want to calculate the fields;
%       default=h
%    np      - horizontal refractive index (default=0)
%    si (Ms) - layer numbers corresponding to sources;
%    I (3 x Ms) -- source currents which are located at the lower boundary
%       of each layer
% Options:
%  'perm' -- (3 x 3 x M) array of dielectric permittivity tensors at h
%            (default calculated from Ne, nu and Bgeo), must come with
%            boolean (of length M) array 'isotropic';
%  'Ne','nu','Bgeo' -- environmental parameters;
%  'ground_bc' -- ground boundary condition ('E=0','H=0' or 'free');
%  'np' -- horizontal refractive index (=kperp/k0),
%                         default=0;
% Output:
%  EH (Mi x 6) -- fields (Ex,Ey,Ez,Hx,Hy,Hz, the component number given
%                 by the second index) at altitudes "hi".
% See also: SOLVE_BOOKER_3D, FWM_DEH, FWM_RADIATION, FWM_INTERMEDIATE
% Previous version: REFLECTPLASMA (see important notes there)
% Author: Nikolai G. Lehtinen

global clight ech me eps0 impedance0
if isempty(clight)
    loadconstants
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse arguments, and some initialization
perm_keys=get_perm('get_keys');
keys={'debug','perm','isotropic','ground_bc','mode',perm_keys{:}};
[h,f,hi,np,si,I,options]=parsearguments(varargin,2,keys);
M=length(h);
if isempty(hi)
    hi=h;
end
if isempty(np)
    np=0;
end
no_sources=isempty(si);
mode=getvaluefromdict(options,'mode','');
if ~no_sources & ~isempty(mode)
    disp('WARNING: the mode option is not used')
end
if no_sources & isempty(mode)
    mode='TE';
end
debugflag=getvaluefromdict(options,'debug',0);
ground_bc=getvaluefromdict(options,'ground_bc','E=0');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Permittivity components
w=2*pi*f;
k0=w/clight;
z=h*1e3*k0;
perm=getvaluefromdict(options,'perm',[]);
if isempty(perm)
    perm_options=getsubdict(options,perm_keys);
    [perm,isotropic,Ne]=get_perm(h,w,perm_options{:});
else
    isotropic=getvaluefromdict(options,'isotropic',[]);
    if isempty(isotropic)
        error('Must specify "isotropic"')
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output altitudes
Mi=length(hi);
zi=hi*1e3*k0;
% Prepare the indeces
ii=zeros(Mi,1);
dzl=zeros(Mi,1); dzh=dzl;
for ki=1:Mi
    % The altitudes
    zi0=zi(ki);
    k=max(find(z<=zi0)); % Which layer are we in?
    ii(ki)=k;
    dzl(ki)=zi0-z(k); % Distance to the boundary below
    if k<M
        dzh(ki)=z(k+1)-zi0; % Distance to the boundary above
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Full-Wave Model starts here and consists of 4 parts

% 1a. Refractive index and mode structure in each layer
nz=zeros(4,M); Fext=zeros(6,4,M);
for k=1:M
    [nz(:,k),Fext(:,:,k)]=solve_booker_3d(perm(:,:,k),np,0,isotropic(k));
end
F=Fext([1:2 4:5],:,:);

if ~no_sources
    if debugflag>0
        disp('Emission by sources');
    end
    % 1b. Sources (Delta E, Delta H) in Fourier space
    eiz=permute(perm(:,3,si),[1 3 2]);
    % The new boundary conditions for vertical sources immersed in medium
    % nxc is equal to nx or to sin(nx*k0*dx)/(k0*dx).
    DEH=fwm_deh(I,eiz,np,0);
    % 2. FWM solved for given DEH
    [ul,dh]=fwm_radiation(z,nz,F,'E=0',si,DEH);
else
    % 2. FWM solved for a given incident wave
    [Pu,Pd,Ux,Dx,Ruh,Rdl] = fwm_radiation(z,nz,F,ground_bc);
    ul=zeros(2,M); dh=zeros(2,M-1);
    if debugflag>0
        disp(['Propagation up for ' mode ' mode']);
    end
    switch mode
        case 'TE'
            ul(:,1)=[1;0];
        case 'TM'
            ul(:,1)=[0;1];
    end
    for k=1:M-1
        uh=Pu(:,:,k)*ul(:,k);
        ul(:,k+1)=Ux(:,:,k)*uh;
        dh(:,k)=Ruh(:,:,k)*uh;
    end
end

% 4. Find the waves and fields at intermediate points
ud=fwm_intermediate(nz,ul,dh,ii,dzl,dzh);
EH=zeros(Mi,6);
for ki=1:Mi
    k=ii(ki);
    EH(ki,:)=Fext(:,:,k)*ud(:,ki);
end

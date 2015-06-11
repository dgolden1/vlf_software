function Nsp=getSpecies(sp,h0,profile)
%function Nsp=getSpecies(sp,h0,profile)
% Get the species density in m^{-3} as a function of height in km.
% Inputs:
%  sp -- species name(s) ('N2','O2','Ne','O+' etc). Can be a cell array,
%        like {'N2','O2'}
%  h0 -- height in km
%  profile -- atmosphere profile over HAARP (e.g., 'summernight' --
%             which is default)
if nargin<3
    profile=[];
end
if iscell(sp)
    n=length(sp);
    Nsp=zeros(n,length(h0));
    for k=1:n
        Nsp(k,:)=getSpecies1(sp{k},h0(:)',profile);
    end
else
    Nsp=getSpecies1(sp,h0,profile);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Nsp0=getSpecies1(sp,h0,profile)
%Nsp=getSpecies1(sp,h,profile) Get Nsp in m^{-3} as a function of h in km
global IONOSPH NEUTRALS
if isempty(IONOSPH)
    loadatmosphere
end
if sp(end)=='+'
    sporig=sp;
    sp(end)='I';
    disp(['WARNING: Getting species ' sp ' instead of ' sporig]);
end

isneutral=~isempty(find(strcmp(sp,NEUTRALS)));
if nargin<3 | isempty(profile)
    profile='HAARPsummernight';
end

% In case h0 is not monotonously growing
nh=length(h0);
[h,isort]=sort(h0);
[tmp,invsort]=sort(isort); % for inverse permutation

% Find the needed profile
found=0;
for p=1:length(IONOSPH)
    if strcmp(IONOSPH{p}.name,profile)
        found=p;
        break
    end
end
if ~found
    error(['Unknown profile: ' profile]);
end
a=IONOSPH{found};
if isneutral & ~isfield(a,'hn')
    % The neutral species are not available
    a=IONOSPH{1};
    disp(['WARNING: Getting ' sp ' profile from ' a.name ...
            ' instead of ' profile]);
end

% Find the needed species
if ~isfield(a,sp)
    error(['This species (' sp ') is not available for profile ' profile]);
end
aNsp=getfield(a,sp);
if isneutral
    ah=a.hn;
else
    ah=a.hi;
end

% Interpolate
ii=find(aNsp>0);
%if strcmp(sp,'Tn')
    % Use linear interpolation for temperature
%    Nsp=interp1(ah(ii),aNsp(ii),h,'linear');
%else
    Nsp=exp(interp1(ah(ii),log(aNsp(ii)),h,'linear'));
%end
ii=find(~isnan(Nsp));
if isempty(ii)
    Nsp0=zeros(size(h0));
    return
end
% Divide into low and high altitudes, use available profile
i1=1:(min(ii)-1);
i2=(max(ii)+1):length(h);
Nsp(i1)=0;
if strcmp(sp,'Ne')
    Nsp(i2)=Nsp(max(ii));
elseif isneutral
    Nsp(i2)=Nsp(end)*exp(-(h(i2)-ah(end))/8);
else
    Nsp(i2)=0;
end
% Unsort back to the original
Nsp0=Nsp(invsort);

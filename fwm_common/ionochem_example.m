% Script to calculate daytime profiles and conductivities
global ech
if isempty(ech)
    loadconstants
end
daytime=1
if daytime
    daystring='day'
else
    daystring='night'
end

h=[0:100].'; % Altitude in km
% Calculate various species densities
[Nspec0,S0,specnames]=ionochem_6spec(['HAARPsummer' daystring],daytime,h)

% Convert to m^{-3} -- IMPORTANT!
Nspec0=1e6*Nspec0;

figure;
semilogx(Nspec0,h); legend(specnames)

% Discard the "active species" which are not calculated and are not
% conducting
nspec=length(specnames)-1;
iac=find(strcmp('Nac',specnames));
Nspec0=Nspec0(:,[1:iac-1 iac+1:nspec+1]);
specnames={specnames{[1:iac-1 iac+1:nspec+1]}};
% Clearer names for somes species
specnames{find(strcmp('NX',specnames))}='NnegX';
specnames{find(strcmp('Nclus',specnames))}='NposX';


% The conductivity

% The mobilities -- inversely proportional to neutral density
% See Horrak et al [2000] or Pasko et al [1997]:
N0N=getNm(0)./getNm(h);
mue=1.4*N0N; % electrons
mui=2.3e-4*N0N; % light ions, in m^2/V/s
muclus=1e-4*N0N; % positive ion clusters
mobil=[mue mui muclus mui mui];

sig0=ech*mobil.*Nspec0;
sig0tot=sum(sig0,2);

figure;
semilogx(sig0,h); 
hold on; plot(sig0tot,h,'k'); hold off;
legend(specnames{:},'Total','Location','NorthWest')
grid on
xlabel('Conductivity, S/m'); ylabel('h, km')

% Store each species in an array with a corresponding name
for k=1:nspec
    eval([specnames{k} '=Nspec0(:,k);']);
    eval(['sig0' specnames{k} '=sig0(:,k);']);
end

save h cond_profile Nspec0 specnames sig0 sig0tot Ne Npos NposX Nneg NnegX ...
    sig0Ne sig0Npos sig0NposX sig0Nneg sig0NnegX

% NPM calculations
given_args_fwm_antenna=1;
do_axisymmetric=0;
% Mi=1 for upper boundary calculations only, if you need ground,
% set Mi=2
Mi=1;
% Accuracy
retol=1e-4;
NeProfile='nighttime';
% Scaling for Ne (if you need higher Ne than given, for example)
Necoef=1;
% Shift Ne profile downward by this distance (in km)
hdownshift=0;
% Collision rate
nuProfile='cold';
ground_bc='E=0'; % overriden by "sground"
% Final output - need_2d=1 takes longer
need_2d=1; % only valid for 3d calculations
% Auxiliary - leave default
uniform_grid=0;

dh=1;
dx=5e3;
dy=dx;
xmax=500e3;
ymax=xmax;

do_plots=1;
save_plots=1;

% NML
vlftransmitters
VLF=NML;
f=VLF.f
Ptot=VLF.P0
% Coordinates are not used so far
lat0=VLF.lat
lon0=VLF.lon
Bgeo=VLF.Bgeo
%sground=0
% Conductivity at the ground
sground=0

fwm_antenna

function loadconstants
% Load various physical constants
global me ech kB clight mu0 eps0 impedance0 ...
    rclass0 uAtomic REarth EBR Ggrav hbar ...
    aBohr sigStefan global_dir ...
    N2 O2 species composition
disp('**** READING PHYSICAL CONSTANTS ****');
% tmp=matlabroot;
% if tmp(1)=='/'
%     global_dir='/home/nleht/MATLAB/common/inputs/';
% else
%     global_dir='C:\MATLAB701\work\common\inputs\';
% end

[pathstr] = fileparts(which('loadconstants'));
global_dir = fullfile(pathstr, 'inputs');
if global_dir(end) ~= filesep, global_dir(end+1) = filesep; end


me=9.1093826e-31; % electron mass in kg
REarth=6378.137; % IUGG value for the equatorial radius of the Earth, km
uAtomic=1.66053886e-27; % Atomic mass unit, =MC/12.
% Electron charge in C
ech=1.60217653e-19;
% Boltzmann constant
kB=1.3806505e-23; % J/K
mu0=4*pi*1e-7;
clight=299792458;
eps0=1/(mu0*clight^2);
% Free space impedance
impedance0=sqrt(mu0/eps0);
% Classical electron radius
rclass0=ech^2/(4*pi*eps0*me*clight^2);
% Planck constant
hbar=1.05457168e-34;
% Bohr radius
aBohr=4*pi*eps0*hbar^2/(me*ech^2);
% Stefan-Boltzmann constant, J/s/m^2/K^4
sigStefan=pi^2/60*kB^4/hbar^3/clight^2;

% Gravitational constant
Ggrav=6.6742e-11;

%whaarp=2*pi*1e6;
%B=3.569e-5; % To get 1 MHz gyrofrequency
%wH=ech*B/me;
%wHhaarp=geomagb(62*pi/180,-145*pi/180,0)*ech/me;

N2=readelendifdata([global_dir 'N2elendif.txt']);
O2=readelendifdata([global_dir 'O2elendif.txt']);
% Special treatment of the 3-body attachment
%O2.q(:,16)=O2.q(:,16)*Nm/Nm0;
O2.q3=O2.q(1:36,16)*1e-22; % must be x N[O2] (m^{-3})
O2.e3=O2.e(1:36,16);
O2.q(:,16)=0;
N2.q3=0; N2.e3=0;

species=[N2 O2];
composition=[.8 .2];
EBR=[13 17.4]; % a quantity used in the ionization cross-section
% ds/dEs=stot/(EBR*atan((Ep-Ei)/(2*EBR)))/(1+(E/EBR)^2)

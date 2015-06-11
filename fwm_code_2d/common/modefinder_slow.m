function [CTM,CTE,alfTM,alfTE]=modefinder_slow(varargin)
%MODEFINDER Find all the modes using the TR 1143 algorithm
% Usage: [CTM,CTE,alfTM,alfTE]=modefinder_slow(f,h,sigtot)
% Inputs:
%   f      - frequency (Hz)
%   h      - altitudes (km)
%   sigtot - conductivities at h (mho/m)
% Outputs:
%   CTM, CTE     = kz/k0 for TM and TE modes
%   alfTM, alfTE - attenuation in dB/Mm
% See also: REFLECTSTRAT, MODEFINDER
% Author: Nikolai G. Lehtinen

global ech clight eps0 mu0
if isempty(ech)
    loadconstants
end
keys={'curved'};
[f,h,sig,options]=parsearguments(varargin,3,keys);
iscurved=getvaluefromdict(options,'curved',0);

w=f*2*pi;
k0=w/clight;
zdim=h*1e3*k0; % dimensionless
epsc=1+i*sig/(eps0*w);
RE=6.378137e+06*k0;

% Estimate the number of modes = max(z)/pi
nmodesest=ceil(max(zdim)/pi);
% The mesh step
dC1=1/nmodesest/20
dC=dC1*(1+i);

Cmin=0.001-0.025*i; % lower left corner
Cmax=1; % upper right corner
%Cmin=-1-i; Cmax=2+i;
%boundary=[Cmin real(Cmax)+i*imag(Cmin) Cmax real(Cmin)+i*imag(Cmax)];
boundary=[real(Cmin)+i*imag(Cmax) Cmin real(Cmax)+i*imag(Cmin) Cmax];

for imode=1:2
    if imode==1
        mode='TM'; R=1;
    else
        mode='TE'; R=-1;
    end
    params={zdim,mode,epsc,R,iscurved,RE};
    C0sol=rootsearch_tri(@Flwpc,params,boundary,dC,...
        'triangles','vertical','debug',2,'Newton-Raphson',1,'shift',0);
    disp('rootsearch done');
    eval(['C' mode '=C0sol;']);
end % cycle over modes

% In dB/Mm
alfTM=20*k0*imag(sqrt(1-CTM.^2))/log(10)*1e6;
alfTE=20*k0*imag(sqrt(1-CTE.^2))/log(10)*1e6;

function res=Flwpc(C0,params)
zdim=params{1}; mode=params{2}; epsc=params{3}; R=params{4}; iscurved=params{5}; RE=params{6};
if iscurved
    res=reflectcurved(RE,zdim,C0,mode,epsc)-R;
else
    res=reflectstrat(zdim,C0,mode,epsc,'branchcut_angle',pi/6)-R;
end

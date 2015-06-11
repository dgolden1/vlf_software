function [EH0,nx,EHf0]=fwm_axisymmetric_antenna1(f,h,perm,eground,xkm,hi,ksa,dxkm,retol)
%FWM_ANTENNA_AXISYMMETRIC Antenna radiation (axisymmetric)
% Calculation of the field from a vertical dipole source on the ground
% (axisymmetric case)
% This function is just a wrapper for FWM_AXISYMMETRIC
% Usage:
%    EH=impedance0*fwm_antenna_axisymmetric(f,h,perm,eground,ksa,xkm,hi[,ksa,dxkm,retol])
% Inputs:
%    f - frequency (Hz)
%    h (M) - altitudes in km
%    perm (3 x 3 x M) - dielectric permittivity tensor
%    eground - ground bc
%    xkm (Nx) - radial distance in km
%    hi (Mi) - output altitudes in km
% Optional inputs:
%    ksa (scalar) - antenna location is at h(ksa) (usually ksa==1 or 2).
%       The default is determined automatically, so that the antenna is at
%       or below 1 km. For greater accuracy for Ex, Ey, Hz on the ground it
%       makes sense to insert an additional point at low altitude into h.
% Output:
%    EH0 (6 x Nx) - E, H components at points xkm
% Notes:
% 1. Assume unit vertical current moment
% 2. We must have h(1)==0
% Author: Nikolai G. Lehtinen
% See also: FWM_AXISYMMETRIC, FWM_FIELD, FWM_RADIATION
if nargin<9
    retol=[];
end
if nargin<8
    dxkm=[];
end
if nargin<7
    ksa=[];
end
if isempty(ksa)
    if h(2)<=1
        ksa=2
    else
        ksa=1
    end
end
[EH0,nx,EHf0]=fwm_axisymmetric1(f,h,perm,eground,[ksa],[],[0;0;1],0,xkm,hi,dxkm,retol);

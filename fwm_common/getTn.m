function Tn=getTn(h,profile)
% The neutral temperature in K as a function of height in km
if nargin<2
    profile=[];
end
Tn=getSpecies('Tn',h,profile);

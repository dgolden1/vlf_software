function Nm=getNm(h,profile)
%Nm=getNm(h) Get Nm in m^{-3} as a function of h in km
if nargin<2
    profile=[];
end
Nm=getSpecies('N2',h,profile)+getSpecies('O2',h,profile)+ ...
    getSpecies('O',h,profile);

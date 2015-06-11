function plot_atmosphere(h,p,neut)
% Plot atmosphere profiles
if nargin<3
    neut=0;
end
if nargin<2
    p=[];
end
if nargin<1
    h=[];
end
if isempty(p)
    p='summernight';
end
if isempty(h)
    h=[0:1000];
end

if neut
    semilogx([getSpecies('N2',h,p);getSpecies('O2',h,p);getSpecies('O',h,p);...
        getSpecies('N',h,p);getSpecies('H',h,p);getSpecies('He',h,p);...
        getSpecies('Ar',h,p)],h)
    legend('N2','O2','O','N','H','He','Ar');
else
    semilogx([getNe(h,p);getSpecies('OI',h,p);getSpecies('Clust',h,p);...
        getSpecies('NOI',h,p); getSpecies('NI',h,p); ...
        getSpecies('HI',h,p);getSpecies('O2I',h,p);...
        getSpecies('HeI',h,p)],h)
    legend('Ne','O+','Clust','NO+','N+','H+','O2+','He+')
end
grid on
title(p);
xlabel('N, m^{-3}'); ylabel('h, km');

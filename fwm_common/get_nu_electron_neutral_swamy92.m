function nu=get_nu_electron_neutral_swamy92(h)
% Collision frequency from Swamy [1992], Astrophysics and Space Sci., 191,
% 203
a=[-0.24056e-9 -0.11541e-9];
b=[0.55560e-10 0.26523e-10];
c=[-0.11177e-11 -0.3819e-12];
d=[0.85373e-14 0.20152e-14];
N2=getSpecies('N2',h)/1e6;
O2=getSpecies('O2',h)/1e6;
T=getTn(h);
SP={N2,O2};
nu=zeros(size(h));
for s=1:2
    tmp=a(s)*T.^(1/2)+b(s)*T+c(s)*T.^(3/2)+d(s)*T.^2;
    nu=nu+SP{s}.*tmp;
end

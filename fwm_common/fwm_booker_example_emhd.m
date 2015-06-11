% EMHD (electron-magneto-hydro-dynamics) demo
% The weakly attenuated helicon mode
% EMHD is defined as w<WH<nui, nue<<wH, can be w<<nue,nui, w<WH
global ech me uAtomic
if isempty(ech)
    loadconstants
end

% Set up an appropriate permittivity
ions={'NO+','O+'}; Zi=[1 1]; Massi=[30 16];
Nions=length(ions);

Babs=3e-5; thB=pi/6;
wH=ech*Babs/me;
fHe=wH/(2*pi)
WH=Zi(1)*ech*Babs./(Massi*uAtomic);
fHi=WH/(2*pi)

% Small frequency
f=10; % < fHi
w=2*pi*f;

% Use the recommended altitude range and check conditions for EMHD

h=[80:5:120].'; M=length(h);
o=ones(M,1);
Ni=getSpecies(ions,h);
Ne=sum(Ni,2);
a=Ni./repmat(Ne,[1 Nions]);
nui=get_nu_ion_neutral_davies97(h);
nue=get_nu_electron_neutral_swamy92(h);

figure; plot(a,h); % We assume NO+ are more important in this region

figure; semilogx([w*o nui WH(1)*o  nue wH*o],h);
legend('\omega','\nu_i','\Omega_{H,NO+}','\nu_e','\omega_H')

[perm,S,P,D]=get_perm_with_ions(h,w,'Babs',Babs,'thB',thB,'ui',Massi,'Zi',Zi,'Ni',Ni);
[perm0,S0,P0,D0]=get_perm_with_ions(h,w,'Babs',Babs,'thB',thB,'ui',Massi,'Zi',Zi,'Ni',Ni,...
    'nue',zeros(M,1),'nui',zeros(M,Nions));
nx=[-2000:5:2000];
N=length(nx);
nz=zeros(4,M,N);
nz0=zeros(4,M,N);

for k=1:M
    nz(:,k,:)=fwm_booker(perm(:,:,k),nx,0);
    nz0(:,k,:)=fwm_booker(perm0(:,:,k),nx,0);
end

figure;
for k=1:M
    ax(1)=subplot(2,1,1);
    plot(nx,squeeze(real(nz(:,k,:)))); hold on;
    plot(nx,squeeze(real(nz0(:,k,:))),'--'); hold off
    axis equal; title(h(k));
    ax(2)=subplot(2,1,2);
    plot(nx,squeeze(imag(nz(:,k,:)))); hold on;
    plot(nx,squeeze(imag(nz0(:,k,:))),'--'); hold off
    linkaxes(ax,'x'); pause;
end

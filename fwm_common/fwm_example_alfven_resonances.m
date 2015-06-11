% Test the proton whistlers
global ech me uAtomic eps0 clight impedance0
if isempty(clight)
    loadconstants
end

Babs=5e-5; thB=pi/6;
% fH[H+]=7.678059231185965e+02; fH[O+]=47.987870194912283

h1=[0 80:120 125:5:360 380:20:1000 1050:50:2000].';
%h1=[0:.1:2000].';
M1=length(h1);
ions={'NO+','O+','H+','O2+','N+','He+'}; Zi=[1 1 1 1 1 1]; Massi=[30 16 1 32 14 2];
%ions={'O+','H+'}; Zi=[1 1]; Massi=[16 1];
Nions=length(ions);
Ni1=getSpecies(ions,h1);
Ne1=sum(Ni1,2);
%ii=slowchange(Ne1,.01); h=h1(ii);
h=h1;

M=length(h)

% Try different frequencies
farr=[0.06:0.02:1.5 1.6:.1:5];
nf=length(farr)
Ni=getSpecies(ions,h);
[dummy,kmax]=max(sum(Ni,2));
tmp=[0.5 2 5 10:10:100 125:25:300];
if thB==0
    nx=[0 tmp];
else
    nx=[-tmp(end:-1:1) 0 tmp];
end
Np=length(nx)
Nzero=find(nx==0)

inv_amplification=zeros(2,M,Np,nf);
res=zeros(M,Np,nf);
krange=find(h>150 & h<600);

for kf=1:nf
    f=farr(kf);
    w=2*pi*f;
    k0=w/clight;
    z=h*1e3*k0;
    [perm,S,P,D]=get_perm_with_ions(h,w,'Babs',Babs,'thB',thB,'ui',Massi,'Zi',Zi,'Ni',Ni);
    % The reflection coefficients for nx=0
    nz=zeros(4,M,Np); Fext=zeros(6,4,M,Np);
    %smallS=(abs(S./P)<1e-10)
    for k=1:M
        [nz(:,k,:),Fext(:,:,k,:)]=fwm_booker(perm(:,:,k),nx,0);
    end
    for ip=1:Np
        [Pu,Pd,Ux,Dx,Ruh,Rdl,Rul,Rdh] = fwm_radiation(z,nz(:,:,ip),Fext([1:2 4:5],:,:,ip),'E=0');
        for k=1:M
            tmp=eig(eye(2)-Rdl(:,:,k)*Rul(:,:,k));
            inv_amplification(:,k,ip,kf)=tmp;
            res(k,ip,kf)=min(abs(tmp));
        end
    end
    disp(['f=' num2str(f) ' Hz, ' ...
        'res=' num2str(min(res(krange,Nzero,kf))) ', ' num2str(kf/nf*100) '% done'])
end

resf=zeros(1,nf);
for kf=1:nf
    resf(kf)=min(res(krange,Nzero,kf));
end

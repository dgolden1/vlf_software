% Test the proton whistlers
global ech me uAtomic eps0 clight impedance0
if isempty(clight)
    loadconstants
end

Babs=5e-5; thB=pi/6;

% We start with whistlers
h1=[300:.1:500].';
M1=length(h1);
%ions={'NO+','O+','H+','O2+','N+','He+'}; Zi=[1 1 1 1 1 1]; Massi=[15 16 1 32 14 2];
ions={'O+','H+'}; Zi=[1 1]; Massi=[16 1];
Nions=length(ions);
Ni1=getSpecies(ions,h1);
Ne1=sum(Ni1,2);

a1=Ni1./repmat(Ne1,[1 Nions]);
wp21=ech^2*Ne1/(me*eps0);
wH=ech*Babs/me;
WH=Zi*ech*Babs./(Massi*uAtomic);
%ii=slowchange(Ne1,.01); h=h1(ii);
h=h1;
M=length(h);

f=760; % fH[H+]=7.678059231185965e+02; fH[O+]=47.987870194912283
w=2*pi*f;
k0=w/clight;

X1=wp21/w^2;
Y=wH/w;
Yi=WH/w;

% Contribution to R,L
%figure; plot(h1,a1.*repmat(X1,[1 Nions])./(Y*(repmat(Yi,[M1 1])-1))); legend(ions); drawnow;

[perm,S,P,D]=get_perm_with_ions(h,w,'Babs',Babs,'thB',thB,'ui',Massi,'Zi',Zi,'Ni',getSpecies(ions,h));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Apply the FWM

do_demo=0;

if do_demo
    hdemo=[300:5:1000].';
    Mdemo=length(hdemo);
    permdemo=get_perm_with_ions(hdemo,w,'Babs',Babs,'thB',thB,'ui',Massi,'Zi',Zi,'Ni',getSpecies(ions,hdemo));
    nxdemo=[-500:20:500];
    Npdemo=length(nxdemo);
    nzdemo=zeros(4,Mdemo,Npdemo);
    for k=1:Mdemo
        nzdemo(:,k,:)=fwm_booker(permdemo(:,:,k),nxdemo,0);
    end
end

Np=256;
nx=[-Np/2+1:Np/2]*5;
Np=length(nx);
nz=zeros(4,M,Np); Fext=zeros(6,4,M,Np);
for k=1:M
    [nz(:,k,:),Fext(:,:,k,:)]=fwm_booker(perm(:,:,k),nx,0);
end

z=h*1e3*k0;
% Wave propagating up
uli=[0;1]; % Whistler at 300 km
ul=zeros(2,M,Np); dh=zeros(2,M-1,Np);
for ip=1:Np
    [ul(:,:,ip),dh(:,:,ip)] = fwm_radiation(z,nz(:,:,ip),Fext([1:2 4:5],:,:,ip),'not_used',[],[],uli,[]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output altitudes
hi=[300:.1:500].';
Mi=length(hi);
zi=hi*1e3*k0;
% Prepare the indeces
[ii,dzl,dzh]=fwm_get_layers(z,zi);

% The field at output altitudes
ud=fwm_intermediate(nz,ul,dh,ii,dzl,dzh);
EH=zeros(Mi,6,Np);
for ki=1:Mi
    k=ii(ki);
    for ip=1:Np
        EH(ki,:,ip)=Fext(:,:,k,ip)*ud(:,ki,ip);
    end
end

% Show the switch between modes
figure;
for ip=1:Np
    ax(1)=subplot(3,1,1); plot(h,real(nz(:,:,ip))); title(nx(ip))
    ax(2)=subplot(3,1,2); semilogy(hi,abs(EH(:,1:2,ip))); legend('Ex','Ey');
    ax(3)=subplot(3,1,3); plot(hi,abs(ud(:,:,ip))); legend('u1','u2');
    linkaxes(ax,'x');
    pause
end

% Take a wave packet
F0=squeeze(Fext([1:2 4:5],:,1,:));
sigma_nx=100;
Hxif=exp(-nx.^2./(2*sigma_nx^2));
ampl=zeros(1,Np);
for ip=1:Np
    udi=F0(:,:,ip)\[0;0;Hxif(ip);0]; % (u,d)
    ampl(ip)=udi(2); % upward whistler mode
end

indx=[Np/2+1:Np 1:Np/2]; % NOTE: switched index convention
Hxi=zeros(1,Np);
Hxi(indx)=ifft(Hxif(indx));
dnx=nx(2)-nx(1);
dx=2*pi/(dnx*k0)/Np;
x=[(-Np/2+1):Np/2]*dx;
xkm=x/1e3;
EHf=EH.*repmat(permute(ampl,[1 3 2]),[Mi 6 1]);
EHx=EHf;
EHx(:,:,indx)=ifft(EHf(:,:,indx),[],3);

if do_demo
    % The n-surface
    figure;
    for k=1:Mdemo
        bx(1)=subplot(2,1,1);
        plot(nxdemo,squeeze(real(nzdemo(:,k,:))));
        axis equal; title(hdemo(k));
        bx(2)=subplot(2,1,2); plot(nxdemo,squeeze(imag(nzdemo(:,k,:))));
        linkaxes(bx,'x'); pause;
    end
end

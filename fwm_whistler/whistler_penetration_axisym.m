% Whister penetration for axisymmetric case
global clight impedance0 mu0
if isempty(clight)
    loadconstants
end

h=[0 55:104 130].'; % h in km
M=length(h);
Bgeo=[0 0 -5e-5];
Ne=getNe(h,'Stanford_eprof3');
f=1000;
w=2*pi*f;
k0=w/clight;
perm=get_perm(h,w,'Ne',Ne(M)*ones(size(h)),'Bgeo',Bgeo);
Iwidth=2.3e4;
nwidth=1/(k0*Iwidth) % in n-space
% To size 3 x Ms x Nnx0 x Nny0
nperpmax=5;
np0=[0:.1:nperpmax];
Nnp0=length(np0);


% The initial field
% The magnetic field is given
m=[-1 1]; % The harmonic number for the horizontal CCW dipole
nharm=2; % length of m
EHd=zeros(4,Nnp0,nharm);
EHd(3:4,:,1)=[1/2;-i/2]*exp(-np0.^2/(2*nwidth^2)); % projection onto \hat{n_+}, times \hat{n_+}
EHd(3:4,:,2)=[1/2;i/2]*exp(-np0.^2/(2*nwidth^2));

% Extract the downward whistler from the initial field
% (we can just extract the downward modes - one of them evanesces fast)
[nz,Fext]=fwm_booker(perm(:,:,M),np0,0);
EHd0=zeros(4,Nnp0,nharm);
for ip=1:Nnp0
    F=Fext([1:2 4:5],:,ip);
    for kharm=1:nharm
        ud=F\EHd(:,ip,kharm);
        EHd0(:,ip,kharm)=F*[0;0;ud(3);0];
    end
end
% For this particular example, only the first harmonic (m=-1) remains
% The surface currents
I=zeros(6,1,Nnp0,nharm);
ksa=[M];
EHd_to_I=[0 0 0 1;0 0 -1 0;0 -1 0 0;1 0 0 0];
for kharm=1:nharm
    for ip=1:Nnp0
        I([1:2 4:5],1,ip,kharm)=EHd_to_I*EHd0(:,ip,kharm);
    end
end

% Output
hi=[0:2:150].';
Mi=length(hi);
rkm=[0:5:1000];
Nr=length(rkm);

EH0=zeros(6,Mi,Nr,nharm);
for kharm=1:nharm
    disp(['******* Harmonic m=' num2str(m(kharm)) ' *******']);
    [EH0(:,:,:,kharm),EHf0,np]=...
        fwm_axisymmetric(f,h,'free',perm,ksa,np0,m(kharm),I(:,:,:,kharm),rkm,hi);
    eval(['EHf' num2str(kharm) '=EHf0; np' num2str(kharm) '=np;']);
end

% Now, we introduce phi dependence
phi=[0:5:360]*pi/180;
Nphi=length(phi);
EH=zeros(6,Mi,Nr,Nphi); % Er, Eth, Ez
for iphi=1:Nphi
    EH(:,:,:,iphi)=EH0(:,:,:,1)*exp(i*phi(iphi)*m(1))+EH0(:,:,:,2)*exp(i*phi(iphi)*m(2));
end

% Plotting
[rm,phim]=ndgrid(rkm,phi);
xm=rm.*cos(phim);
ym=rm.*sin(phim);
cnames={'E_r','E_\phi','E_z','B_r','B_\phi','B_z'};
ccoef=[[1 1 1]*impedance0 [1 1 1]*mu0];

c=5; ki=1;
Ec=squeeze(EH(c,ki,:,:))*ccoef(c);
figure;
hh=pcolor(xm,ym,real(Ec)); set(hh,'edgecolor','none'); axis equal;
xlabel('x, km'); ylabel('y, km');
title([cnames{c} ' at ' num2str(hi(ki)) ' km'])
colorbar;

S=0.5*real(cross(conj(EH(1:3,:,:,:)),EH(4:6,:,:,:)))*impedance0;
Sz=squeeze(S(3,:,:,:));
figure;
Szsat=squeeze(Sz(Mi,:,:));
Szc=Sz(:,1,1);
hh=pcolor(xm,ym,Szsat); set(hh,'edgecolor','none'); axis equal;
xlabel('x, km'); ylabel('y, km');
title(['S_z at ' num2str(hi(Mi)) ' km'])
colorbar

figure; semilogy(hi,abs(Szc))

figure;
c=4;
for iphi=1:Nphi
    Ec=squeeze(EH(c,:,:,iphi))*ccoef(c);
    imagesc(rkm,hi,real(Ec)); set(gca,'ydir','normal'); axis equal;
    xlabel('r, km'); ylabel('h, km');
    title([cnames{c} ' at \phi=' num2str(phi(iphi)*180/pi) ' deg'])
    colorbar;
    pause;
end


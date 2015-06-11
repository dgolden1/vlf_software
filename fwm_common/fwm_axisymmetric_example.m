% Demo of fwm_axisymmetric
% Emission of horizontal dipole
global impedance0 clight mu0
if isempty(impedance0)
    loadconstants
end
%h=[0 0.001 80:120].';
h=[0 81:120].';
M=length(h);

f=5000;
w=2*pi*f;
k0=w/clight;
perm=get_perm(h,w,'Bgeo',[0 0 5e-5]);
%perm=repmat(eye(3),[1 1 M]);

% Set up the horizontal dipole current [1;0;0]
m=[-1 1]; % The harmonic number for the horizontal CCW dipole
nharm=2; % length of m
I0=zeros(6,1,nharm);
I0(:,:,1)=[1/2;-i/2;0;0;0;0]; % projection onto \hat{n_+}, times \hat{n_+}
I0(:,:,2)=[1/2;i/2;0;0;0;0];
% Ir,Iphi~exp(i*m*phi)
ksa=[2]; % location of the current at h(ksa)

% Output
hi=[0 max(h)].';
Mi=length(hi);
xkm=[0:1000];
Nx=length(xkm);

EH0=zeros(6,Mi,Nx,nharm);
for kharm=1:nharm
    disp(['******* Harmonic m=' num2str(m(kharm)) ' *******']);
    [EH0(:,:,:,kharm),EHf0,np]=...
        fwm_axisymmetric(f,h,'E=0',perm,ksa,[],m(kharm),I0(:,:,kharm),xkm,hi);
    eval(['EHf' num2str(kharm) '=EHf0; np' num2str(kharm) '=np;']);
end

% The field in 2D
% E_{m,+|-|z}(rvec)~exp(i*(m+n)*phi_r), n={1|-1|0}
% E_{m,r|phi_r|z}(rvec)~exp(i*m*phi_r)

% Now, we introduce theta dependence
th=[0:360]*pi/180;
dth=th(2)-th(1)
nth=length(th);
EHth=zeros(6,Mi,Nx,nth); % Er, Eth, Ez
for ith=1:nth
    EHth(:,:,:,ith)=EH0(:,:,:,1)*exp(i*th(ith)*m(1))+EH0(:,:,:,2)*exp(i*th(ith)*m(2));
end

S=0.5*real(cross(conj(EHth(1:3,:,:,:)),EHth(4:6,:,:,:)))*impedance0;
Sr=squeeze(S(1,Mi,:,:));
Sth=squeeze(S(2,Mi,:,:));
Sz=squeeze(S(3,Mi,:,:));


%% Plotting
[rm,thm]=ndgrid(xkm,th);
xm=rm.*cos(thm);
ym=rm.*sin(thm);
c=3; ki=1;
cnames={'E_r','E_\theta','E_z','B_r','B_\theta','B_z'};
ccoef=[[1 1 1]*impedance0 [1 1 1]*mu0];
Ephi=squeeze(EHth(c,ki,:,:))*ccoef(c);
figure;
hh=pcolor(xm,ym,real(Ephi)); set(hh,'edgecolor','none'); axis equal;
xlabel('x, km'); ylabel('y, km');
title([cnames{c} ' at ' num2str(hi(ki)) ' km'])
colorbar;

Babs=mu0*squeeze(sqrt(sum(abs(EHth(4:5,ki,:,:)).^2,1)));
figure;
hh=pcolor(xm,ym,log10(Babs)); set(hh,'edgecolor','none'); axis equal;
xlabel('x, km'); ylabel('y, km');
title(['log10(Babs) at ' num2str(hi(ki)) ' km'])
colorbar;

figure;
hh=pcolor(xm,ym,log10(Sz)); set(hh,'edgecolor','none'); axis equal;
xlabel('x, km'); ylabel('y, km');
title('log10(S_z) at 120 km')
colorbar

figure;
hh=pcolor(xm,ym,Sr); set(hh,'edgecolor','none'); axis equal;
xlabel('x, km'); ylabel('y, km');
title('S_r at 120 km')
colorbar

figure;
hh=pcolor(xm,ym,Sth); set(hh,'edgecolor','none'); axis equal;
xlabel('x, km'); ylabel('y, km');
title('S_\theta at 120 km')
colorbar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting
%Ex=EH(:,:,:,1); Ey=EH(:,:,:,2); Ez=EH(:,:,:,3);
%Hx=EH(:,:,:,4); Hy=EH(:,:,:,5); Hz=EH(:,:,:,6);
%Eh=sqrt(abs(Ex).^2+abs(Ey).^2);
%Eh=sqrt(sum(abs(EH0(:,:,1:2)).^2,[],3));
%Bh=sqrt(abs(Hx).^2+abs(Hy).^2)/clight;
% Sz=0.5*real(conj(Ex).*Hy-conj(Ey).*Hx)/impedance0;

%picturesdir='pictures/joe700km_noEarth/'
picturesdir='antennaemission/'
fontsize=14;
Sz=0.5*real(conj(EH(:,:,:,1)).*EH(:,:,:,5)-conj(EH(:,:,:,2)).*EH(:,:,:,4))/impedance0;
Szsat=Sz(:,:,M).';
%Sz120=Sz(:,:,67).';
Bx0=EH(:,:,1,4).'/clight; By0=EH(:,:,1,5).'/clight;
Bh0=sqrt(abs(Bx0).^2+abs(By0).^2);
EHM=permute(EH(:,:,M,:),[2 1 4 3]);
EHx0=EHx(:,:,:,2);
EHy0=EHy(:,:,:,2);
Szx0=0.5*real(conj(EHx0(:,:,1)).*EHx0(:,:,5)-conj(EHx0(:,:,2)).*EHx0(:,:,4))/impedance0;
Szy0=0.5*real(conj(EHy0(:,:,1)).*EHy0(:,:,5)-conj(EHy0(:,:,2)).*EHy0(:,:,4))/impedance0;
Eabs=sqrt(sum(abs(EH(:,:,:,1:3)).^2,4));
Babs=sqrt(sum(abs(EH(:,:,:,4:6)).^2,4))/clight;

figure;
hh=pcolor(x/1e3,y/1e3,log10(abs(Szsat))); axis equal; set(hh,'edgecolor','none'); colorbar
set(gca,'fontsize',fontsize);
title({['log10(S_z) at ' num2str(h(M)) ' km, W/m^2'],
    ['S_{z,max}=' num2str(max(max(Szsat))) ' W/m^2, total=' num2str(sum(sum(Szsat))*dx*dy) ' W']});
xlabel('x, km'); ylabel('y, km');
set(gca,'xlim',[-500 500],'ylim',[-500 500]);
print('-depsc2',[picturesdir 'Szsat.eps']);

figure;
hh=pcolor(x/1e3,y/1e3,Szsat); axis equal; set(hh,'edgecolor','none'); colorbar
set(gca,'fontsize',fontsize);
title({['S_z at ' num2str(h(M)) ' km, W/m^2'],
    ['S_{z,max}=' num2str(max(max(Szsat))) ' W/m^2, total=' num2str(sum(sum(Szsat))*dx*dy) ' W']});
xlabel('x, km'); ylabel('y, km');
set(gca,'xlim',[-500 500],'ylim',[-500 500]);
print('-depsc2',[picturesdir 'Szsatlin.eps']);

figure;
hh=pcolor(x/1e3,y/1e3,Bh0*1e12); axis equal; set(hh,'edgecolor','none'); colorbar
set(gca,'fontsize',fontsize);
title('B_\perp at ground level, pT');
xlabel('x, km'); ylabel('y, km');
set(gca,'xlim',[-500 500],'ylim',[-500 500]);
print('-depsc2',[picturesdir 'Bground.eps']);

%figure;
%hh=pcolor(x/1e3,y/1e3,real(EHM(:,:,4))/clight*1e12); axis equal; set(hh,'edgecolor','none'); colorbar
%set(gca,'fontsize',fontsize);
%title('B_x at 700 km, pT');
%xlabel('x, km'); ylabel('y, km');
%set(gca,'xlim',[-500 500],'ylim',[-500 500]);
%print('-depsc2',[picturesdir 'Bx700.eps']);

%figure;
%hh=pcolor(x/1e3,y/1e3,real(EHM(:,:,5))/clight*1e12); axis equal; set(hh,'edgecolor','none'); colorbar
%set(gca,'fontsize',fontsize);
%title('B_y at 700 km, pT');
%xlabel('x, km'); ylabel('y, km');
%set(gca,'xlim',[-500 500],'ylim',[-500 500]);
%print('-depsc2',[picturesdir 'By700.eps']);

Bsat=Babs(:,:,M).';
figure;
hh=pcolor(x/1e3,y/1e3,log10(Bsat)); axis equal; set(hh,'edgecolor','none'); colorbar
set(gca,'fontsize',fontsize);
title(['log10(B) at ' num2str(h(M)) ' km, T, B_{max}=' num2str(max(max(Bsat))) ' T']);
xlabel('x, km'); ylabel('y, km');
set(gca,'xlim',[-500 500],'ylim',[-500 500]);
print('-depsc2',[picturesdir 'Bsat.eps']);

Esat=Eabs(:,:,M).';
figure;
hh=pcolor(x/1e3,y/1e3,log10(Esat)); axis equal; set(hh,'edgecolor','none'); colorbar
set(gca,'fontsize',fontsize);
title(['log10(E) at ' num2str(h(M)) ' km, V/m, E_{max}=' num2str(max(max(Esat))) ' V/m']);
xlabel('x, km'); ylabel('y, km');
set(gca,'xlim',[-500 500],'ylim',[-500 500]);
print('-depsc2',[picturesdir 'Esat.eps']);

figure;
hh=pcolor(x/1e3,y/1e3,log10(abs(Bx0)*1e12)); axis equal; set(hh,'edgecolor','none'); colorbar
set(gca,'fontsize',fontsize);
title('log10(B_x) at ground level, pT');
xlabel('x, km'); ylabel('y, km');
set(gca,'xlim',[-500 500],'ylim',[-500 500]);
print('-depsc2',[picturesdir 'Bxground.eps']);

figure;
hh=pcolor(x/1e3,y/1e3,real(By0)*1e12); axis equal; set(hh,'edgecolor','none'); colorbar
set(gca,'fontsize',fontsize);
title('B_y at ground level, pT');
xlabel('x, km'); ylabel('y, km');
%set(gca,'xlim',[-500 500],'ylim',[-500 500]);
print('-depsc2',[picturesdir 'Byground.eps']);

figure;
hh=pcolor(x/1e3,y/1e3,real(EH(:,:,1,3)*1e3).'); axis equal; set(hh,'edgecolor','none'); colorbar
set(gca,'fontsize',fontsize);
title('E_z at ground level, mV/m');
xlabel('x, km'); ylabel('y, km');
set(gca,'xlim',[-500 500],'ylim',[-500 500]);
print('-depsc2',[picturesdir 'Eground.eps']);

figure;
hh=pcolor(x/1e3,h,permute(Sz(:,Ny/2,:),[3 1 2]));
set(gca,'xlim',[-50 50]); axis equal; set(hh,'edgecolor','none'); colorbar
set(gca,'fontsize',fontsize);
title('S_z at y=0, W/m^2');
xlabel('x, km'); ylabel('z, km');
print('-depsc2',[picturesdir 'Szslice.eps']);

load([datadir 'sources']);
figure;
J0=sqrt(abs(Jx0).^2+abs(Jy0).^2);
hh=pcolor(x0/1e3,z0/1e3,permute(J0(:,46,:),[3 1 2]));
axis equal; set(hh,'edgecolor','none'); colorbar
set(gca,'fontsize',fontsize);
title('\Delta J at y=0, A/m^2');
xlabel('x, km'); ylabel('z, km');
print('-depsc2',[picturesdir 'J.eps']);

figure;
hh=pcolor(x0/1e3,z0/1e3,permute(J0(46,:,:),[3 2 1]));
axis equal; set(hh,'edgecolor','none'); colorbar
set(gca,'fontsize',fontsize);
title('\Delta J at x=0, A/m^2');
xlabel('y, km'); ylabel('z, km');
print('-depsc2',[picturesdir 'J2.eps']);

figure;
Jxc=permute(Jx0(46,46,:),[3 1 2]);
Jyc=permute(Jy0(46,46,:),[3 1 2]);
plot(abs([Jxc Jyc]),z0/1e3,'linewidth',1)
set(gca,'fontsize',fontsize);
xlabel('J, A/m^2');
ylabel('h, km');
legend('J_x','J_y');
grid on
print('-depsc2',[picturesdir 'Jh.eps']);

nyexample=[-120:120];
nzexample=permute(solve_booker_3d(perm(:,:,M),0,nyexample,0),[3 1 2]);
tmp=permute(abs(Jf(Nx/2,:,1,:)),[2 4 1 3]);
Jexample=sqrt(tmp(:,1).^2+tmp(:,2).^2);
coef=1.2*max(real(nzexample(:,2)))/max(Jexample);
Bveccoef=-1.2*max(real(nzexample(:,2)));
load([datadir 'Bgeo.mat']);
Bnorm=Bveccoef*Bgeo(M,:)/Babs(M);
figure;
subplot(2,1,2);
plot(nyexample,real(nzexample(:,2)),'linewidth',1);
hold on;
plot(ny,Jexample*coef,'r','linewidth',1);
plot([0 Bnorm(2)],[0 Bnorm(3)],'k','linewidth',2);
%plot(nyexample,real(nzexample(:,3)));
axis equal
grid on
set(gca,'fontsize',fontsize);
xlabel('n_y');
ylabel('n_z');
legend('whistler','currents','B field','Location','SouthEast');
print('-depsc2',[picturesdir 'nsurface']);

nxexample=[-120:120];
nzexample2=permute(solve_booker_3d(perm(:,:,M),nxexample,0,0),[2 1 3]);
tmp=permute(abs(Jf(:,Ny/2,25,:)),[1 4 2 3]);
Jexample=sqrt(tmp(:,1).^2+tmp(:,2).^2);
coef=1.2*max(real(nzexample2(:,2)))/max(Jexample);
Bveccoef=-1.2*max(real(nzexample2(:,2)));
load([datadir 'Bgeo.mat']);
Bnorm=Bveccoef*Bgeo(M,:)/Babs(M);
figure;
subplot(2,1,2);
plot(nxexample,real(nzexample2(:,2)),'linewidth',1);
hold on;
plot(nx,Jexample*coef,'r','linewidth',1);
plot([0 Bnorm(1)],[0 Bnorm(3)],'k','linewidth',2);
%plot(nyexample,real(nzexample(:,3)));
axis equal
grid on
set(gca,'fontsize',fontsize);
xlabel('n_x');
ylabel('n_z');
legend('whistler','currents','B field','Location','SouthEast');
print('-depsc2',[picturesdir 'nsurface2']);

figure;
subplot(2,1,2);
yinterp=[-300:0.5:300];
Ezx0=real(EHx0(:,:,3))*1e3;
Ezx0interp=interp1(y/1e3,Ezx0.',yinterp).';
hh=pcolor(yinterp,hi,Ezx0interp); axis equal;
%hh=pcolor(y/1e3,hi,Ezx0); axis equal;
set(hh,'edgecolor','none');
set(gca,'fontsize',fontsize);
set(gca,'xlim',[-300 300],'ylim',[0 150]);
xlabel('y, km'); ylabel('z, km');
title(['E_z at x=0, mV/m']);
colorbar
print('-depsc2',[picturesdir 'Ezx0slice.eps']);

figure;
subplot(2,1,2);
hh=pcolor(x/1e3,hi,real(EHy0(:,:,3))*1e3); axis equal;
set(hh,'edgecolor','none');
set(gca,'fontsize',fontsize);
set(gca,'xlim',[-500 500],'ylim',[0 150]);
xlabel('x, km'); ylabel('z, km');
title(['E_z at y=0, mV/m']);
colorbar
print('-depsc2',[picturesdir 'Ezy0slice.eps']);

figure;
subplot(2,1,2);
hh=pcolor(y/1e3,hi,real(EHx0(:,:,1))*1e3); axis equal;
set(hh,'edgecolor','none');
set(gca,'fontsize',fontsize);
set(gca,'xlim',[-500 500],'ylim',[0 150]);
xlabel('y, km'); ylabel('z, km');
title(['E_x at x=0, mV/m']);
colorbar
print('-depsc2',[picturesdir 'Exx0slice.eps']);

figure;
Bxy0=real(EHy0(:,:,4))*1e12/clight;
hh=pcolor(x/1e3,hi(200:end),Bxy0(200:end,:)); axis equal;
set(hh,'edgecolor','none');
set(gca,'fontsize',fontsize);
%set(gca,'xlim',[-100 100],'ylim',[0 300]);
xlabel('x, km'); ylabel('z, km');
title(['B_x at y=0, pT']);
colorbar
print('-depsc2',[picturesdir 'Bxy0slice.eps']);

figure;
Bxx0=real(EHx0(:,:,4))*1e12/clight;
yinterp=[-200:0.5:200];
Bxinterp=interp1(y/1e3,Bxx0.',yinterp).';
hh=pcolor(yinterp,hi,Bxinterp); axis equal;
%hh=pcolor(y/1e3,hi,Bxx0); axis equal;
set(hh,'edgecolor','none');
set(gca,'fontsize',fontsize);
set(gca,'xlim',[-500 500],'ylim',[100 700]);
xlabel('y, km'); ylabel('z, km');
title(['B_x at x=0, pT']);
colorbar
print('-depsc2',[picturesdir 'Bxx0slice.eps']);


figure;
hh=pcolor(x/1e3,hi,Szy0); axis equal;
set(hh,'edgecolor','none');
set(gca,'fontsize',fontsize);
set(gca,'xlim',[-500 500],'ylim',[0 700]);
xlabel('x, km'); ylabel('z, km');
title(['S_z at y=0, W/m^2']);
colorbar
print('-depsc2',[picturesdir 'Szy0slice.eps']);

figure;
hh=pcolor(y/1e3,hi,Szx0); axis equal;
set(hh,'edgecolor','none');
set(gca,'fontsize',fontsize);
set(gca,'xlim',[-200 200],'ylim',[0 700]);
xlabel('y, km'); ylabel('z, km');
title(['S_z at x=0, W/m^2']);
colorbar
print('-depsc2',[picturesdir 'Szx0slice.eps']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The emission into the Earth-ionosphere waveguide

% The horizontal Poynting vector
% Sx=0.5*real(conj(Ey).*Hz-conj(Ez).*Hy)/impedance0;
% Sy=0.5*real(conj(Ez).*Hx-conj(Ex).*Hz)/impedance0;
% Sz=0.5*real(conj(Ex).*Hy-conj(Ey).*Hx)/impedance0;

% Sx at boundaries x=-xsize and x=+xsize
EHx1=EHx(:,:,:,1);
EHx2=EHx(:,:,:,3);
EHy1=EHy(:,:,:,1);
EHy2=EHy(:,:,:,3);
ix1=xindex(1); ix2=xindex(3);
iy1=yindex(1); iy2=yindex(3);

Sx1=0.5*real(conj(EHx1(:,:,2)).*EHx1(:,:,6)-conj(EHx1(:,:,3)).*EHx1(:,:,5))/impedance0;
Sx2=0.5*real(conj(EHx2(:,:,2)).*EHx2(:,:,6)-conj(EHx2(:,:,3)).*EHx2(:,:,5))/impedance0;
% Sy at boundaries y=-ysize and y=+ysize
Sy1=0.5*real(conj(EHy1(:,:,3)).*EHy1(:,:,4)-conj(EHy1(:,:,1)).*EHy1(:,:,6))/impedance0;
Sy2=0.5*real(conj(EHy2(:,:,3)).*EHy2(:,:,4)-conj(EHy2(:,:,1)).*EHy2(:,:,6))/impedance0;

% Limit to the size of the box
zsize=100e3;
zi=hi*1e3; dzi=zi(2)-zi(1);
iz0=min(find(zi>=zsize));
dSx=Sx2-Sx1;
dSy=Sy2-Sy1;
Stotwaveguide=sum(sum(dSx(1:iz0,iy1:iy2)))*dy*dzi+sum(sum(dSy(1:iz0,ix1:ix2)))*dx*dzi

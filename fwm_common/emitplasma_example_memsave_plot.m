fontsize=14;

Sz=0.5*real(conj(EH(:,:,:,1)).*EH(:,:,:,5)-conj(EH(:,:,:,2)).*EH(:,:,:,4))/impedance0;
Szsat=Sz(:,:,Nzi).';
EHsat=permute(EH(:,:,Nzi,:),[2 1 4 3]);
EH0=permute(EH(:,:,1,:),[2 1 4 3]);
B0=EH0(:,:,4:6)/clight;
E0=EH0(:,:,1:3);

figure;
Sztot=sum(sum(Szsat))*dx*dy
%hh=pcolor(x/1e3,y/1e3,log10(Szsat));
hh=pcolor(x/1e3,y/1e3,log10(abs(Szsat)));
axis equal; set(hh,'edgecolor','none'); colorbar
set(gca,'fontsize',fontsize);
title({['log10(S_z) at ' num2str(h(M)) ' km, W/m^2'],
    ['S_{z,max}=' num2str(max(max(Szsat))) ' W/m^2, total=' num2str(Sztot) ' W']});
xlabel('x, km'); ylabel('y, km');
%set(gca,'xlim',[-500 500],'ylim',[-500 500]);

comp_names={'E_x','E_y','E_z','B_x','B_y','B_z'};
comp_coefs=[1 1 1 [1 1 1]/clight];

c=4;
iz=3;

figure;
hh=pcolor(x/1e3,y/1e3,real(EH(:,:,iz,c).')*comp_coefs(c));
axis equal; set(hh,'edgecolor','none'); colorbar
set(gca,'fontsize',fontsize);
title({[comp_names{c} ' at ' num2str(hchosen(iz)) ' km']});
xlabel('x, km'); ylabel('y, km');
%set(gca,'xlim',[-500 500],'ylim',[-500 500]);

iyi=2;

figure;
hh=pcolor(x/1e3,hi,real(EHy(:,:,c,iyi))*comp_coefs(c)); axis equal;
set(hh,'edgecolor','none');
set(gca,'fontsize',fontsize);
%set(gca,'xlim',[-500 500],'ylim',[0 150]);
xlabel('x, km'); ylabel('z, km');
title([comp_names{c} ' at y=' num2str(ychosen(iyi)/1e3) ' km']);
colorbar

ixi=1;

figure;
hh=pcolor(y/1e3,hi,real(EHx(:,:,c,ixi))*comp_coefs(c)); axis equal;
set(hh,'edgecolor','none');
set(gca,'fontsize',fontsize);
%set(gca,'xlim',[-500 500],'ylim',[0 150]);
xlabel('y, km'); ylabel('z, km');
title([comp_names{c} ' at x=' num2str(xchosen(ixi)/1e3) ' km']);
colorbar


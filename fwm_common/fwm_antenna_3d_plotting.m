%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting
fontsize=14;


if need_2d
    figure;
    %Sztot=sum(sum(Sz))*dx*dy
    imagesc(x/1e3,y/1e3,log10(abs(Sz)));
    %imagesc(x/1e3,y/1e3,Sz);
    set(gca,'ydir','normal');
    axis equal; colorbar
    title({['log10(S_z) at ' num2str(hmax) ' km, W/m^2'],
        ['S_{z,max}=' num2str(max(max(Sz))) ' W/m^2, P_0=' ...
        num2str(Ptot) ' W; transmitted=' num2str(frac*100) '%']});
    xlabel('x, km'); ylabel('y, km');
    set(gca,'xlim',[-500 500],'ylim',[-500 500]);
    echo_print(save_plots,[datadir 'Sz'])

    comp_names={'E_x','E_y','E_z','B_x','B_y','B_z'};
    comp_coefs=[1 1 1 [1 1 1]/clight];
    
    c=5;
    figure;
    imagesc(x/1e3,y/1e3,real(EHp(:,:,c))*comp_coefs(c));
    axis equal; set(gca,'ydir','normal'); colorbar
    set(gca,'fontsize',fontsize);
    title([comp_names{c} ' at ' num2str(hmax) ' km: N_{n\perp}=' ...
        num2str(Nnp) ', N_{modes}=' num2str(Ntot)]);
    xlabel('x, km'); ylabel('y, km');
    %set(gca,'xlim',[-500 500],'ylim',[-500 500]);
    echo_print(save_plots,[datadir comp_names{c}])

end

% Compare the theoretical field of a dipole
EH0=zeros(6,Nx,Ny);
Itot=2*Iscaled*impedance0; % include the impedance0 into the current
% The factor of 2 is from the image
a=hmax*1e3;
[xm,ym]=ndgrid(x,y);
r=sqrt(xm.^2+ym.^2+a^2);
e=exp(i*k0*r);
ikr=i*k0*r;
tmp=(ikr-1).*(ikr-3)./ikr+1;
EH0(1,:,:)=-Itot/(4*pi).*e.*a.*xm./r.^4.*tmp;
EH0(2,:,:)=-Itot/(4*pi).*e.*a.*ym./r.^4.*tmp;
EH0(3,:,:)=-Itot/(4*pi).*e./r.^2.*(-ikr+(ikr-1)./ikr+a^2./r.^2.*tmp);
% The expression for Ez used to be incorrect!
%EH0(3,:,:)=-Itot/(4*pi).*e.*(-i*k0./r+a^2./r.^5.*(r+(tmp-1).*(tmp-3)/(i*k0
%))); % INCORRECT
EH0(4,:,:)= Itot/(4*pi).*e.*ym./r.^3.*(ikr-1);
EH0(5,:,:)=-Itot/(4*pi).*e.*xm./r.^3.*(ikr-1);

figure;
plot(x/1e3,abs(EH(:,:,Ny0))); hold on;
plot(x/1e3,abs(EH0(:,:,Ny0)),'--'); hold off
title(['P_0=' num2str(Ptot) ' W ; transmitted=' num2str(frac*100) '%'])
xlabel('x, km')
ylabel('E or H*Z0, V/m');
legend('Ex','Ey','Ez','Hx','Hy','Hz')
grid on
echo_print(save_plots,[datadir 'EHx'])
set(gca,'yscale','log')
echo_print(save_plots,[datadir 'EHx_log'])

figure;
plot(y/1e3,abs(permute(EH(:,Nx0,:),[1 3 2]))); hold on;
plot(y/1e3,abs(permute(EH0(:,Nx0,:),[1 3 2])),'--'); hold off
title(['P_0=' num2str(Ptot) ' W ; transmitted=' num2str(frac*100) '%'])
xlabel('y, km')
ylabel('E or H*Z0, V/m');
legend('Ex','Ey','Ez','Hx','Hy','Hz')
grid on
echo_print(save_plots,[datadir 'EHy'])
set(gca,'yscale','log')
echo_print(save_plots,[datadir 'EHy_log'])


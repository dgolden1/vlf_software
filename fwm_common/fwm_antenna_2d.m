% Application of FWM to ground-based transmitter and axisymmetric plasma.
% Must call fwm_antenna_parameters before this!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the best np grid, which is coarse enough to save calculation time
% and fine enough to follow all resonance peaks
EHf0=EHf(:,:,:,1);
eval(['save ' datadir 'grid EHf0 np npb Nnp dnrequired '...
    'relerror theta thetab thetas thetabs evanescent_const']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rotate the field at each point
disp('Integrate with Bessel');
if Mi>1
    % Extend for more accurate integration on the ground
    thetalast=thetab(Nnp+1)
    thetalast=pi/2+i*acosh(npb(end))
    dxdamp=dx;
    the1=asinh(sqrt(2*evanescent_const)/(k0*dxdamp))
    dth0=dnrequired/abs(cos(thetalast+i*the1));
    Next=ceil(the1/dth0)
    thbext=thetalast+i*[1:Next]*dth0;
    npbext=real(sin(thbext));
    thext=thetalast+i*[1/2:Next-1/2]*dth0;
    npext=real(sin(thext));
    nzext=sqrt(1-npext.^2);
    Nnpe=Nnp+Next;
    EHf0e=zeros(6,Nnpe,Mi);
    EHf0e(:,1:Nnp,:)=EHf0;
    % Extend Ez and Hy to vacuum values
    switch ground_bc
        case 'E=0'
            EHf0e(3,Nnp+1:Nnpe,2)=-Iscaled*impedance0*npext.^2./nzext;
            EHf0e(5,Nnp+1:Nnpe,2)=Iscaled*impedance0*npext./nzext;
        case 'free'
            EHf0e(3,Nnp+1:Nnpe,2)=-Iscaled*impedance0*npext.^2./nzext/2;
            EHf0e(5,Nnp+1:Nnpe,2)=Iscaled*impedance0*npext./nzext/2;
        otherwise
            error('not implemented');
    end
    npe=[np npext];
    npbe=[npb npbext];
    % Damping so that E(n)->0 when n->infinity
    efactor=exp(-(dxdamp*k0*npe).^2/2);
else
    % No need to extend or damp -- a little faster
    npe=np;
    npbe=npb;
    EHf0e=EHf0;
    efactor=ones(size(npe));
end

% Ex,Ey -> E+, E-
for eh=1:2
    i1=(eh-1)*3+1;
    i2=(eh-1)*3+2;
    tmp=EHf0e(i1,:,:);
    EHf0e(i1,:,:)=tmp+i*EHf0e(i2,:,:);
    EHf0e(i2,:,:)=tmp-i*EHf0e(i2,:,:);
end

% Calculate field on axes only
EHpm=zeros(6,Nx,Mi);
% Integrate
dnp=diff(npb);
dnpe=diff(npbe);
weight=efactor.*dnpe.*npe*k0^2/(2*pi);
% - Multiply by usual integration coefficient
tstart=now*24*3600; toutput=tstart;
for ix=1:Nx
    w0=besselj(0,k0*x(ix)*npe);
    wp=i*besselj(1,k0*x(ix)*npe);
    for c=1:6
        if c==3 | c==6
            w=weight.*w0;
        else
            w=weight.*wp;
        end
        for izi=1:Mi
            EHpm(c,ix,izi)=sum(EHf0e(c,:,izi).*w);
        end
    end
    timec=now*24*3600;
    ttot=timec-tstart;
    if timec-toutput>output_interval
        toutput=timec;
        disp(['Done=' num2str(ix/Nx*100) '%; ' ...
            'Time=' hms(ttot) ...
            ', ETA=' hms(ttot/ix*(Nx-ix))]);
    end
end
% Save some memory
clear EHf0e
EH=EHpm;
EH([1 4],:,:)=0.5*(EHpm([1 4],:,:)+EHpm([2 5],:,:));
EH([2 5],:,:)=-i*0.5*(EHpm([1 4],:,:)-EHpm([2 5],:,:));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EH0=zeros(6,Nx,Mi);
switch ground_bc
    case 'free'
        Itot=Iscaled*impedance0;
    case 'E=0'
        Itot=2*Iscaled*impedance0; % include the impedance0 into the current
        % The factor of 2 is from the image
end
for izi=1:Mi
    if izi==1
        % Satellite
        a=hmax*1e3;
    else % The ground
        a=0;
    end
    r=sqrt(x.^2+a^2);
    e=exp(i*k0*r);
    ikr=i*k0*r;
    tmp=(ikr-1).*(ikr-3)./ikr+1;
    EH0(1,:,izi)=-Itot/(4*pi).*e.*a.*x./r.^4.*tmp;
    EH0(3,:,izi)=-Itot/(4*pi).*e./r.^2.*(-ikr+(ikr-1)./ikr+a^2./r.^2.*tmp);
    EH0(5,:,izi)=-Itot/(4*pi).*e.*x./r.^3.*(ikr-1);
end
eval(['save ' datadir 'EH EH EH0']);

% The power
Sz=0.5*real(conj(EH(1,:,1)).*EH(5,:,1)-conj(EH(2,:,1)).*EH(4,:,1))/impedance0;
Sz0=0.5*real(conj(EH0(1,:,1)).*EH0(5,:,1)-conj(EH0(2,:,1)).*EH0(4,:,1))/impedance0;
frac=sum(Sz.*2.*pi.*x.*dx)/Ptot
frac0=sum(Sz0.*2.*pi.*x.*dx)/Ptot
%figure; plot(np,EHf0w,'-',npnew,EHf0wnew,'x-')
Szf=0.5*real(conj(EHf0(1,:,1)).*EHf0(5,:,1)-conj(EHf0(2,:,1)).*EHf0(4,:,1))/impedance0;
% Fraction leaking in the Fourier space (gives more exact result)
fracf=sum(Szf.*np.*dnp*k0^2/(2*pi))/Ptot
eval(['save ' datadir 'Sz Sz Sz0 fracf']);

if do_plots
    for izi=1:Mi
        if izi==1
            loc='sat';
        else
            loc='gnd';
        end
        figure;
        plot(x/1e3,abs(EH(:,:,izi))); hold on;
        plot(x/1e3,abs(EH0(:,:,izi)),'--'); hold off
        grid on
        legend('Ex','Ey','Ez','Hx','Hy','Hz')
        xlabel('x, km')
        title([loc ': Nnp=' num2str(Nnp)]);
        echo_print(save_plots,[datadir 'fields' loc])
        set(gca,'yscale','log');
        echo_print(save_plots,[datadir 'fields' loc '_log'])
    end
    
    figure;
    plot(x/1e3,[Sz ; Sz0])
    grid on
    title(['P0=' num2str(Ptot) ' W; P=' num2str(fracf*Ptot) ' W; fraction=' num2str(fracf)])
    xlabel('x, km')
    ylabel('S_z, W/m^2')
    print('-depsc2',[datadir 'Sz'])
    set(gca,'yscale','log');
    echo_print(save_plots,[datadir 'Sz_log'])
end

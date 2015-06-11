%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the best np grid, which is coarse enough to save calculation time
% and fine enough to follow all resonance peaks
if do_axisymmetric
    phi=[0]; Nphi=1;
else
    Nphi=8;
    phB=atan2(Bgeo(2),Bgeo(1));
    phi=phB+[0:Nphi-1]*2*pi/Nphi;
end

if uniform_grid
    dv0=dnrequired
else
    dnrequired
    dv0=dnrequired/max(abs(cos(thetab)))
end
iteration=0;
while 1
    if iteration==0
        disp('Initial estimate of the Fourier component of field at np');
    else
        disp(['Re-do the calculation, iteration=' num2str(iteration)])
    end
    disp(['Nnp=' num2str(Nnp)]);
    EHf=zeros(6,Nnp,Mi,Nphi);
    tstart=now*24*3600; toutput=tstart;
    for iphi=1:Nphi
        disp(['Trying angle ' num2str(phi(iphi)*180/pi) ' deg (' ...
            num2str(iphi) ' of ' num2str(Nphi) ')']);
        nx=np*cos(phi(iphi));
        ny=np*sin(phi(iphi));
        if sground~=0
            ground_bc=fwm_Rground(1+i*sground/(w*eps0),nx,ny);
        end
        EHf(:,:,:,iphi)=impedance0*Iscaled*fwm_antenna_transmitter(...
            do_vacuum,zd,perm,isotropic,nx,ny,zero_collisions,ground_bc,Mi);
        timec=now*24*3600;
        ttot=timec-tstart;
        if timec-toutput>output_interval
            toutput=timec;
            disp(['Done=' num2str(iphi/Nphi*100) '%; ' ...
                'Time=' hms(ttot) ...
                ', ETA=' hms(ttot/iphi*(Nphi-iphi))]);
        end
    end
    if iteration==0
        % Save the first attempt
        EHftry=EHf; nptry=np; Nnptry=Nnp; npbtry=npb; phitry=phi; Nphitry=Nphi;
        eval(['save ' datadir 'try EHftry nptry Nnptry npbtry Nphitry phitry']);
    end

    % Choose the best np grid, by choosing the increments in such a way
    % that the integration error |f"|*dv^3=const
    % The integration variable is v=np for uniform grid or v=theta for
    % non-uniform grid.
    ga=zeros(6,Nnp,Mi,Nphi);
    relerror=zeros(6,Mi,Nphi);
    for c=1:6
        for izi=1:Mi
            skip=(strcmp(ground_bc,'E=0') & izi==2 & (c==1 | c==2 | c==6));
            skip=skip | (do_vacuum & (c==2 | c==4 | c==6));
            if skip
                % Skip the variables that are always zero
                continue
            end
            for iphi=1:Nphi
                if uniform_grid
                    f0=EHf(c,:,izi,iphi);
                    % Integration variable is np
                    v=np;
                    vb=npb;
                else
                    % Integration variable is length along theta curve
                    f0=EHf(c,:,izi,iphi).*abs(cos(theta));
                    v=thetas;
                    vb=thetabs;
                end
                % The integration error is = |f"|*dv^3
                dvb=diff(vb);
                dv=diff(v);
                ddv=(dv(1:Nnp-2)+dv(2:Nnp-1))/2;
                f2=[0 abs(diff(diff(f0)./dv)./ddv) 0];
                % - approximation to |f"|
                total=sum(abs(f0).*dvb); % integral
                e0=retol*total/10; % target for |f"|*dv^3
                % Estimate for new value of 1/dn
                ga(c,:,izi,iphi)=max((f2/e0).^(1/3),1/dv0);
                % We coarsen the mesh at some points but preserve the
                % relative error
                relerror(c,izi,iphi)=max(abs(f2).*dvb.^3)/total;
            end
        end
    end
    relerror
    g=max(max(max(ga,[],4),[],3),[],1); % max over the spectator indeces
    G=cumsum(g.*dvb); % dG=1 if dn is optimal
    Gd=linspace(G(1),G(Nnp),ceil(G(Nnp)-G(1)));
    vnew=interp1(G,v,Gd);
    vbnew=[vb(1) 0.5*(vnew(1:end-1)+vnew(2:end)) vb(end)];
    Nnpnew=length(vnew)
    if max(max(max(relerror)))<retol & iteration>0 % & Nnpnew>0.9*Nnp
        % Do at least one iteration before exiting, so that we don't use
        % the initial inefficient grid (to save time, the result should not
        % change).
        break
    end
    % EXIT FROM THE CYCLE IS HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The new grid
    if uniform_grid
        npnew=vnew;
        npbnew=vbnew;
    else
        i0=min(find(vbnew>pi/2));
        % insert one more point at theta=pi/2
        thetabs=[vbnew(1:i0-1) pi/2 vbnew(i0:end)];
        Nnpnew=length(thetabs)-1
        thetab=[vbnew(1:i0-1) pi/2 (vbnew(i0:end)-pi/2)*i+pi/2];
        theta=0.5*(thetab(1:end-1)+thetab(2:end));
        thetas=0.5*(thetabs(1:end-1)+thetabs(2:end));
        npnew=real(sin(theta));
        npbnew=real(sin(thetab));
    end
    Nnp=Nnpnew; np=npnew; npb=npbnew;
    iteration=iteration+1;
end
if do_plots
    for izi=1:Mi
        if izi==1
            loc='sat';
        else
            loc='gnd';
        end
        % relerror is 6 x Mi x Nphi; find iphi corresponding to max error
        [dummy,iphi]=max(max(relerror(:,izi,:),[],1),[],3);
        figure;
        plot(nptry,real(EHftry(:,:,izi,iphi)),'-'); hold on
        plot(np,real(EHf(:,:,izi,iphi)),'x'); hold off
        title([loc ': iphi=' num2str(iphi)]);
        drawnow;
        echo_print(save_plots,[datadir 'try' loc num2str(iphi)])
    end
end
% EHf will be kept for 2D calculations, and discarded for 3D calculations

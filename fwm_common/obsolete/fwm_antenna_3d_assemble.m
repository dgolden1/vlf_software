%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inverse transform
% This would be SOO much faster if we did an FFT
disp('***** Sum the modes with appropriate weights (last step) *****');
% The weighted field
EHfw=EHf.*repmat(da,[6 1])*(k0^2/(2*pi)^2);
% - Multiply by usual integration coefficient
expdx=exp(i*k0*dx*repmat(nx,[6 1]));
expdy=exp(i*k0*dy*repmat(ny,[6 1]));
if need_2d
    % Pre-calculate the Fourier coefficients
    expy0=expdy.^(y(1)/dy); % =exp(i*k0*y(1)*nymat);
    if exist([datadir 'EH.mat'],'file')
        load([datadir 'EH']);
        disp('----- Loaded precalculated fields -----');
        ixstart=Nx+1;
    elseif exist([datadir 'EH_backup.mat'],'file')
        % Load from backup
        load([datadir 'EH_backup']);
        disp('----- Restored fields from backup -----');
        ixstart=ix;
    else
        EH=zeros(6,Nx,Ny);
        expx=expdx.^(x(1)/dx);
        ixstart=1;
    end
    tstart=now*24*3600; toutput=tstart; timebkup=tstart;
    for ix=ixstart:Nx
        expy=expy0; % =exp(i*k0*y(1)*nymat);
        tmp=EHfw.*expx;
        for iy=1:Ny
            %EHsat(:,ix,iy)=sum(EHfw.*exp(i*k0*(x(ix)*nxmat+y(iy)*nymat)),2);
            EH(:,ix,iy)=sum(tmp.*expy,2);
            expy=expy.*expdy;
        end
        expx=expx.*expdx;
        timec=now*24*3600;
        ttot=timec-tstart;
        if timec-toutput>output_interval
            toutput=timec;
            disp(['Done=' num2str(ix/Nx*100) '%; ' ...
            'Time=' hms(ttot) ...
            ', ETA=' hms(ttot/(ix-ixstart+1)*(Nx-ix))]);
        end
        % Do backups every hour
        if timec-timebkup>backup_interval
            timebkup=timec;
            disp('Backing up ...');
            eval(['save ' datadir 'EH_backup EH ix expx']);
            disp(' ... done');
        end
    end
    delete([datadir 'EH_backup.mat']);
else
    % Calculate field on axes only
    expx=expdx.^(x(1)/dx);
    disp('x-direction');
    tstart=now*24*3600; toutput=tstart;
    for ix=1:Nx
        EH(:,ix,Ny0)=sum(EHfw.*expx,2);
        expx=expx.*expdx;
        timec=now*24*3600;
        ttot=timec-tstart;
        if timec-toutput>output_interval
            toutput=timec;
            disp(['Done=' num2str(ix/Nx*100) '%; ' ...
                'Time=' hms(ttot) ...
                ', ETA=' hms(ttot/ix*(Nx-ix))]);
        end
    end
    expy=expdy.^(y(1)/dy);
    disp('y-direction');
    tstart=now*24*3600; toutput=tstart;
    for iy=1:Ny
        EH(:,Nx0,iy)=sum(EHfw.*expy,2);
        expy=expy.*expdy;
        timec=now*24*3600;
        ttot=timec-tstart;
        if timec-toutput>output_interval
            toutput=timec;
            disp(['Done=' num2str(iy/Ny*100) '%; ' ...
                'Time=' hms(ttot) ...
                ', ETA=' hms(ttot/iy*(Ny-iy))]);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EHp=permute(EH,[3 2 1]); % Note: switched x and y
Szp=0.5*real(conj(EHp(:,:,1)).*EHp(:,:,5)-conj(EHp(:,:,2)).*EHp(:,:,4))/impedance0;
Sz=Szp.'; % restore the order
eval(['save ' datadir 'EH EH EHp Sz Szp']);


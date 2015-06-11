% Call fwm_antenna_parameters and fwm_antenna_bestgrid first!
ringarea=pi*diff(npb.^2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up the (nx,ny) mesh
Nphi=zeros(1,Nnp);
for kp=1:Nnp
    if np(kp)<=1
        Nphitmp=2*pi*np(kp)/dnrequired; % Nphi must be greater than this
        Nphi0=2^(max(0,ceil(log2(Nphitmp))));
    end % if np(kp)>1, reuse the previous Nphi0
    Nphi(kp)=Nphi0;
end
% Nphi0 stores the maximum Nphi
ph2=cumsum(Nphi);
Ntot=ph2(Nnp);
ph1=[0 ph2(1:Nnp-1)];

eval(['save ' datadir 'grid dnrequired np npb Nphi ringarea ' ...
    'magic_scale rmax ph1 ph2 Nnp Ntot relerror']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Apply FWM for serious.
disp('***** Calculate the fields in (nx,ny) space *****')
disp(['Nnp=' num2str(Nnp) '; Ntot=' num2str(Ntot)]);
% To save memory, we have to calculate EHf in chunks, corresponding
% to same np
nx=zeros(1,Ntot); ny=zeros(1,Ntot); da=zeros(1,Ntot);
if exist([datadir 'EHf.mat'],'file')
    load([datadir 'EHf']);
    disp('----- Loaded precalculated wave amplitudes -----');
    ipstart=Nnp+1;
elseif exist([datadir 'EHf_backup.mat'],'file')
    % Load from backup
    load([datadir 'EHf_backup']);
    disp('----- Restored wave amplitudes from backup -----');
    ipstart=ip;
    % Catch up on nx,ny,da
    for ip=1:ipstart-1
        ii=[ph1(ip)+1:ph2(ip)];
        dphi=2*pi/Nphi(ip);
        p=[0:Nphi(ip)-1]*dphi;
        nxtmp=np(ip)*cos(p);
        nytmp=np(ip)*sin(p);
        nx(ii)=nxtmp; ny(ii)=nytmp; da(ii)=ringarea(ip)/Nphi(ip);
    end
else
    EHf=zeros(6,Ntot);
    ipstart=1;
end
tstart=now*24*3600; toutput=tstart; timebkup=tstart;
for ip=ipstart:Nnp
    ii=[ph1(ip)+1:ph2(ip)];
    dphi=2*pi/Nphi(ip);
    p=[0:Nphi(ip)-1]*dphi;
    nxtmp=np(ip)*cos(p);
    nytmp=np(ip)*sin(p);
    if sground~=0
        ground_bc=fwm_Rground(1+i*sground/(w*eps0),nxtmp,nytmp,1);
    end
    EHf(:,ii)=impedance0*Iscaled*fwm_antenna_transmitter(...
        do_vacuum,zd,perm,isotropic,nxtmp,nytmp,zero_collisions,ground_bc,Mi);
    % These are needed for mode summation (next step):
    % implemented in fwm_antenna_3d_assemble
    nx(ii)=nxtmp; ny(ii)=nytmp; da(ii)=ringarea(ip)/Nphi(ip);
    timec=now*24*3600;
    ttot=timec-tstart;
    if timec-toutput>output_interval
        toutput=timec;
        % Note that the length of ip cycle is not constant but proportional
        % to ip => quadratic dependence of the required time.
        disp(['Done=' num2str(ph2(ip)/Ntot*100) '%; ' ...
            'Time=' hms(ttot) ...
            ', ETA=' hms(ttot/(ph2(ip)-ph1(ipstart))*(Ntot-ph2(ip)))]);
    end
    % Do backups every hour
    if timec-timebkup>backup_interval
        timebkup=timec;
        disp('Backing up ...');
        eval(['save ' datadir 'EHf_backup EHf ip']);
        disp(' ... done');
    end
end
delete([datadir 'EHf_backup.mat']);
Szf=0.5*real(conj(EHf(1,:)).*EHf(5,:)-conj(EHf(2,:)).*EHf(4,:))/impedance0;
frac=sum(Szf.*da*(k0^2/(2*pi)^2))/Ptot
eval(['save ' datadir 'EHf EHf nx ny da Szf frac']);



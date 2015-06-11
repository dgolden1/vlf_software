% Memory-saving version of emitplasma_example
% Unfortunately, a lot of obtained information cannot be stored.

restore=0
backup_interval=3600
doslices=1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify parameters
datadir='antennaemission7c/'
% Altitude in km
% Insert one more point at low altitude so that J is interpolated correctly
h=[0 1 80:2:100 105:5:150 160:10:300 320:20:700].';
given_Ne=0;
given_nu=0;
w=2*pi*3000; % High frequency will require higher horizontal sampling
Nx=2^7;
Ny=2^7;
dx=10e3;
dy=10e3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize various variables
emitplasma_init

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify sources - the current densities
Jz0=zeros(3,3,2);
Jz0(2,2,1)=1;
% x, y, z are in meters
z0=z(1:2);
x0=[-dx 0 dx];
y0=[-dy 0 dy];
% Jx0,Jy0 are zero, and do not have to be specified.
Jx0=[]; % This looks like a funny box in the 9-point font!
Jy0=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interpolate currents
disp('Interpolate currents');
[J,sxindex,syindex,szindex]=...
    emitplasma_sources_interp(Jx0,Jy0,Jz0,x0,y0,z0,x,y,z);
Ms=length(szindex);
eval(['save ' datadir 'sources Jx0 Jy0 Jz0 x0 y0 z0 J ' ...
    'sxindex syindex szindex Ms']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Slices initialization
if doslices
    hi=[0:.5:700];
    xchosen0=[-100:50:100]*1e3;
    ychosen0=[-100:50:100]*1e3;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Altitudes for output
hchosen0=[0 1 80 100 300 700];
Nzi=length(hchosen0)
zindex=zeros(1,Nzi);
for k=1:Nzi
    zindex(k)=max(find(h<=hchosen0(k)));
end
hchosen=h(zindex)
% - we only save data at these heights

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Horizontal coordinates for output
if doslices
    % Additional initialization for slices
    Mi=length(hi);
    zi=hi.'*1e3;
    zdimi=zi*k0;
    Nxi=length(xchosen0);
    for k=1:Nxi
        xindex(k)=max(find(x<=xchosen0(k)));
    end
    xchosen=x(xindex) % coordinates of x=const slices
    Nyi=length(ychosen0);
    for k=1:Nyi
        yindex(k)=max(find(y<=ychosen0(k)));
    end
    ychosen=y(yindex) % coordinates of y=const slices
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output variables
EHf=zeros(Nx,Ny,Nzi,6); % This will be our ONLY result
if doslices
    % EHx, EHy will be our ONLY additional result for slices calculations
    % The boundaries enclosing the emitting region
    EHx=zeros(Mi,Ny,6,Nxi);
    EHy=zeros(Mi,Nx,6,Nyi);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Temporary variables
nz=zeros(4,Ny,M); Fext=zeros(6,4,Ny,M);
ud=zeros(4,M);
uplus=zeros(2,M); dminus=zeros(2,M);
us=zeros(2,M); ds=zeros(2,M);
if doslices
    ud=zeros(4,Ny,M);
    udprime=zeros(4,Ny,M-1);
    Dud=zeros(4,Ms);
    udzi=zeros(4,Ny);
    EHzi=zeros(Ny,6);
    EHyf=EHy; % Not really temporary, but pretty useless as a final result.
    % If restoring from backup, EHyf will be overwritten.
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Restore from backup, if necessary
if restore
    % Restore values calculated so far for
    % EHx EHyf EHf
    load([datadir 'backup']);
    ixstart=ix+1;
    disp(['Restoring from backup, starting at ix=' num2str(ixstart)]);
else
    ixstart=1;
    disp('Initial calculation, starting at ix=1');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cycle over horizontal wave vectors
disp('Starting the cycle');
tstart=now*24*3600;
tJ=0; tslice=0; tmain=0;
timebkup=tstart;
for ix=ixstart:Nx
    % Calculate nz and modes
    % Save some time using vectorization
    ttmp=now*24*3600;
    for k=1:M
        [nz(:,:,k),Fext(:,:,:,k)]=solve_booker_3d(perm(:,:,k),nx(ix),ny,isvacuum(k));
    end
    tmain=tmain+now*24*3600-ttmp;
    % The sources from currents
    ttmp=now*24*3600;
    % DEH is Delta E, Delta H
    % DEHf means it is a FT (into nx,ny domain)
    % DEHfxi is the slice of DEHf taken at nx(ix)
    DEHfxi=emitplasma_sources_slice(ix,nx(ix),ny,Nx,Ny,z,J,...
        sxindex,syindex,szindex,k0*dx,k0*dy,'central',perm(:,:,szindex));
    tJ=tJ+now*24*3600-ttmp;
    ttmp=now*24*3600;
    for iy=1:Ny
        nz0=permute(nz(:,iy,:),[1 3 2]); % 4 x M array
        F=permute(Fext([1:2 4:5],:,iy,:),[1 2 4 3]); % 4 x 4 x M array
        % Reflection coefs
        % These are Rd,Ru,U,D in the paper (NOTE THE ORDER!)
        [R1,R2,A,B]=reflectplasma(zdim,nz0,F);
        % Find the total up and down waves and fields
        % -------------------------------------------
        % Find the up and down waves due to sources in immediate vicinity
        % of the sources, i.e. uplus and dminus
        %uplus(:,:)=0; dminus(:,:)=0;
        for nhs=1:Ms % cycle over source altitudes
            % This cycle should be fast (because Ms << M)
            k=szindex(nhs);
            % Delta u, Delta d
            d=F(:,:,k)\DEHfxi(:,iy,nhs);
            if doslices
                Dud(:,nhs)=d;
            end
            r1=R1(:,:,k); r2=R2(:,:,k);
            i12=inv(eye(2)-r1*r2);
            tmp=i12*(d(1:2)-r1*d(3:4));
            uplus(:,k)=tmp;
            dminus(:,k)=r2*tmp-d(3:4);
        end
        % Propagate up: find "us", up-wave due only to sources below (no
        % reflected waves coming from sources above)
        us(:,1)=uplus(:,1);
        for k=1:M-1
            us(:,k+1)=uplus(:,k+1)+A(:,:,k)*us(:,k);
        end
        % Propagate down: find "ds", down-wave due only to sources above
        % (no reflected waves coming from sources below). Note that these
        % are calculated just above the plane of the source.
        % ds(:,M)==0 because there are no sources at h>h(M)
        for k=M-1:-1:1
            ds(:,k)=B(:,:,k)*(ds(:,k+1)+dminus(:,k+1));
        end
        % Now, add up and down waves from all sources (not just in
        % direction of propagation) and find fields
        if ~doslices
            for izi=1:Nzi
                k=zindex(izi);
                % The mode amplitudes
                udtmp=[us(:,k)+R1(:,:,k)*ds(:,k) ; ds(:,k)+R2(:,:,k)*us(:,k)];
                % Fourier components of the fields
                EHf(ix,iy,izi,:)=Fext(:,:,iy,k)*udtmp;
            end
        else
            % We store nx=const information for ud, udprime for all ny
            for k=1:M
                ud(:,iy,k)=[us(:,k)+R1(:,:,k)*ds(:,k) ; ds(:,k)+R2(:,:,k)*us(:,k)];
            end
            % NOTE: udprime(k) is (u_{k+1}',d_{k+1}'), although index is k
            udbelow=permute(ud(:,iy,:),[1 3 2]);
            udbelow(:,szindex)=udbelow(:,szindex)-Dud; % ud below the sources
            for k=1:M-1
                udprime(:,iy,k)=F(:,:,k)\F(:,:,k+1)*udbelow(:,k+1);
            end
            % Horizontal slices (exactly same as for doslices==0)
            for izi=1:Nzi
                k=zindex(izi);
                EHf(ix,iy,izi,:)=Fext(:,:,iy,k)*ud(:,iy,k);
            end
        end
    end % of ny cycle
    tmain=tmain+now*24*3600-ttmp;
    ttmp=now*24*3600;
    if doslices
        % We have nz, Fext, ud, udprime for the whole nx=const plane
        % Slices calculations
        for ki=1:Mi
            k=max(find(zdim<=zdimi(ki))); % Which layer are we in?
            dzdimd=zdimi(ki)-zdim(k); % Distance to the boundary below
            if dzdimd==0
                % Simple case -- the new refined mesh coincides with old mesh
                udzi=ud(:,:,k);
            else
                % This excludes the case of k==M, so k+1 is still valid
                dzdimu=zdim(k+1)-zdimi(ki); % Distance to the boundary above
                % Use the matrix capabilities of MATLAB.
                % Avoid instability: upward wave -- from below
                udzi(1:2,:)=exp(i*dzdimd*nz(1:2,:,k)).*ud(1:2,:,k);
                % Downward wave -- from above
                udzi(3:4,:)=exp(-i*dzdimu*nz(3:4,:,k)).*udprime(3:4,:,k);
            end
            % Convert udzi to FT of e/m field EHf, in the nx=const plane:
            for iy=1:Ny
                EHfzi(iy,:)=Fext(:,:,iy,k)*udzi(:,iy);
            end
            % Go to variables (nx,y,z) in nx=const plane 
            EHzi(indy,:)=ifft(EHfzi(indy,:),[],1);
            % For y=const slices, we can store the info:
            EHyf(ki,ix,:,:)=permute(EHzi(yindex,:),[2 1]);
            % - then we'll IFT in x-direction when the cycle is finished.
            % x=const slices are not so easy
            % The IFT in x-direction has to be cumulative.
            for ixi=1:Nxi
                % x=0 or nx=0 corresponds to ix=Nx/2
                coef=exp(2*pi*j*(xindex(ixi)-Nx/2)*(ix-Nx/2)/Nx)/Nx;
                EHx(ki,:,:,ixi)=EHx(ki,:,:,ixi)+permute(EHzi,[3 1 2])*coef;
            end
        end
    end
    tslice=tslice+now*24*3600-ttmp;
    timec=now*24*3600;
    ttot=timec-tstart;
    disp(['Done=' num2str(ix/Nx*100) '%; ' ...
        'Time (' hms(ttot) '): J=' num2str(tJ/ttot*100) '%; ' ...
        'main=' num2str(tmain/ttot*100) '%; ' ...
        'slices=' num2str(tslice/ttot*100) '%; ' ...
        'ETA=' hms(ttot/(ix-ixstart+1)*(Nx-ix))]);
    % Do backups every hour
    if timec-timebkup>backup_interval
        timebkup=timec;
        disp('Backing up ...');
        eval(['save ' datadir 'backup EHx EHyf EHf ix']);
        disp(' ... done');
    end
end
if doslices
    EHy(:,indx,:,:)=ifft(EHyf(:,indx,:,:),[],2);
    eval(['save ' datadir 'EHxy EHx EHy ' ...
        'xchosen ychosen Nxi Nyi xindex yindex hi zdimi Mi']);
end
disp(['Time=' hms(ttot)])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Take the IFFT
EH=zeros(Nx,Ny,Nzi,6);
EH(indx,:,:,:)=ifft(EHf(indx,:,:,:),[],1); % Temporary
EH(:,indy,:,:)=ifft(EH(:,indy,:,:),[],2);
% NEW: must add the electrostatic field of the source
ezz=repmat(perm(3,3,szindex),[length(sxindex) length(syindex) 1]);
EH(sxindex,syindex,szindex,3)=EH(sxindex,syindex,szindex,3)+...
    impedance0*J(:,:,:,3)./(i*k0*ezz);
eval(['save ' datadir 'EH EH EHf hchosen zindex Nzi']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting
emitplasma_example_memsave_plot

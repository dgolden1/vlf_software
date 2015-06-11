function varargout=fwm_waves2(varargin)
%FWM_WAVES Calculate EHf for given np
% Usage:
%    [EHf,nx,ny,da,Nphi]=fwm_waves(zd,eground,perm,dn0,npb,np,...
%       ksa,coornperp,nperp1,nperp2,I0,hi);
% Inputs:
%    zd (M) - altitudes (dimensionless, = z*k0)
%    eground - ground b.c. (see FWM_FIELD)
%    perm (3 x 3 x M) - dielectric permittivity tensor
%    dn0 - minimum change in nperp
%    npb (Nnp+1) - boundaries of np==|nperp|
%    np (Nnp) - central values of np
%    ksa,coornperp,nperp1,nperp2,I0 - current (see FWM_NONAXISYMMETRIC)
%    hi (Mi) - output altitudes in km
% Outputs -- see FWM_NONAXISYMMETRIC
%    EHf (6 x Mi x Nmodes) - fields
%    nx (Nmodes), ny (Nmodes), da (Nmodes), Nphi (Nnp)
% See also: FWM_NONAXISYMMETRIC, FWM_FIELD

%% Constants
program='FWM_WAVES';
arginnames={'zd','eground','perm','dn0','npb','np',...
    'ksa','coornperp','nperp1','nperp2','Ie0','Im0','EHfu0','EHfd0',...
    'kia','dzl','dzh'};
argoutnames={'EHf','nx','ny','da','Nphi'};

%% REUSABLE: Arguments
stdargin=length(arginnames);
stdargout=length(argoutnames);
if nargin < stdargin+1
    bkp_file=[];
else
    bkp_file=varargin{stdargin+1};
end
if nargin < stdargin
    error('Not enough arguments!')
end
for k=1:stdargin
    eval([arginnames{k} '=varargin{k};'])
end
global output_interval backup_interval
if isempty(output_interval)
    output_interval=20;
end
if isempty(backup_interval)
    backup_interval=3600;
end
do_backups=~isempty(bkp_file);

%% Interpretation of arguments
point_source=isempty(nperp1)
Mi=length(kia);
Ms=length(ksa);
switch coornperp
	case 1
		nx0=nperp1; ny0=nperp2;
	case 2
		np0=nperp1; phin0=nperp2;
	case 3
		np0=nperp1; m0=nperp2;
end

%% Set up the (nx,ny) mesh
Nnp=length(np);
Nphi=zeros(1,Nnp);
for kp=1:Nnp
    % Change: do not assume that for np>1 we can take bigger intervals.
    Nphitmp=2*pi*np(kp)/dn0; % Nphi must be greater than this
    Nphi(kp)=2^(max(0,ceil(log2(Nphitmp))));
end
Nphimax=max(Nphi);
ph2=cumsum(Nphi);
Ntot=ph2(Nnp);
ph1=[0 ph2(1:Nnp-1)];

%% Various helpful variables
nx=zeros(1,Ntot); ny=zeros(1,Ntot); da=zeros(1,Ntot);
ringarea=pi*diff(npb.^2);
for ip=1:Nnp
    ii=[ph1(ip)+1:ph2(ip)];
    dphi=2*pi/Nphi(ip);
    p=[0:Nphi(ip)-1]*dphi;
    nxtmp=np(ip)*cos(p);
    nytmp=np(ip)*sin(p);
    nx(ii)=nxtmp; ny(ii)=nytmp; da(ii)=ringarea(ip)/Nphi(ip);
end

%% Prepare a matrix used to interpolate or calculate the current
if point_source
    % Point source, for both cartesian and harmonics cases
    if isempty(Ie0)
        Ie0i=[];
    else
        Ie0i=repmat(I0,[1 1 Nphimax]);
    end
    if isempty(Im0)
        Im0i=[];
    else
        Im0i=repmat(Im0,[1 1 length(np_arg)]);
    end
    if isempty(EHfu0)
        EHfu0i=[];
    else
        EHfu0i=repmat(EHfu0,[1 length(np_arg)]);
    end
    if isempty(EHfd0)
        EHfd0i=[];
    else
        EHfd0i=repmat(EHfd0,[1 length(np_arg)]);
    end
else
	switch coornperp
		case 1
			% To size Nny0 x Nnx0 x 3 x Ms
			% which is more convenient to use with interp2
			% NOTE: we switched x <-> y directions!
            if isempty(Ie0)
                
			Ie0p=permute(Ie0,[4 3 1 2]);
		case 2
			error('not implemented');
		case 3
			error('not implemented');
			% Interpolate at np
			% To size Nnp0 x 3 x Ms x Nh and back to 3 x Ms x Nnp x Nh
			I0p=permute(interp1(np0,permute(I0,[3 1 2 4]),np),[2 3 1 4]);
		otherwise
			error('unknown coornperp');
	end
	Ie0i=zeros(3,Ms,Nphimax); % pre-allocate
end

%% REUSABLE: determine if we can restore from a backup
if do_backups
    bkp_file_ext=[bkp_file '_' program '.mat'];
    if ~exist(bkp_file_ext,'file')
        disp([program ': creating a new backup file ' bkp_file_ext])
        status='starting';
        save(bkp_file_ext,arginnames{:},'status');
        restore=0;
    elseif ~check_bkp_file(bkp_file_ext,arginnames,varargin(1:stdargin))
        disp(['WARNING: the backup file ' bkp_file_ext ' is invalid! Not doing backups']);
        do_backups=0;
    else % File exists and is valid
        disp(['Found backup file ' bkp_file_ext]);
        tmp=load(bkp_file_ext,'status');
        if ~isfield(tmp,'status')
            error('no status!')
        end
        status=tmp.status;
        if strcmp(status,'done')
            disp([program ': loaded precalculated output arguments!']);
            % No need to do anything
            tmp=load(bkp_file_ext,argoutnames{:});
            if nargout>stdargout
                error('Too many output arguments');
            end
            for k=1:nargout
                eval(['varargout{k}=tmp.' argoutnames{k} ';']);
            end
            return;
        end
        restore=strcmp(status,'in progress');
    end
end
if do_backups
    disp([program ' BACKUP STATUS = ' status]);
end

%% Restore
if do_backups & restore
    % The file is guaranteed to exist, and to contain relevant information
    tmp=load(bkp_file_ext,'ip','EHf');
    ipstart=tmp.ip+1;
    EHf=tmp.EHf;
    disp([program ': restored from backup']);
else
    ipstart=1;
    EHf=zeros(6,Mi,Ntot);
    disp([program ': starting a new calculation']);
end

%% Cycle over the (nx,ny) mesh
% Equivalent of former fwm_antenna_3d_waves
tstart=now*24*3600; toutput=tstart; timebkup=tstart;
for ip=ipstart:Nnp
    ii=[ph1(ip)+1:ph2(ip)];
    dphi=2*pi/Nphi(ip);
    p=[0:Nphi(ip)-1]*dphi;
    nxtmp=np(ip)*cos(p);
    nytmp=np(ip)*sin(p);
    % Interpolate the current
    % We have 3D situation
    % We only use I0i(3,Ms,Nphi(ip))
    % The current - interpolate
    if ~point_source
		switch coornperp
			case 1
				% Interpolate
				for c=1:3
					for ks=1:Ms
						% I0p(:,:,c,ks) has size Nny0 x Nnx0
						I0i(c,ks,1:Nphi(ip))=interp2(nx0,ny0,I0p(:,:,c,ks),nxtmp,nytmp);
					end
				end
			case 2
				error('not implemented');
			case 3
				% Calculate by summation
				% Size = 3 x Ms x Nphi(ip) x Nh
				e=permute(repmat(exp(i*m(:)*p(:).'),[1 1 3 Ms]),[3 4 2 1]);
				Ie0i=sum(repmat(I0p(:,:,ip,:),[1 1 Nphi(ip) 1]).*e,4);
			otherwise
				error('unknown coornperp');
		end
	end
    EHf(:,:,ii)=fwm_field(zd,eground,perm,ksa,nxtmp,nytmp,...
        Ie0i,Im0i,EHfu0i,EHfd0i,kia,dzl,dzh);
    % These are needed for mode summation (next step):
    % implemented in fwm_antenna_3d_assemble
    timec=now*24*3600;
    ttot=timec-tstart;
    if timec-toutput>output_interval
        toutput=timec;
        % Note that the length of ip cycle is not constant but proportional
        % to ip => quadratic dependence of the required time.
        disp([program ': Done=' num2str(ph2(ip)/Ntot*100) '%; ' ...
            'Time=' hms(ttot) ...
            ', ETA=' hms(ttot/(ph2(ip)-ph1(ipstart))*(Ntot-ph2(ip)))]);
    end
    if do_backups
        % Do backups every hour
        if timec-timebkup>backup_interval
            timebkup=timec;
            disp('Backing up ...');
            status='in progress';
            save(bkp_file_ext,'ip','EHf','status','-append');
            disp(' ... done');
        end
    end
end

%% REUSABLE: Final backup
if do_backups
    disp(['Saving results of ' program  ' into ' bkp_file_ext ' ...']);
    status='done';
    save(bkp_file_ext,argoutnames{:},'status','-append');
    disp(' ... done');
end
% Output
if nargout>stdargout
    error('Too many output arguments');
end
for k=1:nargout
    eval(['varargout{k}=' argoutnames{k} ';']);
end

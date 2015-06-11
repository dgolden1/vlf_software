function varargout=fwm_waves1(varargin)
%FWM_WAVES Calculate EHf for given np
% Usage:
%    [Nphi,nx,ny,da,EHf]=fwm_waves(z,eground,perm,dn0,npb,np,...
%       ksa,cartesian,nx0,ny0,I0,hi);
% Inputs:
%    I0 (3 x Ms x Nnx0 x Nny0 or 3 x Ms x Nnp0 x Nh) - current
% Outputs:
%
% We discard the value of EHftry

status={};
%% Constants
program='FWM_WAVES';
arginnames={'z','eground','perm','dn0','npb','np',...
    'ksa','cartesian','arg1','arg2','I0','kia','dzl','dzh'};
argoutnames={'Nphi','nx','ny','da','EHf'};

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
Mi=length(kia);
Ms=length(ksa);
if cartesian
    nx0=arg1; ny0=arg2;
else
    np0=arg1; m=arg2;
end

%% Set up the (nx,ny) mesh
Nnp=length(np);
Nphi=zeros(1,Nnp);
for kp=1:Nnp
    % Change: do not assume that for np>1 we can take bigger intervals.
    Nphitmp=2*pi*np(kp)/dn0; % Nphi must be greater than this
    Nphi0=2^(max(0,ceil(log2(Nphitmp))));
    Nphi(kp)=Nphi0;
end
% Nphi0 stores the maximum Nphi
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
if cartesian
    % To size Nny0 x Nnx0 x 3 x Ms
    % which is more convenient to use with interp2
    % NOTE: we switched x <-> y directions!
    I0p=permute(I0,[4 3 1 2]);
else
    % Interpolate at np
    % To size Nnp0 x 3 x Ms x Nh and back to 3 x Ms x Nnp x Nh
    I0p=permute(interp1(np0,permute(I0,[3 1 2 4]),np),[2 3 1 4]);
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
    EHf=zeros(6,Ntot,Mi);
    disp([program ': starting a new calculation']);
end

%% Cycle over the (nx,ny) mesh
% Equivalent of former fwm_antenna_3d_waves
I0i=zeros(3,Ms,Nphi0); % pre-allocate
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
    if cartesian
        % Interpolate
        for c=1:3
            for ks=1:Ms
                % I0p(:,:,c,ks) has size Nny0 x Nnx0
                I0i(c,ks,1:Nphi(ip))=interp2(nx0,ny0,I0p(:,:,c,ks),nxtmp,nytmp);
            end
        end
    else
        % Calculate by summation
        % Size = 3 x Ms x Nphi(ip) x Nh
        e=permute(repmat(exp(i*m(:)*p(:).'),[1 1 3 Ms]),[3 4 2 1]);
        I0i(:,:,1:Nphi(ip))=sum(repmat(I0p(:,:,ip,:),[1 1 Nphi(ip) 1]).*e,4);
    end
    EHf(:,ii,:)=fwm_field1(z,eground,perm,nxtmp,nytmp,ksa,I0i(:,:,1:Nphi(ip)),kia,dzl,dzh);
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
    disp(['Saving results of ' program ' ...']);
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

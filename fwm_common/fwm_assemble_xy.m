function varargout=fwm_assemble_xy(varargin)
%FWM_ASSEMBLE Inverse Fourier transform from the polar mesh
% It is much slower than FFT
% Usage:
%    EH=fwm_assemble(k0,nx,ny,da,EHf,x,y);
% Inputs:
% Outputs:
% Author: Nikolai G. Lehtinen

%% Constants
program='FWM_ASSEMBLE_XY';
arginnames={'k0','nx','ny','da','EHf','x','y'};
argoutnames={'EH'};

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

%% Various
Mi=size(EHf,2);
% This would be SOO much faster if we did an FFT
% The weighted field
%EHfw=EHf.*repmat(da,[6 1 Mi])*(k0^2/(2*pi)^2);
% - Multiply by usual integration coefficient

%% Check if the arrays x, y are uniformly spaced
Nx=length(x); Ny=length(y);
if Nx>1
    tmp=diff(x);
    dx=mean(tmp);
    xunif=max(abs(tmp-dx))<10*eps;
else
    xunif=0;
end
if Ny>1
    tmp=diff(y);
    dy=mean(tmp);
    yunif=max(abs(tmp-dy))<10*eps;
else
    yunif=0;
end

disp(['x uniform = ' num2str(xunif) '; y uniform = ' num2str(yunif)]);

if xunif
    expdx=exp(i*k0*dx*repmat(nx,[6 1]));
    expx0=expdx.^(x(1)/dx); % =exp(i*k0*x(1)*nxmat);
else
    nxmat=repmat(nx,[6 1]);
end
if yunif
    expdy=exp(i*k0*dy*repmat(ny,[6 1]));
    % Pre-calculate the Fourier coefficients
    expy0=expdy.^(y(1)/dy); % =exp(i*k0*y(1)*nymat);
else
    nymat=repmat(ny,[6 1]);
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
    tmp=load(bkp_file_ext,'ki','ix','EH');
    kistart=tmp.ki; % I think there should be +1
    ixsaved=tmp.ix+1;
    EH=tmp.EH;
    disp([program ': restored from backup']);
else
    kistart=1; ixsaved=1;
    EH=zeros(6,Mi,Nx,Ny);
    disp([program ': starting a new calculation']);
end

%% Cycle over ki
tstart=now*24*3600; toutput=tstart; timebkup=tstart;
for ki=kistart:Mi
    EHfw=squeeze(EHf(:,ki,:)).*repmat(da(:).',[6 1])*(k0^2/(2*pi)^2);
    if ki==kistart
        ixstart=ixsaved;
        expx=expdx.^(x(ixstart)/dx);
    else
        ixstart=1;
        expx=expx0;
    end
    for ix=ixstart:Nx
        if xunif
            tmp=EHfw.*expx;
        else
            tmp=EHfw.*exp(i*k0*x(ix)*nxmat);
        end
        if yunif
            expy=expy0; % =exp(i*k0*y(1)*nymat);
            for iy=1:Ny
                %EHsat(:,ix,iy)=sum(EHfw.*exp(i*k0*(x(ix)*nxmat+y(iy)*nymat)),2);
                EH(:,ki,ix,iy)=sum(tmp.*expy,2);
                expy=expy.*expdy;
            end
        else
            for iy=1:Ny
                EH(:,ki,ix,iy)=sum(tmp.*exp(i*k0*y(iy)*nymat),2);
            end
        end
        if xunif
            expx=expx.*expdx;
        end
        timec=now*24*3600;
        ttot=timec-tstart;
        if timec-toutput>output_interval
            toutput=timec;
            isdonenow=(ki-kistart)*Nx+(ix-ixstart+1);
            isremaining=(Mi-ki+1)*Nx-ix;
            disp([program ': Done=' num2str((ki-1+ix/Nx)/Mi*100) '%; ' ...
                'Time=' hms(ttot) ...
                ', ETA=' hms(ttot/isdonenow*isremaining)]);
        end
        if do_backups
            % Do backups every hour
            if timec-timebkup>backup_interval
                timebkup=timec;
                disp('Backing up ...');
                status='in progress';
                save(bkp_file_ext,'ki','ix','EH','status','-append');
                disp(' ... done');
            end
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

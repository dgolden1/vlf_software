function varargout=fwm_assemble_rp(varargin)
%FWM_ASSEMBLE Inverse Fourier transform from the polar mesh
% It is much slower than FFT
% Usage:
%    EH=fwm_assemble(k0,nx,ny,da,EHf,x,y);
% Inputs:
% Outputs:
% Author: Nikolai G. Lehtinen

%% Constants
program='FWM_ASSEMBLE_RP';
arginnames={'k0','nx','ny','da','EHf','r','phi'};
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
Mi=size(EHf,3);
% This would be SOO much faster if we did an FFT
% The weighted field
%EHfw=EHf.*repmat(da,[6 1 Mi])*(k0^2/(2*pi)^2);
% - Multiply by usual integration coefficient

%% Check if the arrays x, y are uniformly spaced
Nr=length(r); Nphi=length(phi);
if Nr>1
    tmp=diff(r);
    dr=mean(tmp);
    runif=max(abs(tmp-dr))<10*eps;
else
    runif=0;
end

disp(['r uniform = ' num2str(runif)]);

nxmat=repmat(nx,[6 1]);
nymat=repmat(ny,[6 1]);

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
    tmp=load(bkp_file_ext,'ki','iphi','EH');
    kistart=tmp.ki; % I think there should be +1
    iphisaved=tmp.iphi+1;
    EH=tmp.EH;
    disp([program ': restored from backup']);
else
    kistart=1; iphisaved=1;
    EH=zeros(6,Mi,Nr,Nphi);
    disp([program ': starting a new calculation']);
end

%% Cycle over ki
tstart=now*24*3600; toutput=tstart; timebkup=tstart;
for ki=kistart:Mi
    EHfw=EHf(:,:,ki).*repmat(da,[6 1])*(k0^2/(2*pi)^2);
    if ki==kistart
        iphistart=iphisaved;
    else
        iphistart=1;
    end
    for iphi=iphistart:Nphi
		nr=cos(phi(iphi))*nxmat+sin(phi(iphi))*nymat;
        if runif
			tmp=EHfw.*exp(i*k0*r(1)*nr);
			expdr=exp(i*k0*dr*nr);
			for ir=1:Nr
                %EH=sum(EHfw.*exp(i*k0*r(ir)*nr),2);
				EH(:,ki,ir,iphi)=sum(tmp,2);
				tmp=tmp.*expdr;
			end
		else
			for ir=1:Nr
				EH(:,ki,ir,iphi)=sum(EHfw.*exp(i*k0*r(ir)*nr));
			end
        end
        timec=now*24*3600;
        ttot=timec-tstart;
        if timec-toutput>output_interval
            toutput=timec;
            isdonenow=(ki-phistart)*Nphi+(iphi-iphistart+1);
            isremaining=(Mi-ki+1)*Nphi-iphi;
            disp([program ': Done=' num2str((ki-1+iphi/Nphi)/Mi*100) '%; ' ...
                'Time=' hms(ttot) ...
                ', ETA=' hms(ttot/isdonenow*isremaining)]);
        end
        if do_backups
            % Do backups every hour
            if timec-timebkup>backup_interval
                timebkup=timec;
                disp('Backing up ...');
                status='in progress';
                save(bkp_file_ext,'ki','iphi','EH','status','-append');
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

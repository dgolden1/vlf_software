function loadatmosphere
global global_dir IONOSPH NEUTRALS
disp('**** READING ATMOSPHERE INFO ****');
if isempty(global_dir)
    loadconstants
end
IONOSPH={};
NEUTRALS={'Nm','O','N2','O2','He','Ar','H','N',...
    'Tn','rho','TAC'};
dodequantize=1;
profiles={'HAARPsummernight','HAARPsummerday','HAARPwinternight','HAARPwinterday',...
    'GammaFlare2004','Starks','DEMETER_NPM'};
nprofiles=length(profiles);
for iprofile=1:nprofiles
    name=profiles{iprofile};
    disp(['loading ' name]);
    iri=load([global_dir 'densities/IRI_' name '.txt']);
    hi=iri(:,1); % Altitudes (in km) for IRI model
    iri(:,[2 7:13])=iri(:,[2 7:13]).*(iri(:,[2 7:13])>0);
    Ne=1e6*iri(:,2); % Convert to m^{-3}
    if dodequantize
        for kk=7:13
            iri(:,kk)=dequantize(hi,iri(:,kk));
        end
    end
    iri(:,[7:13])=0.01*iri(:,[7:13]).*meshgrid(Ne,[7:13])';
    % Load the neutral atmosphere
    if exist([global_dir 'densities/MSIS1_' name '.txt'])==2
        a=load([global_dir 'densities/MSIS1_' name '.txt']);
        b=load([global_dir 'densities/MSIS2_' name '.txt']);
        hn=a(:,1); % Altitudes (in km) for MSIS model
        rho=a(:,5)*1e3;
        a(:,2:4)=a(:,2:4)*1e6; % Convert to m^{-3}
        b(:,2:5)=b(:,2:5)*1e6;
        dh=diff(hn)*1e3;
        rhoc=0.5*(rho(1:end-1)+rho(2:end));
        TACup=[0 ; cumsum(rhoc.*dh)];
        TAC=TACup(end)-TACup;
        TAC=TAC+rho(end)*8000; % so that there is no zero
        IONOSPH={IONOSPH{:},...
            struct('name',name,'hi',hi,'Ne',Ne,'OI',iri(:,7),...
            'NI',iri(:,8),'HI',iri(:,9),'HeI',iri(:,10),'O2I',iri(:,11),...
            'NOI',iri(:,12),'Clust',iri(:,13),...
            'hn',hn,'Nm',(a(:,3)+a(:,4)),'O',a(:,2),...
            'N2',a(:,3),'O2',a(:,4),'Tn',a(:,6),'rho',rho,'TAC',TAC,...
            'He',b(:,2),'Ar',b(:,3),'H',b(:,4),'N',b(:,5))};
    else
        IONOSPH={IONOSPH{:},...
            struct('name',name,'hi',hi,'Ne',Ne,'OI',iri(:,7),...
            'NI',iri(:,8),'HI',iri(:,9),'HeI',iri(:,10),'O2I',iri(:,11),...
            'NOI',iri(:,12),'Clust',iri(:,13))};
    end
end

% The old Stanford profiles
su_names={'eprof0','eprof1','eprof2','eprof3','eprof5','daytime','nighttime','tenuous','sean'};
for k=1:length(su_names)
    name=su_names{k};
    disp(['loading ' name]);
    eprof=load([global_dir 'densities/' name '.dat']);
    IONOSPH={IONOSPH{:},...
        struct('name',['Stanford_' name],'hi',eprof(:,1),'Ne',1e6*eprof(:,2))};
end


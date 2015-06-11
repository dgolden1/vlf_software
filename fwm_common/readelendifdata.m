function SP=readelendifdata(fname,doplot)
% Load the species data from an ELENDIF file
%fname='O2elendif.txt'
if nargin<2
    doplot=0;
end
fid = fopen(fname,'r');
fgetl(fid);
l=fgetl(fid);
name=truncpad(sscanf(l,'%s'),2);
fgetl(fid);
fgetl(fid);
l=fgetl(fid);
[tmp,count]=sscanf(l,'%d',5);
vmax=tmp(1);
if vmax<0
    error('This is not implemented')
end
nelec=tmp(2);
nother=tmp(3);
wmax=vmax+nelec+nother;
kmax=tmp(5);

fgetl(fid);
fgetl(fid);
l=fgetl(fid);
molwt=sscanf(l,'%f');

if vmax>0
    fgetl(fid);
    fgetl(fid);
    l=fgetl(fid);
    [tmp,count]=sscanf(l,'%f',3);
    B0=tmp(1);
    if tmp(3)==2
        dipmom=tmp(2);
        qumom=0;
    elseif tmp(3)==4
        qumom=tmp(2);
        dipmom=0;
    end
else
    B0=0; dipmom=0; qumom=0;
end

fgetl(fid);
fgetl(fid);
fgetl(fid);
l=fgetl(fid);
qscale=sscanf(l,'%f');

fgetl(fid);
for k=1:kmax
    tmp=fscanf(fid,'%f',2);
    em(k)=tmp(1);
    qm(k)=tmp(2);
end
fgetl(fid);

if qscale~=0
    qm=qm*qscale;
end

et=zeros(1,wmax); % energy loss
mv=zeros(1,wmax); % number of points
statwt=zeros(1,wmax); % g(ground state)/g(excited state)
e=zeros(100,wmax);
q=zeros(100,wmax);
procnamelen=30;
procname=char(zeros(wmax,procnamelen));
if vmax>0
    % Vibrational xsections
    for v=1:vmax
        fgetl(fid);
        procname(v,:)=truncpad(fgetl(fid),procnamelen);
        fgetl(fid);
        l=fgetl(fid);
        [tmp,count]=sscanf(l,'%f',3);
        et(v)=tmp(1); mv(v)=tmp(2); qscale=tmp(3);
        fgetl(fid);
        for j=1:mv(v)
            tmp=fscanf(fid,'%f',2);
            e(j,v)=tmp(1); q(j,v)=tmp(2)*qscale;
        end
        fgetl(fid);
    end
end

% Electronic and other cross-sections
for v=vmax+1:wmax
    fgetl(fid);
    procname(v,:)=truncpad(fgetl(fid),procnamelen);
    fgetl(fid);
    l=fgetl(fid);
    [tmp,count]=sscanf(l,'%f',4);
    et(v)=tmp(1); statwt(v)=tmp(2); mv(v)=tmp(3); qscale=tmp(4);
    fgetl(fid);
    for j=1:mv(v)
        tmp=fscanf(fid,'%f',2);
        e(j,v)=tmp(1); q(j,v)=tmp(2)*qscale;
    end
    fgetl(fid);
end

e=e(1:max(mv),:);
q=q(1:max(mv),:);

fclose(fid);


SP=struct('name',name,'molwt',molwt,...
    'B0',B0,'dipmom',dipmom,'qumom',qumom,...
    'numxsec',wmax,'procname',procname,'numvib',vmax,...
    'eloss',et,'numpoints',mv,'statwt',statwt,'e',e,'q',q,'em',em,'qm',qm);

% NOTE:
% energies are in eV
% cross-sections are in 10^{-16} cm^2

% Analize the cross-section so that they are =0 when e<eloss
for v=1:SP.numxsec
    n=SP.numpoints(v);
    eloss=SP.eloss(v);
    en=SP.e(1:n,v);
    sig=SP.q(1:n,v);
    ii=find(en<eloss & sig>0);
    if ~isempty(ii)
        SP.procname(v,:)
        en(ii)
        sig(ii)
        SP.q(ii,v)=0;
    end
end

if doplot
    % The total energy loss per unit time
    energy=logspace(-1,2);
    velocity=sqrt(energy);
    eloss=zeros(size(velocity));
    for v=1:wmax
        eloss=eloss+velocity.*interp1(e(1:mv(v),v),q(1:mv(v),v),energy);
    end
    loglog(energy,eloss)
end

function [C,alf,permrot,C0box,Fbox]=modefinder_plasma_flat(varargin)
%MODEFINDER_PLASMA_FLAT Find modes using flat Earth, nonisotropic medium
% Usage:
%   [C,alf,permrot]=modefinder(k0,h,perm,isvacuum,phi);
%   EH=reflectplasma_modestruct(C(1),k0,h,permrot,isvacuum,hi);
% Inputs:
%   k0               == w/c
%   h (M x 1)        -- altitudes (km)
%   perm (3 x 3 x M) -- permittivity tensors at h
%   isvacuum (M x 1) -- indicator of isotropic medium
%   phi              -- angle of kperp with x-axis (default==0)
% Outputs:
%   C       == kz/k0 for all modes (we don't distinguish TM and TE)
%   alf     -- attenuation in dB/Mm
%   permrot -- "perm" rotated to the direction of kperp, to be used
%              later with REFLECTPLASMA_MODESTRUCT
% See also: MODEFINDER, REFLECTPLASMA_MODESTRUCT, REFLECTPLASMA,
%   SOLVE_BOOKER
% Author: Nikolai G. Lehtinen

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize the parameters
keys={'dC','Crmin','Crmax','Cimin','Cimax','debug','numpoints'};
[k0,h,perm,isvacuum,phi,options]=parsearguments(varargin,4,keys);
M=length(h);
zdim=h.'*1e3*k0; % row, dimensionless
if isempty(phi)
    phi=0;
end
% Rotate the permittivity by phi around z-axis
sp=sin(phi); cp=cos(phi);
% Active
rotmxa=[cp -sp 0; sp cp 0; 0 0 1];
% Passive (inverse of active)
rotmxp=[cp sp 0; -sp cp 0; 0 0 1];
permrot=zeros(3,3,M);
for k=1:M
    permrot(:,:,k)=rotmxa*perm(:,:,k)*rotmxp;
end

debugflag=getvaluefromdict(options,'debug',0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimate the number of modes = 2*hrefl/(lambda/2)
nz=zeros(4,M);
for k=1:M
    nz(:,k)=solve_booker(perm(:,:,k),0,isvacuum(k));
end
zdimrefl=zdim(min(find(imag(nz(1,:))>real(nz(1,:)))));
if isempty(zdimrefl)
    zdimrefl=max(zdim);
end
nmodesest=ceil(2*zdimrefl/pi);
if debugflag>0
    disp(['Estimated number of modes = ' num2str(nmodesest)]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize the mesh of complex C (=nz=kz/k0)
dC=getvaluefromdict(options,'dC',[]);
if isempty(dC)
    % The mesh step
    numpoints=getvaluefromdict(options,'numpoints',10);
    dC=1/nmodesest/numpoints;
    if debugflag>0
        disp(['Step in C = ' num2str(dC)]);
    end
end

Crmin=getvaluefromdict(options,'Crmin',0.01*dC);
Crmax=getvaluefromdict(options,'Crmax',1);
Cimin=getvaluefromdict(options,'Cimin',-.1);
Cimax=getvaluefromdict(options,'Cimax',0);

C0re1=[Crmin:dC:Crmax];
C0im1=[Cimin:dC:Cimax];
Nr=length(C0re1);
Ni=length(C0im1);

[C0re,C0im]=ndgrid(C0re1,C0im1);
[indr,indi]=ndgrid(1:Nr,1:Ni);
C0box=C0re+i*C0im;
radius=2*max(max(abs(C0box)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate F=det(eye(2)+Ru)
% For modes, must be F==0.
tstart=now*24*3600;
params={zdim,permrot,isvacuum};
Fbox=Flwpc(C0box,params);
if debugflag>0
    disp(['Filled the F matrix, time=' hms(now*24*3600-tstart)]);
end

% Find boxes in which imag(F) and real(F) change sign
tmpi=1*(imag(Fbox)>0);
tmpr=1*(real(Fbox)>0);
ifound=find(([diff(tmpi,[],1);zeros(1,Ni)]~=0 | [diff(tmpi,[],2) zeros(Nr,1)]~=0) ...
    & ([diff(tmpr,[],1);zeros(1,Ni)]~=0 | [diff(tmpr,[],2) zeros(Nr,1)]~=0) ...
    & indr<Nr & indi<Ni);
i1=indr(ifound);
i2=indi(ifound);
found=zeros(Nr,Ni);
found(ifound)=1;

% For each found box, refine the solution
nfound=length(ifound);
C0sol=zeros(1,nfound);
if debugflag>2
    disp(['Found ' num2str(nfound) ' initial solutions']);
end
for k=1:nfound
    % Newton-Raphson method
    x1=C0box(i1(k),i2(k));
    F1=Flwpc(x1,params);
    x2=0.5*(C0box(i1(k),i2(k))+C0box(i1(k)+1,i2(k)+1));
    F2=Flwpc(x2,params);
    if debugflag>2
        disp(['Root ' num2str(k) '/' num2str(nfound) ':']);
        disp(['x1=' num2str(x1) '; F1=' num2str(F2) ...
            '; x2=' num2str(x2) '; F2=' num2str(F2)]);
    end
    while 1
        dx=-F2*(x2-x1)./(F2-F1);
        x1=x2;
        x2=x2+dx;
        if real(x2)<0 | abs(x2)>radius
            % no thinking outside the box!
            break
        end
        F1=F2;
        F2=Flwpc(x2,params);
        if debugflag>2
            disp(['x=' num2str(x2) '; F=' num2str(F2)]);
        end
        if abs(F2)<1e-6
            break
        end
    end
    C0sol(k)=x2;
end

% Discard negative solutions: think inside the box
ii=find(real(C0sol)>0 & abs(C0sol)<radius);
C0sol=C0sol(ii);
nfound=length(C0sol);

% Discard duplicate solutions
duplic=zeros(size(C0sol));
k=0;
while k<nfound
    k=k+1;
    if duplic(k)
        continue
    end
    ii=find(abs(C0sol-C0sol(k))<dC);
    if length(ii)>=2
        duplic(ii(2:end))=1;
    end
end
tmp=C0sol(find(~duplic));
[y,ii]=sort(real(tmp));
C=tmp(ii);

if debugflag>1
    figure;
    imagesc(real(C0box(:,1)),imag(C0box(1,:)),log10(abs(Fbox.'))); set(gca,'ydir','normal');
    axis equal
    colorbar
    hold on
    plot(C,'rx');
    hold off
end

% Attenuation, in dB/Mm
alf=20*k0*imag(sqrt(1-C.^2))/log(10)*1e6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Auxiliary function
function FT=Flwpc(C0,params)
% C0 can be a matrix
zdim=params{1}; permrot=params{2}; isvacuum=params{3};
[Nr,Ni]=size(C0);
N=Nr*Ni;
M=length(zdim);
np=sqrt(1-C0(:).^2); % horizontal refractive index

% Vertical reflactive index and mode structure
nz=zeros(4,N,M);
Fext=zeros(6,4,N,M);
for k=1:M
    [nz(:,:,k),Fext(:,:,:,k)]=...
        solve_booker(permrot(:,:,k),np,isvacuum(k));
end
% Make sure the WHISTLER is going up
% This is never a problem for real np, but for complex, there can be 2
% waves attenuating upward.
% ONLY propagating waves. If the wave attenuates fast enough, keep it.

if 0
    if isvacuum(M)
        s=4;
    else
        s=3;
    end
    for ip=1:N
        tmp1=nz(2,ip,M);
        if real(tmp1)<0 & abs(real(tmp1))>abs(imag(tmp1))
            % Switch 2 and "s" modes
            nz(2,ip,M)=nz(s,ip,M);
            nz(s,ip,M)=tmp1;
            tmp2=Fext(:,2,ip,M);
            Fext(:,2,ip,M)=Fext(:,s,ip,M);
            Fext(:,s,ip,M)=tmp2;
        end
    end
elseif 0
    % Sort by the Poynting vector
    % Forget about it.
    S=cross(Fext(1:3,:,:,:),Fext(4:6,:,:,:));
    Sz=permute(S(3,:,:,:),[2 3 4 1]); % 4 x N x M
    % Sort in descending order according to imaginary part
    [dummy,ii]=sort(real(Sz),1,'descend');
    for ip=1:N
        nzs(:,ip,k)=nz(ii(:,ip,k),ip,k);
        Fexts(:,:,ip,k)=Fext(:,ii(:,ip,k),ip,k);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the 2 x 2 reflection coef from upper boundary (part of
% REFLECTPLASMA)
dz=diff(zdim); % dimensionless=k0*h
res=zeros(N,1);
for ip=1:N
    Ru=zeros(2,2); % no reflection at M
    kh=permute(nz(:,ip,1:M-1),[1 3 2]).*repmat(dz,[4 1]);
    kh(3:4,:)=-kh(3:4,:);
    Ep=exp(i*kh);
    % The matrices for transporting (a,b) through a slab z(k)<z<z(k+1), k=1:M-1
    Pu=zeros(2,2,M-1); Pu(1,1,:)=Ep(1,:); Pu(2,2,:)=Ep(2,:); % up
    Pd=zeros(2,2,M-1); Pd(1,1,:)=Ep(3,:); Pd(2,2,:)=Ep(4,:); % down
    for k=M-1:-1:1
        % Down Td(k)
        Td=Fext([1:2 4:5],:,ip,k)\Fext([1:2 4:5],:,ip,k+1);
        if ~isempty(find(isnan(Td)))
            error(['k=' num2str(k)]);
        end
        % Ru(:,:,k) in terms of Ru(:,:,k+1)
        Ru=Pd(:,:,k)*(Td(3:4,1:2)+Td(3:4,3:4)*Ru)*...
            inv(Td(1:2,1:2)+Td(1:2,3:4)*Ru)*Pu(:,:,k);
    end
    res(ip)=det(eye(2,2)+Ru); % =0 for the mode
end
FT=reshape(res,[Nr Ni]);

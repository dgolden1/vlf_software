function [EH,F,a,nzp,nzm,Tcross]=emitstrat(z,nx02,S,P,D,Js)
% EMITSTRAT Emission into stratified plasma by horizontal currents
% Vertical B is assumed.
% Inputs and outputs:
%   Var (Size) Meaning
% Inputs:
%  z    (M) -- dimensionless, =(altitude)*k0, k0=w/c
%  nx02 (1) -- squared horizontal dimensionless wave vector =(kx/k0)^2
%  S,P,D (M) -- the dielectric permittivity tensor at altitudes
%               z(k)<z<z(k+1). Notation is as in Stix
%               (eps11=eps22=S, eps21=-eps12=i*D, eps33=P, other=0).
%               Magnetic permeability is assumed to be == 1
%  Js (2 x M) -- =(surface current density)*Z0 at altitudes z,
%               the first dimension is coordinate (x or y).
% Outputs:
%  EH (4 x M) -- fields (Ex,Ey,Hz*Z0,Hy*Z0) at altitudes z, where Z0 is the
%                vacuum impedance. Note that B=H*Z0/c and in a plane wave
%                in vacuum E==H*Z0
% Outstanding problems:
% 1. When nx02==1, the vacuum conditions lead to singular matrices
% 2. For high imaginary nz (at high altitudes), we get floating overflow
%    and loss of precision.
% See also: EMITPLASMA (obsoleted by it)


% See file ionosphemit.m for debugging information

if nx02==1
	nx02=1.00001; % lame workaround
end

% z is dimensionless
z=z(:).';
M=length(z);
dz=diff(z);
S=S(:).'; P=P(:).'; D=D(:).';

% The isotropic medium is much simpler to handle, so handle it separately.
% The "isotropic" is a medium with TM and TE modes, D==0
iiso=find(abs(D)<1e-4);

Exp=zeros(1,M); Exm=zeros(1,M); Eyp=zeros(1,M); Exm=zeros(1,M);
Hxp=zeros(1,M); Hxm=zeros(1,M); Hyp=zeros(1,M); Hxm=zeros(1,M);

dP=P-nx02;
%Dpl=D(ipl); Ppl=P(ipl); Spl=S(ipl);
PS=P-S;
Disc=sqrt(PS.^2*nx02^2+4*P.*D.^2.*dP);
dSp=(nx02*PS+Disc)./P/2; % nx^2+nz^2-S
dSm=(nx02*PS-Disc)./P/2;

% Handle cases dSp<D and dSp>D separately.
D(iiso)=1; % To avoid division by zero, we discard these values anyway
alfap=dSp./D; alfam=dSm./D;
nz2p=S-nx02+dSp;
nz2m=S-nx02+dSm;
nzp=sqrt(nz2p); nzm=sqrt(nz2m);

% Isotropic medium
% For isotropic medium, TE corresponds to
% "p" and TM corresponts to "m". The whistlers correspond to "m" mode.
nzp(iiso)=sqrt(S(iiso)-nx02);
nzm(iiso)=sqrt(S(iiso).*dP(iiso)./P(iiso));

% Make sure that we deal with growing/decreasing waves at the upper
% boundary correctly.
if imag(nzm(M)<0)
    disp('Switching nzm')
    nzm(M)=-nzm(M);
end
if imag(nzp(M)<0)
    disp('Switching nzp')
    nzp(M)=-nzp(M);
end

% Plasma
Exp=alfap.*dP;
Exm=alfam.*dP;
Eyp=i*dP;
Eym=i*dP;
Hxp=-i*dP.*nzp;
Hxm=-i*dP.*nzm;
Hyp=P.*alfap.*nzp;
Hym=P.*alfam.*nzm;

% Isotropic medium again
% TE (alfap==0)
Exp(iiso)=0; Eyp(iiso)=1;
Hxp(iiso)=-nzp(iiso); Hyp(iiso)=0;
% TM (alfam==inf)
Exm(iiso)=nzm(iiso)./S(iiso); Eym(iiso)=0;
Hxm(iiso)=0; Hym(iiso)=1;

% kz*dz, in terms of dimensionless variables
khp=nzp(1:M-1).*dz;
khm=nzm(1:M-1).*dz;

% "Field matrix", used to convert the coefficients (ap,bp,am,bm) to fields
% (Ex,Ey,Hx*Z0,Hy*Z0), in layer z(k)<z<z(k+1) (z>z(M) for k=M)
% These coefficients correspond to waves going up (ap,am) and down (bp,bm),
% and 2 modes (ap,bp) and (am,bm). 
F=zeros(4,4,M);
F(1,1,:)=Exp; F(1,3,:)=Exm;
F(2,1,:)=Eyp; F(2,3,:)=Eym;
F(3,1,:)=Hxp; F(3,3,:)=Hxm;
F(4,1,:)=Hyp; F(4,3,:)=Hym;
F(1:2,[2 4],:)=F(1:2,[1 3],:); % E field coef. is the same for b
F(3:4,[2 4],:)=-F(3:4,[1 3],:); % H field coef changes sign for b

% The change of the field at a layer between z(k)-0 and z(k)+0, due to
% surface current Js:
% d(Hx*Z0)=Jsy*Z0, d(Hy*Z0)=-Jsx*Z0
dF=[zeros(2,M-1) ; Js(2,2:M) ; -Js(1,2:M)];

% Transmission matrix (downward) for (ap,bp,am,bm) in the interval
% z(k)<z<z(k+1):
T0=zeros(4,4,M-1);
T0(1,1,:)=exp(-i*khp); T0(2,2,:)=exp(i*khp);
T0(3,3,:)=exp(-i*khm); T0(4,4,:)=exp(i*khm);

% Transmission downward: multiply the transmission matrices for layers.
T=zeros(4,4,M-1);
da=zeros(4,M-1);
dacum=zeros(4,M); % It is essential that dacum(:,M)=[0;0;0;0];
Tcum=zeros(4,4,M);
Tcum(:,:,M)=eye(4);
Tcross=zeros(4,4,M-1);
for k=M-1:-1:1
    % Matrix relating (ap,..) across boundary at z(k+1) (going downward)
    Tcross(:,:,k)=F(:,:,k)\F(:,:,k+1);
    % Change of (ap,..) across boundary at z(k+1) due to surface currents
    % at z(k+1). The minus sign is because we go downwards.
    da(:,k)=-F(:,:,k)\dF(:,k);
    % Transmission from z(k+1)+0 to z(k)+0
    T(:,:,k)=T0(:,:,k)*Tcross(:,:,k);
    % Cumulative transmission matrix, from z(M)+0 to z(k)+0
    Tcum(:,:,k)=T(:,:,k)*Tcum(:,:,k+1);
    % Change of (ap,..) due to all currents above z(k)+0
    dacum(:,k)=T0(:,:,k)*da(:,k)+T(:,:,k)*dacum(:,k+1);
end

% Use the boundary condition Ex(z(1))=0, Ey(z(1))=0
% Note that for nx02==1 in vacuum Ex==0, Hx==0 and also Ey==0 because of
% the boundary.
tmp1=F(:,:,1)*Tcum(:,[1 3],1);
tmp2=F(:,:,1)*dacum(:,1);
aMf=-tmp1(1:2,:)\tmp2(1:2);
% aM==(ap,...) at z(M)+0 -- only emitting fields (bp,bm=0)
aM=[aMf(1);0;aMf(2);0];
% Calculate the fields at all z(k)
a=zeros(4,M); EH=zeros(4,M);
for k=1:M
	a(:,k)=Tcum(:,:,k)*aM+dacum(:,k);
	EH(:,k)=F(:,:,k)*a(:,k);
end

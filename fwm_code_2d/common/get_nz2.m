function [nz2,Disc]=get_nz2(nx02,S,P,D)
M=length(S);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The vertical refraction coefficient nz=kz/k0
% The 2 modes are called "p" and "m"
% In plasma (when P<0) we have "m" as a whistler mode.

dP=P-nx02;
%Dpl=D(ipl); Ppl=P(ipl); Spl=S(ipl);
SP=S-P; % usually <0
Disc=sqrt(SP.^2*nx02^2+4*P.*D.^2.*dP);
% If nx02==0, Disc=2*P*D
ii=sign(real(P));
%ii=ones(size(P));
dSp=(-nx02*SP+ii.*Disc)./P/2; % nx^2+nz^2-S
dSm=(-nx02*SP-ii.*Disc)./P/2;
% If nx02==0, dSp=D, dSm=-D

nz2p=S-nx02+dSp;
nz2m=S-nx02+dSm;
nzp=sqrt(nz2p); nzm=sqrt(nz2m);
% Isotropic medium
% The isotropic medium is much simpler to handle, so handle it separately.
% The "isotropic" is a medium with TM and TE modes, D==0
iiso=find(abs(D)<1e-4);
% For isotropic medium, TE corresponds to
% "p" and TM corresponts to "m".
% This is the same as above formulas for D=0, for the case S>P (which is
% typical).
nz2p(iiso)=S(iiso)-nx02;
nz2m(iiso)=S(iiso).*dP(iiso)./P(iiso);
nz2=zeros(M,2);
nz2(:,1)=nz2p; nz2(:,2)=nz2m;
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
nz=zeros(M,4);

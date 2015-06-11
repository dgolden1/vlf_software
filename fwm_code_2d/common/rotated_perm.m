function perm=rotated_perm(S,P,D,thB,phB)
%ROTATED_PERM Rotated permittivity tensor
% Usage:
%  perm=rotated_perm(S,P,D,thB,phB);
% Inputs:
%  S, P, D -- components of the magnetized plasma dielectric permittivity
%             tensor for B||z [see Stix, "The theory of plasma waves"]:
%                   ( S -iD   0)
%             eps = (iD   S   0)
%                   ( 0   0   P)
%             S, P and D can be 1D arrays of length M.
%  thB, phB -- direction of B (the spherical coordinates angles).
% Output:
%  perm -- dielectric permittivity tensor, 3 x 3 x M matrix 
M=length(S);
if length(P)~=M | length(D)~=M
    error('incorrect sizes')
end
% Permittivity with vertical B
%perm0=[S -i*D 0 ; i*D S 0 ; 0 0 P];
perm0=zeros(3,3,M);
perm0(1,1,:)=S; perm0(2,2,:)=S; perm0(3,3,:)=P;
perm0(1,2,:)=-i*D; perm0(2,1,:)=i*D;
% First, rotate the permittivity tensor to direction (theta,phi)
sp=sin(phB); cp=cos(phB);
st=sin(thB); ct=cos(thB);
% Active
rotmxa=[cp -sp 0; sp cp 0; 0 0 1]*[ct 0 st; 0 1 0; -st 0 ct];
% Passive (inverse of active)
rotmxp=[ct 0 -st; 0 1 0; st 0 ct]*[cp sp 0; -sp cp 0; 0 0 1];
perm=zeros(3,3,M);
for k=1:M
    perm(:,:,k)=rotmxa*perm0(:,:,k)*rotmxp;
end

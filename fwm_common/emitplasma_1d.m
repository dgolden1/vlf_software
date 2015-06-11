function EH1d=emitplasma_1d(k0,h,perm,isvacuum,nx1d,hi1d)
%EMITPLASMA_1D Reflection from ionosphere in 1D
% This is a simple demonstration of the usage of SOLVE_BOOKER_3D and
% REFLECTPLASMA.
% Usage:
%  EH=emitplasma_1d(k0,h,perm,isvacuum,nx,hi);
% Inputs (with sizes):
%  k0       (scalar)    -- = w/c;
%  h        (M x 1)     -- array of heights in km;
%  perm     (3 x 3 x M) -- array of dielectric permittivity tensors at h;
%  isvacuum (M x 1)     -- boolean, tells if "perp" is isotropic
%  nx       (scalar)    -- horizontal refractive index (=kx/k0);
%  hi       (Mi x 1)    -- heights (in km) at which we want to calculate
%                          the fields.
% Output:
%  EH (Mi x 6 x 2) -- fields (Ex,Ey,Ez,Hx,Hy,Hz, the component number given
%                     by the second index) at altitudes "hi". The third
%                     index is the mode number (TE for 1, TM for 2). The
%                     oncoming wave has Ey=1 (TE) or Hy=1 (TM), at the
%                     lowest h.

M=length(h);
zdim=h.'*1e3*k0;
% Refractive index and mode structure in each layer
nz=zeros(4,M); Fext=zeros(6,4,M);
for k=1:M
    [nz(:,k),Fext(:,:,k)]=solve_booker_3d(perm(:,:,k),nx1d,0,isvacuum(k));
end
F=Fext([1:2 4:5],:,:);
% Reflection coefs
% These are Rd,Ru,U,D,Tu,Td in the paper (NOTE THE ORDER!)
[R1,R2,A,B,Xu,Xd]=reflectplasma(zdim,nz,F);
% We discard R1,B,Xu, because we don't care about propagation downward.

% Do both TE and TM at once: ud(1:2,1,k) are TE, ud(1:2,2,k) are TM
ud=zeros(4,2,M);
% Initial condition
ud(1:2,:,1)=eye(2);
% Propagate (and reflect) the wave up
for k=1:M-1
    ud(3:4,:,k)=R2(:,:,k)*ud(1:2,:,k);
    ud(1:2,:,k+1)=A(:,:,k)*ud(1:2,:,k);
end
% Wave amplitude below the layer boundaries
% NOTE: udprime(k) is (u_{k+1}',d_{k+1}'), although index is k
udprime=zeros(4,2,M);
for k=1:M-1
    %udprime(:,k)=F(:,:,k)\F(:,:,k+1)*ud(:,k+1);
    udprime(:,:,k)=Xd(:,:,k)*ud(:,:,k+1);
end

% Field at each altitude
Mi1d=length(hi1d);
zdimi1d=hi1d.'*1e3*k0;
EH1d=zeros(Mi1d,6,2);
udzi=zeros(4,2);
for ki=1:Mi1d
    k=max(find(zdim<=zdimi1d(ki))); % Which layer are we in?
    dzdimd=zdimi1d(ki)-zdim(k); % Distance to the boundary below
    if dzdimd==0
        % Simple case -- the new refined mesh coincides with old mesh
        udzi=ud(:,:,k);
    else
        % This excludes the case of k==M, so k+1 is still valid
        dzdimu=zdim(k+1)-zdimi1d(ki); % Distance to the boundary above
        % Use the matrix capabilities of MATLAB.
        nz0=repmat(nz(:,k),[1 2]);
        % Avoid instability: upward wave -- from below
        udzi(1:2,:)=exp(i*dzdimd*nz0(1:2,:)).*ud(1:2,:,k);
        % Downward wave -- from above
        udzi(3:4,:)=exp(-i*dzdimu*nz0(3:4,:)).*udprime(3:4,:,k);
    end
    % Convert udzi to field EHfzi:
    EH1d(ki,:,:)=Fext(:,:,k)*udzi;
end

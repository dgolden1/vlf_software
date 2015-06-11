function EH=reflectplasma_modestruct(C0,k0,h,permrot,isvacuum,hi);
%REFLECTPLASMA_MODESTRUCT Find the mode structure for given C0
% Usage:
%  EH=reflectplasma_modestruct(C0,k0,h,permrot,isvacuum,hi);
% Inputs:
%  C0                   == nz == kz/k0
%  k0                   == w/c
%  h        (M x 1)     -- altitudes in km for permrot
%  permrot  (3 x 3 x M) -- permittivity tensors at h, in coordinate system
%                         in which nperp=nx
%  isvacuum (1 x M)     -- indicator of isotropic medium
%  hi       (Mi x 1)    -- altitudes in km at which the field is to be
%                         calculated
% Outputs:
%  EH (Mi x 6) -- fields (Ex,Ey,Ez,Z0*Hx,Z0*Hy,Z0*Hz) at altitudes hi
% NOTE: Only scalar C0 can be used
% See also: MODEFINDER_PLASMA_FLAT, REFLECTPLASMA, SOLVE_BOOKER

M=length(h);
Mi=length(hi);
np=sqrt(1-C0.^2); % horizontal refractive index
nz=zeros(4,M);
Fext=zeros(6,4,M);
for k=1:M
    [nz(:,k),Fext(:,:,k)]=...
        solve_booker(permrot(:,:,k),np,isvacuum(k));
end
% Make sure the WHISTLER is going up
% This is never a problem for real np, but for complex, there can be 2
% waves attenuating upward.
% NOTE that this may create an instability IF layers M and M-1 are exactly
% the same, i.e. Ru_{M-1}=[0 inf;0 0], to accomodate the small wave
% propagating down from magnetosphere in layer M-1.
tmp1=nz(2,M);
if real(tmp1)<0 & abs(real(tmp1))>abs(imag(tmp1))
    % Switch 2 and 3 modes
    nz(2,M)=nz(3,M);
    nz(3,M)=tmp1;
    tmp2=Fext(:,2,M);
    Fext(:,2,M)=Fext(:,3,M);
    Fext(:,3,M)=tmp2;
end
if imag(nz(2,M))<0
    disp('WARNING: diverging up-wave');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the 2 x 2 reflection coef (part of REFLECTPLASMA)
zdim=h(:).'*1e3*k0; % row, dimensionless
dz=diff(zdim);
Ru=zeros(2,2,M); % no reflection at M
kh=nz(:,1:M-1).*repmat(dz,[4 1]);
kh(3:4,:)=-kh(3:4,:);
Ep=exp(i*kh);
% The matrices for transporting (u,d) through a slab z(k)<z<z(k+1), k=1:M-1
Pu=zeros(2,2,M-1); Pu(1,1,:)=Ep(1,:); Pu(2,2,:)=Ep(2,:); % up
Pd=zeros(2,2,M-1); Pd(1,1,:)=Ep(3,:); Pd(2,2,:)=Ep(4,:); % down
U=zeros(2,2,M-1);
Td=zeros(4,4,M-1);
for k=M-1:-1:1
    % Down Td(k)
    Td(:,:,k)=Fext([1:2 4:5],:,k)\Fext([1:2 4:5],:,k+1);
    Tu=Fext([1:2 4:5],:,k+1)\Fext([1:2 4:5],:,k);
    if any(any(isnan(Td))) | any(any(isnan(Tu)))
        error(['k=' num2str(k)]);
    end    
    % Ru(:,:,k) in terms of Ru(:,:,k+1)
    PdiRu=(Td(3:4,1:2,k)+Td(3:4,3:4,k)*Ru(:,:,k+1))*...
        inv(Td(1:2,1:2,k)+Td(1:2,3:4,k)*Ru(:,:,k+1))*Pu(:,:,k);
    Ru(:,:,k)=Pd(:,:,k)*PdiRu;
    U(:,:,k)=Tu(1:2,1:2)*Pu(:,:,k)+Tu(1:2,3:4)*PdiRu;    
    if ~isempty(find(isnan(U(:,:,k))))
        error(['k=' num2str(k) ': U']);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The mode structure
ud=zeros(4,M);
udprime=zeros(4,M);
% Initial condition: since det(eye(2)+Ru(:,:,1))==0, find when
% (eye(2)+Ru(:,:,1))*ud(1:2,1)==0
% Find u(1:2,1) as an eigenvector corresponding to zero eigenvalue of
% matrix (eye(2)+Ru(:,:,1))
[v,dd]=eig(eye(2)+Ru(:,:,1));
[tmp,ii]=min(abs(diag(dd)));
ud(1:2,1)=v(:,ii);
% Propagate (and reflect) the wave up
for k=1:M
    if k<M
        ud(3:4,k)=Ru(:,:,k)*ud(1:2,k);
        ud(1:2,k+1)=U(:,:,k)*ud(1:2,k);
    end
    % Wave amplitude below the layer boundaries
    % NOTE: udprime(k) is (u_{k+1}',d_{k+1}'), although index is k
    if k>1
        udprime(:,k-1)=Td(:,:,k-1)*ud(:,k);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Field at each altitude "hi"
zdimi=hi(:).'*1e3*k0; % dimensionless
EH=zeros(Mi,6);
udzi=zeros(4,Mi);
for ki=1:Mi
    k=max(find(zdim<=zdimi(ki))); % Which layer are we in?
    dzdimd=zdimi(ki)-zdim(k); % Distance to the boundary below
    if dzdimd==0
        % Simple case -- the new refined mesh coincides with old mesh
        udzi(:,ki)=ud(:,k);
    else
        % This excludes the case of k==M, so k+1 is still valid
        dzdimu=zdim(k+1)-zdimi(ki); % Distance to the boundary above
        % Avoid instability: upward wave -- from below
        udzi(1:2,ki)=exp(i*dzdimd*nz(1:2,k)).*ud(1:2,k);
        % Downward wave -- from above
        udzi(3:4,ki)=exp(-i*dzdimu*nz(3:4,k)).*udprime(3:4,k);
    end
    % Convert udzi to field EHfzi:
    EH(ki,:)=Fext(:,:,k)*udzi(:,ki);
end

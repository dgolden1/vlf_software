function [R1,R2,A,B,Xu,Xd]=reflectplasma(varargin)
%REFLECTPLASMA Reflection from an anisotropic statified medium
% NOTE: The new version is FWM_RADIATION and FWM_INTERMEDIATE (although
% this version is still fully functional)
%
% Inspired by J. R. Wait, "Electromagnetic Waves in Stratified Media"
% [1970, page 11].
% Calculate reflection matrices for 2 modes.
% Usage:
%   [R1,R2,A,B]=reflectplasma(zdim,nz,F[,options]);
% Inputs:
%   zdim - 1D array of length M of dimensionless altitudes, zdim=k0*z,
%          k0=w/c;
%   nz   - 4 x M array of vertical refraction index, at hights zdim, for 4
%          modes sorted by decreasing imaginary part, so that the first two
%          values correspond to upgoing modes (a1,a2) and the second two
%          to downgoing modes (b1,b2);
%   F    - 4 x 4 x M matrix to convert the wave variables (a1,a2,b1,b2),
%          which correspond to nz described above, to fields (Ex, Ey,
%          Z0*Hx, Z0*Hy), where Z0=sqrt(mu0/eps0) is the impedance of free
%          space.
% nz and F are found elsewhere, e.g., by solving the Booker equation.
% nz and F can correspond, e.g., to a wave with a fixed horizontal wave
% vector (kx,ky)=k0*(nx,ny) (fixed due to Snell's law).
% Options:
%   'ground_bc' - boundary conditions on the ground level, z(1)==0.
%   Possible values: 'free', 'E=0' (default), 'H=0'.
% Outputs:
%   R1 - 2 x 2 x M matrix of reflection coefficient for downgoing waves, at
%        each altitude, i.e. a=R1*b;
%   R2 - 2 x 2 x M matrix of reflection coefficient for upgoing waves, at
%        each altitude, i.e. b=R2*a;
%   A  - 2 x 2 x (M-1) matrix for calculating (a1,a2) above the sources,
%        a_{k+1}=A_k*a_k;
%   B  - 2 x 2 x (M-1) matrix for calculating (b1,b2) below the sources,
%        b_k=B_k*b_{k+1};
% IMPORTANT NOTE:
%   For complex values, we use the physics convention:
%      E,H ~ e^{-iwt}
%
% VERSION 2: 9/10/2007 WARNING: The calculation of sources (S) is removed!
%
% Previous versions: EMITSTRAT
% See also: SOLVE_BOOKER, SOLVE_BOOKER_3D
% Author: Nikolai G. Lehtinen

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse arguments
keys={'ground_bc'};
[z,nz,F,options]=parsearguments(varargin,3,keys);
ground_bc=getvaluefromdict(options,'ground_bc','E=0');
z=z(:)';
dz=diff(z); % dimensionless=k0*h
M=length(z);
tmp=size(nz);
if length(tmp)~=2 | tmp(1)~=4 | tmp(2)~=M
    error('nz of incorrect size');
end
tmp=size(F);
if length(tmp)~=3 | tmp(1)~=4 | tmp(2)~=4 | tmp(3)~=M
    error('F of incorrect size');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We are given nz for 4 modes (first 2 are up, second 2 are down), and
% matrix F converting (a,b) to (E,H).
% "Field matrix" F is used to convert the wave coefficients (a1,a2,b1,b2)
% to fields (Ex,Ey,Hx*Z0,Hy*Z0).
% Matrix G is used to convert (Ex,Ey,Hx*Z0,Hy*Z0)->(a1,a2,b1,b2)
%for k=1:M
%    G(:,:,k)=inv(F(:,:,k)); % Not used!
%end

% kz*dz, in terms of dimensionless variables
kh=nz(:,1:M-1).*repmat(dz,4,1);
kh(3:4,:)=-kh(3:4,:); % so that imag(kh)>0
Ep=exp(i*kh);
%Em=exp(-i*kh); % Unstable, not used

% The matrices for transporting (a,b) through a slab z(k)<z<z(k+1), k=1:M-1
% Denoted as P^u and P^d in the paper.
% Transporting up
Ea=zeros(2,2,M-1); Ea(1,1,:)=Ep(1,:); Ea(2,2,:)=Ep(2,:);
% Note that for evanescent waves, |Ea|<=1
% Transporting down (=Ea for vertical, otherwise, also |Eb|<=1)
Eb=zeros(2,2,M-1); Eb(1,1,:)=Ep(3,:); Eb(2,2,:)=Ep(4,:);
% The inverses -- source of instability
%Eai=zeros(2,2,M-1); Eai(1,1,:)=Em(1,:); Eai(2,2,:)=Em(2,:);
%Ebi=zeros(2,2,M-1); Ebi(1,1,:)=Em(3,:); Ebi(2,2,:)=Em(4,:);

% The matrix for transporting (a,b) across a boundary at z(k+1), k=1:M-1
% Denoted as T^u and T^d in the paper.
Xu=zeros(4,4,M-1); Xd=zeros(4,4,M-1);
for k=1:M-1
    % Please note that X(k) corresponds to boundary z(k+1). There is no
    % transport through z(1).
    % Up (from z(k+1)-0 to z(k+1)+0)
    Xu(:,:,k)=F(:,:,k+1)\F(:,:,k);
    if ~isempty(find(isnan(Xu(:,:,k))))
        error(['k=' num2str(k) ': Xu']);
    end
    % Down (just an inverse)
    Xd(:,:,k)=F(:,:,k)\F(:,:,k+1);
    if ~isempty(find(isnan(Xd(:,:,k))))
        error(['k=' num2str(k) ': Xd']);
    end
end
% For dz->0, we must have Xu, Xd -> U, unit matrix.

% Xuaa=Xu(1:2,1:2,:);
% Xuab=Xu(1:2,3:4,:);
% Xuba=Xu(3:4,1:2,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reflection coefficients. R1(k) and R2(k) correspond to waves starting at
% z(k)+0, down and up, correspondingly.

% R2 - from the upper boundary
R2=zeros(2,2,M);
EbiR2=zeros(2,2,M-1); % Auxiliary, = Eb^(-1)*R2
R2(:,:,M)=zeros(2,2); % no reflection
for k=M-1:-1:1
    % Xuk=Xu(:,:,k);
    EbiR2(:,:,k)=(Xd(3:4,1:2,k)+Xd(3:4,3:4,k)*R2(:,:,k+1))*...
        inv(Xd(1:2,1:2,k)+Xd(1:2,3:4,k)*R2(:,:,k+1))*Ea(:,:,k);
    R2(:,:,k)=Eb(:,:,k)*EbiR2(:,:,k);
end
% R1 - from the lower boundary
R1=zeros(2,2,M);
% Rground is given by key 'ground_bc' and was calculated above
switch ground_bc
    case 'free'
        Rground=zeros(2,2);
    case {'default','E=0'}
        Rground=-eye(2); % for E=0 at z(1) (superconducting ground)
        % More generally,
        %   Rground=-inv(F(1:2,1:2,1))*F(1:2,3:4,1)
        % but in vacuum this simplifies to the above expression.
    case 'H=0'
        %error('unknown bc')
        Rground=eye(2); % for H=0 at z(1) (hypothetical situation)
    otherwise
        error('unknown bc')
end
R1(:,:,1)=Rground;
for k=1:M-1
    RR=Ea(:,:,k)*R1(:,:,k)*Eb(:,:,k);
    R1(:,:,k+1)=(Xu(1:2,1:2,k)*RR+Xu(1:2,3:4,k))*...
        inv(Xu(3:4,1:2,k)*RR+Xu(3:4,3:4,k));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating coefficients (a,b) at z(k)+0
% If all sources are below,
% a(k+1)=A(k)*a(k), b(k)=R2(k)*a(k), k=1:M-1
A=zeros(2,2,M-1);
for k=1:M-1
    % Plug in R2(:,:,k) to avoid instability
    A(:,:,k)=Xu(1:2,1:2,k)*Ea(:,:,k)+Xu(1:2,3:4,k)*EbiR2(:,:,k);
    if ~isempty(find(isnan(A(:,:,k))))
        error(['k=' num2str(k) ': A']);
    end
end
% If all sources are above,
% b(k)=B(k)b(k+1), a(k)=R1(k)*b(k), k=1:M-1
B=zeros(2,2,M-1);
for k=1:M-1
    B(:,:,k)=Eb(:,:,k)*(Xd(3:4,1:2,k)*R1(:,:,k+1)+Xd(3:4,3:4,k));
    if ~isempty(find(isnan(B(:,:,k))))
        error(['k=' num2str(k) ': B']);
    end
end

% NOTE: WE REMOVED THIS PART!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Introduce a source
% NOTE: WE REMOVED THIS PART!
% Sources of (a,b) are infinitely thin sheets (Ja,Jb).
% They are related to the sources in E and H by (Ja,Jb)=G*(JE,JH).
% The source means that
%   (E,H)=(E'+JE,H'+JH)
%   (a,b)=(a'+Ja,b'+Jb)
% where (E,H) and (a,b) are variables just above the source sheet, and
% (E',H') and (a',b') are just below it (both still in the same layer).
%
% Assume (Ja,Jb) is located at z(k)+0. Then just above the source
%   (a(k),b(k))=S(k)*(Ja,Jb)
% and just below the source (but still above z(k))
%   (a'(k),b'(k))=(a,b)-(Ja,Jb)=(S-U)*(Ja,Jb)
% where U is a unit matrix.
% The values (a(k),b(k)) should be used to calculate (a,b) at z>z(k),
% using matrices A,R2 from above, while (a'(k),b'(k)) should be used to
% calculate (a,b) at z<z(k), using matrices B,R1 from above.
% At z(k), we must use (a(k),b(k)) (just above the source, since the source
% is at z(k) and (a,b) are at z(k)+0).
% NOTE: WE REMOVED THIS PART!
%S=zeros(4,4,M);
%for k=1:M
%    r1=R1(:,:,k); r2=R2(:,:,k);
%    i12=inv(eye(2)-r1*r2);
%    i21=inv(eye(2)-r2*r1);
%    S(:,:,k)=[i12 , -i12*r1 ; r2*i12 , -r2*i12*r1]; % only up
%    if ~isempty(find(isnan(S(:,:,k))))
%        error(['k=' num2str(k) ': S']);
%    end
%    % Sd(:,:,k)=[r1*i21*r2 , -r1*i21 ; i21*r2 , -i21];
%end

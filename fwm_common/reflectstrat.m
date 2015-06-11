function [R0,E,H,Ez,Hz]=reflectstrat(varargin)
%REFLECTSTRAT Reflection from an isotropic statified medium
% Based on J. R. Wait, "Electromagnetic Waves in Stratified Media"
% [1970, page 11]
% Usage:
%   [R0,E,H,Ez,Hz]=reflectstrat(zdim,C0,mode,eps,mu);
% Inputs:
%   zdim - dimensionless altitudes, zdim=k0*z, k0=w/c
%   C0   - cosine of the incidence angle (=kz/k0, can be complex)
%   mode - 'TM' or 'TE'
%   eps  - electric permittivity (divided by vacuum value eps0)
%   mu   - magnetic permeability (divided by vacuum value mu0), default==1
% All are scalars or 1D arrays of length M.
% eps(k), mu(k) are at zdim(k) < zdim < zdim(k+1) (where 1 <= k < M)
% eps(M), mu(M) are at zdim > zdim(M)
% For most purposes, eps==1+i*sigma/(eps0*w); mu==1
% Outputs:
%   R0 - complex reflection coefficient from zdim(1).
%   E,Ez - electric field
%   H,Hz - scaled magnetic field H'=H*Z0 (so that H==E in a plane wave)
% IMPORTANT NOTES:
%   1. For complex values, we use the physics convention:
%      E,H ~ e^{-iwt}
%   2. H here is H*Z0, where Z0=sqrt(mu0/eps0), so that H=E in a plane
%      wave.
%   3. For TM (TE) mode, R0=1(-1) to match a perfectly conducting ground at
%      zdim=zdim(1)
%
% See also: MODEFINDER
% Author: Nikolai G. Lehtinen

% Parse arguments
keys={'branchcut_angle'};
[zdim,C0,mode,eps,mu,options]=parsearguments(varargin,4,keys);
% branch cut angle with respect to imaginary axis, clockwise
% WARNING: avoid angle phibr=pi/4 (something wrong with it, pi/4+-0.001
% work fine.
phibr=getvaluefromdict(options,'branchcut_angle',0);
zdim=zdim(:)';
M=length(zdim);
if isempty(mu)
	mu=ones(size(zdim));
end
if length(eps)==1
    eps=eps*ones(size(zdim));
end
eps=eps(:).'; mu=mu(:).';
if length(eps)~=M | length(mu)~=M
    error('wrong length of eps or mu');
end

S02=1-C0^2; % sin(thi)^2
%C=sqrt(eps.*mu-S02); % real(C)>=0, dimensionless, =kz/k0
% Use the position of the branch cut, so that C is continuous at
% -pi/2-phibr<angle(C)<pi/2-phibr and pi/2-phibr<angle(C)<3*pi/2-phibr
%if phibr~=0 => imag(C)>=0 => branch cut along real axis
tmp=exp(2*i*phibr)*(eps.*mu-S02);
tmp2=sqrt(tmp);
if any(real(tmp2)<0)
    error('strange error');
end
C=exp(-i*phibr).*tmp2;
% We must have Im(C(M))>0 for dissipation and Re(C(M))>0 for radiation.
if imag(C(M))<0
    C=-C;
end
if real(C(M))<0
    error(['No radiation for C0=' num2str(C0)]);
end

dz=diff(zdim); % dimensionless=k0*h
kh=C(1:M-1).*dz; % kz*h
ep=exp(i*kh); em=exp(-i*kh);
T=zeros(2,2,M-1); a=zeros(2,M);
a(:,M)=[1;0];
switch mode
	case 'TM'
        % H || y
		K=C./eps
        KK=K(2:M)./K(1:M-1);
        if any(K==0)
            C0
        end
        T(1,1,:)=(1+KK)/2.*em; T(1,2,:)=(1-KK)/2.*em;
        T(2,1,:)=(1-KK)/2.*ep; T(2,2,:)=(1+KK)/2.*ep;
		for k=M-1:-1:1
            a(:,k)=T(:,:,k)*a(:,k+1);
        end
		R=a(2,:)./a(1,:); % R(k) is the reflection coef from just above zdim(k)
        if nargout>1
            % H'==Hy*Z0, H(1)==1
            coef=1/(a(1,1)+a(2,1));
            H=coef*(a(1,:)+a(2,:));
            E=coef*K.*(a(1,:)-a(2,:)); % Ex
            Ez=-sqrt(S02).*H./eps; % Ez
            Hz=zeros(size(H));
        end
	case 'TE'
        % E || y
		N=C./mu;
        NN=N(2:M)./N(1:M-1);
        T(1,1,:)=(1+NN)/2.*em; T(1,2,:)=(1-NN)/2.*em;
        T(2,1,:)=(1-NN)/2.*ep; T(2,2,:)=(1+NN)/2.*ep;
		for k=M-1:-1:1
            a(:,k)=T(:,:,k)*a(:,k+1);
        end
		R=a(2,:)./a(1,:);
        if nargout>1
            % H'==Hx*Z0; H(1)=1
            coef=-N(1)*(a(1,1)-a(2,1));
            H=-N.*(a(1,:)-a(2,:))/coef;
            E=(a(1,:)+a(2,:))/coef;
            Hz=sqrt(S02).*E./mu;
            Ez=zeros(size(H));
        end
end
R0=R(1); % reflection coefficient from just above zdim(1)

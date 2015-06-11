function [R0,E,H,Ez,Hz,reliable]=reflectcurved(varargin)

% RE is the Earth's radius (dimensionless)

% Parse arguments
keys={'branchcut_angle'};
[RE,zdim,C0,mode,eps,mu,options]=parsearguments(varargin,5,keys);
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
tmp=exp(2*i*phibr)*(eps.*mu-S02./(1+zdim/RE).^2);
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
% Correction for the curved earth
Ca=C-1./(8*RE^2*C)+i/(2*RE); % also +-i/(2*RE) for up/down
Cb=C-1./(8*RE^2*C)-i/(2*RE);
% Relative error in C
reliable=max(abs(1./(8*RE^2*(eps.*mu-S02))));


dz=diff(zdim); % dimensionless=k0*h
%kh=C(1:M-1).*dz; % kz*h
kha=Ca(1:M-1).*dz;
khb=Cb(1:M-1).*dz;
% Backward
ep=exp(i*khb); em=exp(-i*kha);
T=zeros(2,2,M-1); a=zeros(2,M);
a(:,M)=[1;0];
switch mode
	case 'TM'
        % H || y
		Ka=Ca./eps;
        Kb=Cb./eps;
        Kap=Ka(2:M); Kam=Ka(1:M-1); Kbp=Kb(2:M); Kbm=Kb(1:M-1);
        Ksum=Kam+Kbm;
        T(1,1,:)=(Kbm+Kap)./Ksum.*em;
        T(1,2,:)=(Kbm-Kbp)./Ksum.*em;
        T(2,1,:)=(Kam-Kap)./Ksum.*ep;
        T(2,2,:)=(Kam+Kbp)./Ksum.*ep;
		for k=M-1:-1:1
            a(:,k)=T(:,:,k)*a(:,k+1);
        end
		R=a(2,:)./a(1,:); % R(k) is the reflection coef from just above zdim(k)
        if nargout>1
            % H'==Hy*Z0, H(1)==1
            coef=1/(a(1,1)+a(2,1));
            H=coef*(a(1,:)+a(2,:));
            E=coef*(Ka.*a(1,:)-Kb.*a(2,:)); % Ex
            Ez=-sqrt(S02).*H./eps; % Ez
            Hz=zeros(size(H));
        end
	case 'TE'
        %error('Not implemented');
        % E || y
		Na=Ca./mu; Nb=Cb./mu;
        Kap=Na(2:M); Kam=Na(1:M-1); Kbp=Nb(2:M); Kbm=Nb(1:M-1);
        Ksum=Kam+Kbm;
        T(1,1,:)=(Kbm+Kap)./Ksum.*em;
        T(1,2,:)=(Kbm-Kbp)./Ksum.*em;
        T(2,1,:)=(Kam-Kap)./Ksum.*ep;
        T(2,2,:)=(Kam+Kbp)./Ksum.*ep;
		T;
		for k=M-1:-1:1
            a(:,k)=T(:,:,k)*a(:,k+1);
		end
		a;
		R=a(2,:)./a(1,:);
        if nargout>1
            % H'==Hx*Z0; H(1)=1
            H=-(Na.*a(1,:)-Nb.*a(2,:));
			coef=H(1);
			H=H/coef;
            E=(a(1,:)+a(2,:))/coef;
            Hz=sqrt(S02).*E./mu;
            Ez=zeros(size(H));
        end
end
R0=R(1); % reflection coefficient from just above zdim(1)

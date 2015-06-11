function EH0=fwm_hankel(npb,EHf0,k0r,m)
%FWM_HANKEL Do the Hankel transform to get E, H as a function of radius r
% Usage:
%    EH0=k0^2*fwm_hankel(npb,EHf0,k0*r[,m]);
% Inputs:
%    k0=w/c
%    EHf0 (6 x Mi x N) - Fourier transform of E, H, inside regions bounded
%       by npb, on the positive nx axis (i.e., for phi_k==0);
%    r (in meters) - transverse distance
%    npb (N+1) - boundaries of np=kp/k0, k0=w/c
% Outputs:
%    EH0 (6 x Mi x Nr) - E, H as a function of r, on the positive x-axis
%    (i.e., for phi_r==0).
% Notes:
% 1. E, H ~ exp(i*(k.r)) (physics convention)
% 2. H is in Budden's units (V/m)
% 3. For angles phi_k~=0, phi_r~=0, the field is axially symmetric, i.e.
%    E_k, E_{phi_k}=const(phi_k) and E_r, E_{phi_r}=const(phi_r). Then, in
%    both Fourier space and configuration space, at the same radial
%    distance (r or k) the Cartesian components are given by
%       Ex(phi)=Ex0*cos(phi)-Ey0*sin(phi)
%       Ey(phi)=Ex0*sin(phi)+Ey0*cos(phi)
%       Ez(phi)=Ez0
%    (and the same for H).
%    About implementation: to use Hankel transforms, we introduce
%       E_{+,-}=Ex +- i*Ey
%    which have a simpler transformation property
%       E_{+,-}(phi)=E0_{+,-}*exp(+-i*phi)
%    (Ez stays the same)
% 4. Advanced usage for non-axially symmetric fields:
%       EH0=fwm_hankel(k0,EHf0,x,nxb,m);
%    This is for EHf_k, EHf_{phi_k} ~ exp(i*m*phi_k).
%    Then
%       EHf_{+|-|z}(phi_k)=EHf0_{+|-|z}*exp(i*(n+m)*phi_k), n={+1|-1|0}
%    The EH0 field calculated by this function is on the positive x-axis,
%    so for arbitrary phi_r we have
%       EH_{+|-|z}(phi_r)=EH0_{+|-|z}*exp(i*(n+m)*phi_r), n={+1|-1|0}.
%    i.e., EH_r, EH_{phi_r} also have dependence ~ exp(i*m*phi_r).
% See also: FWM_RADIATION
% Author: Nikolai G. Lehtinen

if nargin<4
    m=[];
end
if isempty(m)
    m=0;
    % In general case, we separate the currents into vectors I_m, such that
    %    (I_m)_{r|phi_r|z}(rvec)=I_{m,r|phi_r|z}*exp(i*m*phi_r)
    % i.e., r and phi_r components have exp(i*m*phi_r) dependence.
    % This is done by utilizing I+- == Ix +- i*Iy and Iz.
    % Then 
    %    (I_m)_{+|-|z}(phi_r) ~ exp(i*(m+n)*phi_r)
    % where n=+1 for {+}-component, n=-1 for {-}-component at n=0 for
    % z-component.
	% Note that m==0 corresponds to an axially symmetric case.
    % After FT, we still have the same phi_k dependence:
    %    (I_m)_{+|-|z}(phi_k) ~ exp(i*(m+n)*phi_k)
    % by the property of the Fourier/Hankel transforms.
    % EXAMPLE: If I==const(phi) (an important example of which is a
    %    horizontal dipole), then we separate the currents into
    %    3 vectors: m==0 component I_0=zu*Iz, and m==+-1 components
    %    I_{+-1}=(Ix-+i*Iy)*(xu+-i*yu)/2.
end
global output_interval
if isempty(output_interval)
	output_interval=20;
end
Nr=length(k0r);
[dummy,Mi,N]=size(EHf0);
npb=npb(:).';
np=(npb(1:end-1)+npb(2:end))/2;
if length(np)~=N | dummy~=6
    error('wrong sizes')
end

% Ex,Ey -> E+, E-
% We reuse the same array to save memory
tmp=EHf0([1 4],:,:);
EHf0([1 4],:,:)=tmp+i*EHf0([2 5],:,:);
EHf0([2 5],:,:)=tmp-i*EHf0([2 5],:,:);
% Ez stays the same.

EH0=zeros(6,Mi,Nr);
% Integrate
dnp=diff(npb);
weight=dnp.*np/(2*pi);
% - Multiply by usual integration coefficient. We define
% A(x)=\int A(kx)*exp(i*kx*x) dkx/(2*pi)
% A(kx)=\int A(x)*exp(-i*kx*x) dx
% We use the fact that in the polar coordinates
% E_{+|-|z}(r,phi_r)=
%    =\iint E_{+|-|z}(kr,phi_k)*exp(i*kr*r*cos(phi_r-phi_k))*
%     kr d kr dphi_k/(2*pi)^2
% We use Bessel function property
% 2*pi*i^{+-n}*J_n(x)=\int_{-pi}^{+pi} exp(i*n*phi+-i*x*cos(phi)) d phi
% and obtain
% E_{+|-|z}(r,phi_r)=
%    =exp(i*n*phi_r) *
%     \iint E_{+|-|z}(kr,phi_k=0)*
%      exp(i*n*(phi_k-phi_r)+i*kr*r*cos(phi_r-phi_k))*
%      kr d kr dphi_k/(2*pi)^2=
%    =\int_0^\infty E_{+|-|z}(kr,phi_k=0) * i^n * J_n(kr*r) *kr*d kr/(2*pi)
%    = i^n/(2*pi)* Hankel transform of order n of E_{+|-|z}(kr,phi_k=0)
% where n={1|-1|0} for E_{+|-|z}.
% This remains true when we E_k, E_phi with exp(i*m*phi_r) dependence, in
% which case we substitute n -> n+m. Note for m==0 we can use
% i^{-n}*J_{-n}=i^n*J_n
tstart=now*24*3600; toutput=tstart;
%EHf0tmp=permute(EHf0,[1 3 2]);
for ir=1:Nr
    w0=(i^m)*besselj(m,k0r(ir)*np); % n==0
    wp=(i^(m+1))*besselj(m+1,k0r(ir)*np); % n==1
    % Calculate for n==-1:
    if m==0
        wm=wp; % save some time for the important case m==0
    else
        wm=i^(m-1)*besselj(m-1,k0r(ir)*np);
	end
	wt=repmat([wp;wm;w0],[2 1]).*repmat(weight,[6 1]); % 6 x N
	for ki=1:Mi
		EH0(:,ki,ir)=sum(squeeze(EHf0(:,ki,:)).*wt,2);
	end
    timec=now*24*3600;
    ttot=timec-tstart;
    if timec-toutput>output_interval
        toutput=timec;
        disp(['FWM_HANKEL: Done=' num2str(ir/Nr*100) '%; ' ...
            'Time=' hms(ttot) ...
            ', ETA=' hms(ttot/ir*(Nr-ir))]);
    end
end

% E+, E- -> Ex, Ey
tmp=EH0([1 4],:,:);
EH0([1 4],:,:)=(tmp+EH0([2 5],:,:))/2;
EH0([2 5],:,:)=(tmp-EH0([2 5],:,:))/(2*i);
% Ez stays the same.


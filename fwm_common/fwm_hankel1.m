function EH0=fwm_hankel(k0,EHf0,x,npb,dxdamp,m,return_Epm)
%FWM_HANKEL Do the Hankel transform to get E, H as a function of radius x
% Usage:
%    EH0=fwm_hankel(k0,EHf0,x,nxb[,dxdamp]);
% Inputs:
%    k0=w/c
%    EHf0 (6 x N x Mi) - Fourier transform of E, H, inside regions bounded
%       by nxb, on the positive nx axis (i.e., for phi_k==0);
%    x (in meters) - transverse distance
%    nxb (N+1) - boundaries of nx=kx/k0, k0=w/c
% Outputs:
%    EH0 (6 x Nx x Mi) - E, H as a function of x, on the positive x-axis
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
%       EH0=fwm_hankel(k0,EHf0,x,nxb,dxdamp,m);
%    This is for EHf_k, EHf_{phi_k} ~ exp(i*m*phi_k).
%    Then
%       EHf_{+|-|z}(phi_k)=EHf0_{+|-|z}*exp(i*(n+m)*phi_k), n={+1|-1|0}
%    The EH0 field calculated by this function is on the positive x-axis,
%    so for arbitrary phi_r we have
%       EH_{+|-|z}(phi_r)=EH0_{+|-|z}*exp(i*(n+m)*phi_r), n={+1|-1|0}.
%    i.e., EH_r, EH_{phi_r} also have dependence ~ exp(i*m*phi_r).
% See also: FWM_RADIATION
% Author: Nikolai G. Lehtinen

if nargin<7
    return_Epm=[];
end
if nargin<6
    m=[];
end
if nargin<5
    dxdamp=[];
end
if isempty(return_Epm)
    return_Epm=0;
end
if isempty(m)
    m=0;
    % In general case, we separate the currents into vectors I_m, such that
    %    (I_m)_{r|phi_r|z}(rvec)=I_{m,r|phi_r|z}*exp(i*m*phi_r)
    % i.e., r and phi_r components have exp(i*m*phi_r) dependence.
    % This is done using 1D Fourier transform in the angles only:
    %    I_{m,z}=\int Iz(phi_r) * exp(-i*m*phi_r) * d(phi_r)/(2*pi)
    %    I_{m,r} +- i*I_{m,phi_r}=
    %        \int I_{+-}(phi_r) * exp(-i*(m+-1)*phi_r) * d(phi_r)/(2*pi)
    % where I_{+-}=Ix +- i*Iy. Then we have in cartesian coordinates
    %    I_m = zu * (I_m)_z +
    %          (xu-i*yu)/2 * (I_m)_{+} + (xu+i*yu)/2 * (I_m)_{-}
    % where (xu,yu,zu) are unit vectors and
    %    (I_m)_z(phi_r) = exp(i*m*phi_r) * I_{m,z}
    %    (I_m)_{+-}(phi_r) = exp(i*(m+-1)*phi_r) * 
    %        (I_{m,r} +- i*I_{m,phi_r})
    % In summary, at phi_r==0, we have
    %    I_{m0} = \int d(phi_r)/(2*pi) * (
    %       zu * Iz(phi_r) * exp(-i*m*phi_r) +
    %       (xu-i*yu)/2 * I_+(phi_r) * exp(-i*(m+1)*phi_r) +
    %       (xu+i*yu)/2 * I_-(phi_r) * exp(-i*(m-1)*phi_r) )
    % or
    %    I_{m0} = \int d(phi_r)/(2*pi) * exp(-i*m*phi_r) * (
    %       zu * Iz(phi_r) + xu * Ir(phi_r) + yu * Iphi(phi_r) )
    % We chose notation so that m==0 corresponds to an axially
    % symmetric case.
    % We see that 
    %    (I_m)_{+|-|z}(phi_r) ~ exp(i*(m+n)*phi_r)
    % where n=+1 for {+}-component, n=-1 for {-}-component at n=0 for
    % z-component.
    % After FT, we still have the same phi_k dependence:
    %    (I_m)_{+|-|z}(phi_k) ~ exp(i*(m+n)*phi_k)
    % by the property of the Fourier/Hankel transforms. The k and phi_k
    % components will have ~exp(i*m*phi_k) dependence:
    %    (I_m)_{k|phi_k|z}(kvec)=I_{m,k|phi_k|z}*exp(i*m*phi_k)
    % Then (E_m)_{k,phi_k,z}(kvec) also ~exp(i*m*phi_k) because of the
    % linearity of the problem. The cartesian components are
    %    E_{m,+|-|z}(kvec)~exp(i*(m+n)*phi_k) where n={+1|-1|0}.
    % After IFT (performed using Hankel transform), we still have the same
    % angular dependence
    %    E_{m,+|-|z}(rvec)~exp(i*(m+n)*phi_r)
    % The total field must be obtained by summing all E_m.
    % EXAMPLE: If I==const(phi) (an important example of which is a
    %    horizontal dipole), then we separate the currents into
    %    3 vectors: m==0 component I_0=zu*Iz, and m==+-1 components
    %    I_{+-1}=(Ix-+i*Iy)*(xu+-i*yu)/2.
end
if isempty(dxdamp)
    dxdamp=0;
end
output_interval=20;
Nx=length(x);
[dummy,N,Mi]=size(EHf0);
np=(npb(1:end-1)+npb(2:end))/2;
if length(np)~=N | dummy~=6
    error('wrong sizes')
end

% Ex,Ey -> E+, E-
% We reuse the same array to save memory
for eh=1:2
    i1=(eh-1)*3+1;
    i2=(eh-1)*3+2;
    tmp=EHf0(i1,:,:);
    EHf0(i1,:,:)=tmp+i*EHf0(i2,:,:); % E+
    EHf0(i2,:,:)=tmp-i*EHf0(i2,:,:); % E-
    % Ez stays the same.
end

EH0=zeros(6,Nx,Mi);
% Integrate
dnp=diff(npb);
% Damping factor
efactor=exp(-(dxdamp*k0*np).^2/2);
weight=efactor.*dnp.*np*k0^2/(2*pi);
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
for ix=1:Nx
    w0=(i^m)*besselj(m,k0*x(ix)*np); % n==0
    wp=(i^(m+1))*besselj(m+1,k0*x(ix)*np); % n==1
    % Calculate for n==-1:
    if m==0
        wm=wp; % save some time for the important case m==0
    else
        wm=i^(m-1)*besselj(m-1,k0*x(ix)*np);
    end
    for c=1:6
        if c==3 | c==6
            % Ez and Hz
            wt=weight.*w0;
        elseif c==1 | c==4
            % E+ and H+
            wt=weight.*wp;
        else
            % E- and H-
            wt=weight.*wm;
        end
        for izi=1:Mi
            EH0(c,ix,izi)=sum(EHf0(c,:,izi).*wt.');
        end
    end
    timec=now*24*3600;
    ttot=timec-tstart;
    if timec-toutput>output_interval
        toutput=timec;
        disp(['FWM_HANKEL: Done=' num2str(ix/Nx*100) '%; ' ...
            'Time=' hms(ttot) ...
            ', ETA=' hms(ttot/ix*(Nx-ix))]);
    end
end

if return_Epm
    return
end
return_Epm
% E+, E- -> Ex, Ey
for eh=1:2
    i1=(eh-1)*3+1;
    i2=(eh-1)*3+2;
    tmp=EH0(i1,:,:);
    EH0(i1,:,:)=0.5*(tmp+EH0(i2,:,:)); % Ex
    EH0(i2,:,:)=-i*0.5*(tmp-EH0(i2,:,:)); % Ey
    % Ez stays the same.
end

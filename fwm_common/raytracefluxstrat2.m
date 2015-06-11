function [r0,n0,tau]=...
	raytracefluxstrat2(thp0,php0,thB,h,wp2,w,wH,mode,alfa,debugflag,maxerr)
%RAYTRACEFLUXSTRAT2 Ray tracing in stratified plasma
% Use a second-order method.
% Trace rays in magnetoactive plasma with constant B, which is
% stratified in horizontal (xp,yp) plane.
% The starting point is at the origin.
% Usage:
%   [r0,n0,tau]=...
%  raytracefluxstrat(thp0,php0,thB,h,wp2,w,wH,mode,alfa,debugflag,maxerr);
% Inputs:
%  thp0 -- starting zenith angle
%  php0 -- starting azimuthal angle
%  thB  -- B zenith angle
%  h    -- array of heights (must be equidistant) (arbitrary length units)
%  wp2  -- array of plasma frequencies squared in s^{-2}
%  w    -- frequency in s^{-1}
%  wH   -- electron gyrofrequency in s^{-1}
%  mode -- +1 for LH, -1 for RH mode
% Optional inputs:
%  alfa -- refining coefficient (1 by default, <1 for more accurate
%          solution): dtau~alfa*dh
%  debugflag -- print debugging information (0 by default, >0 for verbose
%          printout)
%  maxerr -- maximum error. Usually 1e-3 (default) or even 1e-2 is enough.
%          1e-4 gives very accurate solution.
% Outputs:
%  r0 -- ray coordinates xp==r0(:,1), yp==r0(:,2), zp==r0(:,3)
%        (arbitrary length units);
%  n0 -- the refraction coefficient components;
%  tau -- the fake "time" coordinate;
% Implementation:
% Use the Hamilton's equations to find the ray trajectory.
% Use Appleton-Hartree equation for refraction coefficient.
% See also: RAYTRACEFLUXSTRAT
% This version is more accurate near Spitze effects, because it implements
% adaptive time step. Neither
% RAYTRACEFLUXSTRAT nor RAYTRACEFLUXSTRAT2 can handle proper Spitze
% effects, so I suggest to choose rays slightly out of the plane of B.
% The energy flux is not YET calculated, but is planned to.
if nargin<11
    maxerr=1e-4;
end
if nargin<10
    debugflag=0;
end
if nargin<9
    alfa=0.5;
end
x1=0; y1=0; z1=1;
rotmx=[cos(php0) -sin(php0) 0; sin(php0) cos(php0) 0; 0 0 1]*...
    [cos(thp0) 0 sin(thp0); 0 1 0; -sin(thp0) 0 cos(thp0)];
n0s=rotmx*[x1;y1;z1]; % Active rotation
nh=length(h);
Y=wH/w;
if Y==1
    error('Y==1')
end
X0=wp2/w^2;
nmax=30000;
rn=repmat(nan,[nmax,6]);
% The unit vector along B
nB=zeros(1,3);
nB(1)=sin(thB); nB(2)=0; nB(3)=cos(thB);
% Initial conditions
rn(1,:)=[0 0 0 n0s(:).'];
breakcycle=0;
hc=(h(1:nh-1)+h(2:nh))/2;
dX0dz=[(X0(2)-X0(1))/(h(2)-h(1)) (X0(3:nh)-X0(1:nh-2))./(h(3:nh)-h(1:nh-2)) ...
    (X0(nh)-X0(nh-1))/(h(nh)-h(nh-1))];
params={h,X0,dX0dz,nB,Y,mode,debugflag};
dh=h(2)-h(1);
it=1;
tau=repmat(nan,[nmax,1]);
tau(1)=0;
while it<nmax
    if debugflag>1
        disp(['it=' num2str(it) ', x=' num2str(rn(it,1)) ...
            ', z=' num2str(rn(it,3))]);
    end
    [drn,flag]=gderiv(rn(it,:),params);
    if flag
        if flag==1
            if debugflag>0
                disp('out')
            end
            break;
        else
            error('n2<0');
        end
    end
    X=interp1(h,X0,rn(it,3));
    dXdz=interp1(h,dX0dz,rn(it,3));
    % n should not change too much
    dndtau=sqrt(sum(drn(4:6).^2)/sum(rn(it,4:6).^2));
    drdtau=sqrt(sum(drn(1:3).^2));
    % X should not change too much on distance dr=dr/dt*dt
    dXdtau=abs(drdtau*dXdz/max(X,maxerr));
    drddtau=drdtau/(h(2)-h(1));
    dqdtau=max([dndtau dXdtau drddtau]);
    if dqdtau==0
        error('dqdtau==0');
    end
    dtaunew=alfa/dqdtau;
    if it>1
        dtau=min(dtaunew,2*dtau);
    else
        dtau=dtaunew;
    end
    while 1
        rnc=rn(it,:)+drn.*dtau/2;
        [drnc,flag]=gderiv(rnc,params);
        if flag
            if flag==1
                if debugflag>0
                    disp([' out, z=' num2str(rn(it,3))]);
                end
                breakcycle=1;
                break;
            else
                if debugflag>0
                    disp([' ' num2str(it) '-1 n2<0: refining dtau to ' num2str(dtau/4)]);
                end
                dtau=dtau/4;
                continue
            end
        end
        rnd=rn(it,:)+drnc.*dtau;
        [drnd,flag]=gderiv(rnd,params);
        if flag
            if flag==1
                if debugflag>0
                    disp([' out, z=' num2str(rn(it,3))]);
                end
                breakcycle=1;
                break;
            else
                if debugflag>0
                    disp([' ' num2str(it) '-2 n2<0: refining dtau to ' num2str(dtau/2)]);
                end
                dtau=dtau/2;
                continue
            end
        end
        errest=abs(drn+drnd-2*drnc)./max(abs(drnc),maxerr);
        if errest>maxerr
            if debugflag>0
                disp([' -- errest=' num2str(errest) '; refining dtau to ' num2str(dtau/2)]);
            end
            dtau=dtau/2;
        else
            break
        end
    end
    if breakcycle
        break;
    end
    it=it+1;
    rn(it,:)=rnd;
    tau(it)=tau(it-1)+dtau;
end 
r0=rn(1:it,1:3);
n0=rn(1:it,4:6);
tau=tau(1:it);
return;

function [drn,flag]=gderiv(rn,params)
r=rn(1:3);
n=rn(4:6);
drn=zeros(1,6);
h=params{1};
X0=params{2};
dX0dz=params{3};
nB=params{4};
Y=params{5};
mode=params{6};
debugflag=params{7};
r=rn(1:3); n=rn(4:6);
if r(3)>h(end) | r(3)<h(1)
    flag=1;
    return;
end
dXdz=interp1(h,dX0dz,r(3));
X=interp1(h,X0,r(3));
P=1-X;
% The direction of the previously calculated n:
% cos and sin of the (n,nB) angle
nabs=sqrt(sum(n.^2));
%size(n)
%size(nB)
c=sum(n.*nB)/nabs;
s=sqrt(1-c^2);
% The unit th vector
if s>0
    uth=(c*n/nabs-nB)/s;
else
    uth=zeros(1,3);
end
% Calculate the new refraction coef.
Del=sqrt(Y.^2.*s.^4+4.*P.^2.*c.^2);
denom=2.*P-Y.^2.*s.^2+mode*Y.*Del;
n2=1-(2*P.*X)./denom;
if n2<0
    flag=2;
    return;
end
nabs1=sqrt(n2);
% Advance the k-vector (zp-component only) and position
dn2dX=2*((2*X-1)*denom-2*P*X*(1+mode*2*Y*P*c^2/Del))/denom.^2;
% For ray tracing: the alfa
tana=mode*2*P.*X.*Y.*s.*c./(Del.*denom);
drn(6)=dn2dX*dXdz/2;
drn(1:3)=n+nabs1*uth*tana;
flag=0;


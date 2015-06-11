function [r0,n0,tau,beamlen,dAdOmega,SS0,rp,np]=...
	raytracefluxstrat(thp0,php0,thB,h,wp2,w,wH,mode,alfa,debugg)
%RAYTRACEFLUXSTRAT Ray tracing in stratified plasma
% Use a second-order method.
% Trace rays in magnetoactive plasma with constant B, which is
% stratified in horizontal (xp,yp) plane.
% The starting point is at the origin.
% Usage:
%   [r0,n0,tau,beamlen,dAdOmega,SS0,rp,np]=...
%        raytracefluxstrat(thp0,php0,thB,h,wp2,w,wH,mode,alfa,debugg);
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
%  debugg -- print debugging information (0 by default, >0 for verbose
%          printout)
% Outputs:
%  r0 -- ray coordinates xp==r0(:,1), yp==r0(:,2), zp==r0(:,3)
%        (arbitrary length units);
%  n0 -- the refraction coefficient components;
%  tau -- the fake "time" coordinate;
%  beamlen -- the length of the beam;
% Optional outputs (for energy flux calculation, make the program slower):
%  dAdOmega -- the transverse area of a beam emitted by a point source,
%          normalized so that dAdOmega=r0^2 for vacuum;
%  SS0 -- ratio of the Poynting flux to the Poynting flux for 1/beamlen
%         spreading of the beam.
%  rp,np -- the neighbor rays for r0 (for debugging).
% Implementation:
% Use the Hamilton's equations to find the ray trajectory.
% Use Appleton-Hartree equation for refraction coefficient.
% Use Liouville's determinant to find the transverse area.
if nargin<10
    debugg=0;
end
if nargin<9
    alfa=1;
end
% Do not calculate 4 additional rays if the power is not needed
% (this optimizes the program a bit)
needpower=(nargout>4);
if needpower
    numrays=5;
    % Set up the neighbor rays
    dth=1e-3;
    ds=sin(dth/2);
    dc=cos(dth/2);
    x1=[0 -ds ds 0 0];
    y1=[0 0 0 -ds ds];
    z1=[1 dc dc dc dc];
else
    numrays=1;
    x1=0; y1=0; z1=1;
end
rotmx=[cos(php0) -sin(php0) 0; sin(php0) cos(php0) 0; 0 0 1]*...
    [cos(thp0) 0 sin(thp0); 0 1 0; -sin(thp0) 0 cos(thp0)];
n0s=rotmx*[x1;y1;z1]; % Active rotation

nh=length(h);
dh=h(2)-h(1);
Y=wH/w;
if Y==1
    error('Y==1')
end
Xarr=wp2/w^2;
nmax=30000;
rp=repmat(nan,[nmax,3,numrays]);
tau=zeros(nmax,1);
np=rp;
dtau0=dh*alfa;
itmax=nmax;
% The unit vector along B
nB=zeros(1,3);
nB(1)=sin(thB); nB(2)=0; nB(3)=cos(thB);
% Initial conditions
rp(1,:,:)=0;
np(1,:,:)=n0s;
dXdr=zeros(1,3);
n2=zeros(1,numrays);
tana=zeros(1,numrays);
breakcycle=0;
dnp=zeros(3,numrays);
drp=zeros(3,numrays);
for it=1:nmax-1
    if debugg>1
        disp(['it=' num2str(it) ', x=' num2str(rp(it,1,:)) ...
            ', z=' num2str(rp(it,3,:))]);
	end
	% UNFINISHED PIECE HERE
	if 0
		% Calculate the electric field (for the central ray only)
		if X==0 & Y==0
			Ex=c;
			Eyi=-mode;
			Ez=-s;
		elseif X==0
			% Y>0
		elseif Y==0
			% X>0
		else
			% Both>0
		end
	end
    % The parameters at current point -- use the same "slab" for the
    % neighboring rays.
    riz=(rp(it,3,1)-h(1))/dh+1;
    iz=floor(riz);
    if isnan(riz)
        error(['iz is nan at it=' num2str(it)])
    end
    if iz<=0 | iz>=nh
        if debugg>0
            disp('out');
        end
        itmax=it-1;
        breakcycle=1;
        break
    end
    dXdr(1)=0;
    dXdr(2)=0;
    dXdr(3)=(Xarr(iz+1)-Xarr(iz))/dh;
	for ith=1:numrays
        riz=(rp(it,3,ith)-h(1))/dh+1;
        diz=riz-iz;
        X=Xarr(iz)*(1-diz)+Xarr(iz+1)*diz; % linear interpolation
		P=1-X;
		% The direction of the previously calculated n:
		% cos and sin of the (n,nB) angle
		nprev=sqrt(sum(np(it,:,ith).^2));
		c=sum(np(it,:,ith).*nB)/nprev;
		s=sqrt(1-c^2);
		% The unit th vector
		if s>0
			uth=(c*np(it,:,ith)/nprev-nB)/s;
		else
			uth=zeros(1,3);
		end
		% Calculate the new refraction coef.
		Del=sqrt(Y.^2.*s.^4+4.*P.^2.*c.^2);
		denom=2.*P-Y.^2.*s.^2+mode*Y.*Del;
		n2(ith)=1-(2*P.*X)./denom;
		if n2(ith)<0
            if debugg>0
                disp('n2<0')
            end
			itmax=it-1;
			breakcycle=1;
			break
		end
		n=sqrt(n2(ith));
		% Advance the k-vector (zp-component only) and position
		dn2dX=2*((2*X-1)*denom-2*P*X*(1+mode*2*Y*P*c^2/Del))/denom.^2;
		% For ray tracing: the alfa
		tana(ith)=mode*2*P.*X.*Y.*s.*c./(Del.*denom);
		dnp(:,ith)=dn2dX*dXdr/2;
		drp(:,ith)=np(it,:,ith)+n*uth*tana(ith);
	end
	if breakcycle
		break
	end
	if it/2==round(it/2)
        % Calculate the second-order values
        tau(it+1)=tau(it-1)+dtau;
        np(it+1,:,:)=np(it-1,:,:)+dtau*reshape(dnp,[1 3 numrays]);
        rp(it+1,:,:)=rp(it-1,:,:)+dtau*reshape(drp,[1 3 numrays]);
    else % odd it
        % Only used to calculate the time derivative
        dtau=dtau0*min([1 1./n2./(1+tana.^2)]); % Adjust the path step
        tau(it+1)=tau(it)+(dtau/2);
		%size((tau/2)*dnp)
		%size(np(it,:,:))
        np(it+1,:,:)=np(it,:,:)+(dtau/2)*reshape(dnp,[1 3 numrays]);
        rp(it+1,:,:)=rp(it,:,:)+(dtau/2)*reshape(drp,[1 3 numrays]);
    end
end
% Discard even (intermediate) values
rp=rp(1:2:itmax,:,:);
np=np(1:2:itmax,:,:);
tau=tau(1:2:itmax);
% Leave only central values
r0=rp(:,:,1);
n0=np(:,:,1);
% Calculate the Liouville determinant
nn=length(tau);
if needpower
    % Normalize to the angle
    rksi=(rp(2:nn,:,3)-rp(2:nn,:,2))/dth;
    reta=(rp(2:nn,:,5)-rp(2:nn,:,4))/dth;
end
rtau=diff(r0)./meshgrid(diff(tau),1:3)';
% A "fake" group velocity
vgr=sqrt(sum(rtau.^2,2));
% The length of the ray
s=cumsum(sqrt(sum(diff(r0).^2,2)));
if needpower
    % The Liouville determinant
    D=zeros(nn-1,1);
    for k=1:nn-1
        D(k)=det([rksi(k,:); reta(k,:); rtau(k,:)]);
    end
    % Only the power flux has the meaning as dtau can change arbitrarily
    dAdOmega1=D./vgr;
    % The correction to the energy flux (Poynting vector)
    SS0=[1 ; s.^2./dAdOmega1];
    dAdOmega=[0 ; dAdOmega1];
end
beamlen=[0 ; s];

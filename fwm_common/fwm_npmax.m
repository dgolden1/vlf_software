function [npmax1,ki1,need_gauss1,kion,do_extend,npmax2,ki2,need_gauss2]=...
	fwm_npmax(zd,perm,zds,zdi,point_source,np0max,drdampk0)
%FWM_NPMAX Determine the maximum nperp, this is an auxiliary function.
% The effect of ionosphere is limited by evanescence of waves between the
% source and the ionosphere, or by nperp-size of the source. For point
% source, its shape is gaussian with width determined by dxdamp.
% For points close to the source (closer than the ionosphere), there is a
% different nperp, determined either by evanescence between source and
% point, or by nperp-size of the source, or by the gaussian profile point
% source.
% See also: FWM_AXISYMMETRIC, FWM_NONAXISYMMETRIC
M=length(zd);
Mi=length(zdi);
evanescent_const=20; % we neglect exp(-evanescent_const)
isvac=zeros(size(zd));
for k=1:M
    isvac(k)=(max(max(abs(perm(:,:,k)-eye(3))))<=10*eps);
end
kion=min(find(isvac==0)); % The ionosphere starts at h(kion)
zdion=zd(kion);
% npevion - determined by evanescence between source and ionosphere.
% Calculations at np>npmaxev are simplified (without ionosphere) for all
% points.
dzsion=zdion-max(zds);
if dzsion>0
	npev1=sqrt((evanescent_const/dzsion)^2+1);
else % dzsionmin<=0, zero distance through vacuum
	npev1=inf;
end
% npevi - evanescence between source and observation points (in
% vacuum only).
% npevi always >= npevion
npevi=zeros(size(zdi));
zdil=min(zdi,zdion);
zdsl=min(zds,zdion);
for ki=1:Mi
	dzsi=min(abs(zdil(ki)-zdsl));
	if dzsi==0
		npevi(ki)=inf;
	else
		npevi(ki)=sqrt((evanescent_const/dzsi)^2+1);
	end
end
npev2=max(npevi);
extend0=(npevi>npev1);
% npcur - from the shape of the current
if point_source
    npcur=inf;
	if drdampk0==0
		error('drdamp==0 for a point source');
	end
else
	npcur=np0max;
end
% npdamp - from gaussian approximation to a point source
if drdampk0==0
	npdamp=inf;
else
	npdamp=sqrt(2*evanescent_const)/(drdampk0);
end
% choose the min of the two
npshape=min(npdamp,npcur);
need_gauss=(npdamp<npcur);
%% Now we have gathered npev1, npev2, extend0 and (npshape,need_gaussian).
% Determine which npmax1 to use, and if we need extended calculations
% then to which npmax2.
npmax1=min(npev1,npshape);
need_gauss1=(need_gauss & (npev1>npshape));
extend=(extend0 & npev1<=npshape);
do_extend=any(extend);
if do_extend
	npmax2=min(npev2,npshape);
	need_gauss2=(need_gauss & (npev2>npshape));
	ki1=find(~extend);
	ki2=find(extend);
else
	npmax2=[]; need_gauss2=[]; ki1=[1:Mi]; ki2=[];
end

if isinf(npmax1) || (do_extend && isinf(npmax2))
	error('internal error: infinite npmax')
end

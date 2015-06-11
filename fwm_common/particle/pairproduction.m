function sig=pairproduction(k,Z,Ep,method)
% Differential in electron energy
% Neglect screening and assume Born approximation is valid
global rclass0
if isempty(rclass0)
    loadconstants
end
if nargin<4
    method='default';
end
if nargin<3
    Ep=[];
end
if isempty(Ep)
    mode='total';
else
    mode='diffenergy';
end

switch mode
    case 'diffenergy'
        pp=sqrt(Ep.^2-1);
        Em=k-Ep;
        pm=sqrt(Em.^2-1);
        switch method
            case {'exact','default'}
                % "Exact" formula -- Heitler page 258
                xp=2*log(Ep+pp); xm=2*log(Em+pm);
                L=2*log((Ep.*Em+pp.*pm+1)./k);
                sig=pp.*pm./k.^3.*(-4/3-2*Ep.*Em.*(pp.^2+pm.^2)./(pp.^2.*pm.^2)+...
                    Ep.*xm./pm.^3+Em.*xp./pp.^3-xp.*xm./(pp.*pm) ...
                    +L.*(k.^2./(pp.^3.*pm.^3).*(Ep.^2.*Em.^2+pp.^2.*pm.^2) ...
                    -8./3.*Ep.*Em./(pp.*pm)-k./(2.*pp.*pm).*(...
                    (Ep.*Em-pm.^2).*xm./pm.^3+(Ep.*Em-pp.^2).*xp./pp.^3 ...
                    +2.*k.*Ep.*Em./(pp.^2.*pm.^2) )));
            case 'ER'
                % Extremely-relativistic formula
                sig=4*(Ep.^2+Em.^2+(2./3.)*Ep.*Em)./k.^3.*(log(2*Ep.*Em./k)-.5);
        end
        sig(find(Ep<=1))=0;
        sig(find(Em<=1))=0;
    case 'total'
        switch method
            case {'exact','default'}
                % Motz et al, 3D-0000
                is=find(k<3); ks=k(is);
                e=(ks-2)./(ks+2); e1=2.*e./(1+sqrt(1-e.^2));
                sigs=2*pi/3*((ks-2)./ks).^3.*(...
                    1+(1./2.).*e1+(23./40.).*e1.^2+(11./60.).*e1.^3+...
                    (29./960.).*e1.^4);
                ib=find(k>=3); kb=k(ib);
                log2k=log(2.*kb);
                sigb=28./9.*log2k-218./27.+(2./kb).^2.*...
                    (6.*log2k-7./2.+2./3.*log2k.^3-log2k.^2-pi^2/3.*log2k+...
                    pi^2/6.+2*1.2020569)...
                    -(2./kb).^4.*(3./16.*log2k+1./8.)-...
                    (2./kb).^6.*(29./(9.*256).*log2k-77./(27.*512));
                sig=zeros(size(k));
                sig(is)=sigs; sig(ib)=sigb;
            case 'ER'
                sig=28./9.*log(2.*k)-218./27.;
        end
end
sig(find(k<2))=0; % No pair production
sig=sig*Z^2*rclass0^2/137;

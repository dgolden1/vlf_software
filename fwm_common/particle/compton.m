function [sig,arg3,arg4,arg5]=compton(k0,arg2,mode)
% COMPTON Compton scattering cross-section
% Usage:
%   (1) [sig,kav,costhav,vzelav]=compton(k0);
%   (2) [sig,costh,costhel]=compton(k0,k,'diffenergy');
%   (3) [sig,k,costhel]=compton(k0,cos(th),'diffcosth');
% Inputs:
%   k0,k -- initial and final energies in units of mu=me*clight^2
%   th -- scattering angle
% Outputs:
%   sig --
%     (1) total cross-section in m^2
%     (2) differential d(sigma)/dk in m^2 with k in units of mu
%     (3) differential d(sigma)/d(cos(th)) in m^2
%   The following are values after collision:
%     kav -- average photon energy
%     costhav -- average photon scattering angle cosine
%     vzelav -- average electron parallel velocity
%   Cases (2),(3)
%     costh -- photon scattering angle cosine
%     k -- photon energy
%     costhel -- electron angle
global rclass0
if isempty(rclass0)
    loadconstants
end
if nargin==1
    mode='total';
end
if nargin==2
    mode='diffenergy';
end
switch mode
    case 'total'
        % Integrated using Mathematica
        tmp=1+2*k0;
        sig=2*(2+k0.*(1+k0).*(8+k0))./k0.^2./tmp.^2+...
            (k0.^2-2*k0-2)./k0.^3.*log(tmp);
        if nargout>1
            kav=(4/3-2./k0-1/3./tmp.^3+1./tmp+log(tmp)./k0.^2)./sig;
            costhav=(3+k0.*(15+k0.*(23+k0.*(8-3*k0))))./2/k0.^3./tmp.^2+...
                (-3+k0.*(2+k0).*(k0-3)).*log(tmp)./k0.^4;
            vzelav=2*(1+k0.*(7+k0.*(16+k0.*(12+k0))))./k0.^3./tmp.^2+...
                (1+2*k0+k0.^4)./k0.^5.*log(tmp)-...
                (1+k0+k0.^2).*(1+2*k0.*(1+k0)).*log(1+2*k0.*(1+k0))./(1+k0)./k0.^5;
            vzelav=vzelav./sig;
            arg3=kav; arg4=costhav; arg5=vzelav;
        end
    case 'diffcosth'
        costh=arg2;
        kk0=1./(1+k0.*(1-costh));
        sig=kk0.^2.*(kk0+1./kk0-1+costh.^2);
        k=kk0.*k0;
        arg3=k;
        enel=k0-k+1;
        costhel=(enel-kk0)./sqrt(enel.^2-1);
        arg4=costhel;
    case 'diffenergy'
        k=arg2;
        kk0=k./k0;
        costh=1-1./k+1./k0;
        sig=1./k0.^2.*(kk0+1./kk0-1+costh.^2);
        arg3=costh;
        if nargout>2
            enel=k0-k+1;
            costhel=(enel-kk0)./sqrt(enel.^2-1);
            arg4=costhel;
        end
    otherwise
        error('unknown mode')
end
sig=pi*rclass0^2*sig;

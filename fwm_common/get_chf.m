function c=get_chf(varargin)
% GET_CHF Calculate the linear functional of conductivity
% Usage:
%  chf=Ne*sum(ne.*get_chf(en,Nm,w-wH)); % example for x-mode
% Arguments:
%  Ne   -- electron density
%  Nm   -- molecular density (for calculation of collision rate)
%  w-wH -- effective frequency
%  en==[1:nen].'*den -- array of energies
%  ne   -- electron distribution function, normalized to 1
% Advanced usage:
%  method=4;
%  chf=Ne*sum(ne.*get_chf(en,Nm,weff,'method',method));
% Use method=0 for approximate calculation of the conductivity.
% Calculating the DC conductivity tensor:
%  c_parallel=Ne*sum(ne.*get_chf(en,Nm,0));
%  tmp=Ne*sum(ne.*get_chf(en,Nm,wH));
%  c_Pedersen=real(tmp);
%  c_Hall=imag(tmp);
% See also: CONDUCNE (obsoleted by this function).
global ech me
if isempty(ech)
    loadconstants
end
k=ech^2/me; % To remove clutter

keys={'method','n0/n1'};
[en,Nm,weff,options]=parsearguments(varargin,3,keys);
method=getvaluefromdict(options,'method',1);
% Assume ne(0)=ne(1)/3, which is the condition for the flux due to electric
% field Jf to be zero at en(1/2):
% Jf_{k+1/2}=-D_{k+1/2}*(en_{k+1/2}*(ne_{k+1}-ne_k)/den-(ne_{k+1}+ne_k)/4)
% => for k==0 and Jf==0 we get ne_0=ne_1/3.
% The TOTAL flux at en(1/2) is set to zero by ELENDIF. The other
% contribution to flux is from elastic collisions, and is proportional to
% numombar=(2m/M)*numom, the elastic energy loss rate. If M->inf, then we
% can use this condition with confidence.
n0n1=getvaluefromdict(options,'n0/n1',1/3);
% Another popular value for n0/n1 would be zero, but it does not give a
% good result.

nen=length(en);
den=en(nen)/nen;

ec=([0:nen].'+0.5)*den;
numomc=Nm*getnumom(ec,0,'spline')-i*weff;
    
switch method
    case {0,3,5}
        numom=Nm*getnumom(en,0,'spline')-i*weff;
        capprox=k./numom;
        c0approx=k./numomc(1);
end

c0=0; % By default
switch method
    case 0
        % Approximate calculation -- just average 1/numom
        c=capprox;
        c0=c0approx;
    case 1
        % Same as conducne except for normalization, especially for the
        % default value of n0/n1.
        % This is the default method because it gives the best-looking
        % graphs.
        c=(2/3)*k*(diff(ec./numomc)/den+0.25*(1./numomc(1:nen)+1./numomc(2:nen+1)));
        c0=(2/3)*k*(ec(1)/numomc(1)/den+0.25/numomc(1));
    case 2
        % The most straightforward implementation of the functional
        % Gives the worst results, even with n0/n1=1/3.
        c=(2/3)*k*diff(ec.^(3/2)./numomc)/den./sqrt(en);
        c0=(1/3)*k/numomc(1);
    case 3
        % A correction to the approximate solution
        c=capprox-(2/3)*k*diff(numomc)/den.*en./numom.^2;
        c0=c0approx-(1/3)*k/numomc(1);
    case 4
        % Implement sum of en.^(2/3)/nu*(d/den)(ne/sqrt(en))
        ene=[1:nen+1].'*den;
        %nee=[0;ne;0];
        numome=Nm*getnumom(ene,0,'spline')-i*weff;
        e32nu=zeros(nen+2,1);
        e32nu(2:nen+2)=ene.^(3/2)./numome;
        tmp=diff(e32nu)/den./sqrt(ec);
        c=k*2/3*0.5*(tmp(1:nen)+tmp(2:nen+1));
        c0=k*2/3*0.5*tmp(1);
    case 5
        % Same as method 1, basically
        c=(2/3)*k*(diff(ec./numomc)/den+1./2./numom);
        c0=(2/3)*k*(ec(1)/numomc(1)/den+0.25/numomc(1));
    otherwise
        error('unknown method')
end
% Correction for the non-zero value of n(0)
c(1)=c(1)+n0n1*c0;

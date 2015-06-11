function [numom,numombar]=getnumom(en,norot,method)
%[numom,numombar]=getnumom(en,norot)
% Momentum transfer frequency divided by Nm (defined as the sum of elastic
% and inelastic cross-sections).
% en       -- energy in eV
% numom    -- nu_m/N_m in s^{-1}m^3
% numombar -- "energy loss" elastic collision frequency
% norot (optional) -- flag 
% norot==0 -- include, norot==1 -- don't include the rotational losses
% Phelps wants to use linear approximation.
global species composition ech me uAtomic aBohr
if isempty(species)
    loadconstants
end
if nargin<2
    norot=0;
end
if nargin<3
	method='linear';
end
veloc=sqrt(2*en*ech/me);
numom=zeros(size(en));
numombar=zeros(size(en));
rot=zeros(size(en));
rotbar=zeros(size(en));
sig=zeros(size(en));
for isp=1:length(species)
    SP=species(isp);
    % A strange bug:
    %   dnu=Nsp*veloce.*1e-20*interp1(SP.em,SP.qm,ene);
    % doesn't work!!!
    i1=find(en>0 & en<=max(SP.em));
    %sig(i1)=exp(interp1(SP.em,log(SP.qm),en(i1),'spline'));
    sig(i1)=interp1(SP.em,SP.qm,en(i1),method);
    %sig=interp1(SP.em,SP.qm,en);
    i2=find(en>max(SP.em));
    sig(i2)=SP.qm(end)*(en(i2)/SP.em(end)).^(-0.9);
    dnu=composition(isp)*veloc.*(1e-20*sig);
    %plot(ene,dnu); pause
    if any(isnan(dnu))
        en
        dnu
        error('dnu is nan');
    end
    numom=numom+dnu;
    coef=2*me/(SP.molwt*uAtomic);
    numombar=numombar+coef*dnu;
    % The Continuous Approximation to Rotation excitation (CAR)
    % Extremely important at energies < B0*M/m ~ 1 eV
    % Quadrupole moments only
    % See Gerjouy and Stein [1955], eq. 26
    % "B0" is given in eV, and so is "en".
    sig0=8*pi/15*SP.qumom^2*aBohr^2;
    drot=composition(isp)*4*sig0*SP.B0./en.*veloc;
    if ~norot
        numombar=numombar+drot;
    end
end

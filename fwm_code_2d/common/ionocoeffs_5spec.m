function [alfad,alfadc,alfai,gamma,beta,Bcoef,gammaX,Xbar]=...
    ionocoeffs_5spec(varargin)
% IONOCOEFF_5SPEC Calculate the ionosphere chemistry coefficients
%
% Calculate the coefficients in the dynamic 5-species ionosphere model.
% IMPORTANT NOTE: all densities are in cm^{-3}.
%
% Usage:
% ------
%  [alfad,alfadc,alfai,gamma,beta,Bcoef,gammaX,Xbar]=...
%       ionocoeffs_5spec(daytime,Nm,Tn,Te,'option',value,...)
%
% This function is called by IONOCHEM_5SPEC.
%
% Inputs:
% -------
%   daytime - (see IONOCHEM_5SPEC)
%   Nm - atmosphere density
%
% Optional inputs:
% ----------------
%   Tn,Te - neutral and electron temperature profiles
%
% Option-value pairs, in arbitrary order:
% ---------------------------------------
%   'debug'      - level for debugging, >=0, default==1
%   'numspecies' - number of species (5 or 4), default==5. If ==4, then the
%                  old [GPI] model is used.
%   'gamma'      - the formula to use for the detachment coefficient;
%                  possible values: 'temperature','Kozlov','3e-XX','3emXX',
%                  'zero', default=='temperature'
%   'gammaX'     - detachment coefficient for the NX species; possible
%                  values: 'photo','zero', default=='photo'
%   'alfai'      - mutual neutralization coeff; possible values: 'GPI',
%                  'MH', default == 'MH' (3-body at h<40 km) 
%
% Outputs: the coefficients as functions of Nm,Tn,Te.
%
% References:
% -----------
%  [GPI] Glukhov et al [1992], doi:10.1029/92JA01596 (DOI not created yet)
%  [PI]  Pasko and Inan [1994], doi:10.1029/94JA01378
%  [RI]  Rodriguez and Inan [1994], doi:10.1029/93GL03007
%  [Gur] Gurevich, 1978, p. 114, "Nonlinear phenomena in ionosphere"
%  [A]   Alexandrov et al [1997] doi:10.1088/0022-3727/30/11/011
%  [Koz] Kozlov et al (1988), Cosmic Res., v. 26, p. 635
%  [M] Mitra [1975], JATP, 37, p. 895
%  [F] Ferguson [1979], NASA CP-2090, p. 71
%  [R] Reid [1979], NASA CP-2090, p. 27
%  [MH] Mitchell and Hale [1973], Space Research XIII, p. 471
%
% The units in the source papers are m^{-3} [RI] and cm^{-3} [all other]
%
% The equations to be solved are (the prime denotes time derivative)
%
%  Ne'    = S + gamma*Nneg - beta*Ne - alfad*Ne*Npos - alfadc*Ne*Nclus + gammaX*NX;
%  Nneg'  = beta*Ne - gamma*Nneg - alfai*Nneg*(Npos+Nclus) - Xbar*Nneg;
%  Nclus' = - alfadc*Ne*Nclus + Bcoef*Npos - alfai*(Nneg+NX)*Nclus;
%  NX'    = Xbar*Nneg - gammaX*NX - alfai*NX*(Npos+Nclus);
%  Npos'  = S - Bcoef*Npos - alfad*Ne*Npos - alfai*(Nneg+NX)*Npos;
%
% where
%
%  S     - external source of ionization
%  Ne    - electron density
%  Npos  - positive ion density
%  Nneg  - negative ions, from which electrons are easily detached (O2-, ...)
%  Nclus - positive cluster ion density (hydrated Npos, H+(H2O)n)
%  NX    - negative ions, from which electrons are not detached (NO3-, ...)
%          (new in 5-species model)
%
% For neutrality, it is necessary that Ne+Nneg+NX=Npos+Nclus, so that the
% last equation is dependent.
%
% See also: IONOCHEM_5SPEC
% Author: Nikolai G. Lehtinen

keys={'debug','gamma','gammaX','numspecies','alfai'};
[daytime,Nm,Tn,Te,options]=parsearguments(varargin,2,keys);
numspecies=getvaluefromdict(options,'numspecies',5)
if numspecies~=4 & numspecies~=5
    error('incorrect number of species');
end
% Default arguments
if isempty(Tn)
    T=200;
    Tn=T*ones(size(Nm));
end
if isempty(Te)
    Te=Tn;
end

% alfad -- eff. coeff. of dissociative recombination
% --------------------------------------------------
% [GPI]
% alfad=1e-7 -- 3e-7
% [PI]
%   alfad=3e-7
% [RI]
%   alfad = alfa(NO+) N(NO+)/Npos + alfa(O2+) N(O2+)/Npos
% where
%   alfa(NO+)=4.1e-7*(300/Tn^.5/Te^.5)
%   alfa(O2+)=2.1e-7*(300^.7/Tn^.1/Te^.6)
% We take temperatures (nighttime, [PI])
%   Te=Tn=200 K
% The relative concentration of positive ions is
%   N(NO+)/Npos=0.84 at 100km (IRI-95)
% (dominates) at night at 45 deg latitude
% so approximately alfad=5.6e-7
alfad=6e-7*ones(size(Nm));

% alfadc -- eff. coeff. of recombination of Ne with Nclus
% -----------------------------------------------------------------
% [GPI, PI] alfadc=1e-5
% [RI] alfadc=3e-6*(Tn/Te)^(0--.08)
alfadc=1e-5*ones(size(Nm));

% alfai -- eff. coeff. of mutual neutralization
% -------------------------------------------------------
% [GPI, PI, RI] alfai=1e-7
% [MH] alfai ~ Nm at h<50 km
alfai_opt=getvaluefromdict(options,'alfai','MH');
switch alfai_opt
    case 'MH'
        alfai=1e-7*ones(size(Nm))+1e-24*Nm;
    case 'GPI'
        alfai=1e-7*ones(size(Nm));
    otherwise
        error(['unknown option (alfai) = ' alfai_opt]);
end

% gamma -- eff. electron detachment rate
% -------------------------------------------
gamma_opt=getvaluefromdict(options,'gamma','temperature');
switch gamma_opt
    case 'temperature'
        % The new rate [A] of reaction
        %  O2- + O2 -> e + 2 O2
        % and photodetachment [Gur] 0.44 s^{-1}
        gamma=8.61e-10*exp(-6030./Tn).*Nm+0.44*daytime;
    case 'Kozlov'
        % [Koz] Rate of
        %  O2- + O2 -> e + 2 O2
        % [Koz] has photodetachment=0.33 s^{-1}
        gamma=2.7e-10*(Tn/300).^0.5.*exp(-5590./Tn).*Nm + 0.33*daytime;
    case 'zero'
        gamma=zeros(size(Nm));
    otherwise
        % [GPI] gamma=3e-17*Nm
        % [PI]  gamma=3e-18*Nm -- 3e-16*Nm
        % [RI]  gamma=3e-17*Nm
        if length(gamma_opt)==5 & ...
                strcmp(gamma_opt(1:2),'3e') & any(gamma_opt(3)=='-m')
            eval(['gamma=3e-' gamma_opt(4:5) '*Nm;'])
        else
            error(['unknown option (gamma) = ' gamma_opt]);
        end
end

% beta -- eff. electron attachment rate
% ------------------------------------------
% Assume N(O2)=0.2 Nm; N(N2)=0.8 Nm, T=Tn=Te=200 K
% Simplify:
% [GPI,PI,RI] beta=1e-31*N(N2)*N(O2)+k(O2)*(N(O2))^2;
% [GPI,PI] k(O2)=1.4e-29*(300/T)*exp(-600/T) == 1e-30
%   => beta=5.6e-32*Nm^2
% [RI] k(O2)=(see function kO2RI below)=1.5e-30
%   => beta=7.6e-32*Nm^2
beta=5.6e-32*Nm.^2;

% Bcoef -- effective rate of conversion of Npos into Nclus
% --------------------------------------------------------
% [GPI,PI,RI] Bcoef=1e-31*Nm^2
Bcoef=1e-31*Nm.^2;

% Coefficients for the "slow" negative ions (with virtually no detachment)
% See [M,F,R]
% Added on 9/20/2006

% gammaX -- detachment rate from the slow negative ions (NO3-)
% ------------------------------------------------------------
gammaX_opt=getvaluefromdict(options,'gammaX','photo');
if numspecies==4
    gammaX_opt='zero';
end
switch gammaX_opt
    case 'photo'
        gammaX=0.002*daytime*ones(size(Nm)); % see [R]
    case 'zero'
        gammaX=zeros(size(Nm));
    otherwise
        error(['unknown option (gammaX) = ' gammaX_opt]);
end

% Xbar -- the rate of conversion of Nneg (mostly O2-) into NX (N03-)
% ------------------------------------------------------------------
% See [M]
% Xbar=1e-30*N(0_2)*N(M)+3e-10*N(O3), we neglect the ozone.
if numspecies==5
    Xbar=0.2e-30*Nm.^2;
else
    Xbar=zeros(size(Nm));
end

% k02RI -- coef. of reaction e + O2 + O2 -> O2- + O2
% --------------------------------------------------
% From [RI]
% For Tn=Te=200 K, the result is 1.5e-30
% Note that there is an error in a3 in [RI].
% This formula is from Tomko's thesis [1981, page 163].
function k=kO2RI(Tn,Te)
K=1.1617e-27 - 3.4665e-30*Tn + 3.2825e-33*Tn^2;
a1=781.93-3.2964*Tn;
a2=-191.59 + 3.7646*Tn - 4.5446e-3*Tn^2;
a3=-76.834 + 0.012277*Tn - 7.6427e-3*Tn^2 + 1.7856e-5*Tn^3;
k=K*Te^(-0.65)*exp(-a1/Te-(a2/Te)^2-(a3/Te)^3);

function [alfad,alfadc,alfai,gamma,beta,Bcoef,gammaX,Xbar,gamac,betaas,bran]=...
    ionocoeffs_6spec(varargin)
% IONOCOEFF_6SPEC Calculate the ionosphere chemistry coefficients
%
% Version 5.4 (must match the version of IONOCHEM_6SPEC)
%
% Calculate the coefficients in the dynamic 6-species ionosphere model.
% IMPORTANT NOTE: all densities are in cm^{-3}.
%
% Usage:
% ------
%  [alfad,alfadc,alfai,gamma,beta,Bcoef,gammaX,Xbar,gamac,betaas,bran]=...
%       ionocoeffs_6spec(prof,daytime,h,'option',value,...)
%
% This function is called by IONOCHEM_6SPEC.
%
% Inputs:
% -------
%   daytime - (see IONOCHEM_6SPEC)
%   h       - altitudes (km)
%
% Optional inputs:
% ----------------
%   Tn,Te - neutral and electron temperature profiles
%
% Option-value pairs, in arbitrary order:
% ---------------------------------------
%   'debug'  - level for debugging, >=0, default==1
%   'NX'     - use the negative ions with slow detachment (NX)? default==1
%   'Nac'    - use active species (Nac)? default==0
%   'gamma'  - the formula to use for the detachment coefficient;
%              possible values: 'temperature','Kozlov','3e-XX','3emXX',
%              'zero', default=='temperature'
%   'gammaX' - detachment coefficient for the NX species; possible
%              values: 'photo','zero', default=='photo'
%   'alfai'  - mutual neutralization coeff; possible values: 'GPI',
%              'MH', default == 'MH' (3-body at h<40 km)
%   'alfadc' - positive cluster recombination coeff; possible values:
%              'same_as_alfad','normal' (same as in [GPI]),'high',
%              'variable', can add more; default=='normal' (same as in
%              [GPI]).
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
%  [Arijs] Arijs [1992] Planet. Space Sci, 40, 255
%
% The units in the source papers are m^{-3} [RI] and cm^{-3} [all other]
%
% The equations to be solved are (the prime denotes time derivative)
%
%  Ne'    = S + (gamma+gamac*Nac)*Nneg - beta*Ne ...
%             - alfad*Ne*Npos - alfadc*Ne*Nclus + gammaX*NX;
%  Nneg'  = beta*Ne - (gamma+gamac*Nac)*Nneg - alfai*Nneg*(Npos+Nclus) - Xbar*Nneg;
%  Nclus' = - alfadc*Ne*Nclus + Bcoef*Npos - alfai*(Nneg+NX)*Nclus;
%  NX'    = Xbar*Nneg - gammaX*NX - alfai*NX*(Npos+Nclus);
%  Nac'   = bran*S - gamac*Nneg*Nac - betaas*Nac^2;
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
%  Nac -- active species important for detachment (O2(a1Deltag), O, N)
%         Use option 'active'==0 to get rid of this species.
%
% The production of active species by electron impact is bran*S
% where bran=1+1+.17+.1+.1=2.37 according to [Koz]
%
% For neutrality, it is necessary that Ne+Nneg+NX=Npos+Nclus, so that the
% last equation is dependent.
%
% See also: IONOCHEM_6SPEC, IONOCHEM_5SPEC, IONOCOEFFS_5SPEC
% Author: Nikolai G. Lehtinen

keys={'debug','NX','Nac','Nclus',...
    'gamma','gamma_coef','gamma_photo',...
    'gammaX','alfai','alfad','alfadc',...
    'beta','beta_coef','ENm',...
    'Xbar','Xbar_coef',...
    'Nac_profile','Nac_coef','Nac_daytime_coef'};
[prof,daytime,h,options]=parsearguments(varargin,3,keys);
use_NX=getvaluefromdict(options,'NX',1);
use_Nac=getvaluefromdict(options,'Nac',0);
use_Nclus=getvaluefromdict(options,'Nclus',1);
Nm=getNm(h,prof)/1e6;
Tn=getTn(h,prof);
Te=Tn;

% alfad -- eff. coeff. of dissociative recombination
% --------------------------------------------------
% [GPI]
%   alfad=1e-7 -- 3e-7
% [PI]
%   alfad=3e-7
% [RI]
%   alfad = alfa(NO+) N(NO+)/Npos + alfa(O2+) N(O2+)/Npos
% where
%   alfa(NO+)=4.1e-7*(300/Tn^.5/Te^.5)
%   alfa(O2+)=2.1e-7*(300^(0.7)/Tn^(0.1)/Te^(0.6))
% We take temperatures (nighttime, [PI])
%   Te=Tn=200 K
% The relative concentration of positive ions is
%   N(NO+)/Npos=0.84 at 100km (IRI-95)
% (dominates) at night at 45 deg latitude
% so approximately alfad=5.6e-7
alfad_opt=getvaluefromdict(options,'alfad','default');
switch alfad_opt
    case 'default'
        alfad=6e-7*ones(size(Nm));
    otherwise
        tmp=str2double(alfad_opt);
        if ~isnan(tmp) & tmp>0
            alfad=tmp*ones(size(Nm));
        else
            error(['unknown option (alfad) = ' alfad_opt]);
        end
end

% alfadc -- eff. coeff. of recombination of Ne with Nclus
% -----------------------------------------------------------------
% [GPI, PI] alfadc=1e-5
% [RI] alfadc=3e-6*(Tn/Te)^(0--.08)
alfadc_opt=getvaluefromdict(options,'alfadc','default');
switch alfadc_opt
	case 'default'
		alfadc=1e-5*ones(size(Nm));
	case 'same_as_alfad'
        % Clusters are indistinguishible from ions
		alfadc=alfad;
    case 'variable'
        % Try to account for the fact that at lower altitudes the ions are
        % bigger, and have higher recombination rate
        alfadc=1e-6*(1 + (Nm/2.7e16));
	otherwise
        tmp=str2double(alfadc_opt);
        if ~isnan(tmp) & tmp>0
            alfadc=tmp*ones(size(Nm));
        else
            error(['unknown option (alfadc) = ' alfadc_opt]);
        end
end


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
        tmp=str2double(alfai_opt);
        if ~isnan(tmp) & tmp>0
            alfai=tmp*ones(size(Nm));
        else
            error(['unknown option (alfai) = ' alfai_opt]);
        end
end

% gamma -- eff. electron detachment rate
% -------------------------------------------
gamma_opt=getvaluefromdict(options,'gamma','Alexandrov');
gamma_coef=getvaluefromdict(options,'gamma_coef',1);
switch gamma_opt
    case 'Alexandrov'
        % The new rate [A] of reaction
        %  O2- + O2 -> e + 2 O2
        % and photodetachment [Gur, p. 114] 0.44 s^{-1}
        gamma=8.61e-10*exp(-6030./Tn).*Nm*gamma_coef;
    case 'Kozlov'
        % [Koz] Rate of
        %  O2- + O2 -> e + 2 O2
        % [Koz] has photodetachment=0.33 s^{-1}
        gamma=2.7e-10*(Tn/300).^0.5.*exp(-5590./Tn).*Nm*gamma_coef;
    case 'GPI'
        % [GPI] gamma=3e-17*Nm
        % [PI]  gamma=3e-18*Nm -- 3e-16*Nm
        % [RI]  gamma=3e-17*Nm
        gamma=3e-17*Nm*gamma_coef;
    otherwise
        error(['unknown option (gamma) = ' gamma_opt]);
end
gamma_photo=getvaluefromdict(options,'gamma_photo',0.44);
gamma=gamma+gamma_photo*daytime;

% Enhancement of the detachment by the active species
% O2- + O -> O3 + e (k=2.5e-10) [Gur, p. 115]
% Only if we don't calculate the active species explicitly
Nac_coef=getvaluefromdict(options,'Nac_coef',1);
Nac_daytime_coef=getvaluefromdict(options,'Nac_daytime_coef',1);
Nac_daytime=exp(interp1([0 20 50 75 2000],log([1e4 3e7 6e10 2e10 2e10]),h,'cubic'));
% -- fix for incorrect MSIS daytime active species O, O2(a1Delta)
% profiles [Handbook, 21-41; R, Figure 1]
Nac_nighttime=getSpecies('O',h,prof)/1e6;
Nac_profile_default=Nac_coef*Nac_nighttime + ...
    daytime*Nac_daytime*Nac_daytime_coef;
Nac_profile=getvaluefromdict(options,'Nac_profile',[]);
if isempty(Nac_profile)
    Nac_profile=Nac_profile_default;
end
if use_Nac % We are calculating it anyway, even if it is given explicitly
    Nac_profile=0;
end
if length(Nac_profile)==1
    Nac_profile=Nac_profile*ones(size(Nm));
end
gamma=gamma+2.5e-10*Nac_profile;


% beta -- eff. electron attachment rate
% ------------------------------------------
% Assume N(O2)=0.2 Nm; N(N2)=0.8 Nm, T=Tn=Te=200 K
% Simplify:
% [GPI,PI,RI] beta=1e-31*N(N2)*N(O2)+k(O2)*(N(O2))^2;
% [GPI,PI] k(O2)=1.4e-29*(300/T)*exp(-600/T) == 1e-30
%   => beta=5.8e-32*Nm^2
% [RI] k(O2)=(see function kO2RI below)=1.5e-30
%   => beta=7.6e-32*Nm^2
beta_opt=getvaluefromdict(options,'beta','default');
beta_coef=getvaluefromdict(options,'beta_coef',1);
switch beta_opt
    case 'default'
        beta=5.8e-32*Nm.^2*beta_coef;
    otherwise
        error(['unknown option (beta) = ' beta_opt]);
end
% 2-body attachment as a function of electric field
ENm=getvaluefromdict(options,'ENm',0);
beta=beta+twobodyatt(ENm).*Nm;

% Bcoef -- effective rate of conversion of Npos into Nclus
% --------------------------------------------------------
% [GPI,PI,RI] Bcoef=1e-31*Nm^2
if use_Nclus
    Bcoef=1e-31*Nm.^2;
else
    Bcoef=zeros(size(Nm));
end

% Coefficients for the "slow" negative ions (with virtually no detachment)
% See [M,F,R]
% Added on 9/20/2006

% gammaX -- detachment rate from the slow negative ions (NO3-)
% ------------------------------------------------------------
gammaX_opt=getvaluefromdict(options,'gammaX',0.002*daytime);
if ~use_NX
    gammaX_opt=0;
end
gammaX=gammaX_opt*ones(size(Nm));

% Xbar -- the rate of conversion of Nneg (mostly O2-) into NX (N03-)
% ------------------------------------------------------------------
Xbar_opt=getvaluefromdict(options,'Xbar','Ferguson');
Xbar_coef=getvaluefromdict(options,'Xbar_coef',1);
if ~use_NX
    Xbar=zeros(size(Nm));
else
    switch Xbar_opt
        case 'Ferguson'
            % Consider reaction
            % CO3- + N2O5 -> NO3- + NO3 + CO2 (fastest, according to
            % [Arijs]) with k=2.8e-10 [F]
            % Use N[N2O] from Zinn-Sutherland [1990] paper for h > 50 km
            % and from [Handbook, 21-18] for h < 50 km
            NN2O_Nm=exp(interp1([0 20 50 2000],log([3e-7 3e-7 1.5e-8 1.5e-8]),h));
            NN2O=NN2O_Nm.*Nm;
            Xbar=2.8e-10*NN2O*Xbar_coef;
        case 'stop'
            Xbar=3e-17*Nm*Xbar_coef;
            Xbar(find(h>50))=0;
        case 'Mitra-Rowe'
            % See [M]
            % Xbar=1e-30*N(0_2)*N(M)+3e-10*N(O_3), we neglect the ozone.
            Xbar=0.2e-30*Nm.^2*Xbar_coef;
        case 'Ferguson_approximate'
            % Use mixing ratio of N2O == 100 ppbv [Handbook,
            % 21-18] => Xbar=1e-7*2.8e-10*N=3e-17*N
            Xbar=3e-17*Nm*Xbar_coef;
        otherwise
            error(['unknown option (Xbar) = ' Xbar_opt]);
    end
end

% gamac -- electron detachment rate due to active neutral species
% ---------------------------------------------------------------
% Average of coefficients of reactions [Gur, p. 115; A]
%  O2- + O2(a1Deltag) -> 2 O2 + e (k=2e-10)
%  O2- + O -> O3 + e (k=2.5e-10)
%  O2- + N -> NO2 + e (k=3e-10)
% Note that O2(a1Deltag) decays in ~4000 s (Rees, 1989, p. 154)
gamac=2.5e-10*ones(size(Nm));

% betaas -- association of active species
% ---------------------------------------
% [A] betaas=8.27e-34*exp(500/T) for reactions
%  N + N + M -> N2 + M
%  O + O + M -> O2 + M
betaas=1e-32.*Nm;

% bran
% ----
% The production of active species by electron impact is bran*S
% where bran=1+1+.17+.1+.1=2.37 according to [Koz]
if use_Nac
	bran=2.37;
else
	bran=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2-body attachment coefficient from Pasko's thesis
% ENm is in Townsends
function beta2=twobodyatt(ENm)
%a0=-2.41e8/Nm0;
a0=-9.3147296e-18;
%a1=211.92*(Nm0/1e21)/Nm0
a1=2.1192e-19;
%a2=-3.545e-5*(Nm0/1e21)^2/Nm0
a2=-9.1719785e-22;
beta2=1e6*(a0+ENm.*(a1+ENm*a2)); % to convert to cm^3/s
ii=find(beta2<0);
beta2(ii)=0;

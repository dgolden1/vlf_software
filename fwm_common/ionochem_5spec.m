function [Nspec,S0,specnames,Nspec0]=ionochem_5spec(varargin)
%IONOCHEM_5SPEC Calculate ionization as a function of time
%
% Version 4.1
%
% Function to calculate the ionization as a function of time
% for the given source of electrons, using a 5-species model. This is the
% 4-species model [GPI], extended with one more species (NX) to fit lower
% altitudes (<50 km).
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
% Usage
% -----
%  [Nspec,S0,specnames,Nspec0]=...
%      ionochem_5spec(daytime,z,Nspec0,S0,dNini,t,S,'option',value,...)
%
% IMPORTANT NOTE: Units for the densities are cm^{-3}
%
% Inputs:
% -------
%   daytime     - flag to use daytime values of coefficients (1 for
%                 day, 0 for night)
%   z (nh x  1) - altitude array (in km)
%
% Optional arguments:
% -------------------
%   Nspec0 (nh x ns) - equilibrium ionization (species density), in the
%                      following order: Ne, Nneg, Nclus, NX, Npos. Here ns
%                      is the number of species (5).
%                      If S0 is empty, Nspec0 can only have electron
%                      density and be of size (nh x 1).
%   S0     (nh x  1) - equilibrium source (calculated previously). If
%                      empty, it means that we have to calculate it.
%   dNini  (nh x ns) - starting ionization (created by previous sources).
%                      If of size (nh x 1), it means that only the initial
%                      perturbation of Ne is given (and equal to it
%                      perturbation of Npos).
%   t      ( 1 x nt) - time (in seconds) for the source values/density
%                      outputs
%   S      (nh x nt) - source, at different altitudes as a function of
%                      time. If empty, is zero.
%
% Option-value pairs, in arbitrary order:
% ---------------------------------------
%   'debug'      - level for debugging, >=0, default==1
%   'relaxtime'  - relaxation time to calculate the background values;
%                  default==1e4
%   'Scrmax'     - maximum cosmic ray source; default==10 (1/s/cm^3)
%   'hcr'        - altitude of maximum cosmic ray source; default=15 (km)
% Options that are passed to function IONOCOEFFS_5SPEC:
%    'debug','numspecies','gamma','gammaX','alfai'
%
% Output:
% -------
%   Nspec (nh x nt x ns) - species densities as a function of time
%
% Optional outputs:
% -----------------
%   S0 (nh x 1)        - equilibrium source
%   specnames {1 x ns} - cell array of the species names
%   Nspec0 (nh x ns)   - equilibrium densities
%
% See also: IONOCOEFFS_5SPEC
% Author: Nikolai G. Lehtinen

% Revision history:
% -----------------
% v. 1: (9/25/1999) implemented [GPI] model
% v. 2: keep Ne+Nneg==Npos+Nclus, by disregarding DU for Npos
% v. 3: new species Nac (active neutral species)
% v. 4: (9/25/2006) added cosmic ray source; added new species NX (negative
%       ions with slow detachment rate, mostly N03-, see [M,F]); added the
%       automatic source finder; removed the "active species"; added an
%       option of taking the bg values, instead of calculating them all the
%       time; added interface using option-value pairs; cleaned up
%       documentation.

specnames={'Ne','Nneg','Nclus','NX','Npos'};
ns=length(specnames); % Number of species

% Parse the arguments
keys={'debug','gamma','gammaX','numspecies','alfai',...
    'relaxtime','Scrmax','hcr'};
[daytime,z,Nspec0,S0,dNini,t,S,options]=parsearguments(varargin,2,keys);
debugflag=getvaluefromdict(options,'debug',1);
relaxtime=getvaluefromdict(options,'relaxtime',10000);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check for errors in the input

% z
if min(size(z))~=1
    error('z must be 1D');
end
z=z(:); nh=length(z);

% daytime
if daytime
    daystring='day';
else
    daystring='night';
end

% S0 and Nspec0, set "calculatebg"
calculatebg=isempty(S0);
if ~calculatebg & isempty(Nspec0)
    error('Background densities not provided');
    if (min(size(S0))~=1 | length(S0)~=nh)
        error('S0 is of incorrect size');
    end
    S0=S0(:);
end
if calculatebg
    S0=zeros(nh,1);
    if isempty(Nspec0)
        defaultprofile=['winter' daystring];
        disp(['WARNING: assigning a default Ne0 profile = ' defaultprofile]);
        Nspec0=getNe(z,defaultprofile)/1e6;
    end
    if min(size(Nspec0))==1 % only the electron density is provided
        if length(Nspec0)~=nh
            error('Incorrect Ne0')
        end
        Ne0=Nspec0(:);
        Nspec0=zeros(nh,ns); Nspec0(:,1)=Ne0;
    end
end
if any(size(Nspec0)~=[nh ns])
    error('Incorrect Nspec0');
end

% dNini
if isempty(dNini)
    dNini=zeros(nh,1);
end
if (min(size(dNini))==1 & length(dNini)==nh)
    % Only the electron density perturbation is given
    dNeini=dNini(:);
    dNini=zeros(nh,ns);
    dNini(:,1)=dNeini;
    % If there is initial ionization present, the Nposini is assumed to be
    % increased by the same factor.
    dNini(:,ns)=dNeini;
end
if any(size(dNini)~=[nh ns])
    error('dNini is of incorrect size');
end

% t and S, set "bgonly"
bgonly=isempty(t);
if ~calculatebg & bgonly
    disp('WARNING: doing nothing');
    Nspec=Nspec0;
    return
end
if ~bgonly
    if min(size(t))~=1
        error('t must by 1D');
    end
    t=t(:)'; nt=length(t);
    if isempty(S)
        % A small shortcut for relaxation without source
        S=zeros(nh,nt);
    end
    if(any(size(S)~=[nh nt]))
        error('S has incorrect dimensions');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate the coefficients in the dynamic equations
% Note again that the densities here are in cm^{-3}.
% The formulas in source papers use cm^{-3} [GPI,PI] and m^{-3} [RI]

Nm=getNm(z)/1e6; % convert to cm^{-3}
Tn=getTn(z);
options1=getsubdict(options,{'debug','gamma','gammaX','numspecies','alfai'});
[alfad,alfadc,alfai,gamma,beta,Bcoef,gammaX,Xbar]=...
    ionocoeffs_5spec(daytime,Nm,Tn,[],options1{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find the equilibrium (steady-state) conditions, given Ne0

% Calculate the source by binary search.
if calculatebg
    if debugflag>0
        disp('Obtaining the source ... ');
    end
    for iz=1:nh
        Ne=Ne0(iz); % stays constant in this cycle
        if Ne<=0
            continue;
        end
        % Arbitrary initial conditions
        N=Nspec0(iz,1:ns-1)'; % [Ne ; Nneg ; Nclus ; NX];
        % 1. Find the upper and lower bounds
        Stry=1;
        direction=0;
        params=[0 alfad(iz) alfadc(iz) alfai(iz) gamma(iz) beta(iz) ...
            Bcoef(iz) gammaX(iz) Xbar(iz)];
		if debugflag>1
			disp(['h(' int2str(iz) ')=' num2str(z(iz)) ...
				' km: I. DOUBLING, NE GOAL=' num2str(Ne)]);
		end
        while 1
            params(1)=Stry;
            [tf,Nt]=ode15s(@ionochemistry,[0 relaxtime],N,[],params);
            ntsol=length(tf); N=Nt(ntsol,:)';
			if debugflag>1
				disp(['Stry=' num2str(Stry) '; Ne=' num2str(N(1))]);
			end
            newdirection=2*(Ne>N(1))-1;
            if ~direction
                direction=newdirection;
            elseif direction~=newdirection
                % Found our boundaries
                Sprev=Stry/2^direction;
                Slo=min(Stry,Sprev);
                Shi=max(Stry,Sprev);
                break;
            end
            Stry=Stry*2^direction;
        end
        % 2. "Divide and conquer"
		if debugflag>1
			disp('II. DIVIDE AND CONQUER');
		end
        while (Shi-Slo)/Shi>1e-6
			if debugflag>1
				disp(['Slo=' num2str(Slo) '; Shi=' num2str(Shi)]);
			end
            Stry=(Slo+Shi)/2;
            params(1)=Stry;
            [tf,Nt]=ode15s(@ionochemistry,[0 relaxtime],N,[],params);
            ntsol=length(tf); N=Nt(ntsol,:)';
			if debugflag>1
				disp(['Slo=' num2str(Slo) '; Shi=' num2str(Shi) '; Ne=' num2str(N(1))]);
			end
            if Ne>N(1)
                Slo=Stry;
            else
                Shi=Stry;
            end
        end
        S0(iz)=Stry;
        Nspec0(iz,2:ns-1)=N(2:ns-1)';
        if debugflag>0
            disp(['Done source for h(' int2str(iz) ')=' num2str(z(iz)) ' km']);
        end
    end
    % Npos0=Ne0+Nneg0-Nclus0+NX0;
    Nspec0(:,ns)=Nspec0(:,1)+Nspec0(:,2)-Nspec0(:,3)+Nspec0(:,4);

    % Extend the source to low altitudes
    ii=find(S0<=0);
    i0=min(find(S0>0));
    HS=2; % from figures in [R]
    S0(ii)=S0(i0)*exp((z(ii)-z(i0))/HS);
    
    % The cosmic-ray source
    hcr=getvaluefromdict(options,'hcr',15);
	% -- for mid-latitudes
    Scrmax=getvaluefromdict(options,'Scrmax',10);
	% -- From NASA-CP-2090 report [R], in 1/cm^3/s;
    tmp=getNm(z)/getNm(hcr);
    Scr=tmp.*exp(-tmp+1)*Scrmax;
    S0=S0+Scr;
    
    % Get the background constituent concentrations
    if debugflag>0
        disp('Obtaining background concentrations ... ');
    end
    for iz=1:nh
        N=Nspec0(iz,1:ns-1)'; %[Ne0(iz) ; Nneg0(iz) ; Nclus0(iz) ; NX0(iz)];
        params=[S0(iz) alfad(iz) alfadc(iz) alfai(iz) gamma(iz) beta(iz) ...
            Bcoef(iz) gammaX(iz) Xbar(iz)];
        [tf,Nt]=ode15s(@ionochemistry,[0 relaxtime],N,[],params);
        ntsol=length(tf);
        Nspec0(iz,1:ns-1)=Nt(ntsol,:);
    end
    % Npos0=Ne0+Nneg0-Nclus0+NX0;
    Nspec0(:,ns)=Nspec0(:,1)+Nspec0(:,2)-Nspec0(:,3)+Nspec0(:,4);
    if debugflag>0
        disp(' ... done');
    end
end
if bgonly
    Nspec=Nspec0;
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run the simulations
Nspecini=Nspec0+dNini;
disp('Please wait while the ionosphere evolution is calculated ...');
Narr=zeros(ns-1,nh,nt);
for iz=1:nh
	% Initial conditions
	N=Nspecini(iz,1:ns-1)';
	% Cycle over times
	Narr(:,iz,1)=N; % the first value is given
	% Parameters for the equation
	params=[0 alfad(iz) alfadc(iz) alfai(iz) gamma(iz) beta(iz) ...
        Bcoef(iz) gammaX(iz) Xbar(iz)];
	for it=1:(nt-1)
		params(1)=S0(iz)+S(iz,it);
        [tf,Nt]=ode15s(@ionochemistry,[t(it) t(it+1)],N,[],params);
        ntsol=length(tf);
        N=Nt(ntsol,:)';
		Narr(:,iz,it+1)=N;
	end
	disp(['Done with h(' int2str(iz) ')=' num2str(z(iz)) ' km']);
    if debugflag>1
        plot(t,permute(Narr(1,iz,:),[2 3 1]));
        title(['z=' num2str(z(iz))]);
        drawnow; pause(2);
    end
end
Nspec=zeros(nh,nt,ns);
Nspec(:,:,1:ns-1)=permute(Narr,[2 3 1]);
% Npos=Ne+Nneg-Nclus+NX;
Nspec(:,:,ns)=Nspec(:,:,1)+Nspec(:,:,2)-Nspec(:,:,3)+Nspec(:,:,4);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ionochemistry
% -------------
% Time dynamics equations
function Np=ionochemistry(t,N,params)
S=params(1);
alfad=params(2);
alfadc=params(3);
alfai=params(4);
gamma=params(5);
beta=params(6);
Bcoef=params(7);
gammaX=params(8);
Xbar=params(9);
Np=zeros(4,1);
Ne=N(1); Nneg=N(2); Nclus=N(3); NX=N(4);
Npos=Ne+Nneg+NX-Nclus;
Np(1) = S + gamma*Nneg - beta*Ne - alfad*Ne*Npos - alfadc*Ne*Nclus + gammaX*NX;
Np(2) = beta*Ne - gamma*Nneg - alfai*Nneg*(Npos+Nclus) - Xbar*Nneg;
Np(3) = - alfadc*Ne*Nclus + Bcoef*Npos - alfai*(Nneg+NX)*Nclus;
Np(4) = Xbar*Nneg - gammaX*NX - alfai*NX*(Npos+Nclus);

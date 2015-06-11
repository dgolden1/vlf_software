function [ani,dlgndr,dlgndt] = denssub(z,rbase,therm,num,rzero,scbot,...
                    ane0,alpha0,KDUCTS,LK,EXPK,DDK,RCONSN,SCR,...
                    L0,DEF,DD,RDUCLN,HDUCLN,RDUCUN,HDUCUN,...
                    RDUCLS,HDUCLS,RDUCUS,HDUCUS,SIDEDU)
% [ani,dlgndr,dlgndt] = denssub(z,rbase,therm,num,rzero,scbot,ane0,alpha0,...
%                               KDUCTS,LK,EXPK,DDK,RCONSN,SCR,...
%                               L0,DEF,DD,RDUCLN,HDUCLN,RDUCUN,HDUCUN,...
%                               RDUCLS,HDUCLS,RDUCUS,HDUCUS,SIDEDU)
%
% Synopsis (where r=z(1), L derived from z(1),z(2) pair):
%
% ANI(r,L)  =  ANE0 ANR(r) ANLI(r) ANLK(r,L) \Prod_2^{KDUCTS} ANL(r,L)
%
% inputs:
% -------
% z(1)      = geocentric radius (km)
% z(2)      = polar angle (rad)
% rbase     = base radius where ane0 holds (km)
% therm     = diffusive equilibrium temperature (affects ion scale heights)
% num       = total number of participating ions species (e-,H+,He+,O+)
% rzero     = distance to lower ionosphere where density ->0 (typ. r0+100km)
% scbot     = scale height of bottomside of lower ionosphere
% ane0      = base density (el/cc) at rbase
%
% alpha0(2) = H+  relative concentration [0..1]
% alpha0(3) = He+ relative concentration
% alpha0(4) = O+  relative concentration
%
% KDUCTS    = There will be (KDUCTS-1) actual ducts (p-pause Knee is 1st Duct)
% LK        = L value where Plasmapause Knee begins
% EXPK      = Knee Density dropoff exponent value
% DDK       = Knee half-width
% RCONSN    = "geocentric distance to level at which density outside knee
%              equals the density inside knee" .. huh?
% SCR       = "Scale Height of(?) radial density decrease above RCONSN 
%              outside knee"
%
% For description of Duct parameters (begining with LO), see how denssub.m
% works and/or see ratracer documentation, last updated by Ngo Hoc.)
%
% outputs:
% --------
% ani(i)    = species concentrations (el/cc) in order e-, H+, He+, O+
% dlgndr(i) = derivative log(n)? wrt. radius (unverified)
% dlgndt(i) = derivative log(n)? wrt. theta  (unverified)

d2r = pi/180;

r0 = 6370;	% Earth radius (km)

cosz2 = cos(z(2));
sinz2 = sin(z(2));
cosz22 = cosz2 * cosz2;
sinz22 = sinz2 * sinz2;

rb7370 = rbase / 7370;	% 7370 = 6370 + 1000 = standard accepted base alt.
sh(2) =  1.1506 * therm * rb7370*rb7370;% H+  scale height
sh(3) = sh(2) / 4;			% He+ scale height
sh(4) = sh(3) / 4;			% O+  scale height

for i = 1:4,		% 4 species: e-, H+, He+, O+
  alpha(i) = 0;		% these will be concentrations at the pt. of interest
end;

% ----------------------------------------------------------------------
% ANR: Diffusive Equilibrium factor
%
gph = rbase * (1.0 - rbase/z(1) );
exnor(2) = exp(-gph/sh(2));
exnor(3) = exnor(2) * exnor(2) * exnor(2) * exnor(2);
exnor(4) = exnor(3) * exnor(3) * exnor(3) * exnor(3);

q = 0.0;			% used for total concentration
sumi = 0.0;			% used for derivatives
for i = 2:num,
  qi(i) = alpha0(i)*exnor(i);	% how much of this species
  q = q + qi(i);		% total of all species
  sumi = sumi + qi(i)/sh(i);	% total but divided by scale height
end;

for i = 2:num,
  alpha(i) = qi(i) / q;		% actual percent composition at this pt.
end;

anr = sqrt(q);			% concentraion of e- = sum of conc. of ions
ani(1) = ane0 * anr;		% reduction from density at reference pt.

% ----------------------------------------------------------------------
% ANLI: Lower Ionosphere factor
%
arg = (z(1) - rzero)/scbot;	% is this really supposed to go both ways?
arg = min(arg,13.0);

exarg = exp(-(arg*arg));
anli = 1.0 - exarg;
dlnlid = arg*exarg*2.0/(scbot*anli);

l = z(1) / (r0 * sinz22);
dlnldr = 0;
dlnldt = 0;
ani(1) = ani(1) * anli;

if nargin < 9,		% no plasmapause or ducts desired, so return now
  vzs = (rbase/z(1))*(rbase/z(1));
  dlnrdr = -sumi*vzs/(2*q);
  dlgndr(1) = dlnrdr + dlnldr + dlnlid;
  dlgndt(1) = dlnldt;
  for i=2:num,
    ani(i) = ani(1) * alpha(i);
    dlgndr(i) = -dlnrdr - vzs/sh(i) + dlnldr + dlnlid;
    dlgndt(i) = dlnldt;
  end;
  return;
end;

% ----------------------------------------------------------------------
% ANLK: Plasmapause Knee
%
cotz2 = cosz2 / sinz2;
deltal = l - LK;
if deltal > 0,
  d2 = DDK^2;
  argl = deltal*deltal/(d2*2.0);	% this 1/2 not in docs!
  argl = min(argl,80);
  f = exp(-argl);

  argr = (z(1) - RCONSN)/SCR;
  argr = min(argr,12.5);
  fr = exp(-argr*argr);

  trm = (RCONSN/z(1))^EXPK;
  trmodl = trm + (1-trm)*fr;

  dtrmdr = -EXPK*trm*(1-fr)/z(1) - (1-trm)*fr*2*argr/SCR;
  anlk = f + trmodl*(1-f);
  
  factor = deltal*f*l*(1.0-trmodl)/(d2*anlk);
  dlnldr = dlnldr - factor/z(1) + (1.-f)*dtrmdr/anlk;
  dlnldt = dlnldt + 2.0*factor*cotz2;

  ani(1) = ani(1) * anlk;
end;

if KDUCTS < 2 | nargin < 15,	% no further duct-type structures, so return
  vzs = (rbase/z(1))*(rbase/z(1));
  dlnrdr = -sumi*vzs/(2*q);
  dlgndr(1) = dlnrdr + dlnldr + dlnlid;
  dlgndt(1) = dlnldt;
  for i=2:num,
    ani(i) = ani(1) * alpha(i);
    dlgndr(i) = -dlnrdr - vzs/sh(i) + dlnldr + dlnlid;
    dlgndt(i) = dlnldt;
  end;
  return;
end;

% ----------------------------------------------------------------------
% ANL: Duct Factors
%
hl2n = HDUCLN.^2;		% pre-compute some factors
hu2n = HDUCUN.^2;
hl2s = HDUCLS.^2;
hu2s = HDUCUS.^2;
d2 = DD.^2;

latitu = 90. - z(2)/d2r;

for kduc = 2:KDUCTS,
  deltal = l - L0(kduc);
  if (deltal * SIDEDU(kduc)) < 0,
    deltal = 0;
%    disp('deltal set to zero for SIDEDU');
  end;

  argl = (deltal*deltal)/(2*d2(kduc));
%  if argl > 80, break; end;	% this line originally intended for speed

  delnl = DEF(kduc) * exp(-argl);

  SKIPIT = 0;			% trying to replicate original Fotran logic
  frduct = 0;			%   without using GOTO's

  if (latitu >= 0 & z(1) > RDUCUN(kduc)) | (latitu < 0 & z(1) > RDUCUS(kduc)),
    if (latitu >= 0), delr = z(1) - RDUCUN(kduc); end;
    if (latitu <  0), delr = z(1) - RDUCUS(kduc); end;
    if (latitu >= 0), arglr = delr*delr/hu2n(kduc); end;
    if (latitu <  0), arglr = delr*delr/hu2s(kduc); end;
%    if arglr >= 75, break; end;

    frduct = exp(-arglr);
%    disp(sprintf('z(1) > RDUCUx, latitu=%g, z(1)=%g, RDUCUN=%g',latitu,z(1),RDUCUN(kduc)));

    if (latitu >= 0), delroh = 2*delr/hu2n(kduc); end;
    if (latitu <  0), delroh = 2*delr/hu2s(kduc); end;
  else,
    if (latitu >= 0 & z(1) < RDUCLN(kduc))|(latitu < 0 & z(1) < RDUCLS(kduc)),
      if (latitu >= 0), delr = z(1) - RDUCLN(kduc); end;
      if (latitu <  0), delr = z(1) - RDUCLS(kduc); end;
      if (latitu >= 0), arglr = delr*delr/hl2n(kduc); end;
      if (latitu <  0), arglr = delr*delr/hl2s(kduc); end;

%      if arglr >= 75, break; end;

      frduct = exp(-arglr);
%      disp(sprintf('z(1) < RDUCLx, latitu=%g, z(1)=%g, RDUCLS=%g',latitu,z(1),RDUCLS(kduc)));

      if (latitu >= 0), delroh = 2*delr/hl2n(kduc); end;
      if (latitu <  0), delroh = 2*delr/hl2s(kduc); end;
    else,
      SKIPIT = 1;	% Select alternate code segment..
    end;
  end;

%  disp(sprintf('deltal=%g, delnl=%g, frduct=%g',deltal,delnl,frduct));

  if ~SKIPIT,
    delnl = delnl * frduct;	% full equations
    anl = 1 + delnl;
    fac = delnl*deltal*l/(anl*d2(kduc));
    onedut = fac*2*cotz2;
    onedur = -fac/z(1) - delnl*delroh/anl;
  else,
    anl = 1 + delnl;		% minimal effects
    onedur = -delnl*deltal*l/(anl*d2(kduc)*z(1));
    onedut = -onedur*2*z(1)*cotz2;
  end;

  dlnldr = dlnldr + onedur;
  dlnldt = dlnldt + onedut;
  ani(1) = ani(1) * anl;

end;    

vzs = (rbase/z(1))*(rbase/z(1));
dlnrdr = -sumi*vzs/(2*q);
dlgndr(1) = dlnrdr + dlnldr + dlnlid;
dlgndt(1) = dlnldt;
for i=2:num,
  ani(i) = ani(1) * alpha(i);
  dlgndr(i) = -dlnrdr - vzs/sh(i) + dlnldr + dlnlid;
  dlgndt(i) = dlnldt;
end;

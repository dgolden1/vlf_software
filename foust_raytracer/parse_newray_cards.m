function [cfg] = parse_newray_cards(...
    card1,card2,card3,card4,card5,card6,card7,card8,card9,card10,...
    card11,card12,card13,card14,card15);

% script parse_newray_cards
%
% Resolve 'card1', 'card2',... 'card15' just read by read_newray_infile
% into the 75 newray variables.  No input/output arguments are used since 
% this script must operate in your current workspace.  As such this script 
% is provided mostly for convenience.  Note that cards 3, 12 and 15 are
% input termination cards and are not parsed. See read_newray_infile.
%
% To see what this does, give the command: type parse_newray_cards

cfg.INTERA = card1(1); 
cfg.NUMRES = card1(2); 
cfg.NSUPPR = card1(3); 
cfg.SPELAT = card1(4);

cfg.DISTRE = card2(:,1); 
cfg.SATLAT = card2(:,2);

cfg.NUM = card4(1);
cfg.KSKIP = card4(2); 
cfg.MODE = card4(3); 
cfg.KOUNT = card4(4);
cfg.KDUCTS = card4(5);
cfg.KTAPE = card4(6);
cfg.REFALT = card4(7);
cfg.DSRRNG = card4(8); 
cfg.DSRLAT = card4(9); 
cfg.DSDENS = card4(10);

cfg.EGFEQ = card5(1); 
cfg.THERM = card5(2); 
cfg.HM = card5(3); 
cfg.ABSB = card5(4); 
cfg.RELB = card5(5);

cfg.RBASE = card6(1); 
cfg.ANE0 = card6(2); 
cfg.ALPHA2 = card6(3); 
cfg.ALPHA3 = card6(4); 
cfg.ALPHA4 = card6(5);

cfg.RZERO = card7(1); 
cfg.SCBOT = card7(2); 
cfg.RSTOP = card7(3); 
cfg.RDIV = card7(4); 
cfg.HMIN = card7(5);

cfg.LK = card8(1); 
cfg.EXPK = card8(2); 
cfg.DDK = card8(3); 
cfg.RCONSN = card8(4); 
cfg.SCR = card8(5);

if cfg.KDUCTS > 1,
  cfg.L0 = card9(:,1); 
  cfg.DEF = card9(:,2); 
  cfg.DD = card9(:,3); 
  cfg.SIDEDU = card9(:,12);
  cfg.RDUCLN = card9(:,4); 
  cfg.HDUCLN = card9(:,5); 
  cfg.RDUCUN = card9(:,6); 
  cfg.HDUCUN = card9(:,7);
  cfg.RDUCLS = card9(:,8);
  cfg.HDUCLS = card9(:,9); 
  cfg.RDUCUS = card9(:,10); 
  cfg.HDUCUS = card9(:,11);
else,
  cfg.L0 = []; 
  cfg.DEF = []; 
  cfg.DD = []; 
  cfg.SIDEDU = [];
  cfg.RDUCLN = []; 
  cfg.HDUCLN = []; 
  cfg.RDUCUN = []; 
  cfg.HDUCUN = [];
  cfg.RDUCLS = [];
  cfg.HDUCLS = []; 
  cfg.RDUCUS = []; 
  cfg.HDUCUS = [];
end;

cfg.PSTALT = card10(1); 
cfg.PALT1 = card10(2); 
cfg.PALT2 = card10(3); 
cfg.PLATIT = card10(4);
cfg.PSTLAT = card10(5);
cfg.PLAT1 = card10(6);
cfg.PLAT2 = card10(7);
cfg.PALTIT = card10(8);

cfg.FKC = card11(:,1); 
cfg.X01 = card11(:,2); 
cfg.LATITU = card11(:,3);
cfg.DELT = card11(:,4);
cfg.PSI = card11(:,5); 
cfg.TINITI = card11(:,6); 
cfg.X05 = card11(:,7); 
cfg.TGFINA = card11(:,8); 

cfg.TITLE = card13;

cfg.KPLOT = card14(1); 
cfg.XSCALE = card14(2);
cfg.YSCALE = card14(3);
cfg.FLBOT = card14(4);
cfg.FLTOP = card14(5);
cfg.LP1 = card14(6);
cfg.LP2 = card14(7);
cfg.LP3 = card14(8);
cfg.LP4 = card14(9);
cfg.LP5 = card14(10);


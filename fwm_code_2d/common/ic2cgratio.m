function Z=ic2cgratio(latitude)
% Z=ic2cgratio(latitude) Ratio of IC to CG flashes
% 
% Prentice, S. A., and D. Mackerras, The ratio of cloud to cloud-to-ground
% lightning flashes in thunderstorms, J. Appl. Meteorol., 16, 545, 1977.

Z=4.16+2.16*cos(3*latitude);

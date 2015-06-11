function [R,Ro,alpha] = shue_mpause( Bz, Dp, theta )

% [R,Ro,alpha] = shue_mpause( Bz, Dp, theta )
%
% Caluclate a model magnetopause based on solar wind conditions.
%
% Bz is IMF in nT, Dp is solar wind dynamic pressure in nPa, theta (rad)
% is angle with respect to the the Sun-Earth line (like latitude), where
% theta = 0 is towards the Sun.
% 
% Returns R, the magnetopause profile, and the Shue parameters Ro, alpha.
% Ro will be the m-pause standoff at the subsolar point; alpha specifies
% the leval of tail flaring. The result is calcualted from
%
%                     2         ^alpha
%    R = Ro * ( -------------- )
%               1 + cos(theta)
%
% A fairly standard profile is R = shue_model( 0, 2, [-90:90]*pi/180 );
% One can plot the profile with
%
%    plot( R.*cos(theta), R.*sin(theta) ).
%
% Formular derived by Shue '97 from emperical fit to data. 
% See
% http://www-spof.gsfc.nasa.gov/istp/cloud_jan97/theory/shue_model.ps
% and
% http://www-spof.gsfc.nasa.gov/istp/cloud_jan97/theory/shue_preprint.ps

if Bz < 0,
  Ro = (11.4 + 0.140*Bz) * (Dp^(-1/6.6));
else,
  Ro = (11.4 + 0.013*Bz) * (Dp^(-1/6.6));
end;

alpha = (0.58 - 0.010*Bz) * (1 + 0.010*Dp);

R = Ro*(2 ./ (1 + cos(theta))).^alpha;



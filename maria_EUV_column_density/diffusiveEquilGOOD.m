function [n] = diffusiveEquil( L, lamda, neq )

%%%
% CONSTANTS
%%%


% REFERENCE HEIGHT 1000km
h = 1000e3;

% MASS OF EARTH, kg
M = 5.979e24;

% GRAVITATIONAL CONSTANT
G = 6.672e-11;

% RADIUS OF EARTH, m
Ro = 6378e3;

% TEMPERATURE OF PLASMA, Kelvin
Tp = 1600;
kb = 1.38e-23;

% MASS OF PROTON, kg
m_h = 1.673e-27;

% ANGULAR SPEED OF EARTH'S ROTATION
omega = 7.27e-5;

% FRACTION OF PROTONS
c_h = 1.0;


%%%
% VALUES AT h
%%%

% gravity
g1 = M * G ./ (Ro + h)^2;
R1 = Ro + h;
lamda1 = acos(sqrt( R1 / (L*Ro ) ) );


%% CALCULATE
R = L*Ro .* cos(lamda).^2;

H_h = kb*Tp / ( m_h * g1 );

z_eq = R1 - R1^2 / (L*Ro) ...
	- omega^2/(2*g1) * ((L*Ro)^2 - R1^2*cos(lamda1)^2 );

z = R1 - R1^2 ./ R ...
	- omega^2/(2*g1) .* (R.^2.*cos(lamda).^2 - R1^2*cos(lamda1)^2 );

n = neq .* sqrt( (c_h .* exp( -z ./ H_h )) ./ ( c_h .* exp( -z_eq ./ H_h ) ) );


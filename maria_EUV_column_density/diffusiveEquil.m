function [n] = diffusiveEquil( L, lamda, neq, concentration )

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
%Tp = 1600;
Tp = 5800;
%Tp = 11600;
%Tp = 3200;
kb = 1.38e-23;

% MASS OF PROTON, kg
m_h = 1.673e-27;
m_he = 4*m_h;
m_ox = 16*m_h;

% ANGULAR SPEED OF EARTH'S ROTATION
omega = 7.27e-5;

% FRACTION OF PROTONS
if( concentration )
	c_h = 0.90;
	c_he = 0.08;
	c_ox = 0.02;

else
	c_h = 0.50;
	c_he = 0.40;
	c_ox = 0.10;
end;



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
H_he = kb*Tp / ( m_he * g1 );
H_ox = kb*Tp / ( m_ox * g1 );

z_eq = R1 - R1^2 / (L*Ro) ...
	- omega^2/(2*g1) * ((L*Ro)^2 - R1^2*cos(lamda1)^2 );

z = R1 - R1^2 ./ R ...
	- omega^2/(2*g1) .* (R.^2.*cos(lamda).^2 - R1^2*cos(lamda1)^2 );

n = neq .* sqrt ( ...
	(c_h .* exp(- z ./ H_h ))./(c_h .* exp( -z_eq ./ H_h) ) + ...
	(c_he .* exp(- z ./ H_he ))./(c_he .* exp( -z_eq ./ H_he) ) + ...
	(c_ox .* exp(- z ./ H_ox ))./(c_ox .* exp( -z_eq ./ H_ox) ) );


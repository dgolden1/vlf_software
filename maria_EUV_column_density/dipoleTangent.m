function [a_t, b_t] = dipoleTangent( L, lamda );

% TANGENT TO DIPOLE FIELD LINE
% y = a_t * x + b_t

clam = cos( lamda );
slam = sin( lamda );

A = (3*clam.^2 - 2) ./ sqrt(3*slam.^2+1) ;
B = (3*slam.*clam) ./ sqrt(3*slam.^2+1) ;

% SLOPE OF THE NORMAL
a_n = B / A;

% SLOPE OF THE TANGENT
a_t = tan( atan( a_n ) - pi/2 );

ro = L * cos( lamda )^2;
xo = ro * cos(lamda);
yo = ro * sin(lamda);

% Y INTERCEPT OF NORMAL
b_n = yo - a_n * xo;

% Y INTERCEPT OF TANGENT
b_t = yo - a_t * xo;



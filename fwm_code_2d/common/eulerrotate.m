function a=eulerrotate(alfa,beta,gamma)
% Passive rotation matrix for euler angles alfa, beta, gamma.
% See Arfken.
a=[cos(gamma) sin(gamma) 0; -sin(gamma) cos(gamma) 0; 0 0 1]*...
	[cos(beta) 0 -sin(beta); 0 1 0; sin(beta) 0 cos(beta)]*...
	[cos(alfa) sin(alfa) 0; -sin(alfa) cos(alfa) 0; 0 0 1];

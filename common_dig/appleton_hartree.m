function varargout = appleton_hartree(f, Ne, B, nu, theta, b_verbose)
% [n_neg, n_pos, vp_neg, vp_pos, vg_neg, vg_pos, X, Y] = appleton_hartree(f, Ne, B, nu, theta, b_verbose)
% 
% Calculate value of refractive index in plasma via the Appleton-Hartree equation
% 
% INPUTS
% f in Hz
% Ne in electrons per m^3
% B in Teslas
% nu in collisions/sec
% theta in radians
% b_verbose: set to true to print stuff out
% 
% See Robert A. Helliwell's "Whistlers and Related Ionospheric Phenomena" pp 23-4
% 
% By Daniel Golden (dgolden1 at stanford dot edu)

% $Id$

if ~exist('B', 'var'), B = 0; end;
if ~exist('nu', 'var'), nu = 0; end;
if ~exist('theta', 'var'), theta = 0; end;
if ~exist('b_verbose', 'var'), b_verbose = false; end;

%% Constants
global epsilon0 mu0 c q me
if isempty(epsilon0) || isempty(mu0) || isempty(c) || isempty(q) || isempty(me)
	epsilon0 = 8.8541878176e-12; % F/m
	mu0 = 4*pi*1e-7;  % H/m
	c = 1/sqrt(epsilon0*mu0);
	q = 1.60217653e-19; % Electron charge, coulombs
	me = 9.1093826e-31; % Electron mass, kg
end

%% A gazillion variables
fh = (1/(2*pi)) * B*q/me;
f0 = (1/(2*pi)) * sqrt(Ne*q^2/(epsilon0*me));

fl = fh*cos(theta);
ft = fh*sin(theta);

Yt = ft/f;
X = (f0/f)^2;
Y = fh/f;
Yl = fl/f;
Z = nu/(2*pi*f);

if b_verbose
	disp(sprintf('fh = %0.2e Hz', fh));
	disp(sprintf('f0 = %0.2e Hz', f0));
	disp(sprintf('X = %0.2e', X));
	disp(sprintf('Y = %0.2e', Y));
end

%% Calculate phase refractive index
den_LHS = 1 - j*Z - 0.5*Yt^2/(1 - X - j*Z);
den_RHS = (1/(1 - X - j*Z)) * (0.25*Yt^4 + Yl^2*(1 - X - j*Z)^2)^(1/2);

% Note Helliwell switches the sign at some point in the derivation
n_squared_neg = 1 - X / (den_LHS + den_RHS);
n_squared_pos = 1 - X / (den_LHS - den_RHS);

n_pos = sqrt(n_squared_pos);
n_neg = sqrt(n_squared_neg);


%% Calculate phase velocity
vp_neg = c/n_neg;
vp_pos = c/n_pos;

%% Calculate group velocity
if nargout >= 4
	% See Helliwell's book, p30, (3.14)
	% n' = d/df(n*f)
	% Use n_neg as n
	
	f_low = (1 - 0.001)*f;
	f_high = (1 + 0.001)*f;
	[n_neg_low, n_pos_low] = appleton_hartree(f_low, Ne, B, nu, theta);
	[n_neg_high, n_pos_high] = appleton_hartree(f_high, Ne, B, nu, theta);
	n_neg_g = (n_neg_high*f_high - n_neg_low*f_low)/(f_high - f_low);
	n_pos_g = (n_pos_high*f_high - n_pos_low*f_low)/(f_high - f_low);
	vg_neg = c/n_neg_g;
	vg_pos = c/n_pos_g;

% 	vg = 2*c*sqrt(f)*(fh*cos(theta) - f)^(3/2)/(f0*fh*cos(theta));
end

%% Assign output arguments
varargout{1} = n_neg;
if nargout >= 2, varargout{2} = n_pos; end
if nargout >= 3, varargout{3} = vp_neg; end
if nargout >= 4, varargout{4} = vp_pos; end
if nargout >= 5, varargout{5} = vg_neg; end
if nargout >= 6, varargout{6} = vg_pos; end
if nargout >= 7, varargout{7} = X; end
if nargout >= 8, varargout{8} = Y; end

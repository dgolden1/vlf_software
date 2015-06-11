function varargout = get_plasma_speeds(Ne, B0, b_log_f)
% [f, n_neg, n_pos, vp_neg, vp_pos, vg_neg, vg_pos, X, Y] = 
%   get_plasma_speeds(Ne, B0, b_log_f)
% Function that returns parameters, spread across frequency, for a given magnetoplasma
% configuration
% 
% By Daniel Golden (dgolden1 at stanford dot edu) May 27 2007

% $Id$

%% Setup
if ~exist('b_log_f', 'var'), b_log_f = true; end;


%% Calculations

numpts = 1000;

if b_log_f
	f = logspace(0, 6, numpts);
else
	f = linspace(1, 1e6, numpts);
end

n_neg = zeros(1, numpts);
n_pos = zeros(1, numpts);
vp_neg = zeros(1, numpts);
vp_pos = zeros(1, numpts);
vg_neg = zeros(1, numpts);
vg_pos = zeros(1, numpts);
X = zeros(1, numpts);
Y = zeros(1, numpts);

for kk = 1:numpts
	[n_neg(kk), n_pos(kk), vp_neg(kk), vp_pos(kk), vg_neg(kk), vg_pos(kk), X(kk), Y(kk)] = ...
		appleton_hartree(f(kk), Ne, B0);
end

varargout{1} = f;
varargout{2} = n_neg;
varargout{3} = n_pos;
if nargout >= 4, varargout{4} = vp_neg; end
if nargout >= 5, varargout{5} = vp_pos; end
if nargout >= 6, varargout{6} = vg_neg; end
if nargout >= 7, varargout{7} = vg_pos; end
if nargout >= 8, varargout{8} = X; end
if nargout >= 9, varargout{9} = Y; end

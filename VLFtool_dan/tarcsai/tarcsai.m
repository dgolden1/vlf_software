function out = tarcsai(t_vec,f_vec,model,Dci,x0)
% TARCSAI  Equivalent to the original Tarcsai program in FORTRAN
%   Usage:  tarcsai(t_vec,f_vec,model,Dci,x0)
%           tarcsai(t_vec,f_vec,model,Dci)      % Use default x0=[60 100000 0]
%           tarcsai(t_vec,f_vec,model)          % and use default Dci=6
%           tarcsai(t_vec,f_vec)                % and use default density model DE-1
%    Input: t_vec: (vector) t along whistler trace (in sec)
%           f_vec: (vector) f along whistler trace (in kHz)
%           model: (text string) density model to be used in the function "calcK"
%               (see calcK.m for details)
%           Dci: dispersion contributed from ionospheric propagation
%               (see Park [1972])
%           x0: initial guess of [D0 fHeq T], where
%               D0 is the zero disperson
%               fHeq is the equatorial electron gyrofrequency (in Hz, not kHz)
%               T is the sferic time (in sec)

% Modified by Daniel Golden (dgolden1 at stanford dot edu)
% $Id:tarcsai.m 522 2007-09-24 21:29:08Z dgolden $

%EXTRA CODE
%BEGIN
global model_list
%END
%ORIGINAL CODE
%BEGIN
if (nargin < 5), x0 = [60 100000 0].'; end
%END

%if (nargin < 5), x0 = [60 40000 0];, end

if (nargin < 4), Dci = 6; end
%ORIGINAL CODE
%BEGIN
if (nargin < 3), model = 'DE-1'; end
%END
%if (nargin < 3), model = model_list{get(findobj('Tag','tarcsai_modellist'),'Value')};, end

% ORIGINAL CODE
%BEGIN
%disp(['Density model: ',model])
%disp(['Dci = ', num2str(Dci)])
%disp(['Initial values of [D0 fHeq T] = [',num2str(x0),']'])
%x_fit = fmins('fun_tarcsai',x0,[],[],t_vec,f_vec,model,Dci);
%se_tarcsai(t_vec,f_vec,x_fit,model,Dci)
%END

disp(['Density model: ',model])
disp(['Dci = ', num2str(Dci)])
disp(['Initial values of [D0 fHeq T] = [',num2str(x0.'),']'])


% Plot information about the minization procedure while it's running
bDebugPlots = false;

% If true, use a constrained optimization procedure (fmincon or similar)
% instead of an unconstrained one (fminsearch). This should solve issues of
% the causitive sferic occasionally being found to occur after the
% whistler, and may also solve some convergence issues.
% This approach requires that the Matlab Optimization Toolbox is installed.
% Tested on Matlab 2007a.
% Note that I've been unable to this to converge as of Sept 2007.
% --DIG
bAdvancedOptimization = false;

% True to disable output from the minimization function (since we display
% it anyway if it doesn't converge)
bHushOutput = true;

% Set options for all algorithms
opt = optimset;
if bDebugPlots
	opt = optimset(opt, 'PlotFcns', @optimplotfval);
end
if bHushOutput
	opt = optimset(opt, 'Display', 'off');
end

if bAdvancedOptimization && exist('fmincon', 'file')
% 	lb = [20; 1e3; -5];
% 	ub = [120; 2e5; min(t_vec)];
% % 	opt=optimset('MaxFunEvals',100000,'MaxIter',10000,'TolFun',1e-20,'TolX',1e-10,'Jacobian','off','Display','iter');
% % 	opt = optimset('MaxFunEvals', 10000, 'MaxIter', 1000, 'Display', 'iter');
% 	if bDebugPlots
% 		opt = optimset(opt, 'PlotFcns', @optimplotfval);
% 	end
% 	disp(sprintf('Minimizing with lsqnonlin()'));
% 	[x_fit, resnorm, residual, exitflag, output] = lsqnonlin(@(x) fun_tarcsai(x,t_vec,f_vec,model,Dci), ...
% 		x0, lb, ub, opt); % medium-scale: Levenberg-Marquardt, line-search

% 	opt = optimset(opt, 'LargeScale', 'off', 'MaxFunEvals',10000,'MaxIter',10000,'TolFun',1e-20,'TolX',1e-10);
	opt = optimset(opt, 'LargeScale', 'off');

	% Constrain the sferic time to be less than the first point on the
	% whistler trace, and constrain D0 and fHeq to be positive
	A = [-1 0 0; 0 -1 0; 0 0 1];
	b = [0; 0; min(t_vec)];
	Aeq = [];
	beq = [];
	lb = [];
	ub = [];
	nonlcon = [];
	disp(sprintf('Minimizing with fmincon()'));
	[x_fit, fval, exitflag, output] = fmincon(@(x) fun_tarcsai(x,t_vec,f_vec,model,Dci), ...
		x0, A, b, Aeq, beq, lb, ub, nonlcon, opt); % medium-scale: SQP, Quasi-Newton, line-search
% 	disp(sprintf('Minimizing with fminunc()'));
% 	[x_fit, fval, exitflag, output] = fminunc(@(x) fun_tarcsai(x,t_vec,f_vec,model,Dci), x0, opt); % medium-scale: Quasi-Newton line search
else
	opt = optimset(opt, 'MaxFunEvals', 10000);
	disp(sprintf('Minimizing with fminsearch'));
	[x_fit, fval, exitflag, output] = fminsearch(@(x) fun_tarcsai(x,t_vec,f_vec,model,Dci), x0, opt); % Nelder-Mead simplex direct search
end


if exitflag ~= 1
   error('tarcsai:ConvergenceFailed', ['Failed to converge on Tarcsai algorithm\n' output.message]);
end

%x_fit = fminsearchbnd('fun_tarcsai',x0, [-inf -inf -inf], [+inf +inf +inf], [], t_vec, f_vec, model, Dci);
%x_fit = fmincon('fun_tarcsai',x0,[1 0 0; 0 1 0 ; 0 0 1],[+inf; +inf; +inf],[],[],[0 0 0],[+inf +inf +inf], [],[],t_vec,f_vec,model,Dci);
out = se_tarcsai(t_vec,f_vec,x_fit,model,Dci);

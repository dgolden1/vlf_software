function [w, A, sbc,fpe]=arfit(v, pmin, pmax, selector, no_const)
%Least squares estimation of multivariate AutoRegressive model.
%
%  [w,A,SBC,FPE]=ARFIT(v,pmin,pmax) produces estimates of the
%  parameters of a multivariate AR model of order p,
%
%      v(k,:)' = w' + A1*v(k-1,:)' +...+ Ap*v(k-p,:)' + noise(C),
%
%  where p lies between pmin and pmax and is chosen as the optimizer
%  of Schwarz's Bayesian Criterion. The input matrix v must contain
%  the time series data, with columns of v representing variables
%  and rows of v representing observations.  ARFIT returns least
%  squares estimates of the intercept vector w, of the coefficient
%  matrices A1,...,Ap (as A=[A1 ... Ap]).
%
%  As order selection criteria, ARFIT computes approximations to
%  Schwarz's Bayesian Criterion and to the logarithm of Akaike's Final
%  Prediction Error. The order selection criteria for models of order
%  pmin:pmax are returned as the vectors SBC and FPE.
%
%  If the optional argument SELECTOR is included in the function call,
%  as in ARFIT(v,pmin,pmax,SELECTOR), SELECTOR is used as the order
%  selection criterion in determining the optimum model order. The
%  three letter string SELECTOR must have one of the two values 'sbc'
%  or 'fpe'. (By default, Schwarz's criterion SBC is used.) If the
%  bounds pmin and pmax coincide, the order of the estimated model
%  is p=pmin=pmax. 
%
%  If the function call contains the optional argument 'zero' as the
%  fourth or fifth argument, a model of the form
%
%         v(k,:)' = A1*v(k-1,:)' +...+ Ap*v(k-p,:)' + noise(C) 
%
%  is fitted to the time series data. That is, the intercept vector w
%  is taken to be zero, which amounts to assuming that the AR(p)
%  process has zero mean.

  % n: number of observations; m: dimension of state vectors
  [n,m]   = size(v);     

  if (pmin ~= round(pmin) | pmax ~= round(pmax))
    error('Order must be integer.');
  end
  if (pmax < pmin)
    error('PMAX must be greater than or equal to PMIN.')
  end

  % set defaults and check for optional arguments
  if (nargin == 3)              % no optional arguments => set default values
    mcor       = 1;               % fit intercept vector
    selector   = 'sbc';            % use SBC as order selection criterion
  elseif (nargin == 4)          % one optional argument
    if strcmp(selector, 'zero')
      mcor     = 0;               % no intercept vector to be fitted
      selector = 'sbc';            % default order selection 
    else
      mcor     = 1;       % fit intercept vector
    end
  elseif (nargin == 5)          % two optional arguments
    if strcmp(no_const, 'zero')
      mcor     = 0;               % no intercept vector to be fitted
    else
      error(['Bad argument. Usage: ', ...
       '[w,A,C,SBC,FPE,th]=AR(v,pmin,pmax,SELECTOR,''zero'')'])
    end
  end

  ne    = n-pmax;               % number of block equations of size m
  npmax  = m*pmax+mcor;          % maximum number of parameter vectors of length m

  if (ne <= npmax)
    error('Arfit:ShortTimeSeries', 'Time series too short.')
  end

  % compute QR factorization for model of order pmax
  [R, scale]   = arqr(v, pmax, mcor);

  % compute approximate order selection criteria for models 
  % of order pmin:pmax
  [sbc, fpe]   = arord(R, m, mcor, ne, pmin, pmax);

  % get index iopt of order that minimizes the order selection 
  % criterion specified by the variable selector
  [val, iopt]  = min(eval(selector)); 

  % select order of model
  popt         = pmin + iopt-1; % estimated optimum order 
  np           = m*popt + mcor; % number of parameter vectors of length m

  % decompose R for the optimal model order popt according to 
  %
  %   | R11  R12 |
  % R=|          |
  %   | 0    R22 |
  %
  R11   = R(1:np, 1:np);
  R12   = R(1:np, npmax+1:npmax+m);    
  R22   = R(np+1:npmax+m, npmax+1:npmax+m);

  % get augmented parameter matrix Aaug=[w A] if mcor=1 and Aaug=A if mcor=0
  if (np > 0)   
    if (mcor == 1)
      % improve condition of R11 by re-scaling first column
      con   = max(scale(2:npmax+m)) / scale(1); 
      R11(:,1)  = R11(:,1)*con; 
    end;
    Aaug = (R11\R12)';
    
    %  return coefficient matrix A and intercept vector w separately
    if (mcor == 1)
      % intercept vector w is first column of Aaug, rest of Aaug is 
      % coefficient matrix A
      w = Aaug(:,1)*con;        % undo condition-improving scaling
      A = Aaug(:,2:np);
    else
      % return an intercept vector of zeros 
      w = zeros(m,1);
      A = Aaug;
    end
  else
    % no parameters have been estimated 
    % => return only covariance matrix estimate and order selection 
    % criteria for ``zeroth order model''  
    w   = zeros(m,1);
    A   = [];
  end
  




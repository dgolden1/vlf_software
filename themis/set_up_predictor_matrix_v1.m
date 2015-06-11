function [X, X_names] = set_up_predictor_matrix_v1(target_epoch, varargin)
% Set up a predictor matrix of solar wind and THEMIS ephemeris
% 
% PARAMETERS
% num_min: number of minutes between solar wind data samples (default: 1)
% n_hours_history: vector of hours of history for each predictor (default:
%  0:6)
% them_combined: THEMIS data, for ephemeris parameters

% By Daniel Golden (dgolden1 at stanford dot edu) October 2011
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('num_min', 1);
p.addParamValue('n_hours_history', 0:6);
p.addParamValue('them_combined', []);
p.parse(varargin{:});
num_min = p.Results.num_min;
n_hours_history = p.Results.n_hours_history;
them_combined = p.Results.them_combined;

%% Setup
qd = load(fullfile(vlfcasestudyroot, 'indices', sprintf('QinDenton_%02dmin_pol_them.mat', num_min)));
% Time in this file has been shifted so that the epoch is the end of the
% averaging interval

qd.AE(qd.AE == 0) = nan; % This happens rarely, for some reason

% Solar wind coupling function from [Newell et al., 2007,
% doi:10.1029/2006JA012015]
qd.Bt = sqrt(qd.ByIMF.^2 + qd.BzIMF.^2); % Transverse B
qd.theta_c = atan2(qd.ByIMF, qd.BzIMF); % IMF clock angle
qd.dphi_mp_dt = qd.V_SW.^(4/3).*qd.Bt.^(2/3).*abs(sin(qd.theta_c/2).^(8/3));
qd.p12_dphi_mp_dt = sqrt(qd.Pdyn).*qd.dphi_mp_dt; % This function correlates best with Dst

% Other solar wind coupling functions
qd.Ewv = abs(qd.V_SW.^(4/3).*qd.Bt.*sin(qd.theta_c/2).^4.*qd.Pdyn.^(1/6)); % [Vasyliunas et al, 1982]
qd.Ewav = abs(qd.V_SW.*qd.Bt.*sin(qd.theta_c/2).^4); % [Wygant et al, 1983]
qd.vBs = qd.V_SW.*max(0, qd.BzIMF); % [Burton et al, 1975]

symh = load(fullfile(vlfcasestudyroot, 'indices', 'asy_sym.mat'), 'epoch', 'symh');

%% Solar wind predictors
X = zeros(length(target_epoch), 0);
X_names = {};

% We intentionally interpolate across vectors containing NaNs (particularly
% the TS05 vectors) since we want the output values to be NaN where the
% interpolation isn't valid.  glmfit() deals with this automatically.
warning('off', 'MATLAB:interp1:NaNinY');

% 0-N hour history of parameters
for kk = 1:length(n_hours_history)
  this_n_hours_history = n_hours_history(kk);
  if this_n_hours_history == 0
    this_time_range = [0 0];
  else
    this_time_range = [-this_n_hours_history -(this_n_hours_history - 1)]/24;
  end
  
  X(:, end+1) = avg_var_history(qd.epoch, log10(qd.AE), target_epoch, this_time_range);
  X_names{end+1} = sprintf('log10(AE) (t-%dhrs)', this_n_hours_history);

%   X(:, end+1) = avg_var_history(qd.epoch, qd.Dst, target_epoch, this_time_range);
%   X_names{end+1} = sprintf('Dst (t-%dhrs)', this_n_hours_history);

  % SYM-H replaces Dst
  X(:, end+1) = avg_var_history(symh.epoch, symh.symh, target_epoch, this_time_range);
  X_names{end+1} = sprintf('SYM-H (t-%dhrs)', this_n_hours_history);

  X(:, end+1) = avg_var_history(qd.epoch, log10(qd.Pdyn), target_epoch, this_time_range);
  X_names{end+1} = sprintf('log10(Pdyn) (t-%dhrs)', this_n_hours_history);

%   X(:, end+1) = max(0, avg_var_history(qd.epoch, qd.BzIMF, target_epoch, this_time_range));
%   X_names{end+1} = sprintf('Bs (t-%dhrs)', this_n_hours_history);

  X(:, end+1) = avg_var_history(qd.epoch, qd.dphi_mp_dt, target_epoch, this_time_range);
  X_names{end+1} = sprintf('dphi_mp_dt (t-%dhrs)', this_n_hours_history);

%   X(:, end+1) = avg_var_history(qd.epoch, log10(qd.dphi_mp_dt + 1), target_epoch, this_time_range);
%   X_names{end+1} = sprintf('log10(dphi_mp_dt + 1) (t-%dhrs)', this_n_hours_history);

  X(:, end+1) = avg_var_history(qd.epoch, qd.p12_dphi_mp_dt, target_epoch, this_time_range);
  X_names{end+1} = sprintf('p^(1/2)*dphi_mp_dt (t-%dhrs)', this_n_hours_history);

%   X(:, end+1) = avg_var_history(qd.epoch, log10(qd.p12_dphi_mp_dt + 1), target_epoch, this_time_range);
%   X_names{end+1} = sprintf('log10(p^(1/2)*dphi_mp_dt + 1) (t-%dhrs)', this_n_hours_history);

%   X(:, end+1) = avg_var_history(qd.epoch, qd.Ewv, target_epoch, this_time_range);
%   X_names{end+1} = sprintf('Ewv (t-%dhrs)', this_n_hours_history);

%   X(:, end+1) = avg_var_history(qd.epoch, log10(qd.Ewv + 1), target_epoch, this_time_range);
%   X_names{end+1} = sprintf('log10(Ewv + 1) (t-%dhrs)', this_n_hours_history);

%   X(:, end+1) = avg_var_history(qd.epoch, qd.Ewav, target_epoch, this_time_range);
%   X_names{end+1} = sprintf('Ewav (t-%dhrs)', this_n_hours_history);

%   X(:, end+1) = avg_var_history(qd.epoch, log10(qd.Ewav + 1), target_epoch, this_time_range);
%   X_names{end+1} = sprintf('log10(Ewav + 1) (t-%dhrs)', this_n_hours_history);
end

warning('on', 'MATLAB:interp1:NaNinY');

%% Ephemeris predictors
if ~isempty(them_combined)
  X(:,end+1) = abs(log(them_combined.L - 1) - log(4 - 1));
  X_names{end+1} = 'abs(log(them_combined.L - 1) - log(4 - 1))';

  X(:,end+1) = sin(them_combined.MLT/24*2*pi);
  X_names{end+1} = 'sin(them_combined.MLT/24*2*pi)';

  X(:,end+1) = cos(them_combined.MLT/24*2*pi);
  X_names{end+1} = 'cos(them_combined.MLT/24*2*pi)';

  X(:,end+1) = cos(them_combined.lat*pi/180);
  X_names{end+1} = 'cos(them_combined.lat*pi/180)';
end

%% Check that I put in the X names correctly
if length(X_names) ~= size(X, 2)
  error('Number of X names does not match number of X columns');
end

1;

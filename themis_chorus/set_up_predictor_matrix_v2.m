function [X_sorted, X_names_sorted] = set_up_predictor_matrix_v2(epoch, varargin)
% Set up a predictor matrix of solar wind and (optionally) ephemeris
% Used logarithmically spaced # hours history
% 
% [X_sorted, X_names_sorted] = set_up_predictor_matrix_v2(epoch, varargin)
% 
% PARAMETERS
% num_min: number of minutes between solar wind data samples (default: 1)
% n_hours_history: vector of hours of history for each predictor (default:
%  0:6)
% fake_data: fake data; struct with the following fields: 'epoch', 'symh', 'AE',
%  'Pdyn', 'v_sw', 'ByIMF', 'BzIMF'
% xyz_sm: XYZ data in SM coordinates, for ephemeris parameters
% b_ae_kp_only: if true, use only current value of Kp and AE*

% By Daniel Golden (dgolden1 at stanford dot edu) October 2011
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'themis')); % for avg_var_history

%% Parse input arguments
p = inputParser;
p.addParamValue('num_min', 1);
p.addParamValue('n_hours_history', roundto([0 2.^(-2:4)], 1/60));
% p.addParamValue('n_hours_history', 0:6);
p.addParamValue('fake_data', []);
p.addParamValue('xyz_sm', []);
p.addParamValue('b_ae_kp_only', false)
p.parse(varargin{:});
num_min = p.Results.num_min;
n_hours_history = p.Results.n_hours_history;
fake_data = p.Results.fake_data;
xyz_sm = p.Results.xyz_sm;
b_ae_kp_only = p.Results.b_ae_kp_only;

%% Load from history
persistent pers_X_sorted pers_X_names_sorted pers_num_min pers_n_hours_history pers_xyz_sm pers_epoch pers_ae_kp_only
if ~isempty(pers_X_sorted) && pers_num_min == num_min && ...
    isequal(pers_n_hours_history, n_hours_history) && ...
    isequal(pers_xyz_sm, xyz_sm) && ...
    isequal(pers_epoch, epoch) && ...
    pers_ae_kp_only == b_ae_kp_only && ...
    isempty(fake_data)

  X_sorted = pers_X_sorted;
  X_names_sorted = pers_X_names_sorted;
  return;
else
  pers_num_min = num_min;
  pers_n_hours_history = n_hours_history;
  pers_xyz_sm = xyz_sm;
  pers_epoch = epoch;
  pers_ae_kp_only = b_ae_kp_only;
end

%% Load data
if isempty(fake_data)
  % SYM-H
  symh = load(fullfile(vlfcasestudyroot, 'indices', 'asy_sym.mat'), 'epoch', 'symh');

  qd = load(fullfile(vlfcasestudyroot, 'indices', sprintf('QinDenton_%02dmin_pol_them.mat', num_min)));
  % Time in this file has been shifted so that the epoch is the end of the
  % averaging interval
else
  symh.symh = fake_data.symh;
  symh.epoch = fake_data.epoch;
  qd.epoch = fake_data.epoch;
  qd.AE = fake_data.AE;
  qd.ByIMF = fake_data.ByIMF;
  qd.BzIMF = fake_data.BzIMF;
  qd.Pdyn = fake_data.Pdyn;
  qd.V_SW = fake_data.V_SW;
end

qd.AE(qd.AE == 0) = nan; % This happens rarely, for some reason

% Solar wind coupling function from [Newell et al., 2007,
% doi:10.1029/2006JA012015]
[qd.dphi_mp_dt, qd.p12_dphi_mp_dt, qd.Ewv, qd.Ewav, qd.vBs] = get_dphi_mp_dt(qd.V_SW, qd.ByIMF, qd.BzIMF, qd.Pdyn);

%% Solar wind predictors
if b_ae_kp_only
  [X, X_names] = get_ae_kp_predictors(epoch, qd);
else
  [X, X_names] = get_solarwind_predictors(epoch, qd, symh, n_hours_history);
end

%% Ephemeris predictors
if ~isempty(xyz_sm)
  [lat, MLT, L] = xyz_to_lat_mlt_L(xyz_sm);
  
  X(:,end+1) = abs(log(L - 1) - log(8 - 1));
  X_names{end+1} = 'eph: abs(log(L - 1) - log(8 - 1))';

  X(:,end+1) = cos((MLT + 16)/12*pi);
  X_names{end+1} = 'eph: cos((MLT + 16)/12*pi)';

  X(:,end+1) = cos(lat*pi/180);
  X_names{end+1} = 'eph: cos(lat*pi/180)';
end

%% Check that I put in the X names correctly
if length(X_names) ~= size(X, 2)
  error('Number of X names does not match number of X columns');
end

%% Sort
[X_names_sorted, i_sort] = sort(X_names);
X_sorted = X(:, i_sort);

%% Save to history
pers_X_sorted = X_sorted;
pers_X_names_sorted = X_names_sorted;

function [X, X_names] = get_solarwind_predictors(epoch, qd, symh, n_hours_history)
%% Function: Solar wind predictors
X = zeros(length(epoch), 0);
X_names = {};

% We intentionally interpolate across vectors containing NaNs (particularly
% the TS05 vectors) since we want the output values to be NaN where the
% interpolation isn't valid.
s = warning('off', 'MATLAB:interp1:NaNinY');

% 0-N hour history of parameters
for kk = 1:length(n_hours_history)
  if kk == 1
    this_time_range = [-n_hours_history(kk) 0]/24;
  else
    this_time_range = [-n_hours_history(kk), -n_hours_history(kk-1)]/24;
  end
  
  X(:, end+1) = avg_var_history(qd.epoch, log10(qd.AE), epoch, this_time_range);
  X_names{end+1} = sprintf('log10(AE) (t-[%04.1f %04.1f]hrs)', abs(this_time_range([2 1]))*24);

  % SYM-H replaces Dst
  X(:, end+1) = avg_var_history(symh.epoch, symh.symh, epoch, this_time_range);
  X_names{end+1} = sprintf('SYM-H (t-[%04.1f %04.1f]hrs)', abs(this_time_range([2 1]))*24);

%   X(:, end+1) = avg_var_history(qd.epoch, qd.Dst, epoch, this_time_range);
%   X_names{end+1} = sprintf('Dst (t-[%04.1f %04.1f]hrs)', abs(this_time_range([2 1]))*24);

  X(:, end+1) = avg_var_history(qd.epoch, log10(qd.Pdyn), epoch, this_time_range);
  X_names{end+1} = sprintf('log10(Pdyn) (t-[%04.1f %04.1f]hrs)', abs(this_time_range([2 1]))*24);

%   X(:, end+1) = max(0, avg_var_history(qd.epoch, qd.BzIMF, epoch, this_time_range));
%   X_names{end+1} = sprintf('Bs (t-[%04.1f %04.1f]hrs)', abs(this_time_range([2 1]))*24);

  X(:, end+1) = avg_var_history(qd.epoch, qd.dphi_mp_dt, epoch, this_time_range);
  X_names{end+1} = sprintf('dphi_mp_dt (t-[%04.1f %04.1f]hrs)', abs(this_time_range([2 1]))*24);

%   X(:, end+1) = avg_var_history(qd.epoch, log10(qd.dphi_mp_dt + 1), epoch, this_time_range);
%   X_names{end+1} = sprintf('log10(dphi_mp_dt + 1) (t-[%04.1f %04.1f]hrs)', abs(this_time_range([2 1]))*24);

  X(:, end+1) = avg_var_history(qd.epoch, qd.p12_dphi_mp_dt, epoch, this_time_range);
  X_names{end+1} = sprintf('p^(1/2)*dphi_mp_dt (t-[%04.1f %04.1f]hrs)', abs(this_time_range([2 1]))*24);

%   X(:, end+1) = avg_var_history(qd.epoch, log10(qd.p12_dphi_mp_dt + 1), epoch, this_time_range);
%   X_names{end+1} = sprintf('log10(p^(1/2)*dphi_mp_dt + 1) (t-[%04.1f %04.1f]hrs)', abs(this_time_range([2 1]))*24);

%   X(:, end+1) = avg_var_history(qd.epoch, qd.Ewv, epoch, this_time_range);
%   X_names{end+1} = sprintf('Ewv (t-[%04.1f %04.1f]hrs)', abs(this_time_range([2 1]))*24);

%   X(:, end+1) = avg_var_history(qd.epoch, log10(qd.Ewv + 1), epoch, this_time_range);
%   X_names{end+1} = sprintf('log10(Ewv + 1) (t-[%04.1f %04.1f]hrs)', abs(this_time_range([2 1]))*24);

%   X(:, end+1) = avg_var_history(qd.epoch, qd.Ewav, epoch, this_time_range);
%   X_names{end+1} = sprintf('Ewav (t-[%04.1f %04.1f]hrs)', abs(this_time_range([2 1]))*24);

%   X(:, end+1) = avg_var_history(qd.epoch, log10(qd.Ewav + 1), epoch, this_time_range);
%   X_names{end+1} = sprintf('log10(Ewav + 1) (t-[%04.1f %04.1f]hrs)', abs(this_time_range([2 1]))*24);
end

warning(s.state, 'MATLAB:interp1:NaNinY');

function [X, X_names] = get_ae_kp_predictors(epoch, qd)
%% Function: get only AE* and Kp predictors

addpath(fullfile(danmatlabroot, 'vlf', 'themis')); % For get_ae_star_from_ae.m

X = zeros(length(epoch), 0);
X_names = {};

% We intentionally interpolate across vectors containing NaNs (particularly
% the TS05 vectors) since we want the output values to be NaN where the
% interpolation isn't valid.
s = warning('off', 'MATLAB:interp1:NaNinY');

% Instantaneous parameters
X(:, end+1) = interp1(qd.epoch, qd.Kp, epoch);
X_names{end+1} = 'Kp';

[ae_star, ae_star_epoch] = get_ae_star_from_ae(qd.epoch, qd.AE);
X(:, end+1) = interp1(ae_star_epoch, ae_star, epoch);
X_names{end+1} = 'AE*';

warning(s.state, 'MATLAB:interp1:NaNinY');

1;

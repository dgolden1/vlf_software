function varargout = sp_create_neural_network_inputs(b_training, start_datenum, end_datenum)
% Create inputs and targets for neural network
% 
% [nn_inputs, start_datenums, nn_chorus_targets, nn_hiss_targets] = sp_create_neural_network_inputs(b_training, start_datenum, end_datenum)
% 
% if b_training, then inputs and targets are created for the training set
% (manually determined emissions)
% if ~b_training, ONLY INPUTS are created for all dates in the range of the
% database
% 
% To restrict the range of the database, enter the start and end datenums

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Setup
database_filename = '/home/dgolden/vlf/case_studies/southpole_emissions/sp_event_db.mat';

if (~exist('b_training', 'var') || isempty(b_training))
  if nargout < 3
    b_training = false;
  else
    b_training = true;
  end
end

if ~exist('start_datenum', 'var') || isempty(start_datenum)
  start_datenum = 0;
end
if ~exist('end_datenum', 'var') || isempty(end_datenum)
  end_datenum = inf;
end
 

%% Load database
load(database_filename, 'db_chorus', 'db_hiss');

% Pare only database entries in the given date range
db_chorus_keys = cell2mat(db_chorus.keys());
idx_valid = db_chorus_keys >= start_datenum & db_chorus_keys < end_datenum;
remove(db_chorus, num2cell(db_chorus_keys(~idx_valid)));

db_hiss_keys = cell2mat(db_hiss.keys());
idx_valid = db_hiss_keys >= start_datenum & db_hiss_keys < end_datenum;
remove(db_hiss, num2cell(db_hiss_keys(~idx_valid)));


%% Get range of dates for database
db_chorus_dates = unique(floor(cell2mat(db_chorus.keys()))).';
db_hiss_dates = unique(floor(cell2mat(db_hiss.keys()))).';
db_start_date = min([db_chorus_dates; db_hiss_dates]);
db_end_date = max([db_chorus_dates; db_hiss_dates]);


%% Training set (inputs and targets)
if b_training
  db_days = unique(sort([db_chorus_dates; db_hiss_dates]));
  
  nn_inputs = [];
  start_datenums = [];
  nn_chorus_targets = [];
  nn_hiss_targets = [];
  for kk = 1:length(db_days)
    [this_nn_inputs, this_start_datenums, this_nn_chorus_targets, this_nn_hiss_targets] = ...
      get_nn_inputs_by_day(db_days(kk), db_chorus, db_hiss, b_training);
    
    nn_inputs = [nn_inputs, this_nn_inputs];
    start_datenums = [start_datenums, this_start_datenums];
    nn_chorus_targets = [nn_chorus_targets, this_nn_chorus_targets];
    nn_hiss_targets = [nn_hiss_targets, this_nn_hiss_targets];
  end
%% Run set (just inputs)
else
  db_days = db_start_date:db_end_date;
  nn_inputs = [];
  start_datenums = [];
  for kk = 1:length(db_days)
    t_day_start = now;
    
    [this_nn_inputs, this_start_datenums] = get_nn_inputs_by_day(db_days(kk), [], [], b_training);
    nn_inputs = [nn_inputs, this_nn_inputs];
    start_datenums = [start_datenums, this_start_datenums];
    
    fprintf('Got neural network inputs for %s (%d of %d) in %s\n', datestr(db_days(kk), 'yyyy-mm-dd'), kk, length(db_days), time_elapsed(t_day_start, now));
  end
end

varargout{1} = nn_inputs;
varargout{2} = start_datenums;
if nargout > 2
  varargout{3} = nn_chorus_targets;
  varargout{4} = nn_hiss_targets;
end


function varargout = get_nn_inputs_by_day(day_datenum, db_chorus, db_hiss, b_training)
% Outputs: nn_inputs, start_datenums, nn_chorus_targets, nn_hiss_targets

num_mediogram_inputs = 100;
num_other_inputs = 5; % year, day of year (real, imag), time of day (real, imag)
num_inputs = num_mediogram_inputs + num_other_inputs;

% log_spec_dir = '/home/dgolden/vlf/case_studies/southpole_emissions/log_specs';
log_spec_dir = fullfile(scottdataroot, 'user_data', 'dgolden', 'southpole_bb_cleaned', 'southpole_log_specs');

this_dir = fullfile(log_spec_dir, datestr(day_datenum, 'yyyy'), ...
  datestr(day_datenum, 'mm_dd'));

d = dir(fullfile(this_dir, '*.mat'));

nn_inputs = nan(num_inputs, length(d));
start_datenums = nan(1, length(d));
nn_chorus_targets = nan(2, length(d));
nn_hiss_targets = nan(2, length(d));
start_datenums = nan(1, length(d)); % For debugging
for kk = 1:length(d)
  [mediogram_inputs, start_datenums(kk)] = get_nn_inputs_by_file(fullfile(this_dir, d(kk).name));
  if any(~isfinite(mediogram_inputs))
    % Sometimes, if the original BB data is weird, the mediogram is
    % invalid.  Skip this epoch and leave its inputs as nan.
    continue;
  end
  nn_inputs(1:num_mediogram_inputs, kk) = mediogram_inputs;
  
  [yy, mm, dd, HH, MM, SS] = datevec(start_datenums(kk));
  doy = (start_datenums(kk) - datenum([yy 0 0 0 0 0]));
  doy_norm = exp(j*doy/(datenum([yy+1 0 0 0 0 0]) - datenum([yy 0 0 0 0 0]))*2*pi); % How to represent periodic neural network inputs
  tod = fpart(start_datenums(kk));
  tod_norm = exp(j*tod*2*pi); % How to represent periodic neural network inputs
  nn_inputs(num_mediogram_inputs+1:num_inputs, kk) = [start_datenums(kk), real(doy_norm), imag(doy_norm), real(tod_norm), imag(tod_norm)];
  
  
  if b_training
    if db_chorus.isKey(start_datenums(kk))
      nn_chorus_targets(:,kk) = log10(db_chorus(start_datenums(kk)).f_lim.'); % Log frequency
    end
    
    if db_hiss.isKey(start_datenums(kk))
      nn_hiss_targets(:,kk) = log10(db_hiss(start_datenums(kk)).f_lim.'); % Log frequency
    end
  end
end

varargout{1} = nn_inputs;
varargout{2} = start_datenums;
if nargout > 1
  varargout{3} = nn_chorus_targets;
  varargout{4} = nn_hiss_targets;
end

function [nn_inputs_single, start_datenum] = get_nn_inputs_by_file(filename)
load(filename, 'f', 's_mediogram', 'start_datenum');
nn_inputs_single = s_mediogram;

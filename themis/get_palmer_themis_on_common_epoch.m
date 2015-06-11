function [epoch, palmer_em_pow, them] = get_palmer_themis_on_common_epoch(em_type, varargin)
% Get Palmer and THEMIS emission amplitude on common synoptic epochs
% 
% INPUTS
% em_type: either 'chorus' or 'hiss'
% 
% PARAMETERS
% b_use_subsampled_dens: true to use density subsampled to 30-second epochs;
%  otherwise use full-resolution 3-second epochs
% b_exclude_daylight: true to exclude epochs where Palmer is sunlight.
% Default: false

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Process input arguments
p = inputParser;
p.addParamValue('b_use_subsampled_dens', false);
p.addParamValue('b_exclude_daylight', false);
p.parse(varargin{:});
b_use_subsampled_dens = p.Results.b_use_subsampled_dens;
b_exclude_daylight = p.Results.b_exclude_daylight;

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'chorus_hiss_coherence'));
addpath(fullfile(danmatlabroot, 'vlf', 'emission_statistics')); % for data_gaps.mat

persistent events

%% Load Palmer database
if isempty(events)
  load(fullfile(vlfcasestudyroot, 'chorus_hiss_detection', 'databases', 'auto_chorus_hiss_db_em_char_all_reprocessed.mat'), 'events');
end

events = events(strcmp({events.type}, em_type)); % Choose only events of the selected emission type

% % Restrict hiss events to those below 2 kHz
% if strcmp(em_type, 'hiss')
%   events = events([events.f_uc] < 2000);
% end
%% Load THEMIS wave database
min_themis_gap = 10/1440; % Minimum gap between samples to be considered a data gap (days)

% Probes must be treated separately because their data gaps are different
probe = {'A', 'D', 'E'};
for kk = 1:length(probe)
  them(kk).probe = probe{kk};

  [this_them(kk).epoch, this_them(kk).field_power, eph] = get_dfb_by_em_type(probe{kk}, em_type);
  
  % Assign fields of eph struct to this_them
  fn = {'lat', 'MLT', 'L'};
  for jj = 1:length(fn)
    this_them(kk).(fn{jj}) = eph.(fn{jj});
  end
  
  % Note data gaps
  gap_start_idx = find(diff(this_them(kk).epoch) > min_themis_gap);
  gap_end_idx = gap_start_idx + 1;
  them(kk).gap_start_datenum = this_them(kk).epoch(gap_start_idx);
  them(kk).gap_end_datenum = this_them(kk).epoch(gap_end_idx);
end

%% Choose epochs on synoptic epochs while Palmer is in darkness
start_datenum = max([min([events.start_datenum]), min(cell2mat({this_them.epoch}.'))]);
end_datenum = min([max([events.start_datenum]), max(cell2mat({this_them.epoch}.'))]);

% Synoptic epochs spanning when we have data for both data sets
epoch = ((floor(start_datenum) + 5/1440):15/1440:(floor(end_datenum) + 1 - 10/1440)).';

% Determine dawn and dusk times in Palmer MLT and exclude daylit epochs if
% requested
if b_exclude_daylight
  load('palmer_darkness.mat', 'idx_darkness');
  epoch = epoch(idx_darkness);
end

%% Exclude Palmer data gaps
dg_palmer = load('data_gaps.mat');
idx_palmer_hasdata = logical(interp1(dg_palmer.synoptic_epochs, dg_palmer.b_data, epoch, 'nearest', 0));
epoch = epoch(idx_palmer_hasdata);

% Delete Palmer values outside the valid range
events([events.start_datenum] < min(epoch) - 1/86400 | [events.start_datenum] > max(epoch) + 1/86400) = [];

%% Get Palmer wave amplitudes on these epochs
% palmer_em_pow is equal to the mediogram power in fT^2 when there is an
% emission and 0 when there isn't
ec = [events.ec];
palmer_em_pow = accumarray(interp1(epoch, 1:length(epoch), [events.start_datenum], 'nearest', 'extrap').', ...
  10.^([ec.ampl_true]/10).', size(epoch));

%% Get THEMIS wave amplitudes on these epochs
for kk = 1:length(this_them)
  % Histogram bins are like:
  % | gap | continuous | gap | continuous | ...
  % So everything in an odd bin is inside a data gap
  [~, gap_bin] = histc(epoch, sort([them(kk).gap_start_datenum; them(kk).gap_end_datenum]));
  idx_valid = (mod(gap_bin, 2) == 0).';

  % epoch_valid is 15-minute synoptic epochs where both Palmer and THEMIS have data
  epoch_valid = epoch(idx_valid);

  % Use the average of all THEMIS values from this epoch to 15 seconds
  % later (like the Palmer data, which is 5-15 seconds after epoch)
  % Histogram bins are like:
  % | vals in 1st near-epoch range | vals in-between | vals in 2nd near-epoch range | vals in-between | ...
  % So select only the odd bins for the accumarray function
  [~, avg_bin] = histc(this_them(kk).epoch, flatten([epoch_valid, epoch_valid + 15/86400].'));
  idx_in_bin = mod(avg_bin, 2) == 1; % Odd bins only
  in_bin_subs = (avg_bin(idx_in_bin) + 1)/2; % The index into epoch_valid into which each this_them(kk).epoch(idx_in_bin) thatbelongs
  
  for fieldname = {'field_power', 'L', 'MLT', 'lat'}
    old_field = this_them(kk).(fieldname{1});
    % This field value is NaN during data gaps
    new_field = nan(size(epoch));

    % % Use just the nearest THEMIS value to this epoch
    % new_field(idx_valid) = interp1(this_them(kk).epoch, old_field, epoch_valid, 'nearest');

    if strcmp(fieldname{1}, 'field_power')
      % Median power
      accum_fun = @(x) median(x(x > 0));
    else
      % Mean L, MLT and lat
      accum_fun = @mean;
    end
    
    if strcmp(fieldname{1}, 'MLT')
      new_mlt_complex = accumarray(in_bin_subs, exp(j*old_field(idx_in_bin)/24*2*pi), size(epoch_valid), accum_fun, nan);
      new_field(idx_valid) = mod(angle(new_mlt_complex)/(2*pi)*24, 24);
    else
      new_field(idx_valid) = accumarray(in_bin_subs, old_field(idx_in_bin), size(epoch_valid), accum_fun, nan);
    end

    them(kk).(fieldname{1}) = new_field;
  end
  them(kk).epoch = epoch;
end

1;

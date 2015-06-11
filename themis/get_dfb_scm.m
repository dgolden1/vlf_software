function [epoch, data, f_center, f_bw, f_lim] = get_dfb_scm(start_datenum, end_datenum, varargin)
% [epoch, data, f_center, f_bw, f_lim] = get_dfb_scm(start_datenum, end_datenum, varargin)
% 
% Get THEMIS digital fields board SCM1 amplitude for a given time range
% 
% INPUT
% start_datenum, end_datenum: range of times
% 
% PARAMETERS
% 'probe': one of 'A' (default), 'B', 'C', 'D', 'E'
% 
% OUTPUT
% epoch (datenum)
% data (nT)
% f_center (Hz)
% f_bw (Hz)
% f_lim (frequency limits, Hz)

%% Setup
dfb_dir = fullfile(scottdataroot, 'spacecraft', 'themis', 'level2', 'dfb');

%% Parse input arguments
p = inputParser;
p.addParamValue('probe', 'A');
p.parse(varargin{:});
probe = p.Results.probe;

%% Loop to gather data
days = floor(start_datenum):floor(end_datenum - 1/86400);

epoch = [];
data = [];
for kk = 1:length(days)
  this_filename = sprintf('th%s_l2_fbk_%s_v01.cdf', lower(probe), datestr(days(kk), 'yyyymmdd'));
  this_full_filename = fullfile(dfb_dir, sprintf('th%s', lower(probe)), datestr(days(kk), 'yyyy'), this_filename);
  
  [this_time, this_data, f_center, f_bw, f_lim] = read_dfb_cdf(this_full_filename, 'var', 'fb_scm1');
  
  epoch = [epoch; this_time(this_time >= start_datenum & this_time <= end_datenum)];
  data = [data; this_data(this_time >= start_datenum & this_time <= end_datenum, :)];
end

function [epoch, data, b_ac, f_lim] = collect_dfb_data(year, probe, instrument)
% Scan a mess of THEMIS DFB CDFs to greate a big matrix of magnetic field data
% 
% [epoch, data, f_lim] = collect_dfb_data(year, probe, instrument)
% 
% INPUTS
% year: either a 4-digit year or 'all' to get all available years
% probe: one of 'a', 'b', 'c', 'd', 'e', 'f'
% instrument: either 'scm' (default) or 'efi'
% 
% OUTPUTS
% b_ac: Boolean value for each epoch which is true for SCM or EFI
%  AC-coupled data and false for EFI DC-coupled data

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Setup
if ~exist('year', 'var') || isempty(year)
  year = 'all';
end
if ~exist('probe', 'var') || isempty(probe)
  probe = 'a';
end

%% Loop over probes and years to assemble data outuput
t_start = now;

dfb_dir = fullfile(scottdataroot, 'spacecraft', 'themis', 'level2', 'dfb', sprintf('th%s', lower(probe)));

if isnumeric(year)
  [epoch, data, f_lim, b_ac] = get_one_year(dfb_dir, this_year, instrument);
elseif ischar(year) && strcmp(year, 'all')
  epoch = [];
  data = [];
  b_ac = [];

  d = dir(dfb_dir);
  for kk = 1:length(d)
    this_year = str2double(d(kk).name);
    if ~isnan(this_year)
      [this_epoch, this_data, this_b_ac, f_lim] = get_one_year(dfb_dir, this_year, instrument);
      epoch = [epoch; this_epoch];
      data = [data; this_data];
      b_ac = [b_ac; this_b_ac];
    end
  end
  if isempty(epoch)
    error('No valid year directories in %s', dfb_dir);
  end
end

% For some stupid reason, time is not always monotonically increasing
[~, idx_sort] = sort(epoch);
epoch = epoch(idx_sort);
data = data(idx_sort,:);
b_ac = b_ac(idx_sort);


function [epoch, data, b_ac, f_lim] = get_one_year(dfb_dir, year, instrument)

cdf_dir = fullfile(dfb_dir, sprintf('%04d', year));

t_start = now;

%% List available files
d = dir(fullfile(cdf_dir, '*.cdf'));

epoch = [];
data = [];
b_ac = [];

for kk = 1:length(d)
  t_iter_start = now;
  
  this_filename = fullfile(cdf_dir, d(kk).name);
  
  if strcmp(instrument, 'scm')
    [this_datenum, this_data, this_f_center, this_f_bw, this_f_lim] = read_dfb_cdf(this_filename, 'var', 'fb_scm1');
    this_b_ac = true(size(this_datenum));
  elseif strcmp(instrument, 'efi')
    % First look for the edc12 variable. If that's not there, look for the
    % eac variable.  If that's not there, throw an error.
    try
      [this_datenum, this_data, this_f_center, this_f_bw, this_f_lim] = read_dfb_cdf(this_filename, 'var', 'fb_edc12');
      this_b_ac = false(size(this_datenum));
    catch er
      if ~strcmp(er.identifier, 'read_dfb_cdf:variableNotFound')
        rethrow(er);
      end
      
      try
        [this_datenum, this_data, this_f_center, this_f_bw, this_f_lim] = read_dfb_cdf(this_filename, 'var', 'fb_eac12');
        this_b_ac = true(size(this_datenum));
      catch er
        if ~strcmp(er.identifier, 'read_dfb_cdf:variableNotFound')
          rethrow(er);
        else
          error('CDF file %s contains neither fb_edc12 nor fb_eac12 variable', this_filename);
        end
      end
    end
  else
    error('Invalid instrument: %s', instrument);
  end
    
  
  if kk == 1
    f_center = this_f_center;
    f_bw = this_f_bw;
    f_lim = this_f_lim(:,1:3); % Retain only upper three channels
  else
    assert(all(this_f_center(:) == f_center(:)));
    assert(all(this_f_bw(:) == f_bw(:)));
    assert(all(flatten(this_f_lim(:,1:3)) == f_lim(:)));
  end
  
  epoch = [epoch; this_datenum];
  data = [data; this_data(:,1:3)]; % Retain only upper three channels
  b_ac = [b_ac; this_b_ac];

  fprintf('Processed %s (file %d of %d) in %s\n', d(kk).name, kk, length(d), time_elapsed(t_iter_start, now));
end

fprintf('Processed %d files in %s\n', length(d), time_elapsed(t_start, now));

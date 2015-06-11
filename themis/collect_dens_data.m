function [epoch, dens, loc_flag, probe] = collect_dens_data(them_dens_dir)
% Collect THEMIS density data from ASCII files into the workspace
% 
% [epoch, dens, loc_flag, probe_out] = collect_dens_data(start_datenum, end_datenum, probe)
% 
% INPUTS
% probe: one of 'a', 'b', 'c', 'd' or 'e'
% 
% These ASCII files density files were provided by Dr. Wen Li
%  (moonli@atmos.ucla.edu) from UCLA

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Setup
if ~exist('them_dens_dir', 'var') || isempty(them_dens_dir)
  them_dens_dir = fullfile(scottdataroot, 'spacecraft', 'themis', 'level3', 'density', 'unsorted');
end

t_start = now;

%% Loop through files
d = dir(fullfile(them_dens_dir, '*.dat'));

epoch = [];
dens = [];
loc_flag = [];
probe = [];
for kk = 1:length(d)
  t_file_start = now;
  
  assert(strcmp(d(kk).name(1:2), 'th'));
  [this_epoch, this_dens, this_loc_flag, this_probe] = read_one_file(fullfile(them_dens_dir, d(kk).name));
  epoch = [epoch; this_epoch];
  dens = [dens; this_dens];
  loc_flag = [loc_flag; this_loc_flag];
  probe = [probe; this_probe];
  
  fprintf('Processed %s (%d of %d) in %s\n', d(kk).name, kk, length(d), time_elapsed(t_file_start, now));
end

fprintf('Processed %d files in %s\n', length(d), time_elapsed(t_start, now));

function [epoch, dens, loc_flag, probe] = read_one_file(filename)
fid = fopen(filename);
A = textscan(fid, '%19c %f %f %f');
fclose(fid);

if isempty(A{1})
  epoch = [];
  dens = [];
  loc_flag = [];
  probe = '';
else
  epoch = datenum(A{1}, 'yyyy-mm-dd/HH:MM:SS');
  dens = A{2};
  loc_flag = A{3};
  probe = char('a' - 1 + A{4});
end

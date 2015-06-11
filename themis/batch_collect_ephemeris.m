function batch_collect_ephemeris
% Collect ephemeris from CDF files available at, e.g.,
% ftp://cdaweb.gsfc.nasa.gov/pub/istp/themis/tha/ssc
% or
% http://cdaweb.gsfc.nasa.gov/istp_public/data/themis/tha/ssc/

% By Daniel Golden (dgolden1 at stanford dot edu) March 2012
% $Id$

%% Setup
input_dir = fullfile(scottdataroot, 'spacecraft', 'themis', 'ephemeris', 'cdf');
output_dir = fullfile(scottdataroot, 'spacecraft', 'themis', 'ephemeris');

%% Find CDFs
t_start = now;
find_cmd = sprintf('find %s -name "th*.cdf" | sort', input_dir);
[~, filelist_str] = unix(find_cmd);
filelist = textscan(filelist_str, '%s');
filelist = filelist{1};
fprintf('Found %d CDF files in %s in %s\n', length(filelist), input_dir, time_elapsed(t_start, now));


%% Collect data
for kk = 1:length(filelist)
  t_start = now;
  
  file_data = cdfread(filelist{kk}, 'Variables', {'Epoch', 'XYZ_SM'}, 'ConvertEpochToDatenum', true, 'CombineRecords', true);
  epoch_cell{kk,1} = file_data{1};
  xyz_sm_cell{kk,1} = file_data{2};
  
  this_probe = filelist{kk}(regexp(filelist{kk}, 'th[a-e]_or_ssc_[0-9]{8}_v[0-9]{2}\.cdf') + 2);
  if isempty(this_probe)
    error('Unknown filename format: %s', filelist{kk});
  end    
  probe{kk,1} = this_probe;
  
  fprintf('Processed %s (%d of %d) in %s\n', just_filename(filelist{kk}), kk, length(filelist), time_elapsed(t_start, now));
end

%% Save data
probe_list = unique(probe);
for kk = 1:length(probe_list)
  t_start = now;
  
  idx = strcmp(probe, probe_list{kk});
  out.epoch = cell2mat(epoch_cell(idx));
  out.xyz_sm = cell2mat(xyz_sm_cell(idx));
  
  % Make sure dates are sorted properly
  [~, idx_uniq] = unique(out.epoch);
  out.epoch = out.epoch(idx_uniq);
  out.xyz_sm = out.xyz_sm(idx_uniq, :);
  
  output_filename = sprintf('th%s_ephemeris.mat', probe_list{kk});
  full_output_filename = fullfile(output_dir, output_filename);
  save(full_output_filename, '-struct', 'out');
  
  fprintf('Saved %s (%d of %d) in %s\n', full_output_filename, kk, length(probe_list), time_elapsed(t_start, now));
end

function ae_collect_1hr_files
% Collect 1-hr AE text files in Kyoto format and save to .mat file

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

t_start = now;

ae_input_dir = fullfile(dancasestudyroot, 'indices');
ae_output_dir = fullfile(danmatlabroot, 'common_dig', 'indices');

d = dir(fullfile(ae_input_dir, 'ae_1hr*.txt'));

for kk = 1:length(d)
  this_ae_filename = fullfile(ae_input_dir, d(kk).name);
  [epoch_cell{kk,1}, ae_cell{kk,1}, al_cell{kk,1}, au_cell{kk,1}, ao_cell{kk,1}] = ...
    ae_read_datenum([], this_ae_filename);
end

epoch = cell2mat(epoch_cell);
ae = cell2mat(ae_cell);
al = cell2mat(al_cell);
au = cell2mat(au_cell);
ao = cell2mat(ao_cell);


[~, idx] = unique(epoch);
epoch = epoch(idx);
ae = ae(idx);
al = al(idx);
au = au(idx);
ao = ao(idx);

[years, ~] = datevec(epoch);

output_filename = fullfile(ae_output_dir, 'ae_1hr.mat');
save(output_filename, 'epoch', 'ae', 'al', 'au', 'ao');
fprintf('Wrote %s (%d years of data) in %s', output_filename, length(unique(years)), time_elapsed(t_start, now));

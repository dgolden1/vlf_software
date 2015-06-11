function ae_add_data_to_ae_1min_struct(filename)
% Add the data from the 1-minute AE filename to the AE .mat file

% By Daniel Golden (dgolden1 at stanford dot edu) February 2011
% $Id$

old = load(fullfile(dancasestudyroot, 'indices', 'ae_1min.mat'));
[new.epoch, new.ae, new.al, new.au, new.ao] = ae_read_datenum([], filename);

idx = ~ismember(new.epoch, old.epoch);
fn = fieldnames(old);

for kk = 1:length(fn)
  old.(fn{kk}) = [old.(fn{kk}); new.(fn{kk})(idx)];
end

[~, sort_idx] = sort(old.epoch);

for kk = 1:length(fn)
  old.(fn{kk}) = old.(fn{kk})(sort_idx);
end

output_filename = fullfile(dancasestudyroot, 'indices', 'ae_1min.mat');
save(output_filename, '-struct', 'old');
fprintf('Saved %s\n', output_filename);

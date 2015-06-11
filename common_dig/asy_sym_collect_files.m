function asy_sym_collect_files
% Collect 1-min ASY/SYM text files in Kyoto format and save to .mat file

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

%% Setup
t_net_start = now;

input_dir = fullfile(dancasestudyroot, 'indices', 'asy_sym');
output_dir = fullfile(dancasestudyroot, 'indices');

%% Parse files
d = dir(fullfile(input_dir, 'ASY_SYM*.txt'));

for kk = 1:length(d)
  t_start = now;
  this_filename = fullfile(input_dir, d(kk).name);
  [epoch_vec{kk}, symh_vec{kk}, symd_vec{kk}, asyh_vec{kk}, asyd_vec{kk}] = asy_sym_read(this_filename);

  fprintf('Processed %s (%d of %d) in %s\n', d(kk).name, kk, length(d), time_elapsed(t_start, now));
end

%% Collect output
epoch = cell2mat(epoch_vec);
symh = cell2mat(symh_vec);
symd = cell2mat(symd_vec);
asyh = cell2mat(asyh_vec);
asyd = cell2mat(asyd_vec);

%% Remove duplicates
[~, idx] = unique(epoch);
epoch = epoch(idx);
symh = symh(idx);
symd = symd(idx);
asyh = asyh(idx);
asyd = asyd(idx);

%% Save .mat file
output_filename = fullfile(output_dir, 'asy_sym.mat');
save(output_filename, 'epoch', 'symh', 'symd', 'asyh', 'asyd');

fprintf('Saved %s in %s\n', output_filename, time_elapsed(t_net_start, now));

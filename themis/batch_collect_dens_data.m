function batch_collect_dens_data
% Turn Wen's density text files into .mat files

%% Setup
input_dir = fullfile(scottdataroot, 'spacecraft', 'themis', 'level3', 'density');
output_dir = fullfile(vlfcasestudyroot, 'themis_emissions', 'derived_densities');

probe_list = {'a', 'd', 'e'};

%% 
for kk = 1:length(probe_list)
  t_probe_start = now;
  
  probe = probe_list{kk};
  probe_dir = fullfile(input_dir, sprintf('th%s', lower(probe)));
  year_dirs = dir(fullfile(probe_dir, '2*'));
  
  for jj = 1:length(year_dirs)
    this_dens_dir = fullfile(probe_dir, year_dirs(jj).name);
    
    [epoch_vec{jj,1}, dens_vec{jj,1}, loc_flag_vec{jj,1}, probe_vec{jj,1}] = collect_dens_data(this_dens_dir);
    assert(all(probe_vec{jj} == probe));
  end
  epoch = cell2mat(epoch_vec);
  dens = cell2mat(dens_vec);
  loc_flag = cell2mat(loc_flag_vec);
  
  clear epoch_vec dens_vec loc_flag_vec probe_vec
  
  % Sometimes there are duplicate times or the times aren't in order in
  % Wen's density files
  [~, idx] = unique(epoch);
  epoch = epoch(idx);
  dens = dens(idx);
  loc_flag = loc_flag(idx);
  
  output_filename = fullfile(output_dir, sprintf('th%s_derived_densities.mat', probe));
  save(output_filename, 'epoch', 'dens', 'loc_flag', 'probe');
  fprintf('Saved %s in %s\n', output_filename, time_elapsed(t_probe_start, now));
end

function batch_subsample_density_files
% Decimate samples of Wen Li's density files to be 30 sec per sample
% instead of 3 sec

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

source_dir = fullfile(vlfcasestudyroot, 'themis_emissions', 'derived_densities');
dec_factor = 10; % Reduce from 3 sec to 30 sec per sample

for probe = {'a', 'd', 'e'}
  t_start = now;
  
  source_filename = fullfile(source_dir, sprintf('th%s_derived_densities.mat', probe{1}));
  dens = load(source_filename);

  dens.dens = dens.dens(1:dec_factor:end);
  dens.epoch = dens.epoch(1:dec_factor:end);
  dens.loc_flag = dens.loc_flag(1:dec_factor:end);

  output_filename = fullfile(source_dir, sprintf('th%s_derived_densities_subsamp.mat', probe{1}));
  save(output_filename, '-struct', 'dens');
  
  fprintf('Saved %s in %s\n', output_filename, time_elapsed(t_start, now));
end

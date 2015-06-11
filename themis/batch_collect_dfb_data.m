function batch_collect_dfb_data
% Run through all THEMIS probes and years and save the SCM and EFI FBK data
% to .mat files

% By Daniel Golden (dgolden1 at stanford dot edu) November 2011
% $Id$

%% Setup
probe_list = {'a', 'd', 'e'};
output_dir = fullfile(vlfcasestudyroot, 'themis_emissions');

for kk = 1:length(probe_list)
  this_probe = probe_list{kk};

  scm_filename = fullfile(output_dir, 'fb_scm1', sprintf('th%s_fb_scm1.mat', this_probe));
  if exist(scm_filename, 'file')
    fprintf('SCM file %s exists, skipping...\n', scm_filename);
  else
    t_scm_start = now;
    fprintf('Gathering SCM data for probe %s\n', upper(this_probe));
    [epoch, fb_scm1, ~, f_lim] = collect_dfb_data([], this_probe, 'scm');
    save(scm_filename, 'epoch', 'fb_scm1', 'f_lim');
    fprintf('Wrote %s in %s\n', scm_filename, time_elapsed(t_scm_start, now));
  end

  efi_filename = fullfile(output_dir, 'fb_efi12', sprintf('th%s_fb_efi12.mat', this_probe));
  if exist(efi_filename, 'file')
    fprintf('EFI file %s exists, skipping...\n', efi_filename);
  else
    t_efi_start = now;
    fprintf('Gathering EFI data for probe %s\n', upper(this_probe));
    [epoch, fb_efi12, b_ac, f_lim] = collect_dfb_data([], this_probe, 'efi');
    save(efi_filename, 'epoch', 'fb_efi12', 'f_lim', 'b_ac');
    fprintf('Wrote %s in %s\n', efi_filename, time_elapsed(t_efi_start, now));
  end
end

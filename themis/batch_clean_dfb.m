function batch_clean_dfb
% Clean a bunch of dfb files using clean_dfb.m

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Setup
themis_dir = fullfile(vlfcasestudyroot, 'themis_emissions');
% themis_dir = '/Users/dgolden/temp/themis';

%% Clean SCM data
source_dir = fullfile(themis_dir, 'fb_scm1');
b_decimate = false;

for probe = {'a', 'd', 'e'}
  t_start = now;
  
  source_filename = fullfile(source_dir, sprintf('th%s_fb_scm1.mat', probe{1}));
  dfb = load(source_filename);
  [newdfb.epoch, newdfb.fb_scm1] = clean_dfb(dfb.epoch, dfb.fb_scm1, b_decimate, 'scm');
  newdfb.f_lim = dfb.f_lim;
  output_filename = fullfile(source_dir, sprintf('th%s_fb_scm1_cleaned.mat', probe{1}));
  save(output_filename, '-struct', 'newdfb');
  
  fprintf('Saved %s in %s\n', output_filename, time_elapsed(t_start, now));
end

%% Clean EFI data
% source_dir = fullfile(themis_dir, 'fb_efi12');
% b_decimate = false;
% 
% for probe = {'a', 'd', 'e'}
%   t_start = now;
%   
%   source_filename = fullfile(source_dir, sprintf('th%s_fb_efi12.mat', probe{1}));
%   dfb = load(source_filename);
%   [newdfb.epoch, newdfb.fb_efi12] = clean_dfb(dfb.epoch, dfb.fb_efi12, b_decimate, 'efi', dfb.b_ac);
%   newdfb.b_ac = interp1(dfb.epoch, dfb.b_ac, newdfb.epoch, 'nearest');
%   newdfb.f_lim = dfb.f_lim;
%   output_filename = fullfile(source_dir, sprintf('th%s_fb_efi12_cleaned.mat', probe{1}));
%   save(output_filename, '-struct', 'newdfb');
%   
%   fprintf('Saved %s in %s\n', output_filename, time_elapsed(t_start, now));
% end

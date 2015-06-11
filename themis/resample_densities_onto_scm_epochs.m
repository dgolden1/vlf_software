function resample_densities_onto_scm_epochs(probe)
% Resample density files onto the same epochs as the SCM instrument

% By Daniel Golden (dgolden1 at stanford dot edu) November 2011
% $Id$

%% Setup
if ~exist('probe', 'var') || isempty(probe)
  % Sneaky recursion way of running all the probes if one isn't given
  probes = {'A', 'D', 'E'};
  for kk = 1:length(probes)
    resample_densities_onto_scm_epochs(probes{kk});
  end
  return;
end
if ~ischar(probe)
  error('Probe must be one of A, B, C, D or E');
end

output_dir = fullfile(vlfcasestudyroot, 'themis_emissions', 'fb_scm1');
output_filename = fullfile(output_dir, sprintf('th%s_fb_scm1_dens_common.mat', lower(probe)));

%% Get DFB data
data_filename = fullfile(vlfcasestudyroot, 'themis_emissions', 'fb_scm1', sprintf('th%s_fb_scm1_cleaned.mat', lower(probe)));
dfb = load(data_filename, 'epoch', 'fb_scm1', 'f_lim');

epoch = dfb.epoch;

%% Get densities
dens_filename = fullfile(vlfcasestudyroot, 'themis_emissions', 'derived_densities', sprintf('th%s_derived_densities.mat', lower(probe)));
dens = load(dens_filename, 'epoch', 'loc_flag');

% For some reason, the density epochs that Wen gave me aren't all in order
[dens.epoch, idx] = unique(dens.epoch);
dens.loc_flag = dens.loc_flag(idx);


%% Put density measurements on DFB epochs

% Time from each dfb epoch to the closest intra-plasmasphere density
% measurement
time_to_closest_dens_meas = dens.epoch(interp1(dens.epoch, 1:length(dens.epoch), epoch, 'nearest', 'extrap')) - epoch;

new_loc_flag = interp1(dens.epoch, dens.loc_flag, epoch, 'nearest', 'extrap');

%% Parse out only valid epochs
idx_valid = abs(time_to_closest_dens_meas) < 1/1440 & ... % There is a density measurement within 1 min of this epoch
            new_loc_flag < 2; % We're within the magnetosphere
          
% idx_valid = idx_valid & any(dfb.fb_scm1 > 0, 2); % Field power on THEMIS is measurable

them_struct.epoch = epoch(idx_valid);
them_struct.fb_scm1 = dfb.fb_scm1(idx_valid,:);
them_struct.loc_flag = new_loc_flag(idx_valid);
them_struct.f_lim = dfb.f_lim;

%% Save
save(output_filename, '-struct', 'them_struct');
fprintf('Saved %s\n', output_filename);

1;

function combine_them_polar
% Function to combine THEMIS and Polar data into a single .mat file

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'themis'));

polar_filename = fullfile(vlfcasestudyroot, 'themis_chorus', 'PolarChorusDatabase_p.mat');
output_filename = fullfile(vlfcasestudyroot, 'themis_chorus', 'polar_themis_combined.mat');

%% Load and massage Polar data
polar = load(polar_filename, 'Epoch', 'Bw', 'Xsm', 'Ysm', 'Zsm');
polar.epoch = polar.Epoch(:);
polar.xyz_sm = [polar.Xsm(:) polar.Ysm(:) polar.Zsm(:)];
polar.Bw = polar.Bw(:);
polar = rmfield(polar, {'Epoch', 'Xsm', 'Ysm', 'Zsm'});


%% Load and massage THEMIS data
[~, them] = get_combined_them_power('chorus');
them.Bw = sqrt(them.field_power)*1e3; % Convert to pT
them = rmfield(them, {'lat', 'MLT', 'L', 'field_power'});

%% Save
save(output_filename, 'themis_chorus', 'them');
fprintf('Saved %s\n', output_filename);

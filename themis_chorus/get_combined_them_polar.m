function [combined, them, polar] = get_combined_them_polar
% Load THEMIS and Polar databases and combine them into a single struct
% [combined, them, polar] = get_combined_them_polar
% 
% Output Bw is in picoteslas

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

%% Load from persistent memory
% persistent combined_internal them_internal polar_internal
% if ~isempty(combined_internal)
%   combined = combined_internal;
%   them = them_internal;
%   polar = polar_internal;
%   return;
% end

%% Load from files
input_filename = fullfile(vlfcasestudyroot, 'themis_chorus', 'polar_themis_combined.mat');
load(input_filename, 'polar', 'them');

fn = fieldnames(them);
for kk = 1:length(fn)
  if strcmp(fn{kk}, 'probe')
    combined.probe = [repmat('P', size(polar.epoch)); them.probe];
  else
    combined.(fn{kk}) = [polar.(fn{kk}); them.(fn{kk})];
  end
end

%% Save in persistent memory
combined_internal = combined;
them_internal = them;
polar_internal = polar;

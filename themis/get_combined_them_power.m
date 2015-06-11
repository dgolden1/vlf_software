function [epoch_combined, them_combined] = get_combined_them_power(em_type)
% Get combined THEMIS power for probes A, D and E
% [epoch, them] = get_combined_them_power(em_type)

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

% t_them_start = now;

%% Cache variables to save time (and waste memory)
persistent old_epoch_combined old_them_combined old_em_type
if ~isempty(old_em_type) && strcmp(old_em_type, em_type)
  epoch_combined = old_epoch_combined;
  them_combined = old_them_combined;
  return;
end

%% Otherwise, load the data
if ~exist('em_type', 'var') || isempty(em_type)
  em_type = 'hiss';
end

probe_names = {'A', 'D', 'E'};
for kk = 1:length(probe_names)
  [epoch, field_power, eph] = get_dfb_by_em_type(probe_names{kk}, em_type);
  them(kk) = package_themis_struct(probe_names{kk}, epoch, field_power, eph);
end
[epoch_combined, them_combined] = combine_them_simple(them);

%% Save persistent variables
old_epoch_combined = epoch_combined;
old_them_combined = them_combined;
old_em_type = em_type;

% fprintf('Loaded THEMIS data in %s\n', time_elapsed(t_them_start, now));

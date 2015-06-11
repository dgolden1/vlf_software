function [epoch_combined, them_combined, palmer_power_combined] = combine_them_simple(them, palmer_epoch, palmer_power)
% Combine THEMIS struct vector into a single struct
% 
% Take samples from all THEMIS probes, discard samples that have non-finite
% power, and put them all into a single array.  Interpolate palmer power
% onto the same epochs (which will now have duplicates)

% By Daniel Golden (dgolden1 at stanford dot edu) July 2011
% $Id$

for name = fieldnames(them).'
  if length(name{1}) >= 3 && strcmp(name{1}(1:3), 'gap')
    continue;
  end
  
  for kk = 1:length(them)
    idx_valid = ~isnan(them(kk).field_power);
    if ~strcmp(name{1}, 'probe')
      field_combined{kk} = them(kk).(name{1})(idx_valid,:);
    else
      field_combined{kk} = repmat(them(kk).probe, sum(idx_valid), 1);
    end
  end
  them_combined.(name{1}) = cell2mat(field_combined.');
end

% To get indices for probe A, for example, do:
% idx_a = strcmpi(num2cell(them_combined.probe), 'A');

epoch_combined = them_combined.epoch;

if exist('palmer_power', 'var')
  palmer_power_combined = interp1(palmer_epoch, palmer_power, epoch_combined, 'nearest');
end

function [epoch, them] = subsample_them(epoch, them, idx)
% Subsample themis data (output from combine_them_simple)

% By Daniel Golden (dgolden1 at stanford dot edu) November 2011
% $Id$


epoch = epoch(idx);

fn = fieldnames(them);
for kk = 1:length(fn)
  them.(fn{kk}) = them.(fn{kk})(idx, :);
end

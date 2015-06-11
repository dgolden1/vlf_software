function [partition_idx, partition_idx_cell] = partition_contig_by_epoch(epoch, num_partitions)
% Partition data contiguously, based on epoch
%
% INPUTS
% epoch: matlab datenum, not necessarily in order
% num_partitions: number of unique partitions (default: 10)
% 
% OUTPUTS
% partition_idx: vector of same length as epoch with num_partitions unique
% indices
% partition_idx_cell: cell array containing indices for each partition
%  (i.e., epochs for partition one are epoch(parition_idx_cell{1}), epochs
%  for partition two are epoch(partition_idx_cell{2}), etc.

% By Daniel Golden (dgolden1 at stanford dot edu) May 2012
% $Id$

if ~exist('num_partitions', 'var') || isempty(num_partitions)
  num_partitions = 10;
end

epoch_thresholds = quantile(epoch, linspace(0, 1, num_partitions+1));
[~, partition_idx] = histc(epoch, epoch_thresholds);
partition_idx(partition_idx == num_partitions + 1) = num_partitions; % Set values where epoch == max(epoch) to the previous bin
assert(all(partition_idx > 0)); % Make sure all values are in a bin

if nargout > 1
  for kk = 1:num_partitions
    partition_idx_cell{kk} = partition_idx == kk;
  end
end

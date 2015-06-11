function[result] = buildtree_sparse(numlevels, input_vector)

% BUILDTREE_SPARSE  Build a sparse wavelet packet tree.
%
%   [result] = BUILDTREE_SPARSE(numlevels, input_vector)
%
%   This function generates a partial binary tree, numlevels deep, for use
%   with the function wavelet_packet_decomp.  The variable input_vector
%   is a list of normalized (in the range of 0 to 1) frequencies
%   to converge to.  The resultant binary tree can be used with 
%   wavelet_packet_decomp to generate the wavelet packet decomposition
%   with most of the information concentrated at the frequencies of interest.

if (numlevels == 0)
  result = [];
else
  %# The entry after the tail of the tree vector (next slot)
  tail_index = 2;
  %# Construct a minimal tree to start.
  result = [0, 0];

  %# Iterate over all of the normalized input frequencies
  for i=[1:1:length(input_vector)]
    %# The current index into the tree vector
    index = 1;
    %# The frequency of the midpoint of this node.
    frequency = .5;
    interval = .5;
    %# 0 - left branch.  1 - right branch.
    branch = 0;
    %# Iterate over the specified number of levels.
    for j=[1:1:numlevels-1]
      interval = interval/2;
      if (input_vector(i) < frequency)
        %# We want the lower frequency.
        branch = 0;
        %# Update the frequency.  
        frequency = frequency - interval;
      else
        %# We want the higher frequency.
        branch = 1;
        %# Update the frequency.  
        frequency = frequency + interval;
      end;
      
      %# Now add the branch if it's not already there.
      if (result(index, branch+1) == 0)
        %# Add the new node pointer
        result(index, branch+1) = tail_index;
        %# Add the new node
        result(tail_index, 1) = 0;
        result(tail_index, 2) = 0;
        %# Increment the tail.
        tail_index = tail_index + 1;
      end;

      %# Follow the branch.
      index = result(index, branch+1);
    end;
  end;
end;
